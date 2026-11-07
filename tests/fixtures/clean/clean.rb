# frozen_string_literal: true

# Greeter builds a friendly greeting.
class Greeter
  def initialize(name)
    @name = name
  end

  def greeting
    "Hello, #{@name}!"
  end
end
