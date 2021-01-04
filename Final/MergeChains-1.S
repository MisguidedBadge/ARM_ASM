// Input/Output //
#define lb   r0     // left node
#define rb   r1     // right node
#define gnxt r2     // offset to next node
#define gi   r3     // offset to integer
// vars //
#define merg_l r4   // new list node index
#define int_l  r5   // left integer
#define int_r  r6   // right integer
#define t_node r7   // last node of transition list (attach tchain to it)
#define t_iter r8   // iterates through nodes if theres a chain
#define t_chain r9  // holds the beginning of the chain to be stored
#define N_L    r10  // Number in left chain
#define N_R    r11  // Number in right chain 

/*          nodes sorted: n0, n1, n2, ... n_k
            n_0         end of merg   start of chain
          merg_l -> .. -> t_node -> t_iter -> lb or rb 
 */

//
/*
         r0              r0          r1         r2        r3
     void * mrgChains(void *lb, void *rb, uint gNxt, uint gI,
         r 10     r 11
      int N_L, int N_R);
*/
.text
.arm
.local mrgLoop, cleanup, RIGHT_I, RIGHT_L, RIGHT_START, LEFT_L, LEFT_START
.local loop_clean
.globl MergeChains
// Merge two sorted lists into a single list from lest to greatest //
MergeChains:
   // Assumption that lb and rb are
   // already sorted and not null //
   // initial setup //
   // store registers to prevent clobber //
   stmDB SP!, {r4-r11, lr}
   // get the first node //
   ldr int_l, [lb, gi]    // load left node integer
   ldr int_r, [rb, gi]    // load right node integer
   pld [lb, gnxt]         // preload next node  
   pld [rb, gnxt]         // preload next node
   // have to make seperate because we want to deal with == case
   // if (int_l <= int_r)       // 
   cmp int_l, int_r           // if (int_l <= int_r)
   bgt RIGHT_I                // if itn_l > int_r then int_r smaller 

//LEFT_I:
   mov merg_l, lb        // set beg new list to lb
   mov t_node, merg_l    // set transfer node to beg of new list
   ldr lb, [merg_l, gnxt] // let lb = lb->next
   //pld [lb, gnxt]   // preload was slower dont use
   subs N_L, N_L, #1      // decrement left counter and see if 0
   bne mrgLoop            // go to mergloop if lb has moer nodes
   beq cleanup            // go to cleanup else go to merg loop

RIGHT_I:
   mov merg_l, rb        // set beginning to list to rb
   mov t_node, merg_l    // set transfer node to beginning of newe list
   ldr rb, [merg_l, gnxt] // have rb = rb->next
   //pld [rb, gnxt]
   subs N_R, N_R, #1      // decrement right counter and see if 0
   beq cleanup            // if rb == 0 then cleanup


   /* loop that:
      - loads lb and rb's integer values 
      - check if(lb <= rb) or (rb < lb)
      - merg_l-> next = lb or rb, merg_l = merg_l->next
      - if(lb == NULL or rb == NULL) exit and attach last half
      - else rb = rb->next or lb = lb->next (depending on what's 0)
      - 
   */
   mrgLoop:   
      // see if left or right is lesser //
      // gi = r3
      // gnxt = r2 
      ldr int_l, [lb, gi]         // load left integer to compare
      ldr int_r, [rb, gi]         // load right integer to compare
      //pld [lb, gnxt]            // preloads here were slower
      //pld [rb, gnxt]
      cmp int_l, int_r            // if int_l <= int_r
      bgt RIGHT_START             // if int_l <= int_ go to left_L
      // This determines what side to start on

      // left chain
      LEFT_START:
         mov t_chain, lb            // set start of left chain at lb
      // left chain loop
      LEFT_L:
         mov t_iter, lb             // start iterator at start of list
         ldr lb, [lb, gnxt]         // iterate lb 
         // pld [lb, gi]            // does worse if used
         pld [lb, gnxt]             // preload next lb
         subs N_L, N_L, #1          // subtract from coutner and check
         beq loop_clean             // if 0 then go to cleanup
         ldr int_l, [lb, gi]        // else check left < right
         cmp int_l, int_r           // left < right
         ble LEFT_L                 // true then keep going through chain
      // LEFT_LSTOP:
         str t_chain, [t_node, gnxt]  // else stop by attaching chain 
         mov t_node, t_iter           // end of list now end of chain
      // right chain
      RIGHT_START:
         mov t_chain, rb            // set start of right chain at rb
      // right chain loop
      RIGHT_L:
         mov t_iter, rb             // start iterator at start of list
         ldr rb, [rb, gnxt]        // iterate rb
         // pld [rb, gi]           // does worse if used
         pld [rb, gnxt]            // preload rb next
         subs N_R, N_R, #1         // subtract counter
         beq loop_clean            // check if counter 0
         ldr int_r, [rb, gi]       // if not then load right int
         cmp int_r , int_l         // if right < left
         ble RIGHT_L               // keep going through chain
      // RIGHT_STOP:
         str t_chain, [t_node, gnxt]  // else stop by attaching chain
         mov t_node, t_iter        // end of list now end of chain
         bl LEFT_START             // since left > right go to left chain
      

// Cleanup area //
// merg_l has the last node of the new list thus far //
// attach remaining rb or lb onto the new list merg_l //
loop_clean:
   str t_chain, [t_node, gnxt]
   mov t_node, t_iter

cleanup:
   orr lb, rb              // one of them is 0 so make sure it's in lb
   str lb, [t_node, gnxt]   // store the remaining on the tail of the new list
   mov r0, merg_l          // put beginning of list as return

   ldmIA SP!, {r4-r11, lr}
   bx lr               // exit routine
