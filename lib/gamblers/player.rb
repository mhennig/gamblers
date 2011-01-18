module Gamblers
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
end