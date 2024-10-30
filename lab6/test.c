// linear_algebra.c
// Christian Johnson, 10/10/24, chrjohnson@hmc.edu

#include <stdlib.h> // for malloc
#include <stdio.h>

// Prototypes

double dotproduct(int n, double a[], double b[]);

void add(int m, int n, double *A, double *B, double *Y); // Y=A+B

void linearcomb(int m, int n, double sa, double sb, double *A, double *B, double *Y); // Y=sa*A + sb*B

void transpose(int m, int n, double *A, double *A_t); // A_t = transpose(A)

int equal(int m, int n, double *A, double *B); // returns 1 if equal, 0 if not

void mult(int m1, int n1m2, int n2, double *A, double *B, double *Y); //Y=A*B

double *newMatrix(int m, int n);

double *newIdentityMatrix(int n);

int main(void)
{
    double v1[3] = {4, 2, 1};                   // 1x3 vector
    double v2[3] = {1, -2, 3};                  // 1x3 vector
    double dp = dotproduct(3, v1, v2);          // compute v1 dot v2
    double m1[9] = {0, 0, 2, 0, 0, 0, 2, 0, 0}; // 3x3 matrix
    double *m2 = newIdentityMatrix(3);          // 3x3 identity matrix
    double *m3 = newMatrix(3, 3);               // 3x3 matrix
    double m4[6] = {2, 3, 4, 5, 6, 7};          // 3x2 matrix
    double *m5 = newMatrix(3, 2);               // 3x2 matrix
    double m6[6] = {6, 2, 5, 8, 2, 7};          // 2x3 matrix
    double *m7 = newMatrix(3, 2);               // 3x2 matrix
    double *m8 = newMatrix(3, 2);               // 3x2 matrix
    double expected[6] = {2, 1, 0, 1, 0, -1};   // expected result matrix
    int eq;

    add(3, 3, m1, m2, m3);                   // m3 = m1 + m2
    mult(3, 3, 2, m3, m4, m5);               // m5 = m3*m3 (3x2 result matrix)
    transpose(2, 3, m6, m7);                 // m7 = m6^t
    linearcomb(3, 2, 1, 1 - dp, m5, m7, m8); // m8= 1*m5 + (1-dp)*m7
    eq = equal(3, 2, m8, expected);          // check if m8 is as expected
    return eq;                               // return 1 if so; 0 otherwise
}

// Deliverable functions

void add(int m, int n, double *A, double *B, double *Y)
{
    int i;
    int j;

    // iterate through m rows and n columns
    for (i = 0; i < m; i++)
    {
        for (j = 0; j < n; j++)
        {
            // Sets Y equal to the sum of A and B for the current index
            Y[j + i * n] = A[j + i * n] + B[j + i * n];
        }
    }
    printf("%f",*Y);

}

void transpose(int m, int n, double *A, double *A_t)
{
    int i;
    int j;

    // iterate through m rows and n columns
    for (i = 0; i < m; i++)
    {
        for (j = 0; j < n; j++)
        {
            // Sets A_t[i][j] = A[j][i] for the current index
            A_t[i + j*m] = A[j + i * n];
        }
    }
}

int equal(int m, int n, double *A, double *B)
{
    int i;
    int j;

    // iterate through m rows and n columns
    for (i = 0; i < m; i++)
    {
        for (j = 0; j < n; j++)
        {
            // Checks if A[i][j] != B[i][j] for the current index
            if (A[j + i*n] != B[j + i*n])
            {
                return 0;
            }
        }
    }
    return 1; 
}


/*
The last function multiplies an m1 x n1m2 matrix A by an n1m2 x n2 matrix B to
produce an m1 x n2 matrix Y . Y should already be allocated and the contents will be
overwritten.
*/
void mult(int m1, int n1m2, int n2, double *A, double *B, double *Y)
{
    int i;
    int j;


    // iterate though m rows and n columns
    for (i = 0; i < m1; i++)
    {
        for (j = 0; j < n2; j++)
        {
            // Calculate the dot product between the i-th row of A and j-th column of B
            for (int k = 0; k < n1m2; k++)
            {
                Y[j + i * n2] += A[i * n1m2 + k] * B[k * n2 + j];
            }
        }
    }
}

// Y=sa*A + sb*B
void linearcomb(int m, int n, double sa, double sb, double *A, double *B, double *Y)
{
    int i;
    int j;

    // iterate though m rows and n columns
    for (i = 0; i < m; i++)
    {
        for (j = 0; j < n; j++)
        {
            // The sum of a given index of Y is the sum of sa*A[i][j] + sb*A[i][j]
            Y[j + i*n] = sa * A[j + i*n] + sb * B[j + i*n];
        }
    }    
}

double dotproduct(int n, double a[], double b[])
{
    volatile int i;
    double sum = 0;
    for (i = 0; i < n; i++)
    {
        if (i == 0)
            sum = 0;
        sum += a[i] * b[i];
    }
    return sum;
}

double *newMatrix(int m, int n)
{
    double *mat;
    mat = (double *)malloc(m * n * sizeof(double));
    return mat;
}

double *newIdentityMatrix(int n)
{
    double *mat = newMatrix(n, n);
    int i, j;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++)
        {
            mat[j + i * n] = (i == j);
        }
    return mat;
}
