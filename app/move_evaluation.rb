class MoveEvaluation
  attr_accessor :direction, :location, :score

  def initialize(dir)
    @direction = dir
    @score = 0
    @location = nil
  end

  def <=>(other)
    other.score <=> @score
  end

  def to_h
    { move: @direction }
  end
end
