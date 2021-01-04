// Input //
#define ub   r0   // start of unsorted list (relative)
#define gNxt r1   // byte offset to load next node
#define gI   r2   // byte offset to load int in node
#define UB_rem r3 // OUT remaining nodes unsorted
// Preserve on stack //
#define N    r4   // number of nodes in list (relative)
// Local Var //
#define N_L  r4  // N left side N >> 1
#define N_R  r5  // N right side N - N_L
#define N_S  r6  // saving for N
#define ub_save r6 //
#define rb r7    // rb value that holds UB
//
/*
    // Not ABI Compliant //
    // My own RULES // 
    // - gI and gNxt shall not change
       r0                   r0          r1         r2       r3       r4  
    void *MrgSortRecur(void * ub, ulong gNxt, ulong gI, void * UB, int N)
*/
.text
.thumb
.local Basis
.globl MrgSortRecur, MergeChains
.syntax unified

// Merge Sort Recursion // 
// split lists until 1 node and then merge back //
MrgSortRecur:
   // Store lr and one reg spare others until basis not met //
   push {r7}
   push {lr}
   cmp N, #1
   beq Basis
   // if basis not met then store rest of regs //
   push {r4}
   push {r5}
   push {r6}    
   
   movs N_S, N        // store N into r6 as temp
   lsrs N_L, N_L, #1  // N_L = N / 2
   subs N_R, N_S, N_L // N_R = N - N_L
   // Parameter setup for Left side recursion
   // ub = r0, gNxt = r1, gI = r2, UB_rem = r3, N_L = r4
   bl MrgSortRecur    // break up left side
   // Parameter setup for Right side recursion
   movs ub_save, ub   // save ub temporary
   movs ub, UB_rem    // move UB as the ub parameter for right side
   movs N , N_R       // move N_R as N parameter
   // UB = r0, gNxt = r1, gI = r2, UB_rem = r3, N_R = r4
   bl MrgSortRecur    // breakup right side
   // Paremeter setup for Merge Chains
   //movs rb, UB_rem
   movs rb, r3        // hold UB
   movs r3, r2        // move gI to proper spot
   movs r2, r1        // move gNxt to proper spot
   movs r1, r0        // set right side
   movs ub, ub_save   // set left side
   // Parameters r0 = ub, r1 = rb, r2 = gNxt, r3 = gI
   bl MergeChains
   // restore 
   movs r1, r2  //  restore gNxt to proper spot 
   movs r2, r3  //  restore gI to proper spot
   movs r3, rb  //  restore rb
   // restore used registers
   pop {r6} 
   pop {r5}
   pop {r4}
   // restore lr by pop lower then move to lr
   pop {r7}
   mov lr, r7
   pop {r7}
   bx lr

// basis case where N == 1
Basis:
   ldr UB_rem, [ub, gNxt] // load UB to ub->next
   movs N, #0             // set N to 0
   str N , [ub, gNxt]     // store ub->next to 0 (cut list up)
   // restore lr and r7
   pop {r7}              
   mov lr, r7
   pop {r7}
   bx lr 
