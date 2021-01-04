// Input //
#define N  r0     // Number of elements
#define X  r1     // Array of double X elements
#define incX r2   // Not USED SKIP
#define Y  r3     // Array of double Y elements
// #define incY    // Not Used SKIP
// Since var isn't used still eat it //
// Double Bank //
#define x1_val s0   // X Values for first round of dot
#define x2_val s1   // 
#define x3_val s2   //
#define x4_val s3   // X Values for second round of dot
#define x5_val s4   //
#define x6_val s5   //
#define y1_val s6   // Y Values for first round of dot
#define y2_val s7   // 
#define y3_val s8   //
#define y4_val s9   // Y Values for second round of dot
#define y5_val s10  // 
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
   cmp N, #12   // if N < 12
   blt CLEAN   // go to cleanup routine
   // Load before loop to preload values
   fldmIAs X!, {x1_val}
   fldmIAs Y!, {y1_val}
   // preload values in order of what's used first
   fldmIAs X!, {x2_val}
   fldmIAs Y!, {y2_val}
   fldmIAs X!, {x3_val}
   fldmIAs Y!, {y3_val}
   fldmIAs X!, {x4_val}
   fldmIAs Y!, {y4_val}
   fldmIAs X!, {x5_val}
   fldmIAs Y!, {y5_val}
   fldmIAs X!, {x6_val}
   fldmIAs Y!, {y6_val}
   /*
     for(N = num elements; N >= 12; N = N - 6)
     { sum1 += x1 * y1; x1 = (*X)++; y1 = (*Y)++;
       ...
       sum3 += x6 * y6; x6 = (*X)++; y6 = (*Y)++;
      }
    */
   DOT_LOOP:
      fmacs sum1, x1_val, y1_val   // sum1 += x1 * y1
      // preload x1 and y1
      fldmIAs X!, {x1_val}  // load x1 
      fldmIAs Y!, {y1_val}  // load y1
      fmacs sum2, x2_val, y2_val   // sum2 += x2 * y2 
      // preload x2 and y2
      fldmIAs X!, {x2_val}
      fldmIAs Y!, {y2_val}  
      fmacs sum3, x3_val, y3_val   // sum3 += x3 * y3
      // preload x3 and y3
      fldmIAs X!, {x3_val}
      fldmIAs Y!, {y3_val}
      fmacs sum1, x4_val, y4_val   // sum1 += x4 * y4
      // preload x4 and y4  
      fldmIAs X!, {x4_val}
      fldmIAs Y!, {y4_val}
      fmacs sum2, x5_val, y5_val   // sum2 += x5 * y5
      // preload x5 and y5
      fldmIAs X!, {x5_val}
      fldmIAs Y!, {y5_val}
      fmacs sum3, x6_val, y6_val   // sum3 += x6 * y6
      // preload x6 and y6
      fldmIAs X!, {x6_val}
      fldmIAs Y!, {y6_val}
      sub N, N, #6             // check if N - 6 < 12
      cmp N, #12      // if N < 12 then check if N = 0
   bge DOT_LOOP      // keep looping if N > 12
   // want to end when N >= 12 to ensurer preloaded values drain
   fmacs sum1, x1_val, y1_val   // sum1 += x1 * y1
   fmacs sum2, x2_val, y2_val   // sum2 += x2 * y2
   fmacs sum3, x3_val, y3_val   // sum3 += x3 * y3
   fmacs sum1, x4_val, y4_val   // sum1 += x4 * y4
   fmacs sum2, x5_val, y5_val   // sum2 += x5 * y5
   fmacs sum3, x6_val, y6_val   // sum3 += x6 * y6
   // cleanup check
   sub N, N, #6  // Account for drain number
   cmp N, #0     // if N == 0 then skip cleanup routine
   beq EXIT
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
   fadds s0, s0, sum2 // add rest of sum values
   fadds s0, s0, sum3 // add rest of sum values
   bx lr  // exit routine
// exit routine early if N isn't properly set
INVALID:
   fnegs s1, s0     // zero out return
   fadds s0, s0, s1 // if input is invalid
   bx lr  // exit routine







