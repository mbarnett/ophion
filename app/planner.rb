

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
             Move.new(:right)].each {|move| setup_location(move) }
  end

  def best_move(available_moves)
    evaluations = @moves.map {|move| evaluate_position(move) }

    log evaluations

    evaluations.sort.first
  end

  def evaluate_position(move)
    # HEURISTICS.inject(move) do |evaluation, heuristic|
    #   evaluation = self.send(heuristic, evaluation)
    # end

    HEURISTICS.each { |heuristic| self.send(heuristic, move) }
  end

  private

  def setup_location(move)
    move.location = @board.send(*move.direction)
  end

  def avoid_bounds(move)
    move.score -= 100 if @board.out_of_bounds?(*move.location)
  end

  def avoid_self(move)
    move
  end

  def avoid_others(move)
    move
  end

  def seek_food(move)
    move
  end
end
