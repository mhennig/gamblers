module Gamblers  
  class Game
    include Singleton
    attr_reader :board
  
    def initialize
      @board   = Board.new
    end
    
    def players
      @players ||= Array.new(@board.colors.size) { |i| create_player(@board.colors[i]) }
      # @players.each { |p| puts "#{p.color} is #{p.available? ? "available" : "not available"}" }
    end
    
    def available_players
      players.select{ |p| p.available? }
    end
    
    def chat
      @chat ||= Chat.new("game", jabber_host, "game")
    end
    
    def jabber_host
      "im.freebsd.local"
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
      players.each do |player| 
        player.pieces.each { |p| puts "#{p.color} is on #{p.position}"}
      end
    end
  
    def resume
      @status = :running
    end
  
    def play
      if current && running?
        begin
          current.play 
        rescue PlayerUnavailable => error
          available_players.each { |player| chat.say(player.color, "#{current.describe} is unavailable") }
          current.reset && rotate && retry
        end
      end
    end
  
    private
    def rotate
      check_availabilities
      players.rotate!
      chat.say players.first.jid, "Preparing..."
      players
    end
    
    def check_availabilities
      chat.client.presence_updates do |friend, presence|
        players.select{ |p| p.jid == friend.to_s}.first.presence = presence.to_s
        puts "Received presence update from #{friend.to_s}: #{presence}"
      end
    end
    
    def current
      players.first
    end
  
    def create_player(color)
      player = Player.new(color)
      player.jid = "#{color}@#{jabber_host}"
      player
    end
  end
end