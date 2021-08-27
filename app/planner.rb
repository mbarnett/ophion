require './app/move_evaluation'
require './app/util'

class Planner

  DEFAULT_HEURISTICS = [
    :avoid_bounds,
    :avoid_self,
    :avoid_others,
    :attack_weaker_avoid_stronger
  ].freeze

  HUNGRY_HEURISTICS = (DEFAULT_HEURISTICS + [:seek_food]).freeze
  DEFENSIVE_HEURISTICS = (DEFAULT_HEURISTICS + [:seek_corner]).freeze

  ATTACKABLE_LOCATION_OFFSETS = {
    up: [[0,2], [-1,1], [1,1]],
    down: [[0,-2],[-1,-1],[1,-1] ],
    left: [[-1,1], [-2,0], [-1,-1]],
    right: [[1,1], [2,0], [1,-1]]
  }

  def initialize(board)
    @board = board
    @moves = [:up, :down, :left, :right].map {|dir| MoveEvaluation.new(dir) }
    @moves.each {|move| setup_location(move) }

    @current_strategy = board.player_hungry? ? HUNGRY_HEURISTICS : DEFENSIVE_HEURISTICS
  end

  def best_move
    evaluations = @moves.map {|move| evaluate_position(move) }.sort

    evaluations.each do |evaluation|
      log "direction: #{evaluation.direction}, score: #{evaluation.score}"
    end

    evaluations.first
  end

  def evaluate_position(move)
    @current_strategy.each do |heuristic|
      log "#{move.direction} current score #{move.score}"
      log "Running #{heuristic}..."

      self.send(heuristic, move)

      log "#{move.direction} score after #{heuristic}: #{move.score}"
    end
    move
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
    seek_entity(move, *@board.closest_food_to_player)
  end

  def seek_corner(move)
    seek_entity(move, *@board.closest_corner_to_player)
  end

  def seek_entity(move, entity, distance)
    new_distance = @board.distance(move.location, entity)

    log "#{move.direction} new distance: #{new_distance}, change: #{new_distance - distance}"

    # score goes down if we're further away, up if we're closer
    move.score -= (new_distance - distance)
  end

  def attack_weaker_avoid_stronger(move)
    ATTACKABLE_LOCATION_OFFSETS[move.direction].each do |offset|
      attackable_location = @board.player_loc.zip(offset).map {|arr| arr.inject(&:+)}

      log "Attackable: #{attackable_location}"

      enemy_present, enemy_length = @board.enemy_head_at?(attackable_location)

      move.score += 10 if enemy_present && (enemy_length < @board.player_length)
      move.score -= 100 if enemy_present && (enemy_length >= @board.player_length)
    end
  end

end
