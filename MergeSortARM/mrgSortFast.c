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
   int left, right;
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
   left = lb->len;
   right = rb->len;
   new_list_s = new_list;
   while(1)
   {
      // if lb smaller than rb then assign lb to the next node of new list
      if(left < right)
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
     	 left = lb->len;
      }
      // vice versa for rb
      if(right <= left)
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
         right = rb->len;
      }
   }   
      return(NULL);  /* replace wt your implementation */
}

word_t *mrgSortFast     /* RETURNS: base of greatest-to-least ->len sorted list */
(                   /*          using merge sort, so O( N log2(N) )         */
   unsigned int N,  /* number of nodes in list ub */
   word_t *ub,      /* base ptr for N nodes, not necessarily NULL-terminated */
  // int gNxt,
  // int gI,
   //void *ML,      /* OUT: last node in merged list */
   word_t **UB      /* OUT: *UB set to address of n+1 node, which is unsorted */
)
/*
 * On entry ub is an unsorted list, which will be destroyed to produce sort.
 * NOTE: Input lists may not be NULL terminated, but output lists will be.
 * RETURNS: base ptr of list sorted by ->len.
 */
{
   int N_L;         // List lower count
   int N_U;         // List upper count
   void *rb;
   // basis case  where n == 1 //
   if(N == 1)
   {
      *UB = ub->next;   // set the address of n + 1 
      ub->next = NULL;  // cut off left from right
      return ub;        // return left side
   }
   // break list up and return sorted list
   else if (N > 1)
   {
      N_L = N >> 1;   // N_L = N / 2
      N_U = (N + 1) >> 1; // N_U = (N+1) / 2
      ub =  mrgSortFast(N_L, ub,  &rb); // call left side
      rb =  mrgSortFast(N_U, rb, UB);   // call for right side
      ub = mergeLists(N_L, N_U, ub, rb);  // merge both sorted lists
      return(ub);
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
   int length = 0;    // length of list
   word_t * point;    // temp pointer to traverse list right side
   word_t * point_s;  // temp poitner to traverse list left side
   // 0 length list check // (mostly for the entry ub to see if the user is fooling with use >_<)
   if(ub == NULL)
      return NULL;
   // 1 length list check to prevent breaking on that //
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
      // if the point is null then reached end and sorted//
      if(point == NULL)
      {
         printf("already sorted! \n");
         return(ub);
       }
   }
   // count the number of nodes in the list
   for(point = ub; point != NULL; point = point->next)
      { 
         length++;
      }
   // call the recursion function to sort list
   ub = mrgSortFast(length, ub, &ub);
   return(ub);  /* replace with your implementation */
}
