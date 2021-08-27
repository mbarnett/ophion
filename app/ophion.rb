require './app/board'
require './app/planner'

class Ophion
  def self.choose_move(world_state, config)
    log "Hunger threshold: health: #{config.health_hunger_threshold}, length: #{config.length_hunger_threshold}"

    board = Board.new(world_state[:you], world_state[:board], config)

    planner = Planner.new(board)

    planner.best_move
  end
end

