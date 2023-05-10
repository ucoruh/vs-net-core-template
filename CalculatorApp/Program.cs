internal class Program {
  private static void Main(string[] args) {
    Console.WriteLine("Calculator Application Running..");
    var calculatorLibrary = new CalculatorLibrary.Calculator();
    calculatorLibrary.Add(2, 2);
    calculatorLibrary.Multiply(2, 2);
    calculatorLibrary.Subtract(2, 2);
    calculatorLibrary.Divide(2, 2);
  }
}
