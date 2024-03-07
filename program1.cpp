#include <iostream>
#include <cstdlib>
#include <chrono>
#include <iomanip>

void matrix_vector_multiply(uint64_t *y, uint64_t *A, uint64_t *x, size_t size) {
  size_t i, j;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      y[j] += A[j * size + i] * x[i];
    }
  }
}

int main(int argc, char **argv) {

  const size_t size = std::stoi(argv[1]);

  // y = Ax
  uint64_t *A = new uint64_t[size * size];
  uint64_t *x = new uint64_t[size];
  uint64_t *y = new uint64_t[size * size];
  size_t i, j;

  for (i = 0; i < size; ++i)
    for (j = 0; j < size; j++)
      A[i * size + j] = j;

  for (i = 0; i < size; ++i)
    x[i] = i;
  
  auto begin = std::chrono::high_resolution_clock::now();
  matrix_vector_multiply(y, A, x, size);
  auto end = std::chrono::high_resolution_clock::now();

  for (i = 1; i < size; ++i)
    if (y[i] != y[i - 1]) {
      std::cout << "failed" << std::endl;
      return EXIT_FAILURE;
    }

  std::chrono::duration<double> diff = end - begin;
  std::cout << "passed(" << std::setw(10) << diff.count() << " s)" << std::endl;
  delete [] A;
  delete [] x;
  delete [] y;

  return EXIT_SUCCESS;
}

