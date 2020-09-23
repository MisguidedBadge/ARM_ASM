#define N      r0   // input N
#define lower  r0   // accumulated sum. Return
#define in_a   r1   // input address
#define upper  r1   // 
// values to store in registers
#define val_1  r2   // acculumated value 1
#define val_2  r3   //
#define val_3  r12  //
#define val_4  r14 
// SAVE //
#define acc_1  r4   //
#define acc_2  r5   //
#define acc_3  r6   //
#define acc_4  r7   //
#define acc_5  r8   //
#define acc_6  r9   //
#define acc_7  r10  //
#define acc_8  r11  //
// END SAVE //
//#define iter   r12  // iterator register
//#define SP     r13  // stack pointer register
#define RSV    8*8  // callee registers saved on stack
/*
           r0 and r1                    r0              r1
  unsigned long long lvecsum(unsigned int N, unsigned int *V)

*/

.text
.arm
.local BODY, LOOP1, REM, REMLOOP, TOTAL
.globl lvecsum

lvecsum:
   cmp N, #0
   bLT DONE
   stmDB SP!, {r4-r11, LR}        // store all used register on stack
   mov acc_1, #0
   mov acc_2, #0
   mov acc_3, #0
   mov acc_4, #0
   mov acc_5, #0
   mov acc_6, #0
   mov acc_7, #0
   mov acc_8, #0
   mov r14, #0
   ands val_1, N, #0x7
   beq BODY
// Handle the remaining iterations
REM:
   rsb val_1, val_1, #0
   REMLOOP:
      ldr val_2, [in_a], #4
      add acc_1, acc_1, val_2
      adds val_1, val_1, #1
   bne REMLOOP

BODY:
   mvn val_1, #0
   //mov val_1, val_1,
   lsr N, #3
   ands N,  N, val_1
   beq TOTAL
   mov val_1 , #0
   mov val_2 , #0    
   rsb N, N, #0  // make value negative and branch
   LOOP1:
      ldmIA in_a!, {val_1, val_2, val_3, val_4}    
      add  acc_1, acc_1, val_1
      add  acc_2, acc_2, val_2
      add  acc_3, acc_3, val_3
      add  acc_4, acc_4, val_4
      ldmIA in_a!, {val_1, val_2, val_3, val_4}
      add  acc_5, acc_5, val_1
      add  acc_6, acc_6, val_2
      add  acc_7, acc_7, val_3
      add  acc_8, acc_8, val_4
      adds N, N, #1
   bne LOOP1
   
TOTAL:
   mov lower, #0
   mov upper, #0
   add lower, lower, acc_1
   adds lower, lower, acc_2
   adc upper, upper, #0
   adds lower, lower, acc_3
   adc upper, upper, #0
   adds lower, lower, acc_4
   adc upper, upper, #0
   adds lower, lower, acc_5
   adc upper, upper, #0
   adds lower, lower, acc_6
   adc upper, upper, #0
   adds lower, lower, acc_7
   adc upper, upper, #0
   adds lower, lower, acc_8
   adc upper, upper, #0

   ldmIA SP!, { r4-r11, LR}

DONE:
   bx lr












