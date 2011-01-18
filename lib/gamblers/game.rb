module Gamblers  
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
end