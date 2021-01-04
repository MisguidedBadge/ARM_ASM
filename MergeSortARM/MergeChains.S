// Input/Output //
#define lb   r0     // left node
#define rb   r1     // right node
#define gnxt r2     // offset to next node
#define gi   r3     // offset to integer
// vars //
#define merg_l r4   // new list node index
#define int_l  r5   // left integer
#define int_r  r6   // right integer
#define t_node r7   // transition node (pluck from lb/rb and attach to list)
// reuse registers to keep them at 8 //
/*
         r0              r0          r1         r2        r3
     void * mrgChains(void *lb, void *rb, uint gNxt, uint gI);
*/
.text
.thumb
.local mrgLoop, cleanup, RIGHT_I, RIGHT_L
.globl MergeChains
.syntax unified
// Merge two sorted lists into a single list from lest to greatest //
MergeChains:
   // Assumption that lb and rb are
   // already sorted and not null //
   // initial setup //
   // store registers to prevent clobber //
   push {r4}               
   push {r5}              
   push {r6}
   push {r7}
   push {lr}
   // get the first node //
   ldr int_l, [lb, gi]    // load left node integer
   ldr int_r, [rb, gi]    // load right node integer
   // have to make seperate because we want to deal with == case
   // if (int_l <= int_r)       // 
   cmp int_l, int_r           // if (int_l <= int_r)
   bgt RIGHT_I                // if itn_l > int_r then int_r smaller 

//LEFT_I:
   movs merg_l, lb        // set beg new list to lb
   movs t_node, merg_l    // set transfer node to beg of new list
   ldr lb, [merg_l, gnxt] // let lb = lb->next
   cmp lb, #0             // if lb == 0
   bne mrgLoop            // go to mergloop if lb has moer nodes
   beq cleanup            // go to cleanup else go to merg loop

RIGHT_I:
   movs merg_l, rb        // set beginning to list to rb
   movs t_node, merg_l    // set transfer node to beginning of newe list
   ldr rb, [merg_l, gnxt] // have rb = rb->next
   cmp rb, #0             // if rb == 0
   beq cleanup            // if rb == 0 then cleanup


   /* loop that:
      - loads lb and rb's integer values 
      - check if(lb <= rb) or (rb < lb)
      - merg_l-> next = lb or rb, merg_l = merg_l->next
      - if(lb == NULL or rb == NULL) exit and attach last half
      - else rb = rb->next or lb = lb->next (depending on what's 0)
   */
   mrgLoop:   
      // see if left or right is lesser //
      // gi = r3
      // gnxt = r2 
      ldr int_l, [lb, gi]         // load left integer to compare
      ldr int_r, [rb, gi]         // load right integer to compare
      cmp int_l, int_r            // if int_l <= int_r
      bgt RIGHT_L                  // if int_l <= int_ go to left_L

// LEFT_L
      str lb, [t_node, gnxt]      // t_node->next = lb
      movs t_node, lb             // t_node = t_node->next
      ldr lb, [lb, gnxt]          // lb = lb->next
      cmp lb, #0                  // see if lb = 0
      beq cleanup                 // if so then cleanup
      bne mrgLoop                 // else keep looping

   RIGHT_L:
      str rb, [t_node, gnxt]      // t_node->next = rb
      movs t_node, rb             // t_node = t_node->next
      ldr rb, [rb, gnxt]          // rb = rb->next
      cmp rb, #0                  // see if rb = 0
      bne mrgLoop                 // if it isn't then keep looping
   // else cleanup
      

// Cleanup area //
// merg_l has the last node of the new list thus far //
// attach remaining rb or lb onto the new list merg_l //
cleanup:
   orrs lb, rb              // one of them is 0 so make sure it's in lb
   str lb, [t_node, gnxt]   // store the remaining on the tail of the new list
   movs r0, merg_l          // put beginning of list as return

   pop {r4}            // pop lr into r4
   mov lr, r4          // store r4 into lr
   pop {r7}            // restore saved registers
   pop {r6}
   pop {r5}
   pop {r4}
   bx lr               // exit routine
