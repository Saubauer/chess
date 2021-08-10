module Drawing
  # Screen outputs
  def cls
    system('cls') || system('clear')
  end

  # tried TTY::Screen first, but couldn't come to a satisfying conclusion
  def mainBox(left = '', right = '')
    cls
    width = 80
    height = 28
    boxRight = TTY::Box.frame(top: 3, left: (width / 2.3).to_i, padding: [(height / 6.to_i), 4], width: (width / 2).to_i,
                              height: (height / 1.5).to_i, align: :left, title: { bottom_right: $string[3] }) do
      right
    end
    boxLeft = TTY::Box.frame(top: 3, left: 1, padding: [2, 0], width: (width / 2.3).to_i, height: (height / 1.5).to_i,
                             title: { top_left: $string[2] }, align: :center) do
      left
    end
    print boxLeft + boxRight + "\n"
  end

  def introBox
    cls
    font1 = TTY::Font.new('3d')
    font2 = TTY::Font.new('doom')
    box = TTY::Box.frame(top: 2, width: (TTY::Screen.width - 2).to_i, height: (TTY::Screen.height - 2).to_i, align: :center,
                         padding: [(TTY::Screen.height / 4).to_i, 1]) do
      font1.write($string[0]) +
        "#{$string[1]}\n" +
        font2.write('Saubauer')
    end
    print box
    prompt = TTY::Prompt.new
    prompt.keypress($string[40])
  end

  def endBox
    cls
    font = TTY::Font.new('starwars')

    box = TTY::Box.frame(top: 2, width: (TTY::Screen.width - 2).to_i, height: (TTY::Screen.height - 2).to_i, align: :center,
                         padding: [(TTY::Screen.height / 8).to_i, 1]) do
      font.write($string[13]) +
        "\n" + font.write($string[14]) +
        "\n" + font.write($string[15])
    end
    print box
    prompt = TTY::Prompt.new
    prompt.keypress("#{$string[41]} :countdown ...", timeout: 3)
    cls
  end

  def winBox(color)
    cls
    font = TTY::Font.new('standard')

    box = TTY::Box.frame(top: 2, width: (TTY::Screen.width - 2).to_i, height: (TTY::Screen.height - 2).to_i, align: :center,
                         padding: [(TTY::Screen.height / 8).to_i, 1]) do
      if color == 'black'
        font.write($string[42]) +
          "\n" + font.write($string[44])
      elsif color == 'white'
        font.write($string[43]) +
          "\n" + font.write($string[44])
      else
        font.write($string[45])
      end
    end
    print box
    prompt = TTY::Prompt.new
    prompt.keypress("#{$string[41]} :countdown ...", timeout: 3)
    cls
  end
end
