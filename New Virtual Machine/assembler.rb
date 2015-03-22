#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/instructions.rb'
require 'securerandom'

real_reg= (ARGV[1] == '-r') || (ARGV[2] == '-r')

program={}
program_epilogue=[]
const_labels={}
labels={}
cur_byte=0

def hex n
  ("%04x"%n).tr('..','ff').reverse[0, 4].reverse
end

File.open(ARGV[0],"r") do |f|

  puts ""
  puts "Understood Code:"
  puts "================"
  
  f.each_line do |line|
    line = line.split(';')[0] #remove comments
    line.strip! #remove spaces
    next if line.empty? #skip empty lines
    
    if line.end_with? ':'
      label = line.match(/[^\d\W]\w*/)[0]
      puts "#{label}:"
      labels[label] = cur_byte
    elsif line.start_with? 'dw'
      program[cur_byte] = line
      cur_byte += 2
    elsif line.start_with? 'dq'
      program[cur_byte] = line
      cur_byte += 8
    else
      parts=[]
      line.split.each {|s| parts+=s.split(',')}
      puts " #{parts[0]} "+parts[1, parts.length-1].join(', ')
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
          if const_labels.has_key? val
            label = const_labels[val]
            
          else
            label = "l"+SecureRandom.uuid.tr('-','_')[0,9]+"imm_#{val}"
            const_labels[val] = label
            val0 = val&0xFFFF
            val1 = (val>>16)&0xFFFF
            val2 = (val>>32)&0xFFFF
            val3 = (val>>48)&0xFFFF
            program_epilogue << "#{label}:"
            program_epilogue << "dq #{val}"
          end
          parts[index+1] = label
          line = parts[0]+" "+parts[1, parts.length-1].join(",")
          
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
    elsif line.start_with? 'dq'
      program[cur_byte] = line
      cur_byte += 8
    else
      puts "Error - invalid data in program epilogue"
    end
  }
  puts ""
  puts "Symbol table:"
  puts "============="
  labels.each {|name, addr|
    puts "#{name}:".rjust(20)+addr.to_s(16).rjust(4)
  }
  
  puts ""
  puts "Code generation:"
  puts "================"
  
  code = []
  program.each {|addr,instr|
    parts=[]
    instr.split.each {|s| parts+=s.split(',')}

    if parts[0] == 'dw'
      literal = Integer(parts[1])
      puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"     (dw #{literal})"
      code << literal
    elsif parts[0] == 'dq'
      literal = Integer(parts[1])
      puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"     (dq #{literal})"
      code << (literal&0xFFFF)
      code << ((literal>>16)&0xFFFF)
      code << ((literal>>32)&0xFFFF)
      code << ((literal>>48)&0xFFFF)
    else
      instruction = $instructions.find {|inst| inst.opcode == parts[0]}
      reg_count = 1
      if instruction.operands[0] == :reg
        print "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex instruction.offset)+" (#{instruction.opcode})"
      else
        puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex instruction.offset)+" (#{instruction.opcode})"
      end
      code << instruction.offset
      
      instruction.operands.each_index do |index|
        expected_operand = instruction.operands[index]
        operand = parts[index+1]
        
        if expected_operand == :reg
          if (operand.start_with? 'r') || (operand.start_with? 'p')
            reg = operand[1,operand.length-1].to_i
            reg_text = if real_reg then $r[reg] else "r#{reg}" end

            if instruction.operands[index+1] == :reg
              print " +#{reg*reg_count}(#{reg_text})"
            else
              puts " +#{reg*reg_count}(#{reg_text})"
            end
            code[-1] += reg*reg_count
            reg_count *= 6
          else
            puts "Error: #{instruction.opcode} expects a register in position #{index+1}"
          end
        elsif (expected_operand == :imm16) || (expected_operand == :immptr64)
          if labels.has_key? operand
            imm = labels[operand] - (code.length*2)
            puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex imm)+" (lbl: #{parts[index+1]})"
          elsif (operand.start_with? '[') && (operand.end_with? ']')
            imm = Integer(operand[1, operand.length-2])
            puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex imm)+" (ptr)"
          elsif expected_operand == :imm16
            imm = Integer(operand)
            puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"#{imm}".rjust(4)+" (const)"
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
  elsif (ARGV[1] == '-r') && (ARGV[2] != nil)
    filename = ARGV[2]
  else
    filename = ARGV[1]
  end

  puts ""
  puts "Output:"
  puts "======="

  word_count=0
  print (hex 0)+": "
  code.each {|word|
    word_count+=1
    if word_count%4==0
      puts (hex word)
      print (hex word_count)+": "
    else
      print (hex word)+" "
    end
  }
  puts ""
  puts ""
  IO.write(filename, code.pack('s*'))
end



