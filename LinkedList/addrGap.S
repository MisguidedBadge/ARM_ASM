#define a0 r0    // first node address
#define a1 r1    // second node address
/*
        r0                r0        r1
   unsigned long addrGap(void *a0, void *a1)

*/

.text
.arm
.globl addrGap

addrGap:
   // determine what order to subtract to keep distance positive
   CMP a0, a1        // see if a0 is greater than a1
   SUBGE a0, a0, a1  // if a0 >= a1 -> a0 = a0 - a1
   SUBLT a0, a1, a0  // else it's lesser thus a0 = a1 - a0
   bx LR             // exit routine
