require './app/move_evaluation'
require './app/util'

class Planner

  DIRECTIONS = [:up, :down, :left, :right].freeze

  DEFAULT_HEURISTICS = [
    :avoid_bounds,
    :avoid_self,
    :avoid_others,
    :avoid_deadends,
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

  def initialize(board, config)
    @board = board
    @config = config

    @moves = DIRECTIONS.map {|dir| MoveEvaluation.new(dir) }
    @moves.each {|move| setup_location(move) }

    @current_strategy = board.player_hungry? ? HUNGRY_HEURISTICS : DEFENSIVE_HEURISTICS

    log "strategy: #{board.player_hungry? ? 'seek food' : 'seek corner'}"
  end

  def best_move
    evaluations = @moves.map {|move| evaluate_position(move) }.sort

    evaluations.each do |evaluation|
      log "direction: #{evaluation.direction}, score: #{evaluation.score}"
    end

    evaluations.first
  end

  def evaluate_position(move)
    @current_strategy.each { |heuristic| self.send(heuristic, move) }
    move
  end

  private

  def setup_location(move)
    move.location = @board.send(move.direction, *@board.player_loc)
  end

  def avoid_bounds(move)
    move.score -= 200 if @board.out_of_bounds?(move.location)
  end

  def avoid_self(move)
    move.score -= 200 if @board.player_body_collision_at?(move.location)
  end

  def avoid_others(move)
    collision = @board.enemy_collision_at?(move.location)

    move.score -= 200 if collision
  end

  def seek_food(move)
    seek_entity(move, *@board.closest_food_to_player)
  end

  def seek_corner(move)
    seek_entity(move, *@board.closest_corner_to_player)
  end

  def seek_entity(move, entity, distance)
    new_distance = @board.distance(move.location, entity)

    # score goes down if we're further away, up if we're closer
    move.score -= (new_distance - distance)
  end

  def attack_weaker_avoid_stronger(move)
    ATTACKABLE_LOCATION_OFFSETS[move.direction].each do |offset|
      attackable_location = @board.player_loc.zip(offset).map {|arr| arr.inject(&:+)}
      enemy_present, enemy_length = @board.enemy_head_at?(attackable_location)

      move.score += 10 if enemy_present && (enemy_length < @board.player_length)
      move.score -= 95 if enemy_present && (enemy_length >= @board.player_length)
      # sliiightly better to move into an eatable position, where the enemy might not actually
      # eat you, then to run straight out of bounds in fear
    end
  end

  def avoid_deadends(move)
    return if move.score < @config.minimum_search_threshold

    visited = Set.new

    search_for_deadend(move.location, current_depth: 0, visited: visited)

    log "depth #{move.direction}: #{visited.count}"

    unless visited.count > @config.max_search_depth
      # deadends are bad, but we want a larger deadend to be worth more than a smaller one
      # so that we always make the best of a bad situation. Hence they're worth -(100 - number
      # of visited tiles in the deadend)
      move.score -= (100 - visited.count) if (visited.count < @board.player_length)
    end
  end

  def search_for_deadend(location, current_depth:, visited:)
    return if current_depth > @config.max_search_depth

    visited << location
    to_visit = []

    adjacencies = DIRECTIONS.map { |dir| @board.send(dir, *location)}

    adjacencies.each do |adjacent_location|
      to_visit << adjacent_location unless (any_collisions?(adjacent_location) || ((current_depth > 0) && (closable_location?(adjacent_location))))
    end

    to_visit.each do |visiting_location|
      next if visited.include?(visiting_location)
      search_for_deadend(visiting_location, current_depth: current_depth + 1, visited: visited)
    end
  end

  def any_collisions?(loc)
    @board.out_of_bounds?(loc) || @board.player_body_collision_at?(loc) || @board.enemy_collision_at?(loc)
  end

  def closable_location?(loc)
    adjacencies = DIRECTIONS.map { |dir| @board.send(dir, *loc)}

    return adjacencies.any? {|location| present, _ = @board.enemy_head_at?(location); present }
  end

end
