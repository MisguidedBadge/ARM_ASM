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
#define chck_nod r5 // node to check if null and next node for lb or rb
#define cond1  r2   // condition 1 used for bit level prediction 
#define cond2  r3   // condition 2 used for bit level prediction
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
   // store registers to prevent clobber //
   push {r4}               
   push {r5}              
   push {r6}
   push {r7}
   // get the first node //
   ldr int_l, [lb, gi]    // load left node integer
   ldr int_r, [rb, gi]    // load right node integer
   push {gnxt}            // store gnxt to reuse reg
   push {gi}              // store gi to reuse reg
   eors merg_l, merg_l        // start 0 and chose lb or rb
   // have to make seperate because we want to deal with == case
   // if (left <= right)       // 
   adds int_r, #1              // add one to allow ==
   subs cond1, int_l, int_r    // if int_l <= int_r then MSB = 1
   asrs cond1, cond1, #31      // all 1s or all 0s based on MSB
   ands cond1, lb              // and with lb if lb is lesser
   adds merg_l, cond1          // add lb to merg_l if true
   eors lb, cond1              // if lb is lesser then erase it (replace)
   // if (right < left)        // if right > left (MSB = 0)
   subs int_r, #1              // subtract int_r prevent ==
   subs cond1, int_r, int_l    // if right < left (MSB = 1)
   asrs cond1, cond1, #31      // all 1s or all 0s based on MSB
   ands cond1, rb              // and with rb if rb is lesser
   adds merg_l, cond1          // add rb to merg_l if true
   eors  rb, cond1             // if rb is lesser then 0 

   // At this point cond1 or cond2 is 0
   // rb or lb is 0
   // merg_l has the current node 
   // My old way of pop then pushing (slower)
   //pop {gi}                    // restore gi
   //pop {gnxt}                  // restore gnxt
   ldr gnxt, [SP, #4]            // load next offset on stack
   push {merg_l}                 // store merg_l (start of new list)
   // gnxt    +8
   // gi      +4
   // merg_l  <-- SP
   ldr chck_nod, [merg_l, gnxt]
   // check if lb or rb is zero
   // chck_nod has the next node
   // if lb == 0 --> !(lb > 0 || 0 > lb)
   movs cond1, #0          // set the 0 val
   subs cond2, cond1, lb   // neg iff 0 > lb
   subs cond1, lb, cond1   // neg iff lb > 0
   orrs cond1, cond2       // neg iff (0 > lb || lb > 0)
   mvns cond1, cond1       // neg iff (lb == 0)
   asrs cond1, cond1, #31  // if true set all bits
   ands cond1, chck_nod    // if true then cond1 = next node
   adds lb, cond1          // lb = next nod if true or lb doesn't change
   //  check rb
   // if rb == 0 --> !(rb > 0 || 0 > rb)
   movs cond1, #0          // set the 0 val
   subs cond2, cond1, rb   // neg iff 0 > rb
   subs cond1, rb, cond1   // neg iff rb > 0
   orrs cond1, cond2       // neg iff (0 > rb || rb > 0)
   mvns cond1, cond1       // neg iff (rb == 0)
   asrs cond1, cond1, #31  // if true set all its
   ands cond1, chck_nod    // if true con1 = next node
   adds rb, cond1          // rb = next node if true else lb doesn't change

   // check if the next node is null
   cmp chck_nod, #0        
   // if null then tag the other side on the tail and exit
   beq cleanup

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
      ldr gi, [SP, #4]            // load integer var from stack
      ldr int_l, [lb, gi]         // load left integer to compare
      ldr int_r, [rb, gi]         // load right integer to compare
      //push {gi}                   // store gi to reuse reg
      //push {gnxt}                 // store gnxt to reuse reg
      eors t_node, t_node           // init transfer node to 0
      // LEFT
      // if (left <= right)
      adds int_r, #1              // add 1 to account for ==
      subs cond1, int_l, int_r    // if int_l <= int_r then MSB = 1
      asrs cond1, cond1, #31      // all 1s or all 0s based on MSB
      ands cond1, lb              // and with lb if lb is lesser
      adds t_node, cond1          // transfer node is lb if true
      eors lb, cond1              // 0 out lb if true to add next node later
      // RIGHT
      // if (right < left)
      subs int_r, #1              // remove 1 to prevent ==
      subs cond1, int_r, int_l    // if rb < lb MSB = 1
      asrs cond1, cond1, #31      // all 1s or all 0s based on MSB
      ands cond1, rb              // and with rb if rb is lesser
      adds t_node, cond1          // transfer node is rb if true
      eors rb, cond1              // 0 out lb if true to add next node later
 
      ldr gnxt, [SP, #8]          // load the next node from stack
      str t_node, [merg_l, gnxt]  // store lb or rb on new_list->next
      movs merg_l, t_node         // new_list = new_list->next
      ldr chck_nod, [t_node, gnxt] // load lb->next or rb->next

      // check if lb or rb is zero (if zero get next node)
      // if(lb == 0) --> !(lb > 0 || 0 > lb)
      movs cond1, #0          // set the 0 val
      subs cond2, cond1, lb   // neg iff 0 > lb
      subs cond1, lb, cond1   // neg iff lb > 0
      orrs cond1, cond2       // neg iff (0 > lb || lb > 0)
      mvns cond1, cond1       // neg iff (lb == 0)
      asrs cond1, cond1, #31  // if true set all bits
      ands cond1, chck_nod    // if true then cond1 = next node
      adds lb, cond1          // lb = next node if true or lb doesn't change
      // if (rb == 0) --> !(rb > 0 || 0 > lb)
      movs cond1, #0          // set the 0 val 
      subs cond2, cond1, rb   // neg iff 0 > rb
      subs cond1, rb, cond1   // neg iff rb > 0
      orrs cond1, cond2       // neg iff (0 > rb || rb > 0)
      mvns cond1, cond1       // neg iff (rb == 0)
      asrs cond1, cond1, #31  // if true set all bits
      ands cond1, chck_nod    // if true then cond1 = next node
      adds rb, cond1          // rb = next node if true or rb doesn't change

      cmp chck_nod, #0    // check if the next node is 0
      bne mrgLoop         // if the next node isn't null then keep going

// Cleanup area //
// merg_l has the last node of the new list thus far //
// attach remaining rb or lb onto the new list merg_l //
cleanup:
   //   pop {gnxt}
   //   pop {gi}
   ldr gnxt, [SP, #8]    // load the next node offset
   orrs lb, rb           // one of them is 0 so make sure it's in lb
   str lb, [merg_l, gnxt] // store the remaining on the tail of the new list
   pop {r0}    // get return value (start of the new list)
   pop {r1}    // restore stack
   pop {r1}    // restore stack
   // restore registers used and stack //
   pop {r7}
   pop {r6}
   pop {r5}
   pop {r4}
   bx lr                         // exit routine
