// Input/Output //
#define lb   r0     // left node
#define rb   r1     // right node
#define gnxt r2     // offset to next node
#define gi   r3     // offset to integer
// var //
#define merg_l r4 // new list last node index
#define int_l  r5 // left integer
#define int_r  r6 // right integer
#define t_node r7 // transition node (pluck from lb/rb and attach to list)
// reused reg //
#define merg_s r7 // new list node start
.text
.arm
.local mrgLoop, cleanup
.globl mrgChains

mrgChains:
   // Assumption that lb and rb are
   // already sorted //

   // initial setup //
   stmDB SP!, {r4-r7}    // store reg on stack to prevent clobber
   
   // get the first node //
   ldr int_l, [lb, gi]   // load left integer
   ldr int_r, [rb, gi]   // load right integer
   cmp int_l, int_r      // compare integer to see what is greater or lesser
   // obtain our starter node
   // LEFT SIDE
   movle merg_l, lb      // new list is lb if lb lesser
   ldrle lb, [lb, gnxt]  // load next node of new list
   // RIGHT SIDE
   movgt merg_l, rb      // new list is rb if rb lesser
   ldrgt rb, [rb, gnxt]  // load next node if rb greater

   mov merg_s, merg_l    // get our starter node
   str merg_s, [SP, #-4]! // store starter node on stack
   cmple lb, #0   // is lb null now?
   cmpgt rb, #0   // is rb null now?
   beq cleanup    // if not null go to loop
   /*
        while(rb != 0 && lb != 0)
       {
          int_l = lb->gi; int_r = rb->gi;
          if(int_l <= int_r) { t_node = lb; lb = lb->next;}
          else{ t_node = rb; rb = rb->next;}
   */ 
   mrgLoop:   
      // see if left or right is lesser //
      ldr int_l, [lb, gi]  // int_l = lb->gi 
      ldr int_r, [rb, gi]  // int_r = rb->gi
      cmp int_l, int_r     // if left <= right
      // LEFT
      movle t_node, lb     // transfer node = left node
      ldrle lb, [lb, gnxt] // left = left->next
      // RIGHT
      movgt t_node, rb     // transfer node = right node
      ldrgt rb, [rb, gnxt] // right = right->next

      str t_node, [merg_l, gnxt] // merg_l->next = t_node
      mov merg_l, t_node // increment merg_l to be last
      cmple lb, #0 // see if lb == 0
      cmpgt rb, #0   // see if rb == 0
      bne mrgLoop
      // if it is then go to cleanup

// handles the rest of lb or rb when either are 0 //
cleanup:
   // condition code set to know null
   // recheck condition to know which
   orr lb, rb   // either one is zero so make sure lb holds the remainder
   str lb, [merg_l, gnxt] // tack on remaining list to the tail of current
   
   // reset registers back //
   ldr r0, [SP], #4        // get the starting node from stack
   ldmia SP!, {r4-r7}      // restore stack and registers

   bx lr   // exit routine
