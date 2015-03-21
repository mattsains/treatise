require File.dirname(__FILE__)+'/instructions.rb'

program={}
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
      else
        program[cur_byte] = line
        cur_byte += 2
        cur_byte += 2*instruction.operands.count(:imm16) 
      end
    end
  end

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
      reg_count = 0
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
            reg_count += 6
          else
            puts "Error: #{instruction.opcode} expects a register in position #{index+1}"
          end
        elsif expected_operand == :imm16
          if labels.has_key? parts[index+1]
            imm = labels[parts[index+1]] - (code.length*2)
            puts "#{code.length*2}: #{imm} (lbl:#{parts[index+1]})"
          else
            imm = Integer(parts[index+1])
            puts "#{code.length*2}: #{imm} (immediate)"
          end
          code << imm
        end
      end
    end
  }
  puts code.inspect
  IO.write("a.out", code.pack('s*'))
end


