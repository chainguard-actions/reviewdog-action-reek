# Simple Ruby file for reek to analyze
class SampleClass
  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end

  def do_something(x, y)
    x + y + @a + @b + @c
  end
end
