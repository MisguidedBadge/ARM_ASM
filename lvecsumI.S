#define N      r0   // number of iterations (input)
#define sum    r0   // accumulated sum. (output)
#define in_p   r1   // input int array
#define val    r2   // value to add into sum
#define iter   r12  // iterator register
/*
           r0 and r1                   r0              r1
  unsigned long long lvecsum(unsigned int N, unsigned int *V)

*/

.text
.arm
.local SUMLOOP
.globl lvecsum

lvecsum:
   cmp r0, #0          // see if there are no iterations
   beq DONE            // exit if iterations = 0

//BODY: carries out summations
   mov iter, r0        // num iterations = N
   mov sum, #0         // 0 sum register for loop  
   rsb iter, iter, #0  // reverse iter sign to increment until 0
/* for(iter, iter != 0; iter++)
{val = *(in_p++), sum += in_val -> if carry upper++ }
*/
   SUMLOOP:
      // load val from array and post increment array
      ldr val, [in_p], #4   
      add sum, in_val        // add value to sum
      adds iter, iter, #1    // increment iterations until 0
   bne SUMLOOP               // keep looping until 0
// R0 has sum, R1 has in_p 
   mov r1, #0           // zero out upper of long long
// exit
DONE:
   bx lr












