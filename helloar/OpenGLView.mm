/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "OpenGLView.h"

#include <iostream>
#include "ar.hpp"
#include "renderer.hpp"

/*
* Steps to create the key for this sample:
*  1. login www.easyar.com
*  2. create app with
*      Name: HelloAR
*      Bundle ID: cn.easyar.samples.helloar
*  3. find the created item in the list and show key
*  4. set key string bellow
*/
NSString* key = @"E7RZi1nWIjB0LS1FGpRsPOn17suIdXo45rURPkAWk6iNONcNXGt48KzpOvC8oXnrmGNcwI6TzIS8Qp3X7hArcoiQEvYDGjUni6imf7ecd9908bcde0b43e3df598223a2e42A4oJCzpmymvzIeBtj1kEpQC0zec8gwF2luah3S5qXiFIxM9pFTCvgqAz7ywywxKVWZiW";

namespace EasyAR{
namespace samples{

class HelloAR : public AR
{
public:
    HelloAR();
    virtual void initGL();
    virtual void resizeGL(int width, int height);
    virtual void render();
private:
    Vec2I view_size;
    Renderer renderer;
};

HelloAR::HelloAR()
{
    view_size[0] = -1;
}

void HelloAR::initGL()
{
    renderer.init();
    size_t width=0,height=0;
    GLubyte *topData=[OpenGLView imageDataWithFileName:@"top.jpg" width:&width height:&height];
    GLuint topName=renderer.generateTextureID(width, height, topData);
    renderer.setupBuildingTopTexture(topName);
    free(topData);
    GLubyte *sideData=[OpenGLView imageDataWithFileName:@"side.jpg" width:&width height:&height];
    GLuint sideName=renderer.generateTextureID(width, height, sideData);
    renderer.setupBuildingSideTexture(sideName);
    free(sideData);
    augmenter_ = Augmenter();
}

void HelloAR::resizeGL(int width, int height)
{
    view_size = Vec2I(width, height);
}

void HelloAR::render()
{
    glClearColor(0.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    Frame frame = augmenter_.newFrame(tracker_);
    if(view_size[0] > 0){
        int width = view_size[0];
        int height = view_size[1];
        Vec2I size = Vec2I(1, 1);
        if (camera_ && camera_.isOpened())
            size = camera_.size();
        if(portrait_)
            std::swap(size[0], size[1]);
        float scaleRatio = std::max((float)width / (float)size[0], (float)height / (float)size[1]);
        Vec2I viewport_size = Vec2I((int)(size[0] * scaleRatio), (int)(size[1] * scaleRatio));
        if(portrait_)
            augmenter_.setViewPort(Vec4I(0, height - viewport_size[1], viewport_size[0], viewport_size[1]));
        else
            augmenter_.setViewPort(Vec4I(0, width - height, viewport_size[0], viewport_size[1]));
        if(camera_ && camera_.isOpened())
            view_size[0] = -1;
    }
    augmenter_.drawVideoBackground();

    AugmentedTarget::Status status = frame.targets()[0].status();
    if(status == AugmentedTarget::kTargetStatusTracked){
        Matrix44F projectionMatrix = getProjectionGL(camera_.cameraCalibration(), 0.2f, 500.f);
        Matrix44F cameraview = getPoseGL(frame.targets()[0].pose());
        ImageTarget target = frame.targets()[0].target().cast_dynamic<ImageTarget>();
        renderer.render(projectionMatrix, cameraview, target.size());
    }
}

}
}
EasyAR::samples::HelloAR ar;

@interface OpenGLView ()
{
}

@property(nonatomic, strong) CADisplayLink * displayLink;

- (void)displayLinkCallback:(CADisplayLink*)displayLink;

@end

@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.height = MAX(frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if(self){
        [self setupGL];

        EasyAR::initialize([key UTF8String]);
        ar.initGL();
    }

    return self;
}

- (void)dealloc
{
    ar.clear();
}

- (void)setupGL
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;

    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
    if (![EAGLContext setCurrentContext:_context])
        NSLog(@"Failed to set current OpenGL context");

    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);

	GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
}

- (void)start{
    ar.initCamera();
//    ar.loadFromJsonFile("targets.json", "argame");
//    ar.loadFromJsonFile("targets.json", "idback");
//    ar.loadAllFromJsonFile("targets2.json");
//    ar.loadFromImage("namecard.jpg");
    ar.loadFromImage("icon.jpg");
    ar.start();

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stop
{
    ar.clear();
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    ar.render();

    (void)displayLink;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = FALSE;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = TRUE;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = FALSE;
            break;
        default:
            break;
    }
    ar.setPortrait(isPortrait);
    ar.resizeGL(frame.size.width, frame.size.height);
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            EasyAR::setRotationIOS(270);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            EasyAR::setRotationIOS(90);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            EasyAR::setRotationIOS(180);
            break;
        case UIInterfaceOrientationLandscapeRight:
            EasyAR::setRotationIOS(0);
            break;
        default:
            break;
    }
}

+ (GLubyte *)imageDataWithFileName:(NSString *)fileName width:(size_t *)widthRef height:(size_t *)heightRef
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    *widthRef = width;
    *heightRef = height;
    return spriteData;
}

@end
