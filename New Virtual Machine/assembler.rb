#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/instructions.rb'
require 'securerandom'

program={}
program_epilogue=[]
labels={}
cur_byte=0
File.open(ARGV[0],"r") do |f|
  f.each_line do |line|
    line.strip!
    
    if line.end_with? ':'
      label = line.match(/[^\d\W]\w*/)[0]
      puts "Label #{label} found"
      labels[label] = cur_byte
    elsif line.start_with? 'dw'
      program[cur_byte]=line
      cur_byte += 2
    else
      parts=[]
      line.split.each {|s| parts+=s.split(',')}
      puts parts.inspect
      instruction = $instructions.find {|inst| inst.opcode == parts[0]}
      if instruction.operands.length!=parts.length-1
        puts "Error - #{instruction.opcode} given wrong number of arguments "+
             "(#{parts.length-1} for #{instruction.operands})"
      end
      instruction.operands.each_index {|index|
        expected_operand = instruction.operands[index]
        operand = parts[index+1]
        if (expected_operand == :immptr64) && (is_int? operand)
          val = Integer(operand)
          label = "l"+SecureRandom.uuid.tr('-','_')
          parts[index+1] = label
          line = parts[0]+" "+parts[1, parts.length-1].join(",")
          val0 = val&0xFFFF
          val1 = (val>>16)&0xFF
          val2 = (val>>32)&0xFF
          val3 = (val>>48)&0xFF
          program_epilogue << "#{label}:"
          program_epilogue << "dw #{val0}"
          program_epilogue << "dw #{val1}"
          program_epilogue << "dw #{val2}"
          program_epilogue << "dw #{val3}"
        end
      }
      program[cur_byte] = line
      cur_byte += 2
      cur_byte += 2*(instruction.operands.count(:imm16) + instruction.operands.count(:immptr64))
    end
  end

  program_epilogue.each {|line|
    #These can only have constants and labels
    if line.end_with? ':'
      label = line.match(/[^\d\W]\w*/)[0]
      labels[label] = cur_byte
    elsif line.start_with? 'dw'
      program[cur_byte] = line
      cur_byte += 2
    else
      puts "Error - invalid data in program epilogue"
    end
  }
  puts program.inspect
  puts labels.inspect
  puts ""
  puts "Code generation:"
  puts "================"
  
  code = []
  program.each {|addr,instr|
    parts=[]
    instr.split.each {|s| parts+=s.split(',')}
    
    if parts[0] == 'dw'
      literal = Integer(parts[1])
      puts "#{code.length*2}: dw #{literal}"
      code << literal
    else
      instruction = $instructions.find {|inst| inst.opcode == parts[0]}
      reg_count = 1
      if instruction.operands[0] == :reg
        print "#{code.length*2}: #{instruction.offset} (#{instruction.opcode})"
      else
        puts "#{code.length*2}: #{instruction.offset} (#{instruction.opcode})"
      end
      code << instruction.offset
      
      instruction.operands.each_index do |index|
        expected_operand = instruction.operands[index]
        operand = parts[index+1]
        
        if expected_operand == :reg
          if (operand.start_with? 'r') || (operand.start_with? 'p')
            reg = operand[1,operand.length-1].to_i
            if instruction.operands[index+1] == :reg
              print " +#{reg*reg_count}(r#{reg})"
            else
              puts " +#{reg*reg_count}(r#{reg})"
            end
            code[-1] += reg*reg_count
            reg_count *= 6
          else
            puts "Error: #{instruction.opcode} expects a register in position #{index+1}"
          end
        elsif (expected_operand == :imm16) || (expected_operand == :immptr64)
          if labels.has_key? operand
            imm = labels[operand] - (code.length*2)
            puts "#{code.length*2}: #{imm} (lbl:#{parts[index+1]})"
          elsif (operand.start_with? '[') && (operand.end_with? ']')
            imm = Integer(operand[1, operand.length-2])
            puts "#{code.length*2}: #{imm} (ptr)"
          elsif expected_operand == :imm16
            imm = Integer(operand)
            puts "#{code.length*2}:  #{imm} (const)"
          else
            puts "Error: Couldn't make anything from #{operand}"
          end
          code << imm
        end
      end
    end
  }

  if ARGV[1] == nil
    filename = "a.out"
  else
    filename = ARGV[1]
  end
  
  puts code.inspect
  IO.write(filename, code.pack('s*'))
end


