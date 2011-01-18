module Gamblers
  class Chat    
    def initialize(node, host, password)
      @node = node
      @host = host
      @im = Jabber::Simple.new("#{@node}@#{@host}", password)
    end
    
    def client
      @im
    end
    
    def say to, message
      to = (to.is_a?(Symbol) ? "#{to.to_s}@#{@host}" : to)
      @im.deliver(to, message)
    end
  end
end