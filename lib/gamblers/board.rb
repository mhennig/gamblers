module Gamblers
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
end