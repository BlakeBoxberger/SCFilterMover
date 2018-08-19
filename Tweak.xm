@interface SCGeoFilterImageView : UIView
@property (nonatomic, retain) UIImageView *imageView;
@end

@interface SCGeoFilterView : UIView
@property (nonatomic, retain) SCGeoFilterImageView *geoFilterImageView;
@property (nonatomic, retain) UIPanGestureRecognizer *nz9_panGestureRecognizer;
@property (nonatomic, retain) UIPinchGestureRecognizer *nz9_pinchGestureRecognizer;
@property (nonatomic, retain) UILongPressGestureRecognizer *nz9_tapGestureRecognizer;
@property (nonatomic, retain) UIImpactFeedbackGenerator *nz9_hapticGenerator;
@property (nonatomic, assign) BOOL nz9_editing;
- (void)nz9_animateFilter;
@end

%hook SCGeoFilterView
%property (nonatomic, retain) UIPanGestureRecognizer *nz9_panGestureRecognizer;
%property (nonatomic, retain) UIPinchGestureRecognizer *nz9_pinchGestureRecognizer;
%property (nonatomic, retain) UILongPressGestureRecognizer *nz9_tapGestureRecognizer;
%property (nonatomic, retain) UIImpactFeedbackGenerator *nz9_hapticGenerator;
%property (nonatomic, assign) BOOL nz9_editing;

- (instancetype)initWithFrame:(CGRect)arg1 config:(id)arg2 userSession:(id)arg3 {
  %orig;

  self.nz9_hapticGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];

  self.nz9_editing = NO;

  [self setUserInteractionEnabled:YES];

  self.nz9_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(nz9_movingFilter:)];
  self.nz9_panGestureRecognizer.enabled = NO;
  [self addGestureRecognizer: self.nz9_panGestureRecognizer];

  self.nz9_pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(nz9_zoomingFilter:)];
  self.nz9_pinchGestureRecognizer.enabled = NO;
  [self addGestureRecognizer: self.nz9_pinchGestureRecognizer];

  self.nz9_tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(nz9_toggleEditMode:)];
  [self addGestureRecognizer: self.nz9_tapGestureRecognizer];

  return self;
}

%new - (void)nz9_movingFilter:(UIPanGestureRecognizer *)sender {
  SCGeoFilterView *filter = (SCGeoFilterView *)sender.view;
  UIImageView *image = filter.geoFilterImageView.imageView;

  CGPoint translation = [sender translationInView:filter];
  translation.x = image.center.x + translation.x;
  translation.y = image.center.y + translation.y;
  image.center = translation;

  [sender setTranslation:CGPointZero inView:filter];
}

%new - (void)nz9_zoomingFilter:(UIPinchGestureRecognizer *)sender {
  SCGeoFilterView *filter = (SCGeoFilterView *)sender.view;
  UIImageView *image = filter.geoFilterImageView.imageView;

  CGFloat scale = sender.scale;
  [image layer].anchorPoint = CGPointMake(0.5, 0.5);
  image.transform = CGAffineTransformScale(image.transform, scale, scale);
  sender.scale = 1.0;
}

%new - (void)nz9_toggleEditMode:(UILongPressGestureRecognizer *)sender {
  if(sender.state == UIGestureRecognizerStateBegan) {
    [self.nz9_hapticGenerator impactOccurred];
    if(self.nz9_editing) {
      [self.geoFilterImageView.imageView.layer removeAllAnimations];
      self.geoFilterImageView.imageView.alpha = 1.0;
      self.nz9_panGestureRecognizer.enabled = NO;
      self.nz9_pinchGestureRecognizer.enabled = NO;
      self.nz9_editing = NO;
    }
    else {
      [self nz9_animateFilter];
      self.nz9_panGestureRecognizer.enabled = YES;
      self.nz9_pinchGestureRecognizer.enabled = YES;
      self.nz9_editing = YES;
    }
  }
}

%new - (void)nz9_animateFilter {
  [UIView animateWithDuration:0.5
                               delay:0.0
                             options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                          animations:^{
                            self.geoFilterImageView.imageView.alpha = 0.0;
    }
    completion:^(BOOL finished) {
        if (finished) {
          [UIView animateWithDuration:0.5
                                       delay:0.0
                                     options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                  animations:^{
                                    self.geoFilterImageView.imageView.alpha = 1.0;
            }
            completion:^(BOOL finished) {
                if (finished) {
                    [self nz9_animateFilter];
                }
            }];
        }
    }];
}

%end
