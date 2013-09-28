//
//  RDPhotoEditor.m
//  mywear
//
//  Created by Darshan Katrumane on 9/26/13.
//  Copyright (c) 2013 RD. All rights reserved.
//

#import "RDPhotoEditor.h"

#define grayboxeswidth 50
#define grayboxesheight 50

typedef enum {
    cropValueOpen = 0,
    cropValueClose = 1
}cropValue;

@interface RDPhotoEditor () {
    UIScrollView *scroll;
    UIButton *cropButton;
    UIView *top, *down, *left, *right;
    CGFloat fixedDownOrigin, fixedLeftOrigin, fixedRightOrigin;
    CGPoint lastTouchPosition;
    int currentCropButtonValue;
    UIImageView *photoHolder;
}
@end

@implementation RDPhotoEditor
@synthesize originalPhoto;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupEditor];
}

-(void) setupEditor {
    [self.view setBackgroundColor:[UIColor yellowColor]];
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width * 2, 100)];
    [scroll setBackgroundColor:[UIColor purpleColor]];
    [self.view addSubview:scroll];
    
    currentCropButtonValue = cropValueClose;
    cropButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cropButton setBackgroundColor:[UIColor whiteColor]];
    [cropButton setFrame:CGRectMake(10, 10, 75, 75)];
    [cropButton setTitle:@"Crop" forState:UIControlStateNormal];
    [cropButton addTarget:self action:@selector(crop) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:cropButton];
    
    photoHolder = [[UIImageView alloc] initWithImage:originalPhoto];
    [photoHolder setCenter:self.view.center];
    [photoHolder setUserInteractionEnabled:YES];
    [self.view addSubview:photoHolder];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [photoHolder addGestureRecognizer:pan];
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    [photoHolder addGestureRecognizer:rotate];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [photoHolder addGestureRecognizer:pinch];
}

-(void) handlePinch:(UIPinchGestureRecognizer*) recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

-(void) handlePan:(UIPanGestureRecognizer*) recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

-(void) handleRotate:(UIRotationGestureRecognizer*) recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

-(void) crop {
    if (cropValueClose == currentCropButtonValue) {
        currentCropButtonValue = cropValueOpen;
        // open the crop function
        top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        [top setBackgroundColor:[UIColor redColor]];
        [top setAlpha:1];
        UIPanGestureRecognizer *panTop = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(increaseTopArea:)];
        [top addGestureRecognizer:panTop];
        [self.view addSubview:top];
        
        right = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - grayboxeswidth, 0, grayboxeswidth, self.view.frame.size.height-scroll.frame.size.height)];
        [right setAlpha:1];
        [right setBackgroundColor:[UIColor greenColor]];
        UIPanGestureRecognizer *panRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(increaseRightArea:)];
        [right addGestureRecognizer:panRight];
        [self.view addSubview:right];
        fixedRightOrigin = right.frame.origin.x;
        
        down = [[UIView alloc] initWithFrame:CGRectMake(0, scroll.frame.origin.y - 30, self.view.frame.size.width, 30)];
        [down setBackgroundColor:[UIColor blackColor]];
        [down setAlpha:1];
        fixedDownOrigin = down.frame.origin.y;
        UIPanGestureRecognizer *panDown = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(increaseDownArea:)];
        [down addGestureRecognizer:panDown];
        [self.view addSubview:down];
        
        left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, grayboxeswidth, self.view.frame.size.height-scroll.frame.size.height)];
        [left setAlpha:1];
        [left setBackgroundColor:[UIColor blueColor]];
        UIPanGestureRecognizer *panLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(increaseLeftArea:)];
        [left addGestureRecognizer:panLeft];
        [self.view addSubview:left];
        fixedLeftOrigin = left.frame.origin.x+left.frame.size.width;
        
    }else{
        // close the crop function
        currentCropButtonValue = cropValueClose;
        [self cropImageAccordingToUser];
        [top removeFromSuperview];
        [left removeFromSuperview];
        [right removeFromSuperview];
        [down removeFromSuperview];
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	NSString *message;
	NSString *title;
	if (!error) {
		title = NSLocalizedString(@"SaveSuccessTitle", @"");
		message = NSLocalizedString(@"SaveSuccessMessage", @"");
	} else {
		title = NSLocalizedString(@"SaveFailedTitle", @"");
		message = [error description];
	}
}
-(void) cropImageAccordingToUser {
    CGFloat scale = self.originalPhoto.size.width / photoHolder.frame.size.width;
    CGFloat posy = top.frame.origin.y+top.frame.size.height;
    CGFloat posx = left.frame.origin.x+left.frame.size.width;
    CGFloat widthx = right.frame.origin.x - (left.frame.origin.x+left.frame.size.width);
    CGFloat heighty = down.frame.origin.y - (top.frame.origin.y+top.frame.size.height);
    CGRect rect = CGRectMake(posx, posy, widthx, heighty);
    rect.origin.x = (rect.origin.x - photoHolder.frame.origin.x) * scale;
    rect.origin.y = (rect.origin.y - photoHolder.frame.origin.y) * scale;
    rect.size.width *= scale;
    rect.size.height *= scale;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClipToRect(c, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self.originalPhoto drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.originalPhoto.size.width, self.originalPhoto.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(result, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:),NULL);
    UIGraphicsEndImageContext();
    [photoHolder setImage:nil];
    [photoHolder setImage:result];
    [photoHolder setFrame:CGRectMake(0, 0, widthx, heighty)];
    [photoHolder setCenter:self.view.center];
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	CGImageRelease(newImageRef);
    UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:),NULL);
	return newImage;
}

