#define i1 r0       // i1 var and part 1 return
#define i2 r1       // i2 var & part 3 string pointer & ASCII holder
#define i3 r2       // part 2 parameter & loop iterator
#define pi4 r3      // pointer to i4 used as param output
#define alp r12     // alphabet character pointer
#define i4  r4      // value of i4 and result i4=5*(*i4)+i3
#define FSZ 1*4     // saving r4
#define str_size 26 // length of alphabet string 26
#define SP r13      // Stack Pointer Register
/*
                  r0      r1      r2       r3        SP 
       int istr(int i1, int i2, int i3, int *i4, char *alp);

       Part1: Add i1 and i2
       char = 1 byte = 8 bits
           
*/

.text
.arm
.local BODY, LOOP1, DONE
.globl istr

istr:
   ldr alp, [SP]           // load alphabet pointer
   str r4, [SP, #-4]!      // store r4 on stack to prevent overwrite    


BODY:
   // Part 1
   add i1, i1, i2           // add i1 and i2 then return result i1
   // Part 2
   ldr i4,[pi4]             // i4 = *pi4 load value of pointer address
   add i4, i4, i4, LSL#2    // i4 = i4*5
   add i4, i4, i3           // add i3 and i4 and return with i4 result
   str i4, [pi4]            // store in pointer as output
   // Part 3
   MOV i2, #97              // asign the value of ASCII a to i2
   eor i3, i3, i3           // i3 = 0
   sub i3, i3, #str_size    // i3 = 0 - str_size
LOOP1: 
   strb i2,[alp], #1   // store the ascii value
   add i2, i2, #1      // increment i2 ASCII to go through alphabet
   adds i3, i3, #1     // increment N until zero
  bne LOOP1            // check if N is zero and exit

   MOV i2,#0           // assign NULL ascii 
   strb i2,[alp]       // assign null terminator to end of alp 
DONE:
   ldr r4, [SP], #4    // restore stack and r4
   bx lr               // exit
