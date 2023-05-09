namespace CalculatorLibrary {
/// \brief A class for performing basic arithmetic operations.
public class Calculator {
  /// \brief Adds two integers.
  /// \param a The first integer to add.
  /// \param b The second integer to add.
  /// \return The sum of \a a and \a b.
  public int Add(int a, int b) {
    return a + b;
  }

  /// \brief Subtracts two integers.
  /// \param a The first integer to subtract from.
  /// \param b The second integer to subtract.
  /// \return The result of subtracting \a b from \a a.
  public int Subtract(int a, int b) {
    return a - b;
  }

  /// \brief Multiplies two integers.
  /// \param a The first integer to multiply.
  /// \param b The second integer to multiply.
  /// \return The product of \a a and \a b.
  public int Multiply(int a, int b) {
    return a * b;
  }

  /// \brief Divides two integers.
  /// \param a The numerator.
  /// \param b The denominator.
  /// \return The result of dividing \a a by \a b.
  /// \throw DivideByZeroException if \a b is zero.
  public int Divide(int a, int b) {
    if (b == 0) {
      throw new DivideByZeroException();
    }

    return a / b;
  }

}
}
