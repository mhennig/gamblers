require 'rubygems'
require 'backports'
require 'gosu'
# require "observer"
require 'singleton'

class Player
  #include Observable
  
  attr_reader :color, :pieces, :pits
  
  def initialize(color)
    @color = color
    @pieces = Array.new(4) { |i| Piece.new(color) }
  end
  
  def describe
    me
  end
  
  def running_pieces?
    !running_pieces.empty?
  end
  
  def running_pieces
    @pieces.select(&:in_game?)
  end
  
  def waiting_pieces?
   !waiting_pieces.empty?
  end
  
  def waiting_pieces
    @pieces.select{ |p| p.in_game? == false }
  end
  
  def empty_start?
    @pieces.select(&:on_start?).empty?
  end
  
  def was_six?
    @pits == 6
  end
  
  def play
    
    if not running_pieces?
      3.times { waiting_pieces.first.move_to(1) && break if (throw_dice == 6) }
    end
    
    if running_pieces?
      throw_dice
      if was_six? && waiting_pieces? && empty_start?
        waiting_pieces.first.move_to(1)
      else
        sorted_pieces = running_pieces.sort.reverse
        sorted_pieces.rotate! if sorted_pieces.last.on_start?
        sorted_pieces.each do |piece|
          target = piece.calculate_target(@pits)
          unless running_pieces.any?{ |other| other.on?(target)}
            piece.move_to(target) 
            puts "#{me} moved piece to #{target}"
            break
          end
        end 
      end
    end
    Game.instance.update(Time.now, self, :moved)   
  end
  
  private
  def me
    @color.to_s.capitalize
  end
  
  def throw_dice
    pits = 1 + rand(6)
    puts "#{me} has thrown a #{pits}"
    @pits = pits
  end
end

class Piece
  attr_reader :color, :position
  
  def initialize(color)
    @color = color
    @position = :out
  end
  
  def <=>(other)
    self.position <=> other.position 
  end
  
  def calculate_target(pits)
    (@position + pits)
  end
  
  def move_by pits
    move_to calculate_target(pits)
  end
  
  def move_to position
    @position = position
  end
  
  def in_game?
    (1..Board::NumberOfFields).include?(@position)
  end
  
  def on_start?
    @position == 1
  end
  
  def on?(target)
    @position == target
  end
  
  def asset
    "media/#{@color.to_s}.png"
  end
end

class Board
  
  StartFields = {:yellow => 1, :red => 11, :blue => 21, :green => 31}
  NumberOfFields = 40
    
  def initialize (width=640, height=480)
    @fields = {}
    @diameter, @margin = 30, 10
    @offset_x, @offset_y = (width-40*11)/2, (height-40 *11)/2
    @grid = [
        [5,11], [5,10], [5,9], [5,8], [5,7],
        [4,7], [3,7], [2,7], [1,7],
        [1,6], [1,5],
        [2,5], [3,5], [4,5], [5,5],
        [5,4], [5,3], [5,2], [5,1],
        [6,1], [7,1],
        [7,2], [7,3], [7,4], [7,5],
        [8,5], [9,5], [10,5], [11,5],
        [11,6], [11,7],
        [10,7], [9,7], [8,7], [7,7],
        [7,8], [7,9], [7,10], [7,11],
        [6,11]
      ]
  end
  
  def colors
    StartFields.keys
  end
  
  def offsets
    @grid.map do |coords| 
      x,y = coords
      x = @offset_x + (x-1) * (@diameter + @margin)
      y = @offset_y + (y-1) * (@diameter + @margin)
      [x,y]
    end 
  end
  
  def translate_position_of(piece)
    (piece.position + StartFields[piece.color] - 1) % NumberOfFields
  end
  
  def offset_for(piece)
    offsets[translate_position_of(piece)-1]
  end
  
  def field_available?
    
  end
end

class Game
  include Singleton
  
  attr_reader :board, :players
  
  def initialize
    @board   = Board.new
    @players = Array.new(@board.colors.size) { |i| create_player(@board.colors[i]) }
  end
  
  def update(time, observable, message = :none)
    case 
    when observable.is_a?(Player), message == :moved
      puts "#{observable.describe}: #{message.to_s}"
      rotate unless (observable.pits == 6)
    
    when observable.is_a?(Player), message.is_a?(String)
      puts "#{observable.describe}: #{message}"
    
    else
      puts "Recieved message from a #{observable.class.name}"
    end
  end
  
  def running?
    @status == :running
  end
  
  def pause
    @status = :paused
  end
  
  def run
    @status = :running
    current.play
  end
  
  private
  def rotate
    @players.rotate!
    puts "#{@players.first.describe} is next"
    @players
  end
  
  def current
    @players.first
  end
  
  def create_player(color)
    player = Player.new(color)
  end
end

class Screen < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Gamblers"
    @game        = Game.instance
  end
  
  def button_down(id)
    close  if id == Gosu::KbEscape
  end
  
  def update
    @last_update ||= Gosu.milliseconds
    if (Gosu.milliseconds-@last_update > 2000)
      @last_update = Gosu.milliseconds
      Game.instance.run
      Game.instance.pause
    end
  end
  
  def draw
    draw_board
    draw_pieces
  end
  
  private
  def draw_pieces
    @game.players.each do |player|
      player.pieces.each_with_index do |piece, number|
        image = Gosu::Image.new(self, piece.asset, true)
        if piece.in_game?
          x,y = @game.board.offset_for(piece)
          image.draw(x, y, 3)
        end
      end
    end
  end
  
  def draw_board
    @game.board.offsets.each do |coords|
      image = Gosu::Image.new(self, "media/empty.png", true)
      image.draw(coords.first, coords.last, 1)
    end
  end
    
end

window = Screen.new
window.show