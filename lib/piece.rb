class Piece
  # All the pieces and their possible moves
  attr_accessor :memory, :possibleMoves
  attr_reader :symbol, :color

  def initialize(color, pos)
    @color = color
    @symbol = ''
    @memory = [pos]
    @possibleMoves = []
  end

  def symbol
    symbol = if @color == 'black'
               Paint[@symbol, $theme['3']]
             else
               Paint[@symbol, $theme['4']]
             end
  end

  def calculate_moves(coords, grid)
    # outputs array of all cells it can jump to
  end

  private

  def find_cell(coords, grid)
    return false if coords.first < 0 || coords.first > 7 || coords.last < 0 || coords.last > 7
    grid[coords.first][coords.last]
  end

  def rook_moves(coords, grid)
    possibleMoves = []

    4.times do |o|
      lastPiece = nil
      8.times do |i|
        next if i == 0

        direction = [[coords.first + i, coords.last], [coords.first - i, coords.last], [coords.first, coords.last + i],
                     [coords.first, coords.last - i]]
        cell = find_cell(direction[o], grid)
        piece = cell != false ? cell.piece : nil
        break if piece && piece.color == @color

        if lastPiece.nil? && cell
          possibleMoves << cell if piece.nil?
          break possibleMoves << cell if piece && piece.color != @color
        end
        i += 1
        lastPiece = piece
      end
      o += 1
    end
    possibleMoves
  end

  def bishop_moves(coords, grid)
    possibleMoves = []

    4.times do |o|
      lastPiece = nil
      8.times do |i|
        next if i == 0

        direction = [[coords.first + i, coords.last + i], [coords.first - i, coords.last - i], [coords.first + i, coords.last - i],
                     [coords.first - i, coords.last + i]]
        cell = find_cell(direction[o], grid)
        piece = cell != false ? cell.piece : nil
        break if piece && piece.color == @color

        if lastPiece.nil? && cell
          possibleMoves << cell if piece.nil?
          break possibleMoves << cell if piece && piece.color != @color
        end
        i += 1
        lastPiece = piece
      end
      o += 1
    end
    possibleMoves
  end
end

class Pawn < Piece
  def initialize(color, pos)
    @color = color
    @symbol = ' ♙ '
    @memory = [pos]
  end

  def calculate_moves(coords, grid)
    pawn_moves(coords, grid).map! { |x| x.position }
  end

  def en_passant(coords, grid)
    output = []
    twoStep = grid[3].map { |i| i.position } + grid[4].map { |i| i.position }
    left = find_cell([coords.first, coords.last - 1], grid)
    right = find_cell([coords.first, coords.last + 1], grid)

    if left != false && left.piece.instance_of?(Pawn) && left.piece.color != @color && left.piece.memory.length == 2 && twoStep.include?(left.piece.memory.last)
      output << find_cell([coords.first + 1, coords.last - 1], grid) if @color == 'white'
      output << find_cell([coords.first - 1, coords.last - 1], grid) if @color == 'black'
    end
    if right != false && right.piece.instance_of?(Pawn) && right.piece.color != @color && right.piece.memory.length == 2 && twoStep.include?(right.piece.memory.last)
      output << find_cell([coords.first + 1, coords.last + 1], grid) if @color == 'white'
      output << find_cell([coords.first - 1, coords.last + 1], grid) if @color == 'black'
    end
    output
  end

  # lazy copy for compile choices
  def en_passant_enemy(coords, grid)
    output = []
    left = find_cell([coords.first, coords.last - 1], grid)
    right = find_cell([coords.first, coords.last + 1], grid)

    if left != false && left.piece.instance_of?(Pawn) && left.piece.color != @color && left.piece.memory.length == 2
      output << left
    end
    if right != false && right.piece.instance_of?(Pawn) && right.piece.color != @color && right.piece.memory.length == 2
      output << right
    end
    output.map! { |x| x.position }
  end

  private

  def pawn_moves(coords, grid)
    possibleMoves = []
    pawnStart = grid[1].map { |i| i.coords } + grid[6].map { |i| i.coords }
    whiteMoves = [[coords.first + 1, coords.last], [coords.first + 1, coords.last + 1], [coords.first + 1, coords.last - 1],
                  [coords.first + 2, coords.last]]
    blackMoves = [[coords.first - 1, coords.last], [coords.first - 1, coords.last + 1], [coords.first - 1, coords.last - 1],
                  [coords.first - 2, coords.last]]

    if @color == 'white'
      possibleMoves << find_cell(whiteMoves[0], grid) if find_cell(whiteMoves[0],
                                                                   grid) != false && find_cell(whiteMoves[0],
                                                                                               grid).piece.nil?
      possibleMoves << find_cell(whiteMoves[1], grid) if find_cell(whiteMoves[1],
                                                                   grid) != false && find_cell(whiteMoves[1],
                                                                                               grid).piece != nil && find_cell(
                                                                                                 whiteMoves[1], grid
                                                                                               ).piece.color == 'black'
      possibleMoves << find_cell(whiteMoves[2], grid) if find_cell(whiteMoves[2],
                                                                   grid) != false && find_cell(whiteMoves[2],
                                                                                               grid).piece != nil && find_cell(
                                                                                                 whiteMoves[2], grid
                                                                                               ).piece.color == 'black'
      possibleMoves << find_cell(whiteMoves[3], grid) if find_cell(whiteMoves[3],
                                                                   grid) != false && find_cell(whiteMoves[3],
                                                                                               grid).piece.nil? && find_cell(
                                                                                                 whiteMoves[0], grid
                                                                                               ).piece.nil? && pawnStart.include?(coords)
    elsif @color == 'black'
      possibleMoves << find_cell(blackMoves[0], grid) if find_cell(blackMoves[0],
                                                                   grid) != false && find_cell(blackMoves[0],
                                                                                               grid).piece.nil?
      possibleMoves << find_cell(blackMoves[1], grid) if find_cell(blackMoves[1],
                                                                   grid) != false && find_cell(blackMoves[1],
                                                                                               grid).piece != nil && find_cell(
                                                                                                 blackMoves[1], grid
                                                                                               ).piece.color == 'white'
      possibleMoves << find_cell(blackMoves[2], grid) if find_cell(blackMoves[2],
                                                                   grid) != false && find_cell(blackMoves[2],
                                                                                               grid).piece != nil && find_cell(
                                                                                                 blackMoves[2], grid
                                                                                               ).piece.color == 'white'
      possibleMoves << find_cell(blackMoves[3], grid) if find_cell(blackMoves[3],
                                                                   grid) != false && find_cell(blackMoves[3],
                                                                                               grid).piece.nil? && find_cell(
                                                                                                 blackMoves[0], grid
                                                                                               ).piece.nil? && pawnStart.include?(coords)
    end
    possibleMoves + en_passant(coords, grid)
  end
