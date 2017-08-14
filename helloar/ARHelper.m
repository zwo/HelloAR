//
//  ARHelper.m
//  helloar
//
//  Created by zhouweiou on 17/8/14.
//  Copyright © 2017年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#import "ARHelper.h"
#import <OpenGLES/ES2/gl.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@implementation ARHelper

const char * glslSource(const char * fileName)
{
    NSString *fileNameStr=[[NSString alloc] initWithUTF8String:fileName];
    NSString *filePath=[[NSBundle mainBundle] pathForResource:fileNameStr ofType:@"glsl"];
    NSString* shaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [shaderString UTF8String];
}

GLubyte *imageDataWithFileName(const char * fileName, size_t *widthRef, size_t *heightRef)
{
    NSString *fileNameStr=[NSString stringWithUTF8String:fileName];
    CGImageRef spriteImage = [UIImage imageNamed:fileNameStr].CGImage;
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

void printGLErrorMessage(GLuint shaderHandler)
{
    GLint compileSuccess;
    glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandler, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
}

@end
