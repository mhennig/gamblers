require 'rubygems'
require 'backports'
require 'gosu'
require 'singleton'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'gamblers/piece'
require 'gamblers/player'
require 'gamblers/board'
require 'gamblers/game'

module Gamblers 
end