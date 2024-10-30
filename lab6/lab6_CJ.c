// lab6_CJ.c
// Christian Johnson, chrjohnson@hmc.edu, 10/14/24

#include <stdlib.h>    // for malloc

/*
  Function dotproduct accepts two arrays of containing type double and returns
  the sum of the product of each element at index i
*/
double dotproduct(int n, double a[], double b[]) {
  volatile int i;
  double sum = 0;
  for (i = 0; i < n; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}

/*
  Function add accepts the dimensions (m x n) and three pointers to type double.
  Y = A + B
*/
void add(int m, int n, double *A, double *B, double *Y) {
  int i, j;

  // iterate through m rows and n columns
  for (i = 0; i < m; i++) {
    for (j = 0; j < n; j++) {
      // Sets Y[i][j] = A[i][j] + B[i][j]
      Y[i * n + j] = A[i * n + j] + B[i * n + j];
    }
  }
}

/*
  Function linearcomb accepts the dimensions (m x n), two coefficients (sa and sb),
  and three pointers to type double.
  Y = sa*A + sb*B
*/
void linearcomb(int m, int n, double sa, double sb, double *A, double *B, double *Y) {
  int i, j;

  for (i = 0; i < m; i++) {
    for (j = 0; j < n; j++) {
      // Sets y[i][j] = sa*A[i][j] + sb*B[i][j]
      Y[i * n + j] = sa * A[i * n + j] + sb * B[i * n + j];
    }
  }
}

/*
  Function transpose takes the dimensions of matrix A, a pointer to matrix A and
  allocated space for the transpose of matrix A, A_t.
  A_t = A^{t}
*/
void transpose(int m, int n, double *A, double *A_t) {
  int i, j;

  // iterate through m rows and n columns
  for (i = 0; i < m; i++) {
    for (j = 0; j < n; j++) {
      // Sets A_t[i][j] = A[j][i]
      A_t[j * m + i] = A[i * n + j];
    }
  }
}

/*
  Function equal checks if each A[i][j] is equal to each B[i][j]
  Return 1 if true for all elemenets of A and B are equal. Returns 0 otherwise.
*/
int equal(int m, int n, double *A, double *B) {
  int i, j;

  // iterate through m rows and n columns
  for (i = 0; i < m; i++) {
    for (j = 0; j < n; j++) {
      // Checks if A[i][j] != B[i][j] for the current index
      if (A[i * n + j] != B[i * n + j]) {
        return 0;
      }
    }
  }
  return 1;
}

/*
  Function mult accepts dimensions of two matrices and three pointers to matrices.
  Y  = A * B A is m1 x n1m2. B is n1m2 x n2 Y is m1 x n2
*/

/*
void mult(int m1, int n1m2, int n2, double *A, double *B, double *Y) {
  int i, j, k;

  // iterate through m rows and n columns
  for (i = 0; i < m1; i++) {
    for (j = 0; j < n2; j++) {
      // Calculate the dot product between the i-th row of A and j-th column of B
      for (k = 0; k < n1m2; k++) {
        Y[j + i * n2] += A[i * n1m2 + k] * B[k * n2 + j];
      }
    }
  }
}
*/

void mult(int m1, int n1m2, int n2, double *A, double *B, double *Y) {
  int i, j, k;
  double dp = 0;

  // iterate through m rows and n columns
  for (i = 0; i < m1; i++) {
    for (j = 0; j < n2; j++) {
      // Calculate the dot product between the i-th row of A and j-th column of B
      for (k = 0; k < n1m2; k++) {
        dp += A[i * n1m2 + k] * B[k * n2 + j];
      }
      Y[i * n2 + j] = dp;    // Setting Y[i][j] to the dp result
      dp            = 0;     // Resetting dp value so the sum doesn't cary over to the next iter
    }
  }
}

/*
  Function *newMatrix takes two dimensions then returns a pointer, representing
  a 2D matrix of doubles, for the given dimension. All values of mat are 0.0
*/
double *newMatrix(int m, int n) {
  double *mat;
  mat = (double *)malloc(m * n * sizeof(double));
  return mat;
}

/*
  Function *newIdentityMatrix takes one dimension then returns a pointer to an
  identity matrix for a (n x n) matrix.
*/
double *newIdentityMatrix(int n) {
  double *mat = newMatrix(n, n);
  int i, j;
  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++)
      mat[j + i * n] = (i == j);
  return mat;
}

// Main function tests the functionality of the above functions
int main(void) {
  double v1[3]       = {4, 2, 1};                      // 1x3 vector
  double v2[3]       = {1, -2, 3};                     // 1x3 vector
  double dp          = dotproduct(3, v1, v2);          // compute v1 dot v2
  double m1[9]       = {0, 0, 2, 0, 0, 0, 2, 0, 0};    // 3x3 matrix
  double *m2         = newIdentityMatrix(3);           // 3x3 identity matrix
  double *m3         = newMatrix(3, 3);                // 3x3 matrix
  double m4[6]       = {2, 3, 4, 5, 6, 7};             // 3x2 matrix
  double *m5         = newMatrix(3, 2);                // 3x2 matrix
  double m6[6]       = {6, 2, 5, 8, 2, 7};             // 2x3 matrix
  double *m7         = newMatrix(3, 2);                // 3x2 matrix
  double *m8         = newMatrix(3, 2);                // 3x2 matrix
  double expected[6] = {2, 1, 0, 1, 0, -1};            // expected result matrix
  int eq;
  add(3, 3, m1, m2, m3);                               // m3= m1+m2
  mult(3, 3, 2, m3, m4, m5);                           // m5= m3*m4 (3x2 result matrix)

  transpose(2, 3, m6, m7);                             // m7= m6^t
  linearcomb(3, 2, 1, 1 - dp, m5, m7, m8);             // m8= 1*m5 + (1-dp)*m7
  eq = equal(3, 2, m8, expected);                      // check if m8 is as expected
  return eq;                                           // return 1 if so; 0 otherwise
}
