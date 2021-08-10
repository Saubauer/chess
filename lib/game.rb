class Game
	#Game functions like turns, moves, save, etc..
	attr_reader :board, :win
	def initialize(player1, player2, board=Board.new)
		@board = board
		@player1 = player1
		@player2 = player2
		@prompt = TTY::Prompt.new
		@win = nil
		@last_move = @board.memory.last
		@message = $string[31]
		menu 
	end

	def menu(player=@player1)
		@message = @board.check? ? "#{@board.check_color}" : @message
		mainBox(@board.draw_board, "#{@message}\n#{@last_move.nil? ? "" : $string[32]+ @last_move}")
		@message = ""
		choices = {$string[33] => 1, $string[34] => 2, $string[35] => 3, $string[8] => 4}
		item = @prompt.select($string[36], choices, cycle: true)
		if item == 1
			player_move(player)
		elsif item == 3
			@win = "something"
			end_game(@player1.color) if player == @player2
			end_game(@player2.color) if player == @player1
		elsif item == 2
				if player == @player1
					save_game 
					menu(player)
				else
					@message = $string[37]
					menu(player)
				end
		else
			return
		end
	end

	private

	def player_move(player)
		choices = @board.compile_choices(@board.compile_moves(player.color))
		back = {$string[8] => [1]}
		merge = choices.merge(back)
		if player.instance_of?(Player)
			item = @prompt.select($string[33], merge, cycle: true, per_page: 8)
			if item.length == 4
				@board.move_piece(item[0],item[1])
				@board.move_piece(item[2],item[3])
				@board.compile_moves(player.color)
				@board.memory << merge.invert[item]
				continue(player)
			elsif item.length == 3
				@board.move_piece(item.first,item.last)
				@board.delete_piece(item[1])
				@board.compile_moves(player.color)
				@board.memory << merge.invert[item]
				continue(player)
			elsif item.length == 2
				@board.move_piece(item.first,item.last)
				@board.compile_moves(player.color)
				@board.memory << merge.invert[item]
				continue(player)
			else
				menu(player)
			end
		else
			item = choices.to_a.sample[1]
			if item.length == 4
				@board.move_piece(item[0],item[1])
				@board.move_piece(item[2],item[3])
				@board.compile_moves(player.color)
				@board.memory << choices.invert[item]
				continue(player)
			elsif item.length == 3
				@board.move_piece(item.first,item.last)
				@board.delete_piece(item[1])
				@board.compile_moves(player.color)
				@board.memory << choices.invert[item]
				continue(player)
			elsif item.length == 2
				@board.move_piece(item.first,item.last)
				@board.compile_moves(player.color)
				@board.memory << choices.invert[item]
				continue(player)
			end
		end
	end

	def end_game(color)
		winBox(color)
	end

	def save_game
		Dir.mkdir('sav') unless Dir.exist?('sav')
		savename = @prompt.ask($string[38]) do |q|
  					q.validate ->(input) {input =~ /\A\w+\Z/ && input.length <= 10}
  					q.messages[:valid?] = $string[39]
					end
		filename = "sav/#{savename}.json"
		File.open(filename, 'w') do |file|
			file.puts Oj.dump({:player1 => @player1, :player2 => @player2, :board => @board })
		end
	end

	def continue(player)
		if @board.lazy_checkmate == "Black wins!"
			@win = "black"
			return end_game("black")
		elsif @board.lazy_checkmate == "White wins!" 
			@win = "white"
			return end_game("white")
		end
		if @board.stalemate?(player.color)
			@win = "Something"
			return end_game("draw")
		end

		@board.promotion
		@last_move = @board.memory.last if @board.memory.size > 1
		@last_move = @board.memory.to_s if @board.memory.size == 1
		 if player == @player1 && @player2.instance_of?(Player)
			menu(@player2)
		elsif player == @player1 && @player2.instance_of?(Computer)
			player_move(@player2)
		elsif player == @player2
			menu(@player1)	
		end
	end
end

class Player
	attr_reader :color
	def initialize(color)
		@color=color
	end
end

class Computer
	attr_reader :color
	def initialize(color)
		@color=color
	end
end