// Input Parameters //
#define N      r0   // N iterations
#define vec    r1   // unsigned int array
// output registers --> long long out //
#define lower  r0   // accumulated sum lower half
#define upper  r1   // accumulated sum upper half
// Intermediate loading registers //
#define val_1  r2   // value loaded into register to add in accumator
#define val_2  r3   // ^^^^^^^^
#define val_3  r12  // value loaded into register to add in accumator
#define val_4  r14  // ^^^^^^^^ SAVE REGISTER
// Accumulation registers SAVE ALL //
#define acc_1  r4   // accumulator 1 has remainder too
#define acc_2  r5   // accumulator 2
#define acc_3  r6   // accumulator 3
#define acc_4  r7   // accumulator 4
#define acc_5  r8   // accumulator 5
#define acc_6  r9   // accumulator 6
#define acc_7  r10  // accumulator 7
#define acc_8  r11  // accumulator 8
// END SAVE ALL //
// #define RSV    9*8  // callee registers saved on stack
/*
           r0 and r1                    r0              r1
  unsigned long long lvecsum(unsigned int N, unsigned int *V)

*/

.text
.arm
.local QUOTIENT, QLOOP, REM, REMLOOP, TOTAL
.globl lvecsum

lvecsum:
   cmp N, #0                      // see if N is 0
   beq DONE                       // If N is 0 then exit 
   stmDB SP!, {r4-r11, LR}        // store all used register on stack
   // Set registers to zero to prevent using uneeded values //
   mov acc_1, #0                  // set accumulator 1 to 0
   mov acc_2, #0                  // set accumulator 2 to 0
   mov acc_3, #0                  // set accumulator 3 to 0
   mov acc_4, #0                  // set accumulator 4 to 0
   mov acc_5, #0                  // set accumulator 5 to 0
   mov acc_6, #0                  // set accumulator 6 to 0
   mov acc_7, #0                  // set accumulator 7 to 0
   mov acc_8, #0                  // set accumulator 8 to 0

/* Handle the remaining iterations (not divisble by 8) */
REM:
   ands val_1, N, #0x7            // store remainder into value 1
   beq QUOTIENT                   // if no remainder then branch to quotient
   rsb val_1, val_1, #0           // reverse val_1 sign to be iterator
/* for(val_1, val_1 != 0; val_1++)
 {val2 = *(in_a++); acc_1 += val_2; (in for loop) */
   REMLOOP:
      // load address at vec and increment 1 iteration (1 int)
      ldr val_2, [vec], #4        
      add acc_1, acc_1, val_2     // add value 2 to acc 1
      adds val_1, val_1, #1       // increment val_1 until 0
   bne REMLOOP                    // branch when iterator hits 0

/* Compute the sum with iterations being quotient of (N / 8)
   remainder value handled previously */
QUOTIENT:
// val_1 = 0
// val_2 may have values
   lsr N, #3                      // Divide N by 8 
   cmp N, #0                      // See if the quotient is 0
   beq TOTAL                      // if zero then skip to compute total
   rsb N, N, #0                   // flip iteration sign for the loop
/* for(N, N != 0, N++)
{val1 = *(vec++);... val4 = *(vec++); acc_1 += val1...acc_4 += val_4
 val1 = *(vec++);... val4 = *(vec++); acc_5 += val1...acc_8 += val_4} */
   QLOOP:
      // load values and post increment pointer 4 iterations (4 ints)
      ldmIA vec!, {val_1, val_2, val_3, val_4}
      add  acc_1, acc_1, val_1    // accumulate value1 into accum 1
      add  acc_2, acc_2, val_2    // accumulate value2 into accum 2
      add  acc_3, acc_3, val_3    // accumulate value3 into accum 3
      add  acc_4, acc_4, val_4    // accumulate value4 into accum 4
      // load values and post increment pointer 4 iterations (4 ints)
      ldmIA vec!, {val_1, val_2, val_3, val_4}
      add  acc_5, acc_5, val_1    // accumulate value1 into accum 5
      add  acc_6, acc_6, val_2    // accumulate value2 into accum 6
      add  acc_7, acc_7, val_3    // accumulate value3 into accum 7
      add  acc_8, acc_8, val_4    // accumulate value4 into accum 8
      adds N, N, #1               // increment num of quotient till 0
   bne QLOOP                      // Loop until quotient is 0
// R0 now 0

/* compute total SUM with upper = R1 and lower = R0
    Sum = acc1 + acc2 + ... acc8 */
TOTAL:
   // lower = 0 and upper = vec
   mov upper, #0             // reset upper to 0 
   // since lower = 0 can overwrite with combine
   adds lower, acc_2, acc_1  // combine acc1 and acc2 into lower
   adc upper, upper, #0      // account for carried value after combine
   adds lower, lower, acc_3  // combine acc_3 into lower
   adc upper, upper, #0      // account for carried value after combine
   adds lower, lower, acc_4  // combine acc_4 into lower
   adc upper, upper, #0      // account for carried value after combine
   adds lower, lower, acc_5  // combine acc_5 into lower
   adc upper, upper, #0      // account for carried value after combine
   adds lower, lower, acc_6  // combine acc_6 into lower
   adc upper, upper, #0      // account for carried value after combine
   adds lower, lower, acc_7  // combine acc_7 into lower
   adc upper, upper, #0      // account for carried value after combine
   adds lower, lower, acc_8  // combine acc_8 into lower
   adc upper, upper, #0      // account for carried value after combine

   // restore saved registers and restore stack
   ldmIA SP!, { r4-r11, LR}

// EXIT //
DONE:
   bx lr












