require './app/board'
require './app/planner'

class Ophion
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def choose_move(world_state)
    log "Turn: #{world_state[:turn]}"

    board = Board.new(world_state[:you], world_state[:board], config)

    planner = Planner.new(board, config)

    planner.best_move
  end
end

