// Input/Output //
#define lb   r0     // left node
#define rb   r1     // right node
#define gnxt r2     // offset to next node
#define gi   r3     // offset to integer
// vars //
#define merg_l r4 // new list node index
#define int_l  r5 // left integer
#define int_r  r6 // right integer
#define t_node r7 // transition node (pluck from lb/rb and attach to list)
// reuse registers to keep them at 8 //
#define zer_reg r5  // zero register for thumb compare
#define chck_nod r6 // node to check if null
/*
         r0              r0          r1         r2        r3
     void * mrgChains(void *lb, void *rb, uint gNxt, uint gI);
*/
.text
.thumb
.local mrgLoop, cleanup
.globl mrgChains
.syntax unified
// Merge two sorted lists into a single list from lest to greatest //
mrgChains:
   // Assumption that lb and rb are
   // already sorted and not null //

   // initial setup //
   stmDB SP!, {r4-r7}      // Store registers used
   
   // get the first node //
   ldr int_l, [lb, gi]    // load left node integer
   ldr int_r, [rb, gi]    // load right node register
   cmp int_l, int_r       // compare left int and right int
   // obtain our starter node
   // LEFT SIDE is smaller
      ittt le              // 3 predicated instructions
      movle merg_l, lb     // starter is left node
      ldrle lb, [lb, gnxt] // increment left node
      movle chck_nod, lb   // check lb node if null now
   // RIGHT SIDE is smaller
      ittt gt              // 3 predicated instructions
      movgt merg_l, rb     // starter is right node
      ldrgt rb, [rb, gnxt] // increment right node
      movgt chck_nod, rb   // check rb node if null now
   stm SP!, {merg_l}       // store the start onto the stack (save spot)
   mov zer_reg, #0         // move 0 into register to use in compare
   cmp chck_nod, zer_reg   // see if the node is singular
   // if one side is just one then go to cleanup //
   beq cleanup

   mrgLoop:   
      // see if left or right is lesser //
      ldr int_l, [lb, gi]         // load left integer to compare
      ldr int_r, [rb, gi]         // load right integer to compare
      // LEFT
      cmp int_l, int_r            // if( left <= right)
         ittt le                  // 3 predicated instructions (<= right)
         movle t_node, lb         // transfer node is set to left
         ldrle lb, [lb, gnxt]     // increment left node 
         movle chck_nod, lb       // check the left node if null
      // RIGHT
         ittt gt                  // 3 predicated instructions (> right)
         movgt t_node, rb         // set transfer node to left
         ldrgt rb, [rb, gnxt]     // increment right node
         movgt chck_nod, rb       // check the right node if null
      
      str t_node, [merg_l, gnxt]  // store transfer to the next of current
      mov merg_l, t_node          // increment the current node to transfer
      mov zer_reg, #0             // move 0 into temp unused reg for cmp
      cmp chck_nod, zer_reg       // see if the left or right node is null

      bne mrgLoop                 // if node isn't null then loop back

// Check which node is null and attach it //
cleanup:
   // condition code set to know null
   // recheck condition to know which
   cmp lb, zer_reg               // see if left node is null
      it eq                      // 1 predicated inst ( == NULL)
      streq rb, [merg_l, gnxt]   // attach the rest of the right
   cmp rb, zer_reg               // see if right node is null
      it eq                      // 1 predicated inst ( == NULL)
      streq lb, [merg_l, gnxt]   // attach the rest of left

   // reset registers back //
   ldmia SP!, {r0}               // reload start of new list
   ldmia SP!, {r4-r7}            // reload registers used

   bx lr                         // exit routine
