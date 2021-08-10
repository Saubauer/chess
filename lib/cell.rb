class Cell
  # just a storage for each part of the board
  attr_accessor :symbol, :piece, :highlight
  attr_reader :position, :coords

  def initialize(bgcolor, position, coords)
    @coords = coords
    @bgcolor = bgcolor
    @position = position
    @symbol = '   '
    @highlight = false
    @piece = nil
  end

  def to_s
    @symbol = @piece.symbol unless @piece.nil?
    @symbol = '   ' if @piece.nil?
    @symbol = if !@highlight
                if @bgcolor == 'white'
                  Paint[@symbol, nil, $theme['1']]
                else
                  Paint[@symbol, nil, $theme['2']]
                end
              else
                Paint[@symbol, nil, :red]
              end
  end
end
