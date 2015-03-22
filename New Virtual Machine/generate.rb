#!/usr/bin/env ruby
require "rubygems"
require "liquid"

require File.dirname(__FILE__)+"/instructions.rb"
@instructions = $instructions
@r = $r

$debug = true

# Define register mapping

#Some scratch registers
@s = (11..15).collect {|n| "r#{n}"}

def render path, vars={}
  path='templates/'+path
  if $debug and !File.exist?(File.expand_path(path))
    ""
  else
    content = File.read(File.expand_path(path)).gsub('{%','<%').gsub('%}','%>').gsub(/[\{\}]/, '{'=>'{{', '}'=>'}}').gsub('<%','{%').gsub('%>','%}')
    Liquid::Template.parse(content).render({'r' => @r, 's' => @s, 'instructions' => @instructions}.merge(vars))
  end
end


# Now time to generate the code
puts "vector:"
@instructions.each do |instr|
  case instr.operands.count(:reg)
  when 0
    puts "  dq #{instr.opcode}_all"
    
  when 1
    6.times do |i|
      puts "  dq #{instr.opcode}_#{i}"
    end

  when 2
    6.times do |j|
      6.times do |i|
        if instr.allow_trivial || (i!=j)
          puts "  dq #{instr.opcode}_#{i}_#{j}"
        else
          puts "  dq fault"
        end
      end
    end
    
  else
    puts "  %error \"Three-operand codes not implemented\""
  end
end

puts "code:"
@instructions.each do |instr|
  puts "  ;; #{instr.opcode} has #{instr.operands} operands and "+
       "#{instr.allow_trivial ? "allows" : "disallows"} trivials"
  
    case instr.operands.count(:reg)
    when 0 
      puts "  #{instr.opcode}_all:"
      puts render instr.opcode
      puts render "dispatch"
    when 1 
      6.times do |i|
        puts "  #{instr.opcode}_#{i}:"
        puts render instr.opcode, {'i' => i}
        puts render "dispatch"
      end 
      
    when 2 
      6.times do |j|
        6.times do |i|
          if instr.allow_trivial || (i!=j)
            puts "  #{instr.opcode}_#{i}_#{j}:"
            puts render instr.opcode, {'i' => i, 'j' => j}
            puts render "dispatch"
          end 
        end 
      end 
      
    else 
      puts "  %error \"Three-operand codes not implemented\""
    end 
end 

puts "fault:"
puts ";; Virtual Machine error"
