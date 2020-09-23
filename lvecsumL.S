#define sum    r0   // accumulated sum. Retur
#define in_p   r1   // input pointer
#define in_val r2   // input value
#define iter   r12  // iterator register
#define upper  r3   // upper of 64
#define SP r13   // stack pointer register
/*
  unsigned long long lvecsum(unsigned int N, unsigned int *V)


*/

.text
.arm
.local BODY, LOOP1
.globl lvecsum

lvecsum:
   // stack pointer stuff if needed
   mov upper, #0
BODY:
   cmp r0, #1
   bLT DONE

   mov iter, r0        // put input parameter into iter register
   mov sum, #0         // 0 return register   
   rsb iter, iter, #0  // make value negative and branch
LOOP1:
   ldr in_val, [in_p], #4
   addS sum, in_val
   adc upper, upper, #0   
   adds iter, iter, #1
  bne LOOP1
   mov in_p, upper
DONE:
   bx lr












