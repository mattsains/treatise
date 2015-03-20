#!/usr/bin/env ruby
require "rubygems"
require "liquid"

$debug = true

# Define register mapping
r = {
  0 => 'rbx',
  1 => 'rcx',
  2 => 'rdx',
  3 => 'r8',
  4 => 'r9',
  5 => 'r10',
  :pc => 'rsi',
  :fp => 'rbp'
}

#Some scratch registers
s = (11..15).collect {|n| "r#{n}"}

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
    'addc', 'subc', 'csub', 'mulc', 'divc', 'andc', 'orc',
    'shlc', 'cshl', 'shrc', 'cshr', 'sarc', 'csar', 'movc',
    'null', 'jmp', 'jmpf', 'switch', 'jcmpc', 'jnullp',
    'alloc', 'in', 'out', 'err'
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

# Sort instructions by their numbers
instructions.sort! {|a,b| offsets[a.opcode] <=> offsets[b.opcode]}
@instructions = instructions
@r=r
@s=s

def render path, vars={}
  path='templates/'+path
  if $debug and !File.exist?(File.expand_path(path))
    ""
  else
    content = File.read(File.expand_path(path))
    z={'a'=>6}
    Liquid::Template.parse(content).render({'r' => @r, 's' => @s, 'instructions' => @instructions}.merge(vars))
  end
end


# Now time to generate the code
puts "vector:"
instructions.each do |instr|
  case instr.operands 
  when 0
    puts "  dq #{instr.opcode}"
    
  when 1
    6.times do |i|
      puts "  dq #{instr.opcode}_#{i}"
    end

  when 2
    6.times do |i|
      6.times do |j|
        if instr.valid i, j
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
instructions.each do |instr|
  puts "  ;; #{instr.opcode} has #{instr.operands} operands and "+
       "#{instr.allowed_trivial ? "allows" : "disallows"} trivials"
  
    case instr.operands 
    when 0 
      puts "  #{instr.opcode}:"
      puts render instr.opcode
      puts render "dispatch"
    when 1 
      6.times do |i|
        puts "  #{instr.opcode}_#{i}:"
        puts render instr.opcode, {'i' => i}
        puts render "dispatch"
      end 
      
    when 2 
      6.times do |i|
        6.times do |j|
          if instr.valid i, j 
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
