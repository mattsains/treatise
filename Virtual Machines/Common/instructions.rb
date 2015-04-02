class Inst
  attr_accessor :opcode #mnemonic
  attr_accessor :allow_trivial
  attr_accessor :operands # a list of symbols - :reg, :imm16, :immptr64, :arbimm16
  attr_accessor :offset

  def initialize(opcode, operands, allow_trivial=true)
    @opcode = opcode
    @operands = operands
    @allow_trivial = allow_trivial
  end
end

instructions = []

#instructions with just one operand (register)
instructions +=
  ['null', 'in', 'out']
  .collect {|opcode| Inst.new opcode, [:reg]}

#instructions with just one operand (immediate)
instructions +=
  ['jmp','err']
  .collect {|opcode| Inst.new opcode, [:imm16]}

instructions +=
  ['jmpf']
  .collect {|opcode| Inst.new opcode, [:immptr64]}

#instructions with two registers only where the trivial case is allowed
instructions +=
  ['add','mul']
  .collect {|opcode| Inst.new opcode, [:reg, :reg]}

#instructions with two registers where the trivial case is disallowed
instructions +=
  ['sub','div','and','or','xor','shl','shr','sar','mov','movp','newpa','newa']
  .collect {|opcode| Inst.new opcode, [:reg, :reg], false}

#instructions with one register and one 16b immediate
instructions +=
  ['addc','mulc','divc','andc','orc','movc']
  .collect {|opcode| Inst.new opcode, [:reg, :immptr64]}

instructions +=
  ['shlc','shrc','sarc','getl','getlp','newp']
  .collect {|opcode| Inst.new opcode, [:reg, :imm16]}

#instructions with one ptr and one register
instructions +=
  ['csub','cshl','cshr','csar']
  .collect {|opcode| Inst.new opcode, [:immptr64, :reg]}

instructions +=
  ['setl','setlp']
  .collect {|opcode| Inst.new opcode, [:imm16, :reg]}

#Three-operand instructions
instructions +=
  ['getm','getmp','setm','setmp']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16]}

instructions +=
  ['geta','getap','seta','setap','getb','setb']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :reg]}

#strange instructions
instructions +=
  ['switch']
  .collect {|opcode| Inst.new opcode, [:reg, :imm16, :arbimm16]}

instructions +=
  ['jcmp']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16, :imm16, :imm16], false}

instructions +=
  ['jcmpc']
  .collect {|opcode| Inst.new opcode, [:reg, :immptr64, :imm16, :imm16, :imm16]}

instructions +=
  ['jeqp']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16, :imm16], false}

instructions +=
  ['jnullp']
  .collect {|opcode| Inst.new opcode, [:reg, :imm16, :imm16]}

instructions +=
  ['call']
  .collect {|opcode| Inst.new opcode, [:imm16, :imm16, :imm16]}

instructions +=
  ['ret']
  .collect {|opcode| Inst.new opcode, []}

offsets =
  {
    'add' => 0, 'addc' => 36, 'sub' => 42, 'csub' => 72, 'mul' => 78,
    'mulc' => 114, 'div' => 120, 'divc' => 150, 'and' => 156, 'andc' => 186,
    'or' => 192, 'orc' => 222, 'xor' => 228, 'shl' => 258, 'shlc' => 288,
    'cshl' => 294, 'shr' => 300, 'shrc' => 330, 'cshr' => 336, 'sar' => 342,
    'sarc' => 372, 'csar' => 378, 'mov' => 384, 'movp' => 414, 'movc' => 444,
    'null' => 450, 'getl' => 456, 'getlp' => 62, 'setl' => 68, 'setlp' => 74,
    'getm' => 80, 'getmp' => 16, 'setm' => 52, 'setmp' => 88, 'geta' => 24,
    'getap' => 04, 'seta' => 84, 'setap' => 164, 'getb' => 344, 'setb' => 524,
    'jmp' => 704, 'jmpf' => 705, 'switch' => 706, 'jcmp' => 1712,
    'jcmpc' => 1742, 'jeqp' => 1748, 'jnullp' => 1778, 'call' => 1784,
    'ret' => 785, 'newp' => 786, 'newpa' => 792, 'newa' => 822, 'in' => 852,
    'out' => 1858, 'err' => 1864
  }

# Yeah this is bad but it is still the nicest way
def is_int? str
  Integer(str) rescue return false
  return true
end

instructions.each {|instruction| instruction.offset = offsets[instruction.opcode]}

# Sort instructions by their numbers
instructions.sort_by! {|instruction| instruction.offset }

# Validate instructions
instructions.each {|instruction|
  raise "#{instruction.opcode} has no offset defined!" unless instruction.offset
}
offsets.each {|k,v|
  raise "#{k} has no instruction object" unless instructions.any? {|instr| instr.opcode == k}
}

# Register Mapping
r = {
  0 => 'rbx',
  1 => 'rcx',
  2 => 'rdx',
  3 => 'r8',
  4 => 'r9',
  5 => 'r10',
  'pc' => 'rsi',
  :fp => 'rbp'
}


# Export these variables
$instructions = instructions
$offsets = offsets
$r = r
