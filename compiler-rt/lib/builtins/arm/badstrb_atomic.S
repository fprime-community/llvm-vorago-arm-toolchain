//===----- lib/arm/badstrb_atomic.c - Perform 16-bit atomic operations in-place of 8-bit ----*- C -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===------------------------------------------------------------------------------------------===//

#include "../assembly.h"

        .syntax unified
        .p2align 2
DEFINE_COMPILERRT_FUNCTION(__badstrb_ldrexb)
        // address => r0
        // Return loaded value on r0

        // Put the even address into r2
        bic r2, r0, #1

        // Compute a shift amount
        movs	r3, #0x8
        and.w	r0, r3, r0, lsl #3 // r0 == 0 for even addresses and 8 for odd

        // Compute the mask
        mov.w	r12, #0xff00

        // Load the address early to allow the pipeline to go out to memory
        ldrexh r3, [r2]

        // Shift the mask to the spot we don't care about
        // Even => The current mask is fine (i.e r0 == 0)
        // Odd => The current mask needs shifting right by one byte (i.e r0 == 8)
        lsr.w	r2, r12, r0

        // Apply the load mask
        ands	r2, r3

        // Move the value to the expected byte and return
        lsls	r0, r1, r0

        bx  lr
END_COMPILERRT_FUNCTION(__badstrb_ldrexb)

        .syntax unified
        .p2align 2
DEFINE_COMPILERRT_FUNCTION(__badstrb_strexb)
        // Put the even address into r2
        bic r2, r0, #1

        // Compute a shift amount
        movs	r3, #0x8
        and.w	r0, r3, r0, lsl #3 // r0 == 0 for even addresses and 8 for odd

        // Compute the mask
        mov.w	r12, #0xff00

        // Shift the value to the right byte and apply the mask
        lsls  r1, r0
        ands r1, r12

        strexh r0, r1, [r2]

END_COMPILERRT_FUNCTION(__badstrb_strexb)
