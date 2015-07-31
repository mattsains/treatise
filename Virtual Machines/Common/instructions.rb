class Inst
  attr_accessor :opcode #mnemonic
  attr_accessor :disallow_trivial_between #[0,1] means between reg argument 0 and reg argument 1
  attr_accessor :operands # a list of symbols - :reg, :imm16, :immptr64, :arbimm16
  attr_accessor :offset

  def initialize(opcode, operands, disallow_trivial_between=[])
    @opcode = opcode
    @operands = operands
    @disallow_trivial_between = disallow_trivial_between
  end

  def allowed? (*r)
    check = []
    @disallow_trivial_between.each {|i| check << r[i]}
    not (check.any? {|item| check.count(item) > 1})
  end
end

instructions = []

#instructions with no operands
instructions +=
  ['ret']
  .collect {|opcode| Inst.new opcode, []}

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
  .collect {|opcode| Inst.new opcode, [:reg, :reg], [0,1]}

#instructions with one register and one 16b immediate
instructions +=
  ['addc','mulc','divc','cdiv','andc','orc','movc']
  .collect {|opcode| Inst.new opcode, [:reg, :immptr64]}

instructions +=
  ['shlc','shrc','sarc','getl','getlp','newp','movsc']
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
  ['getm','getmp']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16]}
instructions +=
  ['setm','setmp']
  .collect {|opcode| Inst.new opcode, [:reg, :imm16, :reg]}

instructions +=
  ['geta','getap','getb']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :reg], [1,2]}

instructions +=
  ['seta','setap','setb']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :reg], [0,1]}

#strange instructions
instructions +=
  ['switch']
  .collect {|opcode| Inst.new opcode, [:reg, :imm16, :arbimm16]}

instructions +=
  ['jcmp']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16, :imm16, :imm16], [0,1]}

instructions +=
  ['jcmpc']
  .collect {|opcode| Inst.new opcode, [:reg, :immptr64, :imm16, :imm16, :imm16]}

instructions +=
  ['jeqp']
  .collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16, :imm16], [0,1]}

instructions +=
  ['jnullp']
  .collect {|opcode| Inst.new opcode, [:reg, :imm16, :imm16]}

instructions +=
  ['call']
  .collect {|opcode| Inst.new opcode, [:imm16, :imm16, :imm16]}

offsets =
  {
    'add' => 0, 'addc' => 36, 'sub' => 42, 'csub' => 78, 'mul' => 84, 'mulc' => 120,
    'div' => 126, 'divc' => 162, 'cdiv' => 168, 'and' => 174, 'andc' => 210, 'or' => 216,
    'orc' => 252, 'xor' => 258, 'shl' => 294, 'shlc' => 330, 'cshl' => 336, 'shr' => 342,
    'shrc' => 378, 'cshr' => 384, 'sar' => 390, 'sarc' => 426, 'csar' => 432, 'mov' => 438,
    'movp' => 474, 'movc' => 510, 'null' => 516, 'getl' => 522, 'getlp' => 528, 'setl' => 534,
    'setlp' => 540, 'getm' => 546, 'getmp' => 582, 'setm' => 618, 'setmp' => 654, 'geta' => 690,
    'getap' => 906, 'seta' => 1122, 'setap' => 1338, 'getb' => 1554, 'setb' => 1770,
    'jmp' => 1986, 'jmpf' => 1987, 'switch' => 1988, 'jcmp' => 1994, 'jcmpc' => 2030,
    'jeqp' => 2036, 'jnullp' => 2072, 'call' => 2078, 'ret' => 2079, 'newp' => 2080,
    'newpa' => 2086, 'newa' => 2122, 'movsc' => 2158, 'in' => 2164, 'out' => 2170, 'err' => 2176,
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