-(CGPoint) CGPointDistance:(CGPoint) point1 andPoint:(CGPoint) point2 {
    return CGPointMake(point2.x - point1.x, point2.y - point1.y);
}

-(void) increaseLeftArea:(UIPanGestureRecognizer*) recognizer {
    if([recognizer state] == UIGestureRecognizerStateBegan){
        lastTouchPosition = [recognizer locationInView:self.view];
    }else if([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateBegan){
        CGPoint currentTouchLocation = [recognizer locationInView:self.view];
        CGPoint deltaMove = [self CGPointDistance:currentTouchLocation andPoint:lastTouchPosition];
        float distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
        CGPoint velocity = [recognizer velocityInView:self.view];
        if(velocity.x > 0){
            if(recognizer.view.frame.size.width+recognizer.view.frame.origin.x < self.view.center.x){
                [recognizer.view setFrame:CGRectMake(0, recognizer.view.frame.origin.y, recognizer.view.frame.size.width+distance, recognizer.view.frame.size.height)];
            }
        }else{
            if(recognizer.view.frame.size.width+recognizer.view.frame.origin.x > grayboxeswidth){
                [recognizer.view setFrame:CGRectMake(0, recognizer.view.frame.origin.y, recognizer.view.frame.size.width-distance, recognizer.view.frame.size.height)];
            }
        }
        lastTouchPosition = currentTouchLocation;
    }
}

-(void) increaseRightArea:(UIPanGestureRecognizer*) recognizer {
    if([recognizer state] == UIGestureRecognizerStateBegan){
        lastTouchPosition = [recognizer locationInView:self.view];
    }else if([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateBegan){
        CGPoint currentTouchLocation = [recognizer locationInView:self.view];
        CGPoint deltaMove = [self CGPointDistance:currentTouchLocation andPoint:lastTouchPosition];
        float distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
        CGPoint velocity = [recognizer velocityInView:self.view];
        if(velocity.x > 0){
            if(recognizer.view.frame.origin.x < fixedRightOrigin){
                [recognizer.view setFrame:CGRectMake(recognizer.view.frame.origin.x + distance, recognizer.view.frame.origin.y, recognizer.view.frame.size.width-distance, recognizer.view.frame.size.height)];
            }
        }else{
            if(recognizer.view.frame.origin.x > self.view.center.x){
                [recognizer.view setFrame:CGRectMake(recognizer.view.frame.origin.x - distance, recognizer.view.frame.origin.y, recognizer.view.frame.size.width+distance, recognizer.view.frame.size.height)];
            }
        }
        lastTouchPosition = currentTouchLocation;
    }
}

-(void) increaseDownArea:(UIPanGestureRecognizer*) recognizer {
    if([recognizer state] == UIGestureRecognizerStateBegan){
        lastTouchPosition = [recognizer locationInView:self.view];
    }else if([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateBegan){
        CGPoint currentTouchLocation = [recognizer locationInView:self.view];
        CGPoint deltaMove = [self CGPointDistance:currentTouchLocation andPoint:lastTouchPosition];
        float distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
        CGPoint translation = [recognizer translationInView:self.view];
        CGPoint p = CGPointMake(recognizer.view.frame.origin.x + translation.x, recognizer.view.frame.origin.y + translation.y);
        CGFloat height = down.frame.size.height;
        CGPoint velocity = [recognizer velocityInView:self.view];
        if(p.y < fixedDownOrigin && p.y > 30){
            // we should be moving only if its less than the origin
            // get the difference in height to increase
            // this is the difference between the current y position and p.y
            if(velocity.y > 0){
                // user is going down
                [recognizer.view setFrame:CGRectMake(0, down.frame.origin.y + distance, self.view.frame.size.width, height - distance)];
            }else{
                // user is going up
               [recognizer.view setFrame:CGRectMake(0, down.frame.origin.y - distance, self.view.frame.size.width, height + distance)];
            }
        }
        lastTouchPosition = currentTouchLocation;
    }
}

-(void) increaseDownArea2:(UIPanGestureRecognizer*) recognizer {
        CGPoint translation = [recognizer translationInView:self.view];
        CGPoint p = CGPointMake(recognizer.view.frame.origin.x + translation.x, recognizer.view.frame.origin.y + translation.y);
        CGFloat height = down.frame.size.height;
        if(p.y < fixedDownOrigin && p.y > 30){
            // we should be moving only if its less than the origin
            // get the difference in height to increase
            // this is the difference between the current y position and p.y
            if (p.y > down.frame.origin.y) {
                // user is going down
                CGFloat diff = p.y - down.frame.origin.y;
                [UIView animateWithDuration:0.5f animations:^{
                    [recognizer.view setFrame:CGRectMake(0, p.y, self.view.frame.size.width, height - diff)];
                }];
            }else{
                // user is going up
                CGFloat diff = down.frame.origin.y - p.y;
                [UIView animateWithDuration:0.5f animations:^{
                    [recognizer.view setFrame:CGRectMake(0, p.y, self.view.frame.size.width, height + diff)];
                }];
            }
        }
}

-(void) increaseTopArea:(UIPanGestureRecognizer*) recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint p = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    if(p.y > 30 && p.y < scroll.frame.origin.y){
        [recognizer.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, p.y)];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end