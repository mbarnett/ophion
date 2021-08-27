require './app/move_evaluation'
require './app/util'

class Planner

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

    @moves = [:up, :down, :left, :right].map {|dir| MoveEvaluation.new(dir) }
    @moves.each {|move| setup_location(move) }

    @current_strategy = board.player_hungry? ? HUNGRY_HEURISTICS : DEFENSIVE_HEURISTICS
  end

  def best_move
    log "Player loc: #{@board.player_loc}"
    log "Player length: #{@board.player_length}"
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
    move.score -= 100 if @board.out_of_bounds?(move.location)
  end

  def avoid_self(move)
    move.score -= 100 if @board.player_body_collision_at?(move.location)
  end

  def avoid_others(move)
    collision = @board.enemy_collision_at?(move.location)

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

    # score goes down if we're further away, up if we're closer
    move.score -= (new_distance - distance)
  end

  def attack_weaker_avoid_stronger(move)
    ATTACKABLE_LOCATION_OFFSETS[move.direction].each do |offset|
      attackable_location = @board.player_loc.zip(offset).map {|arr| arr.inject(&:+)}

      enemy_present, enemy_length = @board.enemy_head_at?(attackable_location)

      move.score += 10 if enemy_present && (enemy_length < @board.player_length)
      move.score -= 98 if enemy_present && (enemy_length >= @board.player_length)
      # sliiightly better to move into an eatable position, where the enemy might not actually
      # eat you, then to run straight out of bounds in fear
    end
  end

  def avoid_deadends(move)
    return if move.score < @config.minimum_search_threshold

    visited = Set.new

    log "Search: #{move.direction} at #{move.location}"
    found_tail = search_for_tail(move.location, current_depth: 0, visited: visited)

    move.score -= 100 unless found_tail || (visited.count > @board.player_length + 3)
  end

  def search_for_tail(location, current_depth:, visited:)
  #  log "%%% Depth exceeded" if @config.max_search_depth
    return false if current_depth > @config.max_search_depth

 #   log "Visited: #{visited}"

    offsets = [[1,0], [-1,0], [0,1], [0,-1]]
    to_visit = []

    log "loc: #{location}"
    log "thing: #{offsets.zip([location]*4)}"

    adjacencies = offsets.zip([location]*4).map {|arr| arr.inject(:+)}
   # log "adjacent locations: #{adjacencies}"

    adjacencies.each do |adjacent_location|
      next if visited.include?(adjacent_location)
      return true if @board.player_tail_at?(adjacent_location)
      to_visit << adjacent_location unless (@board.out_of_bounds?(adjacent_location) || @board.player_body_collision_at?(adjacent_location) || @board.enemy_collision_at?(adjacent_location))
    end

    to_visit.each do |visiting_location|
 #     log "Visiting: #{visiting_location}"
      found_tail = search_for_tail(visiting_location, current_depth: current_depth + 1, visited: visited)
      return true if found_tail
      visited << visiting_location
    end

    return false
  end

end
