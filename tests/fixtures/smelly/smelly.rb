# Intentionally smelly code for reek to report on.
class Smelly
  def x(a, b, c, d, e)
    if a
      if b
        if c
          d + e
        end
      end
    end
  end

  def y(a, b, c, d, e)
    x(a, b, c, d, e)
  end
end