end

class Rook < Piece
  def initialize(color, pos)
    @color = color
    @symbol = ' ♜ '
    @memory = [pos]
  end

  def calculate_moves(coords, grid)
    rook_moves(coords, grid).map! { |x| x.position }
  end
end

class Knight < Piece
  def initialize(color, pos)
    @color = color
    @symbol = ' ♞ '
    @memory = [pos]
  end

  def calculate_moves(coords, grid)
    knight_moves(coords, grid).map! { |x| x.position }
  end

  private

  def knight_moves(coords, grid)
    possibleMoves = []
    direction = [[coords.first + 2, coords.last + 1], [coords.first + 2, coords.last - 1], [coords.first - 2, coords.last + 1], [coords.first - 2, coords.last - 1],
                 [coords.first + 1, coords.last + 2], [coords.first - 1, coords.last + 2], [coords.first + 1, coords.last - 2], [coords.first - 1, coords.last - 2]]

    direction.each do |d|
      cell = find_cell(d, grid)
      piece = cell != false ? cell.piece : nil
      possibleMoves << cell unless !cell || piece && piece.color == @color
    end
    possibleMoves
  end
end

class Bishop < Piece
  def initialize(color, pos)
    @color = color
    @symbol = ' ♝ '
    @memory = [pos]
  end

  def calculate_moves(coords, grid)
    bishop_moves(coords, grid).map! { |x| x.position }
  end
end

class Queen < Piece
  def initialize(color, pos)
    @color = color
    @symbol = ' ♛ '
    @memory = [pos]
  end

  def calculate_moves(coords, grid)
    queenMoves = rook_moves(coords, grid).map! { |x| x.position } + bishop_moves(coords, grid).map! { |x| x.position }
  end
end

