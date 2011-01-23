module Gamblers
  
  class PlayerUnavailable < RuntimeError; end
  
  
  class Player

    attr_accessor :jid, :presence
    attr_reader :color, :pieces, :announcement, :pits

    def initialize(color)
      @color = color
      reset
    end
    
    def reset
      @pieces = Array.new(4) { |i| Piece.new(color, i) }
    end
    
    def available?
      (presence.to_s == "online")
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
      @pieces.select { |piece| piece.in_game? }
    end

    def waiting_pieces
      @pieces.select { |piece| piece.out? }
    end

    def empty_start?
      @pieces.select{ |piece| piece.on_start? }.empty?
    end
    
    def finished?
      @pieces.select{ |p| p.home? }.size == 4
    end
    
    def was_six?
      @pits == 6
    end

    def play
      raise PlayerUnavailable, "#{describe} is currently not available" unless available?
      
      @announcement = nil

      if running_pieces?
        throw_dice
        if was_six? && !waiting_pieces.empty? && empty_start?
          announce(waiting_pieces.first, 1)
          
        else
          sorted_pieces = running_pieces.sort #.reverse
          #sorted_pieces.rotate! if sorted_pieces.last.on_start? && !waiting_pieces.empty?
          sorted_pieces.each do |piece|
            
            target = piece.calculate_target(@pits) 
            if target.is_a?(Integer) && pieces.select{ |other| other.on?(target)}.empty?
              announce(piece, target)
              puts @announcement
              break
            else
              puts "rejected #{target}"
            end
          end
        end
      elsif not waiting_pieces.empty?  
        3.times { announce(waiting_pieces.first, 1) && break if (throw_dice == 6) }
      end
      
      Game.instance.chat.say jid, ["Finished", "Next", "Ready", "That's it"].shuffle.first
      Game.instance.update(Time.now, self, :finished_move)
    end

    private
    def me
      @color.to_s.capitalize
    end

    def throw_dice
      pits = 1 + rand(6)
      Game.instance.chat.say jid, "Thrown dice and got #{pits} pits"
      @pits = pits
    end
  end
end