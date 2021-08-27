require './app/move'
require './app/util'

class Planner

  HEURISTICS = [
    :avoid_bounds,
    :avoid_self,
    :avoid_others,
    :seek_food
  ].freeze

  def initialize(board)
    @board = board
    @moves = [Move.new(:up),
             Move.new(:down),
             Move.new(:left),
             Move.new(:right)]
    @moves.each {|move| setup_location(move) }
  end

  def best_move
    evaluations = @moves.map {|move| evaluate_position(move); move }.sort

    evaluations.each do |evaluation|
      log "direction: #{evaluation.direction}, score: #{evaluation.score}"
    end

    evaluations.first
  end

  def evaluate_position(move)
    HEURISTICS.each { |heuristic| self.send(heuristic, move) }
  end

  private

  def setup_location(move)
    move.location = @board.send(move.direction, *@board.player_loc)
  end

  def avoid_bounds(move)
    move.score -= 100 if @board.out_of_bounds?(*move.location)
  end

  def avoid_self(move)
    move.score -= 100 if @board.player_body_collision_at?(move.location)
  end

  def avoid_others(move)
    collision = @board.enemy_collision_at?(move.location)

    log "collides? #{collision}"

    move.score -= 100 if collision
  end

  def seek_food(move)
    closest_food, distance = @board.closest_food_to_player
    new_distance = @board.distance(move.location, closest_food)

    log "New food distance: #{new_distance}, change: #{new_distance - distance}"
    log "#{move.direction} score was: #{move.score}"

    # score goes down if we're further away, up if we're closer
    move.score -= (new_distance - distance)

    log "#{move.direction} score now: #{move.score}"
  end
end
