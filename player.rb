require 'rubygems'
require 'blather/client'

subscription :request? do |s|
  write_to_stream s.approve!
end

message :chat?, :body do |m|
  puts m.body
end
