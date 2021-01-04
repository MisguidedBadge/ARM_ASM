// Input //
#define ub   r0   // start of unsorted list (relative)
#define gNxt r1   // byte offset to load next node
#define gI   r2   // byte offset to load int in node
#define UB_rem r3 // OUT remaining nodes unsorted
// Preserve on stack //
#define N    r4   // number of nodes in list (relative)
// Local Var //
#define N_L  r10  // N left side N >> 1
#define N_R  r11  // N right side N - N_L
#define N_S  r6  // saving for N
#define ub_save r6 // hold ub value
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
.arm
.local Basis
.globl MrgSortRecur, MergeChains

// Merge Sort Recursion // 
// split lists until 1 node and then merge back //
MrgSortRecur:
   // Store lr and one reg spare others until basis not met //
   stmDB SP!, {r4-r11, lr}
   cmp N, #1   // see if basis
   beq Basis   //
   
   mov N_L, N        // store N into r6 as temp
   lsr N_L, N_L, #1  // N_L = N / 2
   sub N_R, N, N_L // N_R = N - N_L
   mov N, N_L        // setup N parameter for left recure
   // Parameter setup for Left side recursion
   // ub = r0, gNxt = r1, gI = r2, UB_rem = r3, N_L = r4
   bl MrgSortRecur    // break up left side
   // Parameter setup for Right side recursion
   mov ub_save, ub   // save ub temporary
   mov ub, UB_rem    // move UB as the ub parameter for right side
   mov N , N_R       // move N_R as N parameter for right recur
   // UB = r0, gNxt = r1, gI = r2, UB_rem = r3, N_R = r4
   bl MrgSortRecur    // breakup right side
   // Paremeter setup for Merge Chains
   //movs rb, UB_rem
   //pld [r0, gI]           // yields worse than pairing right next to call
   //pld [ub_save, gI]
   mov rb, r3        // hold UB
   mov r3, r2        // move gI to proper spot
   mov r2, r1        // move gNxt to proper spot
   mov r1, r0        // set right side
   mov ub, ub_save   // set left side
   // Parameters r0 = ub, r1 = rb, r2 = gNxt, r3 = gI, r10 = N_L, r11 = N_R
   pld [ub, gI]      // preload cache with integers before entering
   pld [rb, gI]
   bl MergeChains
   // restore 
   mov r1, r2  //  restore gNxt to proper spot 
   mov r2, r3  //  restore gI to proper spot
   mov r3, rb  //  restore rb
   // restore used registers
   ldmIA SP!, {r4-r11, lr}
   bx lr

// basis case where N == 1
Basis:
   ldr UB_rem, [ub, gNxt] // load UB to ub->next
   mov N, #0             // set N to 0
   str N , [ub, gNxt]     // store ub->next to 0 (cut list up)
   // restore lr and r7
   ldmIA SP!, {r4-r11, lr}
   bx lr 
