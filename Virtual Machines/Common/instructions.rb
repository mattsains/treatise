class Inst
  attr_accessor :opcode #mnemonic
  attr_accessor :allow_trivial
  attr_accessor :operands # a list of symbols - :reg, :imm16, :immptr64, :arbimmptr64
  attr_accessor :offset

  def initialize(opcode, operands, allow_trivial=true)
    @opcode = opcode
    @operands = operands
    @allow_trivial = allow_trivial
  end
end

instructions = []

#instructions with just one operand (register)
instructions += ['null', 'in', 'out', 'err'].collect {|opcode| Inst.new opcode, [:reg]}

#instructions with just one operand (immediate)
instructions += ['jmp'].collect {|opcode| Inst.new opcode, [:imm16]}
instructions += ['jmpf'].collect {|opcode| Inst.new opcode, [:immptr64]}

#instructions with two registers only where the trivial case is allowed
instructions += ['add','mul'].collect {|opcode| Inst.new opcode, [:reg, :reg]}

#instructions with two registers where the trivial case is disallowed
instructions += ['sub','div','and','or','xor','shl','shr','sar','mov','movp'].collect {|opcode| Inst.new opcode, [:reg, :reg], false}

#instructions with one register and one 16b immediate
instructions += ['addc','subc','mulc','divc','andc','orc','movc','alloc'].collect {|opcode| Inst.new opcode, [:reg, :immptr64]}
instructions += ['shlc','shrc','sarc'].collect {|opcode| Inst.new opcode, [:reg, :imm16]}

#instructions with one 16b immediate and one register
instructions += ['csub'].collect {|opcode| Inst.new opcode, [:immptr64, :reg]}
instructions += ['cshl','cshr','csar'].collect {|opcode| Inst.new opcode, [:imm64, :reg]}

#strange instructions
instructions += ['jcmp'].collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16, :imm16, :imm16], false}
instructions += ['jcmpc'].collect {|opcode| Inst.new opcode, [:reg, :immptr64, :imm16, :imm16, :imm16]}
instructions += ['jeqp'].collect {|opcode| Inst.new opcode, [:reg, :reg, :imm16, :imm16], false}
instructions += ['jnullp'].collect {|opcode| Inst.new opcode, [:reg, :imm16, :imm16]}
instructions += ['switch'].collect {|opcode| Inst.new opcode, [:reg, :imm16, :arbimm16]} #TODO: work out what to make of this

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

# Yeah this is bad but it is still the nicest way
def is_int? str
  Integer(str) rescue return false
  return true
end

instructions.each {|instruction| instruction.offset = offsets[instruction.opcode]}
# Sort instructions by their numbers
instructions.sort_by! {|instruction| instruction.offset }

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
