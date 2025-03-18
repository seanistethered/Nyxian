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

/// Runtime headers
#import <Runtime/Runtime.h>
#import <Runtime/Include.h>
#import <Runtime/EnvRecover.h>
#import <FridaScript-Swift.h>

/// Header for threading
#include <pthread.h>

extern bool FJ_RUNTIME_SAFETY_ENABLED;

/*
 @Brief Structure to make our lifes easier
 */
typedef struct {
    JSContext *context;
    NSString *code;
    TerminalWindow *term;
} FridaScript_Runtime_Thread_t;

/*
 @Brief FridaScript runtime extension
 */
@interface FJ_Runtime ()

@property (nonatomic,strong) TerminalWindow *Serial;

@property (nonatomic,strong) NSMutableArray<Module*> *array;
@property (nonatomic,strong) EnvRecover *envRecover;

@end

/*
 @Brief FridaScript runtime implementation
 */
@implementation FJ_Runtime

- (instancetype)init:(UIView*)ptr
{
    self = [super init];
    FJ_RUNTIME_SAFETY_ENABLED = true;
    _Serial = (TerminalWindow*)ptr;
    _Context = [[JSContext alloc] init];
    _envRecover = [[EnvRecover alloc] init];
    [_envRecover createBackup];
    _array = [[NSMutableArray alloc] init];
    add_include_symbols(self, ptr);
    chdir([[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()] UTF8String]);
    return self;
}

void* runner(void *args)
{
    // getting the arguments
    FridaScript_Runtime_Thread_t *rtargs = (FridaScript_Runtime_Thread_t*)args;
    JSContext *context = rtargs->context;
    NSString *code = rtargs->code;
    
    __block TerminalWindow *BlockSerial = rtargs->term;
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            BlockSerial.terminalText.text = [BlockSerial.terminalText.text stringByAppendingFormat:@"\nFridaScript Error: %@", exception];
        });
    };
    [context evaluateScript:code];
    
    return NULL;
}

/// Main Runtime functions you should focus on
- (void)run:(NSString*)code
{
    // building the thread args
    FridaScript_Runtime_Thread_t *args = malloc(sizeof(FridaScript_Runtime_Thread_t));
    args->context = _Context;
    args->term = _Serial;
    args->code = code;
    
    // creating the pthread
    pthread_create(&_thread, NULL, runner, (void*)args);
    pthread_join(_thread, NULL);
    
    // cleaning up
    [self cleanup];
}

/// relatively new function to terminate the JSContext execution
- (void)kill
{
    pthread_cancel(_thread);
    for (id item in _array) {
        dispatch_semaphore_signal([item giveSemaphore]);
    }
}

/// Private cleanup function
- (void)cleanup
{
    __block TerminalWindow *BlockSerial = _Serial;
    
    for (id item in _array) {
        [item moduleCleanup];
        [_array removeObject:item];
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        BlockSerial.terminalText.text = [BlockSerial.terminalText.text stringByAppendingFormat:@"[EXIT]\n"];
    });
    
    _Context = nil;
    
    [_envRecover restoreBackup];
}

/// Module Handoff function
- (void)handoffModule:(Module*)module
{
    [_array addObject:module];
}

@end
