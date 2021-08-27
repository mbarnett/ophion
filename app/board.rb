
class Board
  attr_accessor :player_loc

  def initialize(player_json, board_json)
    player_id = player_json[:id]

    @player_hungry = (player_json[:health] < 40)

    log "Board: #{board_json}"

    @max_x = board_json[:width]; @max_y = board_json[:height]
    @player_loc = to_loc(player_json[:head])
    @board_json = board_json

    @player_body_locs = player_json[:body].map {|hash| to_loc(hash)}
    @player_size = @player_body_locs.count

    @enemies = board_json[:snakes].select {|snake| snake[:id] != player_id}.map do |snake|
      snake[:body].map {|hash| to_loc(hash)}
    end

    @food_locs = @board_json[:food].map {|hash| to_loc(hash)}
    log "Food: #{@food_locs}"
  end

  def player_hungry?; @player_hungry; end

  def out_of_bounds?(x, y)
    (x < 0) || (y < 0) || (x >= @max_x) || (y >= @max_y)
  end

  def player_body_collision_at?(loc)
    # can't collide with own tail
    @player_body_locs[0...-1].include?(loc)
  end

  def enemy_collision_at?(loc)
    log "looking for enemy collisions at #{loc}"

    @enemies.each do |enemy_locs|
      log "enemy: #{enemy_locs}"

      # can't collide with enemy tail, since they have to move too
      return true if enemy_locs[0...-1].include?(loc)
    end
    false
  end

  def up(x, y)
    [x, y+1]
  end

  def down(x, y)
    [x, y-1]
  end

  def left(x, y)
    [x-1, y]
  end

  def right(x, y)
    [x+1, y]
  end

  # top left, top right, bottom left, bottom right
  def corners
    [[0, @max_y - 1], [@max_x - 1, @max_y - 1], [0,0], [@max_x - 1, 0]]
  end

  def closest_food_to_player
    closest_food, distance = closest_entity_to_player(@food_locs)
    log "Closest food: #{closest_food}, dist: #{distance}"

    return closest_food, distance
  end

  def closest_corner_to_player
    closest_corner, distance = closest_entity_to_player(corners)
    log "Closest corner: #{corner}, dist: #{distance}"

    return closest_corner, distance
  end

  def closest_entity_to_player(entity_locs)
    closest = entity_locs.first
    min_distance_seen = distance(@player_loc, closest)

    entity_locs[1..-1].each do |loc|
      dist = distance(@player_loc, loc)

      if dist < min_distance_seen
        closest = loc
        min_distance_seen = dist
      end
    end

    return closest, min_distance_seen
  end

  def distance(loc1, loc2)
    loc1_x, loc1_y = loc1
    loc2_x, loc2_y = loc2

    Math.sqrt((loc2_y - loc1_y)**2 + (loc2_x - loc1_x)**2 )
  end

  private

  def to_loc(position_hash)
    [position_hash[:x], position_hash[:y]]
  end
end
