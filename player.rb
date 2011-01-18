require 'rubygems'
require 'blather/client'

#set_status(:available, "Lets get ready")

# say "manager@im.freebsd.local", "Gruezo"
# puts my_roster
# 


subscription :request? do |s|
  write_to_stream s.approve!
end

message :chat?, :body do |m|
  # client.roster.each { |ri| puts ri.node }
  puts m.body
end
