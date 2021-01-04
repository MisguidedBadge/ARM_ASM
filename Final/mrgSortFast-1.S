// input //
#define ub   r0 // start of unsorted list input and sorted output
#define gNxt r1 // offset in bytes to next node
#define gI   r2 // offset in bytes to int in struct
// local var //
#define curr r3    // current node of unsorted list
#define cur_n r7   // next of current node (check if sorted)
#define count r4   // list length counter
#define int_l r5   // left node integer
#define int_r r6   // right node integer

/*
      r0               r0                   r1                  r2
   void *mrgSort(void *basep, unsigned long gNxt, unsigned long gI)
*/

.text
.arm
.local EXIT, Sort_Loop, Count_Loop
.globl mrgSort, MrgSortRecur

//  Sort unsorted list //
// Wrapper function to handle exit conditions and prep for recursion //
mrgSort:
   // Store regs that aren't saved
   stmDB SP!, {r4-r11, lr}
   // Deal with cases N = 0 and N = 1
   // N = 0 Case
   cmp ub, #0    // see if ub is null
   beq EXIT      // go to null list exit condition
   // N = 1 Case
   mov curr, ub         // see if ub->next is null
   ldr curr, [ub, gNxt]  // load in ub->next to see if null
   cmp curr, #0          // if it is then it is a single single sorted list
   beq EXIT              // KList is the exit branch for sorted list
   // prep for Sort_Loop
   mov curr, ub           // reset current node to ub (to check sort)
   mov cur_n, curr        // next node set to current node 
   ldr int_r, [cur_n, gI]  // load right integer value 

   mov count, #0 
   // Check if list already sorted
   Sort_Loop:
      add count, count, #1
      mov curr, cur_n   // increment current node forward
      mov int_l, int_r    // set left integer value and move right by 1 
      ldr cur_n, [cur_n, gNxt]   // load next node
      cmp cur_n, #0             // check if node is null
      beq EXIT                 // Return sorted list through KList exit
      ldr int_r, [cur_n, gI]    // load right integer value of next node
      cmp int_l, int_r          // see if left < right
      ble Sort_Loop             // if true keep going (list may be sorted)
      // if list not sorted keep counting
      Count_Loop:
         add count, count, #1      // increment counter
         ldr cur_n, [cur_n, gNxt]  // load next value
         cmp cur_n, #0             // see if null
         bne Count_Loop            // if null fall out else keep going
         
      
//Unsorted:
   mov curr, ub    // reset curr to start of list
   // Prep for mrgSortFast subroutine
   // routine is non-ABI compliant //
   // parameters ub, gNxt, gI, *UB, N --> r0, r1, r2, r3, r4
   // Don't care about any clobbered registers just want r0 to return output //
   bl MrgSortRecur  // call mrgsortfast recursive function
   // upon exit r0 has the sorted list
EXIT:
   // restore regsiters //   
   ldmIA SP!, {r4-r11, lr}
   // exit routine
   bx lr
