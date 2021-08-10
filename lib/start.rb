class Start
  # options, load, new, etc.. menuprompts
  include Colors
  def initialize
    @game = nil
    @prompt = TTY::Prompt.new
    introBox
    main_menu
  end

  private

  def main_menu
    mainBox
    choices = { $string[5] => 1, $string[6] => 2, $string[7] => 3 }
    item = @prompt.select($string[4], choices, cycle: true)
    option_menu if item == 2
    game_menu if item == 1
    quit if item == 3
  end

  def game_menu
    mainBox('', $string[20])
    item = @prompt.select($string[16], cycle: true) do |menu|
      menu.choice $string[17], 1 if @game
      menu.choice $string[18], 2
      menu.choice $string[19], 3
      menu.choice $string[8], 4
    end
    if item == 2
      if @game.nil?
        new_game
      else
        choice = @prompt.yes?($string[21])
        game_menu unless choice
        new_game if choice
      end
    elsif item == 3
      load_game
      @game = nil if @game.win
      game_menu
    elsif item == 1
      @game.menu
      @game = nil if @game.win
      game_menu
    else
      main_menu
    end
  end

  def new_game
    mainBox('', $string[22])
    choices = { $string[23] => 1, $string[24] => 2, $string[8] => 3 }
    item = @prompt.select($string[25], choices, cycle: true)
    if item == 1
      @game = Game.new(Player.new('white'), Computer.new('black'))
      @game = nil if @game.win
    elsif item == 2
      @game = Game.new(Player.new('white'), Player.new('black'))
      @game = nil if @game.win
    end
    game_menu
  end

  def load_game
    return game_menu unless Dir.exist?('sav')

    mainBox('', $string[26])
    choices = []
    save = nil
    Dir.foreach('sav') { |x| choices << x if x != '.' && x != '..' }
    choices << $string[8].downcase
    item = @prompt.select($string[26], choices, cycle: true)
    if item == $string[8].downcase
      game_menu
    else
      File.open("sav/#{item}", 'r') do |file|
        save = file.read
      end
      save = Oj.load(save)
      @game = Game.new(save[:player1], save[:player2], save[:board])
    end
  end

  def option_menu
    mainBox('', $string[27])
    choices = { $string[9] => 1, $string[10] => 2, $string[11] => 3, $string[8] => 4 }
    item = @prompt.select($string[6], choices, cycle: true)
    main_menu if item == 4
    language_menu if item == 3
    theme_menu if item == 2
    color_menu if item == 1
  end

  def language_menu
    mainBox('', $string[28])
    choices = { 'English' => 1, 'Deutsch' => 2, $string[8] => 3 }
    item = @prompt.select($string[12], choices, cycle: true)

    if $string == Lang::EN && item == 1 || $string == Lang::DE && item == 2
      language_menu
    elsif item == 1
      change_lang('en')
      introBox
      option_menu
    elsif item == 2
      change_lang('de')
      introBox
      option_menu
    else
      option_menu
    end
  end

  def theme_menu
    symbolA = Paint[' ♙ ', $theme['3'], $theme['1']]
    symbolB = Paint[' ♜ ', $theme['4'], $theme['2']]
    symbolC = Paint[' ♞ ', $theme['3'], $theme['2']]
    symbolD = Paint[' ♛ ', $theme['4'], $theme['1']]
    teststr = ' ' + symbolA + symbolB + symbolC + symbolD
    mainBox(teststr, $string[29])

    choices = { "#{$string[10]} 1" => 1, "#{$string[10]} 2" => 2, "#{$string[10]} 3" => 3, $string[8] => 4 }
    item = @prompt.select($string[10], choices, cycle: true)
    if item != 4
      change_theme(item)
      theme_menu
    else
      option_menu
    end
  end

  def color_menu
    symbolA = Paint[' ♙ ', $theme['3'], $theme['1']]
    symbolB = Paint[' ♜ ', $theme['4'], $theme['2']]
    symbolC = Paint[' ♞ ', $theme['3'], $theme['2']]
    symbolD = Paint[' ♛ ', $theme['4'], $theme['1']]
    teststr = ' ' + symbolA + symbolB + symbolC + symbolD
    mainBox(teststr, $string[30])

    choices = { 'True Color' => 1, '256' => 2, '16' => 3, '8' => 4, $string[8] => 5 }
    item = @prompt.select($string[9], choices, cycle: true)
    if item == 1
      Paint.mode = 0xFFFFFF
      color_menu
    elsif item == 2
      Paint.mode = 256
      color_menu
    elsif item == 3
      Paint.mode = 16
      color_menu
    elsif item == 4
      Paint.mode = 8
      color_menu
    else
      option_menu
    end
  end

  def quit
    endBox
  end
end
