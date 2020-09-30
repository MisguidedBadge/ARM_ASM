// caller saved *if needed* //
#define N   r0       // N iterations
#define pX  r1       // Integer Array of values
#define offset r2    // offset for right side
// callee saved  //
#define N_L r4   //     Number of iterations for left
#define N_R r5   //     Number of iterations for right
#define sum r4   //     Sum used at end and replaces N_L
#define pX_R r6
/*   
     r0         r0       r1
    int irsum(int N, int *pX)     
*/

.text
.arm
.local SingleExit, NullExit
.globl irsum

irsum:
// Exit Conditions //
   cmp N, #0          // compare to see if value is <= 0
   bLE NullExit       // exit routine if it is <= 0

// values >= 1
   cmp N, #1          // compare to see if value is 1
   beq SingleExit     // if it is one then hit basis condition

// values > 1
   stmDB SP!, {r4-r6, LR}  // Allocate stack space for regs used
//   sub SP, SiP ,#4 //
   mov N_L, r0        // initialize number of left  to current iterations
   mov N_R, r0        // initialize number of right to current iterations
   add N_R, N_R, #1   // add 1 to right to round up when divided
   lsr N_L, #1        // N_L = divide N by 2 and round down
   lsr N_R, #1        // N_R = divide N by 2 and round up
   mov pX_R, pX       // start right side address at pX
   mov offset, N_L    // set number of integer offset by left iterations
   LSL offset, #2     // multiply by 4 bytes for integer size
   add pX_R, pX_R, offset  // move to the right side address by adding offset
   // begin 1st call //
   mov N, N_L    // set 1st arg to left iterations
   // 2nd agument (pX) already set properly //
   bl  irsum     // recursive call for left
   // N_L no longer used after this point -> using sum now //
   mov sum, r0   // value of sum set to return of 1st call
   
   mov N, N_R    // 1st argument number of right iterations
   mov pX, pX_R  // set 2nd argument to right side starting address
   bl irsum      // recursive call for right
   add r0, r0, sum   // add sum to output of right

//   add SP, SP, #4 //
   ldmIA SP!, {r4-r6, LR}  // restore stack space
   bx lr   // exit this routine

// Basis condition
SingleExit:
   ldr r0, [pX]   // load 1st and only value 
   bx lr   // exit the routine

// Condition for N <= 0
NullExit:
   mov r0, #0  // return 0 since the input isn't valid
   bx lr   // exit the routine