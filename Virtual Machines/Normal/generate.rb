#!/usr/bin/env ruby
require File.dirname(__FILE__)+"/../Common/instructions.rb"

puts "vectors:"
$instructions.each_index {|i|
  instruction = $instructions[i]
  puts "dq #{instruction.opcode}"
}
