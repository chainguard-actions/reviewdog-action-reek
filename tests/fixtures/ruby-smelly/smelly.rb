# Ruby class with intentional code smells for testing
class SmellyClass
  def method_with_many_params(a, b, c, d, e)
    x = a + b
    y = c + d
    z = e + x
    result = y + z
    result
  end

  def another_method(a, b, c, d, e)
    a + b + c + d + e
  end
end
