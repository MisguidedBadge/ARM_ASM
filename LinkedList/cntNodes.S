// Input //
#define bp     r0       // linked list starting node
#define gapNxt r1       // offset of bytes from beg 
// VARS //
#define count  r2       // counter
/*
    r0              r0                    r1
   int cntNodes(void *bp, unsigned long gapNxt)
*/

.text          
.arm
.local CntLoop, exit            
.globl cntNodes  
cntNodes:
   MOV count, #0     // initially set counter to 0
   /*
    while(1){
             if(bp == NULL)
             {return count} 
             else
             {count++; bp = bp + gapNxt; bp = *bp;}
   */
   CntLoop:
      cmp bp, #0            // if bp is null exit
      beq exit              // end of list

      add count, count, #1  // else increment list count
      add bp, bp, gapNxt    // add add byte offset to go to list tail
      ldr bp, [bp]          // load list tail (next node)
      b CntLoop             // loop back and continue
   // exit function when reach null //
   exit:
      MOV r0, count         // set return as count
      bx lr                 // exit function
