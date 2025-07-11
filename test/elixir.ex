# elixir.ex
# This is a single-line comment explaining the next function

defmodule Example do
  # The following function prints a greeting
  def greet(name) do
    IO.puts("Hello, #{name}!") # Inline comment: prints the greeting
    # The next line returns the name in uppercase
    String.upcase(name) # Another inline comment
  end

  # Multi-step calculation with comments
  def calculate(a, b) do
    result = a + b # Add the numbers
    # Check if result is even
    if rem(result, 2) == 0 do
      IO.puts("Result is even") # Inform the user
    else
      IO.puts("Result is odd") # Inform the user
    end
    result
  end

  # The following string contains a hash, but it's not a comment:
