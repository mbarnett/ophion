
class Board
  attr_accessor :player_loc, :player_length

  def initialize(player_json, board_json, config)
    player_id = player_json[:id]

    @max_x = board_json[:width]; @max_y = board_json[:height]
    @player_loc = to_loc(player_json[:head])
    @board_json = board_json

    @player_body_locs = player_json[:body].map {|hash| to_loc(hash)}
    @player_tail_at = @player_body_locs.last
    @player_length = @player_body_locs.count

    @player_hungry = (player_json[:health] < config.health_hunger_threshold) || (@player_length < config.length_hunger_threshold)

    @enemies = []
    @enemy_heads = []
    @enemy_length_by_head = {}

    board_json[:snakes].select {|snake| snake[:id] != player_id}.each do |snake|
      snake_locs = snake[:body].map {|hash| to_loc(hash)}
      head = snake_locs.first
      @enemies << snake_locs
      @enemy_heads << head
      @enemy_length_by_head[head] = snake_locs.count
    end

    @enemy_heads = @enemies.map { |enemy| enemy.first }

    @food_locs = @board_json[:food].map {|hash| to_loc(hash)}
  end

  def player_hungry?; @player_hungry; end

  def out_of_bounds?(loc)
    x, y = loc
    (x < 0) || (y < 0) || (x >= @max_x) || (y >= @max_y)
  end

  def player_body_collision_at?(loc)
    # can't collide with own tail
    @player_body_locs[0...-1].include?(loc)
  end

  def enemy_collision_at?(loc)
    @enemies.each do |enemy_locs|
      # can't collide with enemy tail, since they have to move too
      return true if enemy_locs[0...-1].include?(loc)
    end
    false
  end

  def enemy_head_at?(loc)
    is_head = @enemy_heads.include?(loc)
    return is_head, @enemy_length_by_head[loc]
  end

  def player_tail_at?(loc)
    @player_tail_at == loc
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
    log "Closest corner: #{closest_corner}, dist: #{distance}"

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
