// INPUT //
// #define ta r0 Overwrite
// #define tb r1 Values don't matter
#define SP_A  r0        //
#define M    r2         // M dimension iterator
#define N    r3         // N dimension iterator
// Reg input from stack //
#define A    r1         // A matrix with MxK elements
// Callee saved //
#define lda  r4         // offset for next row in Mat A
#define B    r5         // B matrix with KxN elements
#define ldb  r6         // offset for next column in Mat B
#define C    r7         // *C
#define ldc  r8         // Offset for next row in Mat C
#define index r9        // Index variable to correctly index
#define K    r10        // K dimension iterator
#define K_i  r0         // K dimension const
#define M_j  r11        // M dimension const
#define N_k  r12        // N dimension const
// Num regs stored on stack
// Double Bank //
#define ALPHA_f d0      // alpha * A
#define BETA_f d1       // beta * C
#define sum d2          // overall sum for C element
// values for matrix elements
#define A_val d3        //
#define B_val d4        //
#define C_val d5        //

/*
                      r0    r1   r2    r3     SP     d0
    void dgemm_asg(int ta, tb, int M, int N, int K, double alpha,
            SP + 4      SP + 8     SP + 12       SP + 16
      const double *A, int lda, const double *B, int ldb,
         d1          SP + 20    SP + 24
      double beta, double *C, int ldc
      )

 */
.text
.arm
.local K_LOOP //, SPEC_B
.globl dgemm_asg

dgemm_asg:
   // store callee saved registers
   mov SP_A, SP
   stmDB SP!, {r4-r11}
   // load in argument inputs using orignal Stack address
   ldr K, [SP_A ]          
   ldr A, [SP_A , #4]
   ldr lda, [SP_A , #8]
   ldr B, [SP_A , #12]
   ldr ldb, [SP_A , #16]
   ldr C, [SP_A , #20]
   ldr ldc, [SP_A, #24]
   // set constant values for loop fallback and comparison
   mov K_i , K
   mov M_j , M
   mov N_k , N
   // N doesn't need hold since it's the last
   /*
       for (N ; N != N_k; N++)
       {
         N = N * 8; M = 0
         for( M ; M != M_j; M++)
         {
           M = M * 8; K = 0; sum = 0;
           for(K ; K != K_i; K++)
           {
               K = K * 8; index = lda * M + K + A;
               A_val = *index;
               index = ldb * N + K + B;
               B_val = *index;
               sum += A_val + B_val;
               K = K / 8;
            }
            index = ldc * N + M + C
            if(beta != 0)
            {
              C_val = *index;
              C_val = C_val * beta;
              sum = sum * alpha;
              sum = sum + C_val;
            }
            else{
              sum = sum * alpha;
               }
            *index = sum;
            M = M / 8;
         }
        N = N / 8;
       }
    */
   // Set iterator to 0 for start
   mov N, #0
   N_LOOP:
      // set M iterator to 0 before entrance
      mov M, #0
      // This is was painful to finally realize
      //
      LSL N , #3  // Offset of 8 bytes.. set before going in to reduce 
      // amount of times it des
      M_LOOP:
         LSL M , #3   // add offset to M also     
         mov K , #0   // reset K value
         fnegd d3, sum // zero out sum value
         faddd sum, sum, d3
         //add A, A, #(K_hold * 8)
         K_LOOP:
            // A
            LSL K, #3  // add offset byte to K 
            mul index, lda, M // multiply the row offset by M iterator
            add index, index,K // add K index 
            add index, A, index // add index and A to get offset address 
            fldd A_val, [index] // load A double precision with offset
            // B
            mul index, ldb, N   // multiply column offset by N iterator
            add index, index,K  // add K index
            add index, B, index // add B and index to get offset address
            fldd B_val, [index] // load B double precision with offset
            // sum
            fmacd sum, A_val, B_val // multiply A and B and add to sum
            // K stuff
            LSR K, #3      //  set K back to normal
            add K, K, #1   //  iterate K by 1
            cmp K , K_i    //  see if K has hit it's boundry
         bne K_LOOP // if it has then loop back
         // C
         mul index, ldc, N     // load row offset by N
         add index, index, M   // add offset of column via M
         add index, C, index   // add C address by offset
         fcmpzd BETA_f         // If beta is 0?
         fmstat                // get control reg val
         //beq SPEC_B:
         flddne C_val, [index] // load in C element based on offset pos
         //fmuld BETA_f, BETA_f, ALPHA_f
         fmuldne C_val, C_val, BETA_f //  multiply C by beta
         fmuldne sum, sum, ALPHA_f    //  multiply the sum by alpha
         fadddne sum, sum, C_val      //  add to get output
         // special case where Beta is 0 therefore we skip C load
         SPEC_B:
         fmuldeq sum, sum, ALPHA_f    // if C doesn't exist then just 
         // multiply sum by alpha
         fstd sum, [index]      // store sum into the offset address
         LSR M, #3     // shift M back to normal
         add M, M, #1  // iterate M by 1
         cmp M, M_j    // see if M has hit boundary
      bne M_LOOP // If M hit boundary then  exit else keep going

      LSR N, #3        // set N back to normal
      add N, N, #1     // iterate N by 1
      cmp N, N_k       // see if N has hit boundary
   bne N_LOOP   // if N hit boundary then Mat Math done
   // restore registers
   ldmIA SP!, {r4-r11}
   bx lr    // exit routine