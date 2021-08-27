require './app/board'
require './app/planner'

Move = Struct.new(:direction, :location, :score) do
  def <=>(other_score)
    other_score <=> score
  end

  def to_h
    {move: direction}
  end
end

class Ophion
  def self.choose_move(world_state)
    board = Board.new(world_state[:you], world_state[:board])

    planner = Planner.new(board)

    planner.best_move
  end
end

