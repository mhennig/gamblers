require 'rubygems'
require 'backports'
require 'singleton'
require 'xmpp4r-simple'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'gamblers/piece'
require 'gamblers/player'
require 'gamblers/board'
require 'gamblers/game'
require 'gamblers/chat'

#module Gamblers 
#end