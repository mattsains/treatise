class Inst
  attr_accessor :opcode
  attr_accessor :allowed_trivial
  attr_accessor :operands
  def initialize(opcode, operands, allowed_trivial=true)
    @opcode = opcode
    @operands = operands
    @allowed_trivial = allowed_trivial
  end

  def valid(r1, r2)
    if @allowed_trivial then true else r1!=r2 end
  end
end

instructions = []

#instructions with two arguments where the trivial case is allowed
instructions += ['add', 'mul'].collect {|opcode| Inst.new opcode, 2}

#instructions with one argument
instructions +=
  [
    
    'null', 'jmp', 'jmpf', 'switch', 'jcmpc', 'jnullp',
    'alloc', 'in', 'out', 'err', 'movc'
  ].collect {|opcode| Inst.new opcode, 1}


#instructions with two arguments where the trivial case is not allowed
instructions +=
  [
    'sub', 'div', 'and', 'or', 'xor', 'shl', 'shr',
    'sar', 'mov', 'movp', 'jcmp', 'jeqp'
  ].collect {|opcode| Inst.new opcode, 2, false}

offsets =
  {
    'add' => 0, 'addc' => 36, 'sub' => 42, 'subc' => 78, 'csub' => 84,
    'mul' => 90, 'mulc' => 126, 'div' => 132, 'divc' => 168, 'and' => 174,
    'andc' => 210, 'or' => 216, 'orc' => 252, 'xor' => 258, 'shl' => 294,
    'shlc' => 330, 'cshl' => 336, 'shr' => 342, 'shrc' => 378, 'cshr' => 384,
    'sar' => 390, 'sarc' => 426, 'csar' => 432, 'mov' => 438, 'movp' => 474,
    'movc' => 510, 'null' => 516, 'jmp' => 522, 'jmpf' => 523, 'switch' => 524,
    'jcmp' => 530, 'jcmpc' => 566, 'jeqp' => 572, 'jnullp' => 608,
    'alloc' => 614, 'in' => 620, 'out' => 626, 'err' => 632
  }

imm_length =
  {
    'addc' => 2, 'subc' => 2, 'csub' => 2, 'mulc' => 2, 'divc' => 2,
    'andc' => 2, 'orc' => 2, 'cshl' => 2, 'cshr' => 2, 'csar' => 2,
    'movc' => 2, 'jmpf' => 2, 'alloc' => 2, 'shlc' => 2, 'shrc' => 2,
    'sarc' => 2, 'jmp' => 2, 'err' => 2
  }

# Yeah this is bad but it is still the nicest way
def is_int? str
  Integer(str) rescue return false
  return true
end

# Sort instructions by their numbers
instructions.sort! {|a,b| offsets[a.opcode] <=> offsets[b.opcode]}

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
      cur_byte+=2
    else
      parts=[]
      line.split.each {|s| parts+=s.split(',')}
      puts parts
      instruction = instructions.find {|inst| inst.opcode == parts[0]}
      #if instruction.operands!=parts.length-1
      #  puts "Error - #{instruction.opcode} given wrong number of arguments "+
      #       "(#{parts.length-1} for #{instruction.operands})"
      #else
        program[cur_byte] = line
        cur_byte+=2
        if imm_length.has_key? instruction.opcode 
          cur_byte+=imm_length[instruction.opcode]
        end
      #end
      
    end
  end

  code = []
  program.each {|addr,instr|
    parts=[]
    instr.split.each {|s| parts+=s.split(',')}
    instruction = instructions.find {|inst| inst.opcode == parts[0]}

    if parts[0]!='dw' && instruction.operands > 0
            
      if (parts[1].start_with? 'r') || (parts[1].start_with? 'p')
        ni = parts[1][1,parts[1].length-1].to_i
      elsif (is_int? parts[1]) and imm_length[parts[0]] > 0
        imm1 = Integer(parts[1])
      elsif (labels.has_key? parts[1]) and imm_length[parts[0]] > 0
        imm1 = labels[parts[1]] - (addr+2)
      end
      
      if instruction.operands > 1 || imm_length[parts[0]]>0
        if (parts[2].start_with? 'r') || (parts[2].start_with? 'p')
          nj = parts[2][1,parts[2].length-1].to_i
        elsif (is_int? parts[2]) && imm_length[parts[0]] > 0
          imm2 = Integer(parts[2])
        elsif (labels.has_key? parts[2]) && imm_length[parts[0]] > 0
          imm2 = labels[parts[2]] - (addr+4)
        end
      end      
    end

    if parts[0] == 'dw'
      puts "#{addr}: dw #{Integer(parts[1])}"
      code[addr/2] = Integer(parts[1])
    else
      puts "#{addr}: #{offsets[parts[0]]} (#{parts[0]})"
      code[addr/2]=offsets[parts[0]]
      if ni != nil
        puts "#{addr}: +#{ni} (r#{ni})"
        code[addr/2] += ni
      end
      if nj != nil
        puts "#{addr}: +#{nj*6} (r#{nj})"
        code[addr/2] += ni*6
      end
      addr+=2
    end
    
    if imm1 != nil
      puts "#{addr}: #{imm1} (imm1)"
      code[addr/2] = imm1
      addr+=2
    end
    if imm2 != nil
      puts "#{addr}: #{imm2} (imm2)"
      code[addr/2] = imm2
      addr+=2
    end
  }
  puts code.inspect
  IO.write("a.out", code.pack('s*'))
end



