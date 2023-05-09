
namespace CalculatorLibrary.Tests {
public class CalculatorTests {
  [Fact]
  public void TestAdd() {
    Calculator calc = new Calculator();
    Assert.Equal(4, calc.Add(2, 2));
  }

  [Fact]
  public void TestSubtract() {
    Calculator calc = new Calculator();
    Assert.Equal(2, calc.Subtract(4, 2));
  }

  [Fact]
  public void TestMultiply() {
    Calculator calc = new Calculator();
    Assert.Equal(8, calc.Multiply(2, 4));
  }

  [Fact]
  public void TestDivide() {
    Calculator calc = new Calculator();
    Assert.Equal(2, calc.Divide(4, 2));
  }

  [Fact]
  public void TestDivideByZero() {
    Calculator calc = new Calculator();
    Assert.Throws<DivideByZeroException>(() => calc.Divide(4, 0));
  }
}
}