class King < Piece
  attr_accessor :check

  def initialize(color, pos)
    @color = color
    @symbol = ' ♚ '
    @memory = [pos]
    @check = false
  end

  def calculate_moves(coords, grid)
    king_moves(coords, grid).map! { |x| x.position }
  end

  # for consistency I used the same methods to find pieces instead of going for grid[y][x]
  def castling(coords, grid)
    possibleMoves = []
    enemyMoves = map_enemies(grid, @color).map! { |x| x.possibleMoves }.flatten

    return possibleMoves if @memory.length != 1 || @check

    direction = [[coords.first, coords.last - 4], [coords.first, coords.last - 3], [coords.first, coords.last - 2], [coords.first, coords.last - 1],
                 [coords.first, coords.last + 1], [coords.first, coords.last + 2], [coords.first, coords.last + 3]]
    if find_cell(direction[0], grid).piece.instance_of?(Rook) && find_cell(direction[0], grid).piece.memory.length == 1
      possibleMoves << find_cell(direction[2], grid) if find_cell(direction[1],
                                                                  grid).piece.nil? && find_cell(direction[2],
                                                                                                grid).piece.nil? && find_cell(direction[3],
                                                                                                                              grid).piece.nil? && !enemyMoves.include?(find_cell(direction[1],
                                                                                                                                                                                 grid).position) && !enemyMoves.include?(find_cell(direction[2],
                                                                                                                                                                                                                                   grid).position) && !enemyMoves.include?(find_cell(
                                                                                                                                                                                                                                     direction[3], grid
                                                                                                                                                                                                                                   ).position)
    elsif find_cell(direction[6],
                    grid).piece.instance_of?(Rook) && find_cell(direction[6], grid).piece.memory.length == 1
      possibleMoves << find_cell(direction[5], grid) if find_cell(direction[5],
                                                                  grid).piece.nil? && find_cell(direction[4],
                                                                                                grid).piece.nil? && !enemyMoves.include?(find_cell(direction[5],
                                                                                                                                                   grid).position) && !enemyMoves.include?(find_cell(
                                                                                                                                                     direction[4], grid
                                                                                                                                                   ).position)
    end
    possibleMoves
  end

  # lazy copy for compile choices
  def castling_rook(coords, grid)
    possibleMoves = []
    return possibleMoves if @memory.length != 1 || @check

    direction = [[coords.first, coords.last - 4], [coords.first, coords.last - 3], [coords.first, coords.last - 2], [coords.first, coords.last - 1],
                 [coords.first, coords.last + 1], [coords.first, coords.last + 2], [coords.first, coords.last + 3]]

    if find_cell(direction[0], grid).piece.instance_of?(Rook) && find_cell(direction[0], grid).piece.memory.length == 1
      possibleMoves << find_cell(direction[0], grid) if find_cell(direction[1],
                                                                  grid).piece.nil? && find_cell(direction[2],
                                                                                                grid).piece.nil? && find_cell(
                                                                                                  direction[3], grid
                                                                                                ).piece.nil?
      possibleMoves << find_cell(direction[3], grid) if find_cell(direction[1],
                                                                  grid).piece.nil? && find_cell(direction[2],
                                                                                                grid).piece.nil? && find_cell(
                                                                                                  direction[3], grid
                                                                                                ).piece.nil?

    elsif find_cell(direction[6],
                    grid).piece.instance_of?(Rook) && find_cell(direction[6], grid).piece.memory.length == 1
      possibleMoves << find_cell(direction[6], grid) if find_cell(direction[5],
                                                                  grid).piece.nil? && find_cell(direction[4],
                                                                                                grid).piece.nil?
      possibleMoves << find_cell(direction[4], grid) if find_cell(direction[1],
                                                                  grid).piece.nil? && find_cell(direction[2],
                                                                                                grid).piece.nil? && find_cell(
                                                                                                  direction[3], grid
                                                                                                ).piece.nil?
    end
    possibleMoves.map! { |x| x.position }
  end

  private

  def king_moves(coords, grid)
    possibleMoves = []
    enemyMoves = map_enemies(grid, @color).map! { |x| x.possibleMoves }.flatten
    direction = [[coords.first + 1, coords.last], [coords.first - 1, coords.last], [coords.first, coords.last + 1], [coords.first, coords.last - 1],
                 [coords.first + 1, coords.last + 1], [coords.first - 1, coords.last - 1], [coords.first - 1, coords.last + 1], [coords.first + 1, coords.last - 1]]

    direction.each do |d|
      cell = find_cell(d, grid)
      piece = cell != false ? cell.piece : nil
      possibleMoves << cell unless !cell || piece && piece.color == @color || enemyMoves.include?(cell.position)
    end
    possibleMoves + castling(coords, grid)
  end

  def map_enemies(grid, color)
    enemies = []
    grid.each do |y|
      y.each do |x|
        enemies << x.piece if !x.piece.nil? && x.piece.color != color
      end
    end
    enemies
  end
end
