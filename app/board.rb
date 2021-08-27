
class Board
  attr_accessor :player_loc

  def initialize(player_json, board_json)
    player_id = player_json[:id]


    @max_x = board_json[:width]; @max_y = board_json[:height]
    @player_loc = to_loc(player_json[:head])
    @board_json = board_json

    @player_body_locs = player_json[:body].map {|hash| to_loc(hash)}
    @player_size = @player_body_locs.count

    @enemies = board_json[:snakes].select {|snake| snake[:id] != player_id}.map do |snake|
      snake[:body].map {|hash| to_loc(hash)}
    end
  end

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
  def corners(board)
    [[0, @max_y - 1], [@max_x - 1, @max_y - 1], [0,0], [@max_x - 1, 0]]
  end

  def food_locs
    @food_locs ||= @board_json[:food].map {|hash| to_loc(hash)}
  end

  def closest_food_loc_to_player
    closest_food = @food_locs.first
    min_distance_seen = distance(@player_loc, closest_food)

    @food_locs[1..-1].each do |loc|
      dist = distance(@player_loc, loc)

      if dist < min_distance_seen
        closest_food = loc
        min_distance_seen = dist
      end
    end
    return closest_food, min_distance_seen
  end

  def distance(loc1, loc2)
    Math.sqrt((loc2.y - loc1.y)**2 + (loc2.x - loc1.x)**2 )
  end

  private

  def to_loc(position_hash)
    [position_hash[:x], position_hash[:y]]
  end
end
