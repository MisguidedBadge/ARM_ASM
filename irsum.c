


int irsum(int N, int *pX)
{
    int *pX_right;
    int Left_N, Right_N;
    int Left_sum, Right_sum, sum;
    // handle less than 1 element
    if(N <= 0)
        return 0;

    // handle condtion for 1 element
    if(N == 1)
        return *pX;

    // Lower half
    Left_N = N/2;
    // upper half doing division with roundup if odd
    Right_N = (N + 2 - 1)/2;
    printf(" Right Half %d : Left Half %d \n", Left_N, Right_N );
    // 
    pX_right = pX + Left_N;
    //
    Left_sum = irsum(Left_N, pX);
    //
    Right_sum = irsum(Right_N, pX_right);

    sum = Left_sum + Right_sum;
    printf("Sum %d \n", sum);
    return sum;

}