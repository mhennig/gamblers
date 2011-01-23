require 'rubygems'
require 'gosu'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'lib/gamblers'

class Screen < Gosu::Window
  
  attr_reader :game
  
  def initialize(jid, jabber_password, moves_per_minute)
    super(640, 480, false)
    self.caption = "Gamblers"
    @wait_for_next_move = (60/moves_per_minute*1000)
    @game = Gamblers::Game.instance
    @game.jid = jid
    @game.jabber_password = jabber_password
    @game.resume
  end
  
  def button_down(id)
    close if id == Gosu::KbEscape
    (@game.running? ? @game.pause : @game.resume) if id == Gosu::KbSpace
  end
  
  def update
    @last_update ||= Gosu.milliseconds
    if (Gosu.milliseconds-@last_update > @wait_for_next_move)
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
    
    # @game.board.colors.each do |color|
    #       @game.board.offsets(@game.board.homes[color]).each do |coords|
    #         image = Gosu::Image.new(self, "media/empty.png", true)
    #         image.draw(coords.first, coords.last, 1)
    #       end
    #     end
  end
end


if ARGV.size != 3
  puts "Usage:"
  puts "ruby #{$0} <jid> <password> <moves_per_minute>"
  exit
else   
  jid, password, moves_per_minute = ARGV
  gamblers = Screen.new(jid, password, moves_per_minute.to_i)
  gamblers.show
end


