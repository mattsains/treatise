#!/usr/bin/env ruby
require File.dirname(__FILE__)+"/../Common/instructions.rb"

$offsets.each {|opcode,offset|
  puts "#{opcode}_offset equ #{offset}"
}

puts "%macro dispatch 0"
puts "    lodsw"

for i in 0...$instructions.length
  instruction = $instructions[i]
  next_instr = $instructions[i+1]
  puts ".#{instruction.opcode}_dispatch:"
  if next_instr
    puts "   cmp rax, #{next_instr.opcode}_offset"
    puts "   jge .#{next_instr.opcode}_dispatch"
  end
  puts "   sub rax, #{instruction.opcode}_offset"
  puts "   jmp #{instruction.opcode}"
end

puts "%endmacro"
