namespace CalculatorLibrary {

/// <summary>
/// Parses and runs the calculator's command-line arguments.
/// </summary>
/// <remarks>
/// <para>
/// The parsing logic lives here, in the library, instead of in <c>CalculatorApp/Program.cs</c>, so
/// it can be unit tested directly (see <c>CalculatorLibrary.Tests/CalculatorCliTests.cs</c>) without
/// spawning the console application as a process. <c>Program.cs</c> only calls
/// <see cref="Run(string[])"/> or <see cref="RunDemo"/> and prints the result — it never reads from
/// the console, so it never blocks when the app is launched from a script, a build pipeline or CI.
/// </para>
/// <para>
/// When you rename this sample into your own project, replace this class with your own
/// argument-parsing entry point, keeping the same "parsing is a library function, not something the
/// console shell does inline" shape.
/// </para>
/// </remarks>
public static class CalculatorCli {
  /// <summary>The usage line shown when the arguments cannot be parsed.</summary>
  public const string UsageText = "Usage: CalculatorApp <add|subtract|multiply|divide> <a> <b>";

  /// <summary>
  /// Parses <paramref name="args"/> as <c>&lt;operation&gt; &lt;a&gt; &lt;b&gt;</c> and returns a
  /// line of text describing the result.
  /// </summary>
  /// <param name="args">
  /// Exactly three arguments: the operation name (<c>add</c>, <c>subtract</c>, <c>multiply</c> or
  /// <c>divide</c>, case-insensitive) followed by the two integer operands.
  /// </param>
  /// <returns>A human-readable line such as <c>"2 add 2 = 4"</c>.</returns>
  /// <exception cref="ArgumentException">
  /// Thrown when the argument count is wrong, an operand is not a valid 32-bit integer, or the
  /// operation name is not recognized. The message always ends with <see cref="UsageText"/>.
  /// </exception>
  /// <exception cref="DivideByZeroException">Thrown when dividing by zero.</exception>
  public static string Run(string[] args) {
    if (args.Length != 3) {
      throw new ArgumentException($"Expected 3 arguments (operation, a, b) but got {args.Length}. {UsageText}");
    }

    string operation = args[0].Trim().ToLowerInvariant();

    if (!int.TryParse(args[1], out int a)) {
      throw new ArgumentException($"'{args[1]}' is not a valid 32-bit integer for <a>. {UsageText}");
    }

    if (!int.TryParse(args[2], out int b)) {
      throw new ArgumentException($"'{args[2]}' is not a valid 32-bit integer for <b>. {UsageText}");
    }

    var calculator = new Calculator();

    int result = operation switch {
      "add" => calculator.Add(a, b),
        "subtract" => calculator.Subtract(a, b),
        "multiply" => calculator.Multiply(a, b),
        "divide" => calculator.Divide(a, b),
        _ => throw new ArgumentException($"Unknown operation '{args[0]}'. {UsageText}"),
    };

    return $"{a} {operation} {b} = {result}";
  }

  /// <summary>
  /// Runs a small built-in demonstration that exercises every operation once, used when the
  /// application is started with no arguments at all (so a first run always shows something,
  /// without waiting on keyboard input).
  /// </summary>
  /// <returns>The combined demo output, ending with <see cref="UsageText"/>.</returns>
  public static string RunDemo() {
    var calculator = new Calculator();
    var lines = new System.Text.StringBuilder();
    lines.AppendLine("Calculator Application Running (no arguments given, showing the built-in demo)...");
    lines.AppendLine($"2 add 2 = {calculator.Add(2, 2)}");
    lines.AppendLine($"2 multiply 2 = {calculator.Multiply(2, 2)}");
    lines.AppendLine($"2 subtract 2 = {calculator.Subtract(2, 2)}");
    lines.AppendLine($"2 divide 2 = {calculator.Divide(2, 2)}");
    lines.Append(UsageText);
    return lines.ToString();
  }
}
}
