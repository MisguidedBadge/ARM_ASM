// input //
#define ub   r0 // start of unsorted list input and sorted output
#define gNxt r1 // offset in bytes to next node
#define gI   r2 // offset in bytes to int in struct
// local var //
#define curr r3    // current node of unsorted list
#define cur_n r4   // next of current node (check if sorted)
#define count r4   // list length counter
#define int_l r5   // left node integer
#define int_r r6   // right node integer

/*
      r0               r0                   r1                  r2
   void *mrgSort(void *basep, unsigned long gNxt, unsigned long gI)
*/

.text
.thumb
.local EXIT, Sort_Loop, Count_Loop
.globl mrgSort, MrgSortRecur
.syntax unified 
//  Sort unsorted list //
// Wrapper function to handle exit conditions and prep for recursion //
mrgSort:
   // Store regs that aren't saved
   push {r4}
   push {r5}
   push {r6}
   push {r7}
   push {lr}
   // Deal with cases N = 0 and N = 1
   // N = 0 Case
   cmp ub, #0    // see if ub is null
   beq EXIT      // go to null list exit condition
   // N = 1 Case
   movs curr, ub         // see if ub->next is null
   ldr curr, [ub, gNxt]  // load in ub->next to see if null
   cmp curr, #0          // if it is then it is a single single sorted list
   beq EXIT              // KList is the exit branch for sorted list
   // prep for Sort_Loop
   movs curr, ub           // reset current node to ub (to check sort)
   movs cur_n, curr        // next node set to current node 
   ldr int_r, [cur_n, gI]  // load right integer value 

   // Check if list already sorted
   Sort_Loop:
      movs curr, cur_n   // increment current node forward
      movs int_l, int_r    // set left integer value and move right by 1 
      ldr cur_n, [cur_n, gNxt]   // load next node
      cmp cur_n, #0             // check if node is null
      beq EXIT                 // Return sorted list through KList exit
      ldr int_r, [cur_n, gI]    // load right integer value of next node
      cmp int_l, int_r          // see if left < right
      ble Sort_Loop             // if true keep going (list may be sorted)
      
//Unsorted:
   movs curr, ub    // reset curr to start of list
   movs count, #0 
   Count_Loop:
      adds count, count, #1  // increment counter
      ldr curr, [curr, gNxt] // load next list node
      cmp curr, #0           // see if next list node is null
      bne Count_Loop         // if not keep counting
    
   // Prep for mrgSortFast subroutine
   // routine is non-ABI compliant //
   // parameters ub, gNxt, gI, *UB, N --> r0, r1, r2, r3, r4
   // Don't care about any clobbered registers just want r0 to return output //
   bl MrgSortRecur  // call mrgsortfast recursive function
   // upon exit r0 has the sorted list
EXIT:
   // restore regsiters //   
   pop {r4}   // lr restoration by pop to lower and mov into lr
   mov lr, r4
   pop {r7}
   pop {r6}
   pop {r5}
   pop {r4}
   // exit routine
   bx lr
