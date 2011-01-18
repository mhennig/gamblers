require 'rubygems'
require 'gosu'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'lib/gamblers'

class Screen < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Gamblers"
    @game        = Gamblers::Game.instance
  end
  
  def button_down(id)
    close if id == Gosu::KbEscape
    (@game.running? ? @game.pause : @game.resume) if id == Gosu::KbSpace
  end
  
  def update
    @last_update ||= Gosu.milliseconds
    if (Gosu.milliseconds-@last_update > 3000)
      @last_update = Gosu.milliseconds
      @game.play
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
        x,y = @game.board.offset_for(piece)
        image.draw(x, y, 3)
      end
    end
  end
  
  def draw_board
    @game.board.offsets(@game.board.round).each do |coords|
      image = Gosu::Image.new(self, "media/empty.png", true)
      image.draw(coords.first, coords.last, 1)
    end
    
    @game.board.colors.each do |color|
      @game.board.offsets(@game.board.homes[color]).each do |coords|
        image = Gosu::Image.new(self, "media/empty.png", true)
        image.draw(coords.first, coords.last, 1)
      end
    end
  end
end

gamblers = Screen.new
gamblers.show