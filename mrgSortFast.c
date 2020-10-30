#include <stdlib.h>
#ifdef DEBUG
   #include <stdio.h>
   #include <assert.h>
#endif
#include "word.h"

word_t *mergeLists
(
   unsigned int nL, /* # of nodes in unsorted list lb (left base) */
   unsigned int nR, /* # of nodes in unsorted list rb (Right base) */
   word_t *lb,      /* address of left base node */
   word_t *rb       /* address of right base node */
) 
{
   // List pointers fro the new list
   word_t * new_list_s;     // start
   word_t * new_list;       // end

   // if left base is less than right then take that as the first list node
   // lb increments to it's next node
   if(lb->len < rb->len)
   {   new_list = lb;
       lb = lb->next;
       nL--; 
       // check if the end of lb list
       if(nL == 0)
         {
            new_list->next = rb;
            return(new_list);
         }
       }
   // vice versa for rb
   else
   {
      new_list = rb;
      rb = rb->next;
      nR--;
      if(nR == 0)
      {
         new_list->next = lb;
         return(new_list);
      }
   }
   // new list starting assigned
   new_list_s = new_list;
   while(1)
   {
      // if lb smaller than rb then assign lb to the next node of new list
      if(lb->len < rb->len)
      {
         new_list->next = lb;
         // increment new list
         new_list = new_list->next;
         // increment lb
         lb = lb->next;
         nL--;
         // assign the rest of the list to rb if lb is empty
         if(nL == 0)
           {
              new_list->next = rb;
              return(new_list_s);
           } 
      }
      // vice versa for rb
      if(rb->len <= lb->len)
      {
         new_list->next = rb;
         new_list = new_list->next;
         rb = rb->next;
         nR--;
         if(nR == 0)
         {
            new_list->next = lb;
            return(new_list_s);
         }
      }
   }   
      return(NULL);  /* replace wt your implementation */
}

word_t *mrgSortFast     /* RETURNS: base of greatest-to-least ->len sorted list */
(                   /*          using merge sort, so O( N log2(N) )         */
   unsigned int N,  /* number of nodes in list ub */
   word_t *ub,      /* base ptr for N nodes, not necessarily NULL-terminated */
   int gNxt,
   int gI,
  // void *ML,      /* OUT: last node in merged list */
   void *UB      /* OUT: *UB set to address of n+1 node, which is unsorted */
)
/*
 * On entry ub is an unsorted list, which will be destroyed to produce sort.
 * NOTE: Input lists may not be NULL terminated, but output lists will be.
 * RETURNS: base ptr of list sorted by ->len.
 */
{

   word_t *start;  // List start address of the list pointer
   word_t * half;   // Upper half pointer
   int N_L;         // List lower count
   int N_U;         // List upper count
   int i;


   if(N == 1)
   {
      int **pp = UB;
      *pp = *((int**)(((char*)(ub))+(gNxt)));
      *((int**)(((char*)(ub))+(gNxt))) = (int*)(NULL);
      return ub;
   }
   else if(N > 1)
   {

      N_L = N >> 1;
      N_U = (N + 1) >> 1;

      void *rb;
      ub =  mrgSortFast(N_L, ub, gNxt, gI, &rb);
      rb =  mrgSortFast(N_U, rb, gNxt, gI, UB);
      ub = mergeLists(N_L, N_U, ub, rb);
      return(rb);
   }
   return(NULL);

}

word_t *mrgSort(word_t *ub, int gNxt, int gI) /* required ABI, wraps recursive mrgSort */
/* 
 * NOTE: mrgSortFast is not recursive: the optimized mrgSort above handles
 *       the recursion while passing extra information (not of interest to 
 *       top level) in order to avoid redundant memory access.
 * RETURNS: address of base node of list sorted least-to-greatest on ->len.
 *          ub's nodes are used to create list, so unsorted list will be
 *          destroyed by sort.
 */
{

   // local variables
   int length = 0;
   word_t * point;
   word_t * point_s;
   //word_t * last;
   //word_t * 
   //int counter = 0;
   //int threshold = 1;



   // 0 length list check // (mostly for the entry ub to see if the user is fooling with use >_<)
   if(ub == NULL)
      return NULL;
   if(ub->next == NULL)
      return ub;
   // check if the list is already sorted
   // have a follower and leader to check values
   point = ub->next;
   point_s = ub;
   // loop until NULL. If it completes then the list is already sorted
   while(point_s->len <= point->len)
   {
      point = point->next;
      point_s = point_s->next;
      //printf("Exit \n");
      if(point == NULL)
      {
         printf("already sorted! \n");
         return(ub);
       }
         

   }

   for(point = ub; point != NULL; point = point->next)
      { 
         length++;
      }
  // allocate pointer list according to the length


   ub = mrgSortFast(length, ub, gNxt, gI, &ub);



   return(ub);  /* replace with your implementation */
}
