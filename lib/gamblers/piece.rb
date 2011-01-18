module Gamblers
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
    end
  
    def move_by pits
      move_to calculate_target(pits)
    end
  
    def move_to(position)
      Game.instance.chat.say color, ["Uuuh! Why did you kick me out?", "Damn! I was kicked!", "Argh. You kicked me off!", "©ªª∆¥µπå ∂dœ∆º∂"].shuffle.first  if position == :out
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
end