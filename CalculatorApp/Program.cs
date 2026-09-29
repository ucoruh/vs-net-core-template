namespace CalculatorApp {

/// <summary>
/// Console entry point. All parsing and calculation logic lives in
/// <see cref="CalculatorLibrary.CalculatorCli"/> so it is unit tested there; this class only wires
/// the process arguments to that logic and prints the result. It never calls
/// <c>Console.ReadLine</c> or otherwise waits on keyboard input, so it never blocks when launched
/// from a build script or CI.
/// </summary>
internal class Program {
  private static int Main(string[] args) {
    try {
      string output = args.Length == 0 ? CalculatorLibrary.CalculatorCli.RunDemo() : CalculatorLibrary.CalculatorCli.Run(args);
      Console.WriteLine(output);
      return 0;
    } catch (Exception ex) when (ex is ArgumentException or DivideByZeroException) {
      Console.Error.WriteLine($"Error: {ex.Message}");
      return 1;
    }
  }
}
}
