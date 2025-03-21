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

#include <Runtime/Modules/ArbCall/ArbCallCore.h>

///
/// This function calls the function behind the call structure
///
uint64_t call(call_t call)
{
    // Checking if the function pointer is valid
    if(call.func_ptr == NULL)
    {
        // Its not so we return -1
        return -1;
    }
    
    // Its valid so we return the result of the call
    return (uint64_t)call.func_ptr(call.args[0], call.args[1], call.args[2], call.args[3], call.args[4], call.args[5], call.args[6], call.args[7], call.args[8], call.args[9]);
}

///
/// This function finds a symbol and assigns it to the call structure using
/// dlsym
///
void call_find_func(call_t *call)
{
    // We find the function pointer address by asking the dynamic loader nicely
    // and write its result onto the call structures function pointer holder
    call->func_ptr = dlsym(RTLD_DEFAULT, call->name);
}

///
/// Argument setter functions
///
/// Their purpose is to set the arguments of the call structure which allows
/// NyxianRuntime to use ArbCalling very flexible
///

/// 8 bit functions to set a 8 bit value in a arg
void call_set_int8(call_t *call_struct, uint8_t pos, int8_t value)
{
    call_struct->args[pos] = (int8_t)value;
}
void call_set_uint8(call_t *call_struct, uint8_t pos, uint8_t value)
{
    call_struct->args[pos] = (uint8_t)value;
}

/// 16 bit functions to set a 16 bit value in a arg
void call_set_int16(call_t *call_struct, uint8_t pos, int16_t value)
{
    call_struct->args[pos] = (int16_t)value;
}
void call_set_uint16(call_t *call_struct, uint8_t pos, uint16_t value)
{
    call_struct->args[pos] = (uint16_t)value;
}

/// 32 bit functions to set a 32 bit value in a arg
void call_set_int32(call_t *call_struct, uint8_t pos, int32_t value)
{
    call_struct->args[pos] = (int32_t)value;
}
void call_set_uint32(call_t *call_struct, uint8_t pos, uint32_t value)
{
    call_struct->args[pos] = (uint32_t)value;
}

/// 64 bit functions to set a 64 bit value in a arg
void call_set_int64(call_t *call_struct, uint8_t pos, int64_t value)
{
    call_struct->args[pos] = (int64_t)value;
}
void call_set_uint64(call_t *call_struct, uint8_t pos, uint64_t value)
{
    call_struct->args[pos] = (uint64_t)value;
}

///
/// This function is special as it allows you to use together using the Memory module to use pointers and
/// string buffers.
///
void call_set_ptr(call_t *call_struct, uint8_t pos, void *ptr)
{
    call_struct->args[pos] = (uintptr_t)ptr;
}
