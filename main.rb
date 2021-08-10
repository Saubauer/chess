require_relative './lib/colors'
require_relative './lib/start'
require_relative './lib/game'
require_relative './lib/piece'
require_relative './lib/board'
require_relative './lib/cell'
require_relative './lib/lang'
require_relative './lib/drawing'

require 'paint'
require 'tty-box'
require 'tty-font'
require 'tty-prompt'
require 'tty-screen'
require 'oj'

include Drawing
include Lang

start = Start.new

#themes
