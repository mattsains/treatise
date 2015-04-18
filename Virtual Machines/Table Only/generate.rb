#!/usr/bin/env ruby
require "rubygems"
require "liquid"

require File.dirname(__FILE__)+"/../Common/instructions.rb"
@instructions = $instructions

$debug = true

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
        if instr.allowed? i, j
          puts "  dq #{instr.opcode}_#{i}_#{j}"
        else
          puts "  dq fault"
        end
      end
    end
    
  when 3
    6.times do |k|
      6.times do |j|
        6.times do |i|
          if instr.allowed? i, j, k
            puts "  dq #{instr.opcode}_#{i}_#{j}_#{k}"
          else
            puts "  dq fault"
          end
        end
      end
    end
  else
    puts "  %error \"Four-operand codes not implemented\""
  end
end

puts "code:"
@instructions.each do |instr|
  puts "  ;; #{instr.opcode} has #{instr.operands} operands and "
  
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
          if instr.allowed? i, j
            puts "  #{instr.opcode}_#{i}_#{j}:"
            puts render instr.opcode, {'i' => i, 'j' => j}
            puts render "dispatch"
          end 
        end 
      end

    when 3
      6.times do |k|
        6.times do |j|
          6.times do |i|
            if instr.allowed? i, j, k
              puts "  #{instr.opcode}_#{i}_#{j}_#{k}:"
              puts render instr.opcode, {'i' => i, 'j' => j, 'k' => k}
              puts render "dispatch"
            end
          end
        end
      end
    else 
      puts "  %error \"Four-operand codes not implemented\""
    end 
end 

puts "fault:"
puts ";; Virtual Machine error"
