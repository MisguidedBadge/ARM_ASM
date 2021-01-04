// INPUT/OUTPUT //
#define bp r0        // Start of list/min node
#define minPrev r1   // node previous to min node / optional output
#define nextgap r2   // byte offset to node tail
#define igap    r3   // byte offset to integer
// local var
#define prev    r4   // previous node (behind min)
#define min     r5   // minimum node 
#define cur     r6   // current nod (traversal node)
#define trail   r7   // trailing node behind current (potential prev)
#define prev_in r8   // the min integer thus far (in min)
#define cur_in  r9   // potential min integer (in cur)

.text 
.arm
.local EarlyExit //, finish
.globl findIntMinNode

// find the node with the minimum integer (if valid)//
findIntMinNode:
   // Initial check //
   cmp bp, #0           // check if this is an empty/invalid list
   beq EarlyExit        // if so then exit 
   // initial setup //
   stmDB SP!, {r4-r9}   // save regs on stack
   mov cur, bp          // set current at start
   mov prev, #0         // set prev to null since there isn't one yet
   // redundant at first but allows us to have a relative minimum //
   ldr cur_in, [cur, igap]   // load in and initialize current's integer 
   mov prev_in, cur_in       // initialize previous also
   mov trail, #0             // set the trail to null since it's at start

/*  // easiest representation since cur isn't null at first //
    while(cur != null) { 
    cur_in = cur->integer; 
    if(cur_in <= prev_in)
    { prev_in = cur_in; prev = trail; min = cur;}
    trail = cur; cur = cur->next; 
*/
   trav_loop:
      // integer load
      ldr cur_in, [cur, igap]   // load integer in current structure
      // int val compare //
      cmp cur_in, prev_in       // compare min int and current int
      movle prev_in, cur_in     // So far min val found 
      movle prev, trail         // The previous node behind min
      movle min, cur            // minimum node changed
      // traverse node //
      mov trail, cur            // increment trailing node to current
      ldr cur, [cur, nextgap]   // current node increments forward
      cmp cur, #0               // test if at end of list
      bne trav_loop             // if not end then continue searching     
 
//   finish: finish list traversal //
   cmp minPrev, #0         // see if minPrev is null
   strNE prev, [minPrev]   // if minPrev isn't null then store 
   mov r0, min             // set the min node to return
   ldmIA SP!, {r4-r9}      // load registers back before exiting

   bx LR                   // exit routine
// Leave routine early if bp is null
   EarlyExit:
      cmp minPrev, #0      // if minPrev already null then don't touch
      strNE bp, [minPrev]  // if minPrev isn't null then store null to it
      bx LR                // exit routine
