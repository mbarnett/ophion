require './app/board'
require './app/planner'

class Ophion
  def self.choose_move(world_state)
    board = Board.new(world_state[:you], world_state[:board])

    planner = Planner.new(board)

    planner.best_move
  end
end

