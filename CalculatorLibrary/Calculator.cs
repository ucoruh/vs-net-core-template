namespace CalculatorLibrary {

/// <summary>
/// Performs basic arithmetic operations on integers.
/// </summary>
/// <remarks>
/// This is the sample class the template ships with. When you start your own project, replace it
/// (and <see cref="CalculatorCli"/>) with your own domain classes — see
/// <c>docs/guide/from-topic-to-project.en.md</c> for the step-by-step walkthrough.
/// </remarks>
public class Calculator {
  /// <summary>Adds two integers.</summary>
  /// <param name="a">The first addend.</param>
  /// <param name="b">The second addend.</param>
  /// <returns>The sum of <paramref name="a"/> and <paramref name="b"/>.</returns>
  public int Add(int a, int b) {
    return a + b;
  }

  /// <summary>Subtracts one integer from another.</summary>
  /// <param name="a">The value to subtract from.</param>
  /// <param name="b">The value to subtract.</param>
  /// <returns>The result of <paramref name="a"/> minus <paramref name="b"/>.</returns>
  public int Subtract(int a, int b) {
    return a - b;
  }

  /// <summary>Multiplies two integers.</summary>
  /// <param name="a">The first factor.</param>
  /// <param name="b">The second factor.</param>
  /// <returns>The product of <paramref name="a"/> and <paramref name="b"/>.</returns>
  public int Multiply(int a, int b) {
    return a * b;
  }

  /// <summary>Divides one integer by another using integer (truncating) division.</summary>
  /// <param name="a">The dividend.</param>
  /// <param name="b">The divisor.</param>
  /// <returns>The integer quotient of <paramref name="a"/> divided by <paramref name="b"/>.</returns>
  /// <exception cref="DivideByZeroException">Thrown when <paramref name="b"/> is zero.</exception>
  public int Divide(int a, int b) {
    if (b == 0) {
      throw new DivideByZeroException();
    }

    return a / b;
  }
}
}
