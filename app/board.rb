
class Board
  attr_accessor :player_loc

  def initialize(player_json, board_json)
    @max_x = board_json[:width]; @max_y = board_json[:height]
    @player_loc = to_loc(player[:head])
  end

  def out_of_bounds?(x, y)
    (x < 0) || (y < 0) || (x >= @max_x) || (y >= @max_y)
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

  def food_locs(board)
    board[:food].map(&:to_loc)
  end

  # top left, top right, bottom left, bottom right
  def corners(board)
    [[0, board[:height] - 1], [board[:width] - 1, board[:height] - 1], [0,0], [board [:width] -1, 0]]
  end

  private

  def to_loc(position_hash)
    [position_hash[:x], position_hash[:y]]
  end
end