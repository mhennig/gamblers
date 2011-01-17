require 'rubygems'
require 'backports'
require 'gosu'
require 'singleton'

class Player
  attr_reader :color, :pieces, :announcement, :pits
  
  def initialize(color)
    @color = color
    @pieces = Array.new(4) { |i| Piece.new(color, i) }
  end
  
  def describe
    me
  end
  
  def announce(piece, position)
    @announcement = [piece, position]
  end
  
  def move_announced?
    !announcement.nil?
  end
  
  def running_pieces?
    !running_pieces.empty?
  end
  
  def running_pieces
    @pieces.select(&:in_game?)
  end
  
  def waiting_pieces
    @pieces.select(&:out?)
  end
  
  def empty_start?
    @pieces.select(&:on_start?).empty?
  end
  
  def was_six?
    @pits == 6
  end
  
  def play
    @announcement = nil
    
    if waiting_pieces.size == 4
      3.times { waiting_pieces.first.move_to(1) && break if (throw_dice == 6) }
    end
    
    if running_pieces?
      throw_dice
      if was_six? && !waiting_pieces.empty? && empty_start?
        announce(waiting_pieces.first, 1)
      else
        sorted_pieces = running_pieces.sort.reverse
        sorted_pieces.rotate! if sorted_pieces.last.on_start? && !waiting_pieces.empty?
        sorted_pieces.each do |piece|
          target = piece.calculate_target(@pits)
          unless running_pieces.any?{ |other| other.on?(target)}
            announce(piece, target)
            break
          end
        end 
      end
    end
    Game.instance.update(Time.now, self, :finished_move)
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
  attr_reader :color, :position, :number
  
  def initialize(color, number)
    @color = color
    @position = :out
    @number = number
  end
  
  def <=>(other)
    self.position <=> other.position 
  end
  
  def calculate_target(pits)
    target = (@position + pits)
    #target > Board::NumberOfFields ? :home : target
  end
  
  def move_by pits
    move_to calculate_target(pits)
  end
  
  def move_to(position)
    puts "#{color.to_s.capitalize}: Uuuuuuuuuuuh!" if position == :out
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
  
  def out?
    @position == :out
  end
  
  def home?
    @position > Board::NumberOfFields
  end
  
  def asset
    "media/#{@color.to_s}.png"
  end
end

class Board

  StartFields = {:yellow => 1, :red => 11, :blue => 21, :green => 31}
  NumberOfFields = 40
    
  attr_reader :round, :outs, :homes
  
  def initialize (width=640, height=480)
    @fields = []
    @diameter, @margin = 30, 10
    @offset_x, @offset_y = (width-40*11)/2, (height-40 *11)/2
    @round = [ [5,11], [5,10], [5,9], [5,8], [5,7],
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
               [6,11] ]
      
    @outs =  { :yellow => [[1,11], [2,11], [1,10], [2,10]],
               :red => [[1,1], [2,1], [1,2], [2,2]],
               :blue => [[10,1], [11,1], [10,2], [11,2]],
               :green => [[10,10], [11,10], [10,11], [11,11]] }
              
    @homes = { :yellow => [[6,10], [6,9], [6,8], [6,7]],
               :red => [[2,6], [3,6], [4,6], [5,6]],
               :blue => [[6,2], [6,3], [6,4], [6,5]],
               :green => [[10,6], [9,6], [8,6], [7,6]] }
    
  end
  
  def colors
    StartFields.keys
  end
  
  def offsets(grid)
    grid.map do |coords| 
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
    if piece.in_game?
      offsets(@round)[translate_position_of(piece)-1]
      
    elsif piece.out?
      offsets(@outs[piece.color])[piece.number]
      
    elsif piece.home?
      offsets(@homes[piece.color])[piece.number]
      
    else
      [-100, -100]
    end
  end
  
  def set(piece, target)
    @fields[@fields.index(piece)] = nil unless @fields.index(piece).nil?
    piece.move_to target
    position_on_field = translate_position_of(piece)
    remove_piece_from(position_on_field)
    @fields[position_on_field] = piece
  end
  
  def remove_piece_from(position)
    @fields[position].move_to(:out) if @fields[position].is_a?(Piece)
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
    when observable.is_a?(Player), message == :finished_move
      if observable.move_announced?
        piece, target = observable.announcement
        @board.set(piece, target)
      end
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
    current.pieces.each { |p| puts "#{p.color} is on #{p.position}"}
  end
  
  def resume
    @status = :running
  end
  
  def play
    current.play if running?
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
    close if id == Gosu::KbEscape
    (@game.running? ? @game.pause : @game.resume) if id == Gosu::KbSpace
  end
  
  def update
    @last_update ||= Gosu.milliseconds
    if (Gosu.milliseconds-@last_update > 10)
      @last_update = Gosu.milliseconds
      Game.instance.play
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