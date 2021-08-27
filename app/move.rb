class Move
  attr_accessor :direction, :location, :score

  def initialize(dir)
    direction = dir
    score = 0
    location = nil
  end

  def <=>(other_score)
    other_score <=> score
  end

  def to_h
    {move: direction}
  end
end
