//
//  MachineMashViewController.m
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MachineMashViewController.h"
#import "MachineMashModel.h"
#import "Renderer.h"
#import "EAGLView.h"

@interface MachineMashViewController ()
- (void)setupUserInteraction;
- (void)userDidZoom:(UIPinchGestureRecognizer*)sender;
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation MachineMashViewController
@synthesize animating, context, displayLink;

- (id)init {
    NSLog(@"%s",__FUNCTION__);
    self = [super init];
    self.view = [[EAGLView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [[MachineMashModel sharedModel] setGLESAPI:2];
    
    if (!aContext) {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        [[MachineMashModel sharedModel] setGLESAPI:1];
    }
    
    if (!aContext) {
        NSLog(@"Failed to create ES context");
    } else if (![EAGLContext setCurrentContext:aContext]) {
        NSLog(@"Failed to set ES context current");
    }
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2) {
        if (![[Renderer sharedRenderer] loadShaders]) {
            NSLog(@"%s could not load shaders...",__FUNCTION__);
        }
    }
    
    if (![[Renderer sharedRenderer] loadTextures]) {
        NSLog(@"%s could not load textures...",__FUNCTION__);
    }
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    [self setupUserInteraction];
    
    return self;
}

- (void)dealloc
{
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma -
#pragma View Events

- (void)viewWillAppear:(BOOL)animated {
    [self startAnimation];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopAnimation];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#endif
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"%s",__FUNCTION__);
}

#pragma -
#pragma Animation

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation {
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation {
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)drawFrame {
    EAGLView* glView = (EAGLView *)self.view;
    [glView setFramebuffer];
    
    MachineMashModel* model = [MachineMashModel sharedModel];
    CGSize size = [[UIScreen mainScreen] applicationFrame].size;
    CGFloat bigger = MAX(size.width, size.height);
    CGFloat smaller = MIN(size.width, size.height);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        size = CGSizeMake(bigger, smaller);
    } else {
        size = CGSizeMake(smaller, bigger);
    }
    [[Renderer sharedRenderer] setScreenWidth:size.width andHeight:size.height];
    [model step];
    [(EAGLView *)self.view presentFramebuffer];
}

#pragma -
#pragma USER INTERACTION

- (void)setupUserInteraction {
    UIPinchGestureRecognizer* pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userDidZoom:)];
    [self.view addGestureRecognizer:pinchRec];
}

- (void)userDidZoom:(UIPinchGestureRecognizer*)sender {
    Renderer* renderer = [Renderer sharedRenderer];
    CGFloat velocity = [sender velocity]/4.0;
    if ([sender scale] > 0) {
        [renderer setZoomScale:[renderer zoomScale] + velocity];
    } else {
        [renderer setZoomScale:[renderer zoomScale] - velocity];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[[MachineMashModel sharedModel] level] touchesBegan:touches inView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[[MachineMashModel sharedModel] level] touchesMoved:touches inView:self.view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[[MachineMashModel sharedModel] level] touchesEnded:touches inView:self.view];
}

@end
