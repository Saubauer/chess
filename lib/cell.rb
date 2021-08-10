class Cell
	#just a storage for each part of the board
	attr_accessor :symbol, :piece, :highlight
	attr_reader :position, :coords

	def initialize(bgcolor, position, coords)
		@coords = coords
		@bgcolor = bgcolor
		@position = position
		@symbol = "   "
		@highlight = false
		@piece = nil
	end
	
	def to_s
		@symbol = @piece.symbol if @piece != nil
		@symbol = "   " if @piece.nil?
		if !@highlight
			if @bgcolor == "white"
				@symbol = Paint[@symbol, nil, $theme["1"]]
			else
				@symbol = Paint[@symbol, nil, $theme["2"]]
			end
		else
			@symbol = Paint[@symbol, nil, :red]
		end
	end

end