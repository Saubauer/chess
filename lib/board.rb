class Board
	#Main class for the board
	attr_accessor :memory
	def initialize
		@X_HASH = Hash["a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5, "f" => 6, "g" => 7, "h" => 8]
		@grid = map_grid
		@whitePieces = []
		@blackPieces = []
		@deadPieces = []
		@memory = [nil]
		add_pieces
	end

	def delete_piece(pos)
		position = find_pos(pos)
		if position.piece.color == "white"
			@whitePieces.delete(pos)
		elsif position.piece.color == "black"
			@blackPieces.delete(pos)
		end
		@deadPieces << position.piece
		position.piece = nil
	end

	def move_piece(pos1, pos2)
		position1 = find_pos(pos1)
		position2 = find_pos(pos2)
		return if !position1 || !position2 

		if position1.piece.color == "white"
			@whitePieces.delete(pos1)
			@whitePieces << pos2
		elsif position1.piece.color == "black"
			@blackPieces.delete(pos1)
			@blackPieces << pos2
		end

		if position2.piece != nil && position2.piece.color == "white"
			@whitePieces.delete(pos2)
		elsif position2.piece != nil && position2.piece.color == "black"
			@blackPieces.delete(pos2)
		end
		@deadPieces << position2.piece if position2.piece

		position2.piece = position1.piece
		position1.piece = nil
		position2.piece.memory << pos2
	end

def compile_moves(color)
		moveablePieces = {}
		if color == "white"
			@whitePieces.each {|piece|
				moveablePieces[piece] = find_pos(piece).piece unless valid_moves(pick_piece(color, piece)).empty?
			}
		elsif color == "black"
			@blackPieces.each {|piece|
				moveablePieces[piece] = find_pos(piece).piece unless valid_moves(pick_piece(color, piece)).empty?
			}
		end
		moveablePieces
	end

	def compile_choices(moves)
		choices = {}
		normal_moves = {}
		special_moves = {}
		capture_moves = {}
		urgent_moves = {}


		moves.each {|pos, piece|
			piece.possibleMoves.each {|pos2|
				if check? && find_pos(pos2).piece.instance_of?(King) && find_pos(pos2).piece.check
					urgent_moves["!#{piece.symbol + pos} => #{$string[51]} #{pos2}!"] = [pos, pos2]
					next
				end
				if check? && find_pos(pos).piece.instance_of?(King) && find_pos(pos).piece.check
					urgent_moves["!#{piece.symbol + pos} => #{$string[51]} #{pos2}!"] = [pos, pos2] if find_pos(pos2).piece
					urgent_moves["!#{piece.symbol + pos} => #{pos2}!"] = [pos, pos2] if find_pos(pos2).piece.nil?
					next
				end
				if en_passant?(pos,pos2)
				cell = find_pos(pos)
				enemy_pos = cell.piece.en_passant_enemy(cell.coords,@grid)
				special_moves["#{piece.symbol + pos} => EN PASSANT #{pos2}"] = [pos, enemy_pos, pos2].flatten(1)
				next
				end
				if castling?(pos,pos2)
				cell = find_pos(pos)
				rook_pos = cell.piece.castling_rook(cell.coords,@grid)
				special_moves["#{piece.symbol + pos} => #{$string[52]} #{pos2}"] = [[pos, pos2],rook_pos].flatten(1) 
				next
				end

				capture_moves["#{piece.symbol + pos} => #{$string[51]} #{pos2}"] = [pos, pos2] if find_pos(pos2).piece
				normal_moves["#{piece.symbol + pos} => #{pos2}"] = [pos, pos2] if find_pos(pos2).piece.nil?
			}
		}
		choices.merge(urgent_moves, capture_moves, special_moves, normal_moves)
	end

	def promotion
		prompt = TTY::Prompt.new
		choices = {$string[47] => 1, $string[48] => 2, $string[49] => 3, $string[50] => 4 }

		@grid[0].each {|cell|
			if cell.piece && cell.piece.instance_of?(Pawn)
				choice = prompt.select($string[46], choices, cycle: true)
				if choice == 1
					cell.piece = Queen.new(cell.piece.color, cell.position)
				elsif choice == 2
					cell.piece = Rook.new(cell.piece.color, cell.position)
				elsif choice == 3
					cell.piece = Bishop.new(cell.piece.color, cell.position)
				elsif choice == 4
					cell.piece = Knight.new(cell.piece.color, cell.position)
				end
			end							
		}

		@grid[7].each {|cell|
			if cell.piece && cell.piece.instance_of?(Pawn)
				choice = prompt.select($string[46], choices, cycle: true)
				if choice == 1
					cell.piece = Queen.new(cell.piece.color, cell.position)
				elsif choice == 2
					cell.piece = Rook.new(cell.piece.color, cell.position)
				elsif choice == 3
					cell.piece = Bishop.new(cell.piece.color, cell.position)
				elsif choice == 4
					cell.piece = Knight.new(cell.piece.color, cell.position)
				end
			end							
		}
	end

	def check?
		whiteKing = find_king("white")
		blackKing = find_king("black")
		whiteKing.piece.check = false
		blackKing.piece.check = false

		@whitePieces.each {|pos|
			cell = find_pos(pos)
			possibleMoves = cell.piece.calculate_moves(cell.coords, @grid)
			blackKing.piece.check = true if possibleMoves.include?(blackKing.position)
		}

		@blackPieces.each {|pos|
			cell = find_pos(pos)
			possibleMoves = cell.piece.calculate_moves(cell.coords, @grid)
			whiteKing.piece.check = true if possibleMoves.include?(whiteKing.position)
		}

		return true if whiteKing.piece.check == true || blackKing.piece.check == true
		false
	end

	def check_color
		return false if !check?
		whiteKing = find_king("white")
		blackKing = find_king("black")

		if whiteKing.piece.check
			return "White King is checked!"
		elsif blackKing.piece.check
			return "Black King is checked!"
		else 
			return "Both Kings are checked!"
		end
	end

	def stalemate?(color)
		return true if !check? && safe_moves(color).empty?
		false
	end

	def lazy_checkmate
		if find_king("white") == false
			return "Black wins!"
		elsif find_king("black") == false
			return "White wins!"
		end	
	end

	def draw_board
		output = ""
		count = 8
			output += " a  b  c  d  e  f  g  h \n"
			output += " ┌────────────────────────┐\n"
		@grid.reverse.each {|y|
			output +=" #{count}│"
				y.each{|x|
					output += x.to_s
				}
			output +="│#{count}\n"
			count -= 1
		}
		output +=" "
		output += "└────────────────────────┘\n"
		output += " a  b  c  d  e  f  g  h \n"
		output
	end

	private

	def map_grid
		grid = []
		y = 1
		coordY = 0
		8.times do |i|
			arr = []
			colorCount = 1
			coordX = 0
			x = 1
			8.times do |o|
				coords = [coordY, coordX]
				position = @X_HASH.invert[x].to_s + y.to_s
				if colorCount.odd? && y.odd?
					o = Cell.new("black", position, coords)
				elsif colorCount.odd? && y.even?
					o = Cell.new("white", position, coords)	
				elsif colorCount.even? && y.odd?
					o = Cell.new("white", position, coords)	
				else
					o = Cell.new("black", position, coords)
				end
				arr << o
				colorCount += 1
				coordX += 1
				x += 1
			end
			grid << arr
			coordY += 1
			y += 1
		end
		grid
	end

	def add_pieces
		@grid[0].each {|cell|
			if cell.position == "a1" || cell.position == "h1"
				cell.piece = Rook.new("white",cell.position) 
			elsif cell.position == "b1" || cell.position == "g1"
				cell.piece = Knight.new("white",cell.position) 
			elsif cell.position == "c1" || cell.position == "f1"
				cell.piece = Bishop.new("white",cell.position)
			elsif cell.position == "d1"
				cell.piece = Queen.new("white",cell.position)
			else
				cell.piece = King.new("white",cell.position)
			end			
		}
		@grid[1].each {|cell| cell.piece = Pawn.new("white",cell.position)} 
		@grid[6].each {|cell| cell.piece = Pawn.new("black",cell.position)} 

		@grid[7].each {|cell|
			if cell.position == "a8" || cell.position == "h8"
				cell.piece = Rook.new("black",cell.position) 
			elsif cell.position == "b8" || cell.position == "g8"
				cell.piece = Knight.new("black",cell.position) 
			elsif cell.position == "c8" || cell.position == "f8"
				cell.piece = Bishop.new("black",cell.position)
			elsif cell.position == "d8"
				cell.piece = Queen.new("black",cell.position)
			else
				cell.piece = King.new("black",cell.position)
			end			
		}
		map_pieces
	end

	def map_pieces
		@grid.each {|y|
			y.each {|x|
				if x.piece != nil && x.piece.color == "black"
					@blackPieces << x.position
				elsif x.piece != nil && x.piece.color == "white"
					@whitePieces << x.position
				end
			}
		}
	end

	def find_pos(pos)
		@grid.each {|y|
			y.each {|x|
				return x if pos == x.position
			}
		}
		return false
	end

	def find_king(color)
		@grid.each {|y|
			y.each {|x|
				return x if x.piece.instance_of?(King) && x.piece.color == color
			}
		}
		return false
	end

	def pick_piece(color, pos)
		if color == "white" && @whitePieces.include?(pos)
			return find_pos(pos)
		elsif color == "black" && @blackPieces.include?(pos)
			return find_pos(pos)
		else
			return false
		end
	end

	def valid_moves(cell)
		return false if !cell.instance_of?(Cell)
		cell.piece.possibleMoves = cell.piece.calculate_moves(cell.coords, @grid)
	end

	def en_passant?(pos, pos2)
		cell = find_pos(pos)
		return false if !cell.piece.instance_of?(Pawn)
		arr = cell.piece.en_passant(cell.coords, @grid).map! {|x| x.position}
		return true if arr.include?(pos2)
		false
	end

	def castling?(pos, pos2)
		cell = find_pos(pos)
		return false if !cell.piece.instance_of?(King)
		arr = cell.piece.castling(cell.coords, @grid).map! {|x| x.position}
		return true if arr.include?(pos2)
		false
	end

	def safe_moves(color)
		compile_moves("black")
		compile_moves("white")
		whiteMoves = []
		blackMoves = []

		@whitePieces.each {|pos|
			cell = find_pos(pos)
			whiteMoves << cell.piece.possibleMoves
			whiteMoves << cell.position if color == "white"
		}
		@blackPieces.each {|pos|
			cell = find_pos(pos)
			blackMoves << cell.piece.possibleMoves
			blackMoves << cell.position if color == "black"
		}
		blackMoves.flatten!(2).uniq!
		whiteMoves.flatten!(2).uniq!

		if color == "black"
			return output = blackMoves - whiteMoves
		elsif color == "white"
			return output = whiteMoves - blackMoves
		end
	end

end