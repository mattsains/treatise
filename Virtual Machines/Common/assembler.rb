#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/instructions.rb'

real_reg = ARGV.include? '-r'
conventional = ARGV.include? '-c'
argv_without_flags = ARGV - ['-r', '-c']

program={}
program_epilogue=[]
const_labels={}
obj_member_labels={}

labels={}
cur_byte=0

def hex n
  ("%04x"%n).tr('..','ff').reverse[0, 4].reverse
end

if argv_without_flags[0] == nil
  puts "Matt's assembler"
  puts ""
  puts "Invocation:"
  puts " assembler.rb input_file [output_file] [-r -c]"
  puts ""
  puts " output_file defaults to a.out"
  puts " -r flag prints the names of the actual registers used in x64,"
  puts "   to make debugging a little easier."
  puts " -c flag generates code in the more conventional bytecode format"
  puts "   defined by Douglas:"
  puts "    bits  |  meaning"
  puts "   --------------------"
  puts "    0..3  |  register 2"
  puts "    4..7  |  register 1"
  puts "    8..16 |  opcode"
else
  File.open(argv_without_flags[0],"r") do |f|

    puts ""
    puts "Understood Code:"
    puts "================"

    busy_object = nil
    busy_object_keys = []
    
    f.each_line do |line|
      line = line.split(';')[0] #remove comments
      line.strip! #remove spaces
      next if line.empty? #skip empty lines
      
      if line.start_with? 'object ' or line.start_with? 'function' or busy_object
        parts = line.split(' ')
        
        if parts[0] == 'object' or parts[0] == 'function'
          busy_object = {:name => parts[1]}
          puts ""
          puts "#{parts[0]} #{parts[1]}"
          busy_object_keys = []
        elsif parts[0] == 'ptr' or parts[0] == 'int'
          busy_object[parts[1]] = parts[0]
          puts "  #{parts[1]}: #{parts[0]}"
          busy_object_keys << parts[1]
        else
          #align objects defs to 16 bytes
          for i in (cur_byte)...(cur_byte/16.0).ceil*16
            if i % 2 == 0
              program[i] = 'dw 0'
            end
          end
          cur_byte = (cur_byte/16.0).ceil*16
          labels[busy_object[:name]] = cur_byte

          program[cur_byte] = "dq " + (busy_object.length - 1).to_s
          cur_byte += 8

          bitmap = 0
          busy_object_keys.each_index {|i|
            k = busy_object_keys[i]
            unless k == :name
              obj_member_labels[busy_object[:name]+"."+k] = i
              if i % 64 == 0 and i != 0
                program[cur_byte] = "dq #{bitmap}"
                cur_byte += 8
                bitmap = 0
              end
              bitmap |= (busy_object[k] == 'ptr'?1:0) << (i%64)
            end
          }

          unless bitmap == 0
            program[cur_byte] = "dq #{bitmap}"
            cur_byte += 8
          end

          busy_object = nil
          busy_object_keys = []
        end
      elsif line.end_with? ':'
        label = line.match(/[^\d\W]\w*/)[0]
        puts "#{label}:"
        labels[label] = cur_byte
      elsif line.start_with? 'dw'
        program[cur_byte] = line
        cur_byte += 2
      elsif line.start_with? 'dq'
        program[cur_byte] = line
        cur_byte += 8
      elsif line == 'align 8'
        for i in (cur_byte)...(cur_byte/8.0).ceil*8
          if i % 2 == 0
            program[i] = 'dw 0'
          end
        end
        cur_byte = (cur_byte/8.0).ceil * 8
      else
        parts=[]
        line.split.each {|s| parts+=s.split(',')}
        puts " #{parts[0]} "+parts[1, parts.length-1].join(', ')
        instruction = $instructions.find {|inst| inst.opcode == parts[0]}
        if instruction.operands.length!=parts.length-1
          raise "Error - #{instruction.opcode} given wrong number of arguments "+
                "(#{parts.length-1} for #{instruction.operands})"
        end
        last_index = 0
        instruction.operands.each_index {|index|
          last_index=index
          expected_operand = instruction.operands[index]
          operand = parts[index+1]
          if expected_operand == :immptr64 and is_int? operand
            val = Integer(operand)
            if const_labels.has_key? val
              label = const_labels[val]
              
            else
              label = "_imm_#{val.to_s.tr('-','m')}"
              const_labels[val] = label
              program_epilogue << "align 8"
              program_epilogue << "#{label}:"
              program_epilogue << "dq #{val}"
            end
            parts[index+1] = label
            line = parts[0]+" "+parts[1, parts.length-1].join(",")
          end
        }
        if instruction.operands[-1] == :arbimm16
          for index in (last_index+1)...parts.length
            operand = parts[index+1]
            val = Integer(operand)
            if const_labels.has_key? val
              label = const_labels[val]
              
            else
              label = "_imm_#{val.to_s.tr('-','m')}"
              const_labels[val] = label
              program_epilogue << "align 8"
              program_epilogue << "#{label}:"
              program_epilogue << "dq #{val}"
            end
            parts[index+1] = label
            line = parts[0]+" "+parts[1, parts.length-1].join(",")
          end
        end
        
        program[cur_byte] = line
        cur_byte += 2*(parts.length - instruction.operands.count(:reg))
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
      elsif line == 'align 8'
        for i in (cur_byte)...(cur_byte/8.0).ceil*8
          if i % 2 == 0
            program[i] = 'dw 0'
          end
        end
        cur_byte = (cur_byte/8.0).ceil * 8
      else
        raise "Error - invalid data in program epilogue"
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

      labels.each {|k,v| puts "    #{k}:" if v==(code.length*2)}
        
      if parts[0] == 'dw'
        literal = Integer(parts[1])
        if literal >= 0
          raise "Constant #{literal} too big for 16 bit" if (literal>>16)!=0
        else
          raise "Constant #{literal} too big for 16 bit" if (~(literal>>16))!=0
        end
        puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"     (dw #{literal})"
        code << literal
      elsif parts[0] == 'dq'
        literal = Integer(parts[1])
        if literal >= 0
          raise "Constant #{literal} too big for 64 bit" if (literal>>64)!=0
        else
          raise "Constant #{literal} too big for 64 bit" if (~(literal>>64))!=0
        end
        puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"     (dq #{literal})"
        code << (literal&0xFFFF)
        code << ((literal>>16)&0xFFFF)
        code << ((literal>>32)&0xFFFF)
        code << ((literal>>48)&0xFFFF)
      else
        instruction = $instructions.find {|inst| inst.opcode == parts[0]}
        raise "No such instruction '#{parts[0]}'" unless instruction
        reg_count = 1
        if instruction.operands[0] == :reg
          if conventional
            print "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex $instructions.index(instruction) << 6)+" (#{instruction.opcode})"
          else
            print "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex instruction.offset)+" (#{instruction.opcode})"
          end
        else
          if conventional
            puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex $instructions.index(instruction) << 6)+" (#{instruction.opcode})"
          else
            puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex instruction.offset)+" (#{instruction.opcode})"
          end
        end
        if conventional
          code << ($instructions.index(instruction) << 6)
        else
          code << instruction.offset
        end
        
        instruction_end = code.length*2
        last_index = 0
        instruction.operands.each_index do |index|
          last_index = index
          expected_operand = instruction.operands[index]
          operand = parts[index+1]
          
          if expected_operand == :reg
            if (operand.start_with? 'r') || (operand.start_with? 'p')
              reg = operand[1,operand.length-1].to_i
              reg_text = if real_reg then $r[reg] else "r#{reg}" end

              if conventional
                if reg_count == 1
                  reg_val = reg << 3
                else
                  reg_val = reg
                end
                if instruction.operands[index+1] == :reg
                  print " +#{reg_val}(#{reg_text})"
                else
                  puts " +#{reg_val}(#{reg_text})"
                end
              else
                if instruction.operands[index+1] == :reg
                  print " +#{reg*reg_count}(#{reg_text})"
                else
                  puts " +#{reg*reg_count}(#{reg_text})"
                end
              end
              if conventional
                if reg_count == 1
                  code[-1] |= reg << 3
                else
                  code[-1] |= reg
                end
              else
                code[-1] += reg*reg_count
              end
              reg_count *= 6
            else
              puts "Error: #{instruction.opcode} expects a register in position #{index+1}"
            end
          elsif (expected_operand == :imm16) || (expected_operand == :immptr64)
            if labels.has_key? operand
              imm = labels[operand] - instruction_end
              puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex imm)+" (lbl: #{parts[index+1]})"
            elsif (operand.start_with? '[') && (operand.end_with? ']')
              imm = Integer(operand[1, operand.length-2])
              puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex imm)+" (ptr)"
            elsif expected_operand == :imm16
              if obj_member_labels.has_key? operand
                imm = obj_member_labels[operand]
              else
                imm = Integer(operand)
              end
              puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"#{imm}".rjust(4)+" (const)"
            else
              raise "Error: Couldn't make anything from #{operand}"
            end
            code << imm
          end
          if instruction.operands[-1] == :arbimm16
            for index in (last_index+1)...parts.length
              operand = parts[index+1]
              if labels.has_key? operand
                imm = labels[operand] - instruction_end
                puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex imm)+" (lbl: #{parts[index+1]})"
              elsif (operand.start_with? '[') && (operand.end_with? ']')
                imm = Integer(operand[1, operand.length-2])
                puts "#{(code.length*2).to_s(16)}: ".rjust(4)+(hex imm)+" (ptr)"
              elsif expected_operand == :imm16
                imm = Integer(operand)
                puts "#{(code.length*2).to_s(16)}: ".rjust(4)+"#{imm}".rjust(4)+" (const)"
              else
                raise "Error: Couldn't make anything from #{operand}"
              end
              code << imm
            end
          end
        end
      end
    }

    if argv_without_flags[1] == nil
      filename = "a.out"
    else
      filename = argv_without_flags[1]
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
        print (hex word_count*2)+": " unless word_count==code.length
      else
        print (hex word)+" "
      end
    }
    puts ""
    puts ""
    IO.write(filename, code.pack('s*'))
  end
end



