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

/// Importing necessary headers
#import <Runtime/UISurface/UISurface.h>
#include <pthread.h>

/// The holder for the UISurface root
UIView *uisurface_root;

/// The holder for the message you wanna pass
NSString *uisurface_msg = nil;

/// Stuff necessary to keep it safe
BOOL uisurface_initialized = NO;
dispatch_semaphore_t uisurface_semaphore;
pthread_mutex_t uisurface_mutex;

///
/// Functions to handoff a UIView as target to the UISurface
/// This is specifically used for the UI module to know which
/// UIView to add view to, extends the flexibility of the
/// NyxianRuntime
///
void UISurface_Handoff_Slave(UIView *view)
{
    // First we set the slaves view to the UISurface Root
    uisurface_root = view;
    uisurface_msg = NULL;
    
    // Now we have to allocate the semaphore/msgQueue to work correctly
    if(!uisurface_initialized)
    {
        uisurface_semaphore = dispatch_semaphore_create(0);
        pthread_mutex_init(&uisurface_mutex, NULL);
    }
    
    // Now as its initialized set it to true
    uisurface_initialized = YES;
}

UIView* UISurface_Handoff_Master(void)
{
    // We complete the full handoff and the master side receives the slaves UIView
    return uisurface_root;
}

///
/// Functions for Buttons to communicate with the execution and the other way around
///
NSString* UISurface_Wait_On_Msg(void)
{
    // The master side waits on the slave side to send a message using UISurface_Send_Msg
    dispatch_semaphore_wait(uisurface_semaphore, DISPATCH_TIME_FOREVER);
    
    NSString *result;
    
    // We use the mutex to block any operation on uisurface_msg
    pthread_mutex_lock(&uisurface_mutex);
    
    // Now we read what the slave side provided
    result = [uisurface_msg copy];
    uisurface_msg = NULL;
    
    pthread_mutex_unlock(&uisurface_mutex);
    
    // As we received the message we can just return it to the master side as requested
    return result;
}

void UISurface_Send_Msg(NSString *umsg)
{
    // The slave side pleases the master and copies over the message it wants to overbring
    pthread_mutex_lock(&uisurface_mutex);
    
    // Now we write what the slave side wants to overbring to the master side
    uisurface_msg = [umsg copy];
    
    pthread_mutex_unlock(&uisurface_mutex);
    
    // Now we signal the master side that we copied over what was requested
    dispatch_semaphore_signal(uisurface_semaphore);
}


///
/// Functions for onocasion message gathering
///
BOOL UISurface_Did_Got_Messaged(void)
{
    // Boolean result placeholder
    BOOL got_messaged = NO;
    
    // Locking mutex so uisurface_msg can be accessed safely
    pthread_mutex_lock(&uisurface_mutex);
    
    // Checking if uisurface_msg is nil to know if a message was passed
    if(uisurface_msg != NULL)
    {
        // We got message so we set it to YES
        got_messaged = YES;
    }
    
    // Unlocking mutex so another operation can safely access uisurface_msg
    pthread_mutex_unlock(&uisurface_mutex);
    
    // Returning the boolean placeholder
    return got_messaged;
}

NSString* UISurface_Get_Message(void)
{
    // NSString result placeholder
    NSString *result;
    
    // Locking mutex so uisurface_msg can be accessed safely
    pthread_mutex_lock(&uisurface_mutex);
    
    // Copying uisurface_msg to the result NSString pointer in order to safely hand over the message
    result = [uisurface_msg copy];
    
    // Setting uisurface_msg back to NULL so another operation does not assume that a message was already passed
    uisurface_msg = NULL;
    
    // Unlocking mutex so another operation can safely access uisurface_msg
    pthread_mutex_unlock(&uisurface_mutex);
    
    // Returning the result
    return result;
}
