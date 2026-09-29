namespace CalculatorLibrary.Tests {

/// <summary>Unit tests for <see cref="Calculator"/>: normal cases, boundaries and invalid input.</summary>
public class CalculatorTests {
  private readonly Calculator _calculator = new();

  [Theory]
  [InlineData(2, 2, 4)]
  [InlineData(-2, 2, 0)]
  [InlineData(-2, -3, -5)]
  [InlineData(0, 0, 0)]
  [InlineData(int.MaxValue, 0, int.MaxValue)]
  [InlineData(int.MinValue, 0, int.MinValue)]
  public void Add_ReturnsSum(int a, int b, int expected) {
    Assert.Equal(expected, _calculator.Add(a, b));
  }

  [Fact]
  public void Add_AtIntMaxValue_OverflowsLikeOrdinaryIntArithmetic() {
    // Boundary case: unchecked int addition wraps around; the library does not hide this from
    // callers, so the test documents the behavior instead of assuming an exception is thrown.
    unchecked {
      Assert.Equal(int.MinValue, _calculator.Add(int.MaxValue, 1));
    }
  }

  [Theory]
  [InlineData(4, 2, 2)]
  [InlineData(2, 4, -2)]
  [InlineData(0, 0, 0)]
  [InlineData(int.MinValue, 0, int.MinValue)]
  public void Subtract_ReturnsDifference(int a, int b, int expected) {
    Assert.Equal(expected, _calculator.Subtract(a, b));
  }

  [Theory]
  [InlineData(2, 4, 8)]
  [InlineData(-2, 4, -8)]
  [InlineData(0, 12345, 0)]
  [InlineData(1, int.MaxValue, int.MaxValue)]
  public void Multiply_ReturnsProduct(int a, int b, int expected) {
    Assert.Equal(expected, _calculator.Multiply(a, b));
  }

  [Theory]
  [InlineData(4, 2, 2)]
  [InlineData(7, 2, 3)]   // truncating division, not rounding
  [InlineData(-7, 2, -3)]
  [InlineData(0, 5, 0)]
  public void Divide_ReturnsTruncatedQuotient(int a, int b, int expected) {
    Assert.Equal(expected, _calculator.Divide(a, b));
  }

  [Fact]
  public void Divide_ByZero_ThrowsDivideByZeroException() {
    Assert.Throws<DivideByZeroException>(() => _calculator.Divide(4, 0));
  }

  [Fact]
  public void Divide_ZeroByNonZero_ReturnsZero() {
    Assert.Equal(0, _calculator.Divide(0, 5));
  }

  [Fact]
  public void Divide_IntMinValueByNegativeOne_ThrowsOverflowException() {
    // Boundary case: this one division cannot be represented as a positive int (the magnitude of
    // int.MinValue is one larger than int.MaxValue), so .NET raises OverflowException here even
    // though the surrounding code is not in a `checked` block.
    Assert.Throws<OverflowException>(() => _calculator.Divide(int.MinValue, -1));
  }
}
}
