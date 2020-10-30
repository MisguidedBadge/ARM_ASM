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
.local mrgLoop, cleanup, RIGHT_L, RIGHT
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
   bgt RIGHT             // if greater than branch to right side eval
   // obtain our starter node
   // use branches because they're faster
   // LEFT SIDE
   // LEFT:
      mov merg_l, lb      // new list is lb if lb lesser
      ldr lb, [lb, gnxt]  // load next node of new list
      mov merg_s, merg_l    // store lb in starting list
      str merg_s, [SP,#-4]! // store the starting list on stack
      cmp lb, #0            // see if lb == 0
      bne mrgLoop           // if it isn't go to loop
      beq  cleanup          // if it is attach rb to the tail
   // RIGHT SIDE
   RIGHT:
      mov merg_l, rb      // new list is rb if rb lesser
      ldr rb, [rb, gnxt]  // load next node if rb greater
      mov merg_s, merg_l  // store rb in starting list
      str merg_s, [SP,#-4]!  // store starting list on stack
      cmp rb, #0   // see if rb == 0
      beq cleanup  // if rb is 0 then attach lb to the tail
      // else go to the loop
      
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
      bgt RIGHT_L          // if greater than go the right loop eval
      // LEFT
      //LEFT_L:
         mov t_node, lb     // transfer node = left node
         ldr lb, [lb, gnxt] // left = left->next
         str t_node, [merg_l, gnxt]  // merg_l->next = t_node
         mov merg_l, t_node // increment merg_l to be last
         cmp lb, #0    // see if lb is null after increment
         bne mrgLoop   // if it isn't keep looping
         beq cleanup   // if it is attach rb to tail
      // RIGHT
      RIGHT_L:
         mov t_node, rb     // transfer node = right node
         ldr rb, [rb, gnxt] // right = right->next
         str t_node, [merg_l, gnxt] // merg_l->next = t_node
         mov merg_l, t_node // increment merg_l to be last
         cmp rb, #0   // see if rb == 0
         bne mrgLoop  // if it isn't keep looping
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
