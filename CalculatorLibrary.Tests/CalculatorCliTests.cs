namespace CalculatorLibrary.Tests {

/// <summary>
/// Unit tests for <see cref="CalculatorCli"/>: this is the class that demonstrates "move parsing
/// into the library so it is testable" — these tests exercise the parser directly, without
/// starting the <c>CalculatorApp</c> process.
/// </summary>
public class CalculatorCliTests {
  [Theory]
  [InlineData("add", "2", "2", "2 add 2 = 4")]
  [InlineData("subtract", "5", "3", "5 subtract 3 = 2")]
  [InlineData("multiply", "4", "6", "4 multiply 6 = 24")]
  [InlineData("divide", "9", "3", "9 divide 3 = 3")]
  [InlineData("ADD", "-1", "1", "-1 add 1 = 0")] // operation name is case-insensitive
  public void Run_WithValidArguments_ReturnsFormattedResult(string operation, string a, string b, string expected) {
    Assert.Equal(expected, CalculatorCli.Run(new[] { operation, a, b }));
  }

  [Fact]
  public void Run_DivideByZero_ThrowsDivideByZeroException() {
    Assert.Throws<DivideByZeroException>(() => CalculatorCli.Run(new[] { "divide", "1", "0" }));
  }

  // xUnit cannot pass a string[] straight through [InlineData] (CS0182: it is ambiguous with the
  // attribute's own `params object[]`), so array-shaped cases use [MemberData] instead.
  public static IEnumerable<object[]> WrongArgumentCounts() {
    yield return new object[] { Array.Empty<string>() };
    yield return new object[] { new[] { "add" } };
    yield return new object[] { new[] { "add", "1" } };
    yield return new object[] { new[] { "add", "1", "2", "3" } };
  }

  [Theory]
  [MemberData(nameof(WrongArgumentCounts))]
  public void Run_WithWrongArgumentCount_ThrowsArgumentExceptionWithUsage(string[] args) {
    var exception = Assert.Throws<ArgumentException>(() => CalculatorCli.Run(args));
    Assert.Contains(CalculatorCli.UsageText, exception.Message);
  }

  [Theory]
  [InlineData("power", "2", "2")]   // unknown operation
  [InlineData("", "2", "2")]        // empty operation
  public void Run_WithUnknownOperation_ThrowsArgumentException(string operation, string a, string b) {
    var exception = Assert.Throws<ArgumentException>(() => CalculatorCli.Run(new[] { operation, a, b }));
    Assert.Contains(CalculatorCli.UsageText, exception.Message);
  }

  [Theory]
  [InlineData("add", "two", "2")]
  [InlineData("add", "2", "two")]
  [InlineData("add", "2.5", "2")]
  [InlineData("add", "", "2")]
  public void Run_WithNonIntegerOperand_ThrowsArgumentException(string operation, string a, string b) {
    Assert.Throws<ArgumentException>(() => CalculatorCli.Run(new[] { operation, a, b }));
  }

  [Fact]
  public void RunDemo_ExercisesEveryOperationAndEndsWithUsage() {
    string demo = CalculatorCli.RunDemo();
    Assert.Contains("2 add 2 = 4", demo);
    Assert.Contains("2 multiply 2 = 4", demo);
    Assert.Contains("2 subtract 2 = 0", demo);
    Assert.Contains("2 divide 2 = 1", demo);
    Assert.EndsWith(CalculatorCli.UsageText, demo);
  }
}
}
