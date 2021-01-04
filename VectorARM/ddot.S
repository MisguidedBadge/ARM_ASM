// Input //
#define N  r0     // Number of elements
#define X  r1     // Array of double X elements
#define incX r2   // Not USED SKIP
#define Y  r3     // Array of double Y elements
// #define incY    // Not Used SKIP
// Since var isn't used still eat it //
// Vars VFP Double Precision //
#define x_val d0   // X Value
#define y_val d1   // Y Value
#define sum   d2   // Total sum of X + Y with iterating array
// 
/*
                           r0                 r1              r2
      double ATL_UDOT(const int N, const double *X, const int incX,
                 r3              SP
      const double *Y, const int incY)
 */
.text
.arm
.local DOT_LOOP, INVALID
.globl ATL_UDOT

ATL_UDOT:
   // prereq
   cmp N, #0    // see if N <= 0
   ble INVALID  // exit early if so
   // obtain sum = 0 by
   fnegd d3, sum  // d3 = -sum
   faddd sum, sum, d3  // sum = sum - sum = 0
   /*
         for ( N = num elements; N != 0; N--)
         { x_val = (*X)++; y_val = (*Y)++; sum += x_val * y_val; }
    */
   DOT_LOOP:
      //fldmIAd X!, {x_val}       // load x value and iterate
      //fldmIAd Y!, {y_val}       // load y value and iterate
      fldd x_val, [X]
      fldd y_val, [Y]
      add Y, Y, #8
      add X, X, #8
      /* 
      fmuld x_val, x_val, y_val // dot = x * y 
      faddd sum, sum, x_val     // add that to total sum
      */
      fmacd sum, x_val, y_val   // dot += x * y
      subs N, N, #1             // see if we reached end
   bne DOT_LOOP      // branch if we haven't reached end
   fcpyd x_val, sum  // set return value = to sum
   bx lr  // exit routine
// exit routine early if N isn't properly set
INVALID:
   fnegd d0, d1     // zero out 
   faddd d0, d0, d1 // return value D0
// exit routine
   bx lr







