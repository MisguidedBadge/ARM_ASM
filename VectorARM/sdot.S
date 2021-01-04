// Input //
#define N  r0     // Number of elements
#define X  r1     // Array of double X elements
#define incX r2   // Not USED SKIP
#define Y  r3     // Array of double Y elements
// #define incY    // Not Used SKIP
// Since var isn't used still eat it //
// Double Bank //
#define x1_val s0   // X Values for round two
#define x2_val s1
#define x3_val s2
#define x4_val s3   // X Values for round two 
#define x5_val s4
#define x6_val s5
#define y1_val s6   // Y Values for round one
#define y2_val s7
#define y3_val s8
#define y4_val s9   // Y Values for round two
#define y5_val s10   
#define y6_val s11
#define sum1   s12   // Total sum of X + Y with iterating array
#define sum2   s13
#define sum3   s14
// 
/*
                           r0                 r1              r2
      double ATL_UDOT(const int N, const double *X, const int incX,
                 r3              SP
      const double *Y, const int incY)
 */
.text
.arm
.local DOT_LOOP, INVALID, CLEAN, EXIT
.globl ATL_UDOT

ATL_UDOT:
   // prereq
   cmp N, #0    // see if N <= 0
   ble INVALID  // exit early if so
   // obtain sum = 0 by 
   fnegs s0, sum1  // s3 = -sum
   fadds sum1, sum1, s0  // sum = sum - sum = 0
   fnegs s0, sum2  // s3 = -sum
   fadds sum2, sum2, s0  // sum = sum - sum = 0
   fnegs s0, sum3  // s3 = -sum
   fadds sum3, sum3, s0  // sum = sum - sum = 0
   cmp N, #6   // if N < 3
   blt CLEAN   // go to cleanup routine
   /*
     for( N = num elem ; N >= 6; N = N - 6)
     { x1 = (*X)++; .... x3 = (*X)++; y1 = (*Y)++; .... y3 = (*Y)++; 
       sum1 += x1 * y1; ... sum3 = x3 * y3
       x4 = (*X)++; .... x6 = (*X)++; y4 = (*Y)++; .... y6 = (*Y)++; 
       sum1 += x4 * y4; ... sum3 = x6 * y6
     }
    */
   DOT_LOOP:
      fldmIAs X!, {x1_val, x2_val, x3_val}       // load x value and iterate
      fldmIAs Y!, {y1_val, y2_val, y3_val}       // load y value and iterate
      /*
      fmuls x1_val, x1_val, y1_val // dot1 = x1 * y1 
      fmuls x2_val, x2_val, y2_val // dot2 = x2 * y2
      fmuls x3_val, x3_val, y3_val // dot3 = x3 * y3
      fadds sum1, sum1, x1_val     // add to total sum1     
      fadds sum2, sum2, x2_val     // add to total sum2
      fadds sum3, sum3, x3_val     // add to total sum3
      */
      fmacs sum1, x1_val, y1_val   // dot1 += x1 * y1
      fmacs sum2, x2_val, y2_val   // dot2 += x2 * y2
      fmacs sum3, x3_val, y3_val   // dot3 += x3 * y3
      fldmIAs X!, {x4_val, x5_val, x6_val}       // load x value and iterate
      fldmIAs Y!, {y4_val, y5_val, y6_val}       // load y value and iterate
      /* 
      fmuls x4_val, x4_val, y4_val // dot1 = x1 * y1 
      fmuls x5_val, x5_val, y5_val // dot2 = x2 * y2
      fmuls x6_val, x6_val, y6_val // dot3 = x3 * y3
      fadds sum1, sum1, x4_val     // add to total sum1     
      fadds sum2, sum2, x5_val     // add to total sum2
      fadds sum3, sum3, x6_val     // add to total sum3
      */
      fmacs sum1, x4_val, y4_val   // dot1 += x4 * y4
      fmacs sum2, x5_val, y5_val   // dot2 += x5 * y5
      fmacs sum3, x6_val, y6_val   // dot3 += x6 * y6
      sub N, N, #6             // check if N < 3
      cmp N, #6      // if N < 3 then check if N = 0
   bge DOT_LOOP      // keep looping if N > 3
   // cleanup check
   cmp N, #0         // If N = 0 then don't clean up
   beq EXIT          // cleanup otherwise
   /*
     for(N = rem elemen; N != 0; N--)
     {x1 = (*X)++; y1 = (*Y)++; sum1 += x1 * y1; }
    */
   CLEAN:
      fldmIAs X!, {x1_val}   // load in x value
      fldmIAs Y!, {y1_val}   // load in y value
      fmacs sum1, x1_val, y1_val // sum1 += x1 * y1
      subs N, N, #1  // check if N has reached 0
   bne CLEAN // if it has then exit clean loop else keep going

EXIT:
   fcpys s0, sum1    // set return value = to sum
   fadds s0, s0, sum2  // add rest of sum values
   fadds s0, s0, sum3  // add rest of sum values
   bx lr  // exit routine
// exit routine early if N isn't properly set
INVALID:
   fnegs s1, s0    // zero out return value
   fadds s0, s0, s1  // when input is invalid
   bx lr  // exit routine







