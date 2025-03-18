/*
 MIT License

 Copyright (c) 2025 SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#ifndef FS_MODULE_MATH_H
#define FS_MODULE_MATH_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

/*
 @Brief JSExport Protocol for Math Module
 */
@protocol MathModuleExport <JSExport>

/// Math functions
- (int)abs:(int)x;
- (int)sqrt:(int)x;
- (double)sin:(double)x;
- (double)cos:(double)x;
- (double)tan:(double)x;
- (double)log:(double)x;
- (double)exp:(double)x;
- (double)floor:(double)x;
- (double)ceil:(double)x;
- (double)round:(double)x;
- (int)min:(int)x y:(int)y;
- (int)max:(int)x y:(int)y;
- (int)rand;
JSExportAs(pow,     - (double)pow:(double)x y:(double)y                                                 );

@end

/*
 @Brief Math Module Interface
 */
@interface MathModule : NSObject <MathModuleExport>

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

#endif /* FS_MODULE_MATH_H */
