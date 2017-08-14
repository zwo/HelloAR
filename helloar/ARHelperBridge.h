//
//  ARHelperBridge.h
//  helloar
//
//  Created by zhouweiou on 17/8/14.
//  Copyright © 2017年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#ifndef ARHelperBridge_h
#define ARHelperBridge_h

const char * glslSource(const char * fileName);
GLubyte *imageDataWithFileName(const char * fileName, size_t *widthRef, size_t *heightRef);
#endif /* ARHelperBridge_h */
