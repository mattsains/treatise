#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/instructions.rb'

USE_REAL_REG_NAMES = ARGV.include? '-r'
USE_CONVENTIONAL_BYTECODE = ARGV.include? '-c'
ARGV_WITHOUT_FLAGS = ARGV - ['-r', '-c']

def error line, msg
  puts "="*60
  puts "Error with '#{line}':"
  puts "  #{msg}"
  puts "="*60
  x=1/0
  abort
end

def is_int? str
  (Integer(str)) rescue return false
  return true
end

class BetterFile < File
  alias _readline readline
  alias _eof? eof?
  
  @next = nil
  
  def initialize(a, b)
    super(a, b)
    @next = _readline
    @next = @next.split(';')[0] #remove comments
    @next.strip!
  end
  
  def readline
    if _eof?
      temp = @next
      @next = nil
      return temp
    else
      temp = @next
      line = super
      line = line.split(';')[0] #remove comments
      line.strip!
      @next = line
      return temp
    end
  end
  
  def eof?
    super & (@next == nil)
  end
    
  def peek
    if eof?
      return nil
    else
      return @next
    end
  end
end

class Program
  class Fixup
    attr_accessor :instr_base_addr
    attr_accessor :fixup_addr
    attr_accessor :name
    def initialize(instr_base_addr, fixup_addr, name)
      self.instr_base_addr = instr_base_addr
      self.fixup_addr = fixup_addr
      self.name = name
    end
  end

  def initialize
    # Stores the absolute location of symbols: label => address
    @abs_symbols = {}

    # Stores symbols that do not undergo arithmetic
    # ie., object/function member indexes
    @fake_symbols = []

    # Stores display messages by address: addr => msg
    @display_messages = {}
    
    # Last symbol in the source file (used for local labels)
    @last_symbol = nil

    # Stores a queue of address substitutions of type Fixup
    # Fixups are always sixteen bits
    @fixups = []

    # Array of bytes to be written to output file
    @output_bytes = []

    # Constants to relocate to the end of the program.
    # Constants might also appear as names in fixups.
    # They are referenced as _imm_val or _imm_mval for negatives
    @constants = []
  end
  
  def hex n
    ("%04x"%n).tr('..','ff').reverse[0, 4].reverse
  end
  
  def bin n
    ("0b%b"%n)
  end

  def write_bytes(data, bytes, buffer = nil)
    if data >=0
      if data >> (bytes*8) != 0
        error(data,"#{data} does not fit in #{bytes} bytes")
      end
    else
      if (~(data >> (bytes*8))) != 0
        error(data,"#{data} does not fit in #{bytes} bytes")
      end
    end

    for i in 0...bytes
      if buffer == nil
        @output_bytes << ((data >> (i*8)) & 0xFF)
      else
        buffer << (data >> (i*8)) & 0xFF
      end
    end
  end

  def add_label(label, fake = false)
    if label[0] == '.'
      if @last_symbol == nil
        error(label, "Local label with no scope")
      else
        label = @last_symbol + label
      end
    end

    if @abs_symbols.has_key? label
      error(label, "#{label} has already been defined")
    end

    @abs_symbols[label] = @output_bytes.length
    @fake_symbols << label if fake

    if not label.include? '.'
      @last_symbol = label
    end
  end
  
  def parse_label(file)
    line = file.readline
    label = line.match(/\.?[^\d\W]\w*/)[0] # optional ., alphabet, alphanumeric*
    add_label(label)
  end

  def parse_constant(file)
    line = file.readline
    @display_messages[@output_bytes.length] = line
    if line.start_with? 'ds'
      if line =~ /ds\s+(("[^"]*")|('[^"]*'))/
        parts = line.rpartition(/("[^"]*")|('[^']*')/)
        if parts[0] == ""
          error(line, "Could not find a string accompanying ds")
        end

        string = parts[1][1, parts[1].length-2] #remove quotes
        write_bytes(string.length + 1, 8)
        string.each_byte {|c|
          @output_bytes << c
        }
        @output_bytes << 0
      else
        error(line, "Invalid syntax for ds")
      end
    else
      parts = line.split(/[, ]+/)
      case parts[0]
      when 'db'
        width = 1
      when 'dw'
        width = 2
      when 'dq'
        width = 8
      end
      for i in 1...parts.length
        (literal = Integer(parts[i])) rescue error(line, "Couldn't turn '#{parts[i]}' into an integer")
        if literal >=0
          error(line, "#{literal} too big for #{width} byte int") if literal>>(8*width)!=0
        else
          error(line, "#{literal} too big for #{width} byte int") if (~(literal>>(8**width)))!=0
        end
        write_bytes(literal, width)
      end
    end
  end

  def align(length)
    wrote_blanks = false
    start_pos = @output_bytes.length
    while @output_bytes.length % length != 0
      @output_bytes << 0
      wrote_blanks = true
    end
    @display_messages[start_pos] = "align #{length}" if wrote_blanks
  end
  
  def parse_align(file)
    line = file.readline
    align(line.split[1].to_i)
  end

  def parse_function(file)
    line = file.readline
    keyword, name = line.split
    align(16)
    @display_messages[@output_bytes.length] = "function #{name}"
    add_label(name)

    length = 0
    bitmaps = []
    
    while file.peek.start_with?('ptr ','int ') or file.peek == ''
      if file.peek == ''
        file.readline
        next
      end
      
      type, mem_name = file.readline.split(/\W+/)
      @abs_symbols["#{name}.#{mem_name}"] = length
      @fake_symbols << "#{name}.#{mem_name}"
      if length % 64 == 0
        bitmaps << 0
      end
      bitmaps[-1] |= (if type == 'ptr' then 1 else 0 end) << (length % 64)
      length += 1
    end
    write_bytes(length, 8)
    bitmaps.each {|bitmap| write_bytes(bitmap, 8)}
  end

  def parse_object(file)
    line = file.readline
    keyword, name = line.split
    align(16)
    @display_messages[@output_bytes.length] = "object #{name}"
    add_label(name)

    length = 0
    bitmaps = []
    
    while file.peek.start_with?('ptr ','int ') or file.peek == ''
      if file.peek == ''
        file.readline
        next
      end
      
      type, mem_name = file.readline.split(/\W+/)
      @abs_symbols["#{name}.#{mem_name}"] = length
      @fake_symbols << "#{name}.#{mem_name}"
      if length % 64 == 0
        bitmaps << 0
      end
      bitmaps[-1] |= (if type == 'ptr' then 1 else 0 end) << (length % 64)
      length += 1
    end
    write_bytes(length, 8)
    bitmaps.each {|bitmap| write_bytes(bitmap, 8)}
  end

  def parse_instruction(file)
    line = file.readline
    parts = line.split(/[,\[\] ]+/)
    instruction = $instructions.find {|inst| inst.opcode == parts[0]}

    if instruction == nil
      error(line, "#{parts[0]} is not a valid instruction")
    end

    if instruction.operands.length != parts.length-1
      unless instruction.operands[-1] == :arbimm16
        error(line, "#{instruction.opcode} given wrong number of arguments "+
                    "(#{parts.length-1} for #{instruction.operands})")
      end
    end
    
    start_address = @output_bytes.length

    @output_bytes << 0 # reserve opcode length
    @output_bytes << 0
    reg_arguments = []

    next_instr_immediates = [] # address in output_bytes
    
    instruction.operands.each_with_index {|op_type, op_pos|
      argument = parts[op_pos+1]
      case op_type
      when :reg
        if not argument.start_with?('r','p')
          error(line, "Expected a register in position #{op_pos+1}")
        end
        register = Integer(argument[1...argument.length])
        if register > 5
          error(line, "Expected a register in position #{op_pos+1}")
        end
        reg_arguments << register
      when :imm16
        if is_int? argument
          @display_messages[@output_bytes.length] = "  imm: #{argument}"
          write_bytes(Integer(argument), 2)
        elsif argument =~ /'[^']'/
          @display_messages[@output_bytes.length] = "  imm: #{argument}"
          argument = argument[1].ord
          write_byte(argument, 2)
        elsif argument == '$'
          @display_messages[@output_bytes.length] = "  imm: $"
          next_instr_immediates << @output_bytes.length

          @output_bytes << 0
          @output_bytes << 0
        else
          if argument.start_with? '.'
            if @last_symbol == nil
              error(line, "Local label #{argument} without scope")
            end
            argument = @last_symbol + argument
          end
          if not argument =~ /([a-zA-Z]\w*.)?[a-zA-Z]\w*/
            error(line, "Argument #{argument} is not valid")
          end
          @display_messages[@output_bytes.length] = "  imm: #{argument}"
          @fixups << Fixup.new(start_address, @output_bytes.length, argument)

          @output_bytes << 0
          @output_bytes << 0
        end
      when :immptr64
        if is_int? argument
          argument = Integer(argument)
          @display_messages[@output_bytes.length] = "  imm: &#{argument}"
          if not @constants.include? argument
            @constants << argument
          end
          
          if argument < 0
            label = "imm_m#{argument.abs}"
          else
            label = "imm_#{argument.abs}"
          end
          @fixups << Fixup.new(start_address, @output_bytes.length, label)

          @output_bytes << 0
          @output_bytes << 0
        elsif argument =~ /'[^']'/
          @display_messages[@output_bytes.length] = "  imm: &#{argument}"
          argument = argument[1].ord
          if not @constants.include? argument
            @constants << argument
          end
          
          label = "imm_#{argument.abs}"
          
          @fixups << Fixup.new(start_address, @output_bytes.length, label)

          @output_bytes << 0
          @output_bytes << 0
        elsif argument == '$'
          next_instr_immediates << @output_bytes.length
          @display_messages[@output_bytes.length] = "  imm: $"

          @output_bytes << 0
          @output_bytes << 0
        else
          if argument.start_with? '.'
            if @last_symbol == nil
              error(line, "Local label #{argument} without scope")
            end
            argument = @last_symbol + argument
          end
          if not argument =~ /([a-zA-Z]\w*.)?[a-zA-Z]\w*/
            error(line, "Argument #{argument} is not valid")
          end
          @display_messages[@output_bytes.length] = "  imm: #{argument}"
          @fixups << Fixup.new(start_address, @output_bytes.length, argument)

          @output_bytes << 0
          @output_bytes << 0
        end
      when :arbimm16
        for i in (op_pos+1)...parts.length
          if is_int? argument
            @display_messages[@output_bytes.length] = "  imm: #{argument}"
            write_bytes(Integer(argument), 2)
          elsif argument =~ /'[^']'/
            @display_messages[@output_bytes.length] = "  imm: #{argument}"
            argument = argument[1].ord
            write_byte(argument, 2)
          elsif argument == '$'
            @display_messages[@output_bytes.length] = "  imm: $"
            next_instr_immediates << @output_bytes.length

            @output_bytes << 0
            @output_bytes << 0
          else
            if argument.start_with? '.'
              if @last_symbol == nil
                error(line, "Local label #{argument} without scope")
              end
              argument = @last_symbol + argument
            end
            if not argument =~ /([a-zA-Z]\w*.)?[a-zA-Z]\w*/
              error(line, "Argument #{argument} is not valid")
            end
            @display_messages[@output_bytes.length] = "  imm: #{argument}"
            @fixups << Fixup.new(start_address, @output_bytes.length, argument)

            @output_bytes << 0
            @output_bytes << 0
          end
        end
      end
    } # end of all expected operands
    displacement = @output_bytes.length - start_address
    next_instr_immediates.each {|imm|
      @output_bytes[imm] = displacement & 0xFF
      @output_bytes[imm+1] = displacement >> 8
    }
    
    opcode = generate_opcode(instruction, reg_arguments, start_address)
    @output_bytes[start_address] = opcode & 0xFF
    @output_bytes[start_address+1] = opcode >> 8
  end

  def register_str(n)
    if USE_REAL_REG_NAMES
      $r[n]
    else
      "r#{n}"
    end
  end
  
  def generate_opcode(instruction, reg_arguments, start_address)

    if USE_CONVENTIONAL_BYTECODE
      opcode = $instructions.index(instruction) << 9
      message = instruction.opcode + "(#{hex opcode}) "
      reg_arguments.each_with_index {|reg,i|
        opcode |= reg << (i*3)
        message += "#{register_str(reg)} "
      }
      @display_messages[start_address] = message
      return opcode
    else
      opcode = instruction.offset
      message = instruction.opcode + "(#{hex opcode}) "
      reg_arguments.each_with_index {|reg,i|
        opcode += reg * (6**i)
        message += "#{register_str(reg)}(#{reg*(6**i)})"
      }
      @display_messages[start_address] = message
      return opcode
    end
  end

  # At the end of the code, time to generate the constants section
  # and fill in the fixups
  def complete
    align(8)
    @constants.each {|constant|
      if constant < 0
        label = "imm_m#{constant.abs}"
      else
        label = "imm_#{constant.abs}"
      end
      
      add_label(label)
      @display_messages[@output_bytes.length] = "const #{constant}"
      write_bytes(constant, 8)
    }

    @fixups.each {|fixup|
      if not @abs_symbols.has_key? fixup.name
        error(fixup.name, "Symbol #{fixup.name} does not exist")
      end
      if @fake_symbols.include? fixup.name
        offset = @abs_symbols[fixup.name]
      else
        offset = @abs_symbols[fixup.name] - fixup.instr_base_addr
      end

      @output_bytes[fixup.fixup_addr] = offset & 0xFF
      @output_bytes[fixup.fixup_addr+1] = offset >> 8
    }
  end

  def render
    @output_bytes.pack('C*')
  end

  def display
    for i in 0...(@output_bytes.length-1)
      next if i % 2 != 0

      if @abs_symbols.any? {|name,addr| addr == i and not @fake_symbols.include? name }
        puts ""
        
        @abs_symbols.each {|name, addr|
          if addr == i and not @fake_symbols.include? name
            puts "#{name}:"
          end
        }
      end
      
      word = (@output_bytes[i+1] << 8)|@output_bytes[i]
      print "  #{hex i}: #{hex word} "
      if @display_messages.has_key? i
        print "- #{@display_messages[i]}"
        if @display_messages.has_key? (i+1)
          puts ", #{@display_messages[i]}"
        else
          puts ""
        end
      else
        puts ""
      end
    end
  end

  def display_raw
    for i in 0...(@output_bytes.length-1)
      next if i % 2 != 0

      print "#{hex i}: " if i % 8 == 0
      
      word = (@output_bytes[i+1] << 8)|@output_bytes[i]
      if i % 8 == 6
        puts " #{hex word}"
      else
        print " #{hex word}"
      end
    end
  end
end

def process_file(file, program)
  while not file.eof?
    line = file.peek

    if line.start_with? '%include '
      parts = file.readline.split(' ')
      BetterFile.open(File.dirname(file.path)+'/'+parts[1], 'r') {|f| process_file(f, program)}
    elsif line.end_with? ':'
      program.parse_label(file)
    elsif line.start_with? 'object '
      program.parse_object(file)
    elsif line.start_with? 'function '
      program.parse_function(file)
    elsif line.start_with?('db ', 'dw ', 'dq ', 'ds ')
      program.parse_constant(file)
    elsif line.start_with? 'align '
      program.parse_align(file)
    elsif line == ''
      file.readline
      next
    elsif line == nil
      break #end of file
    else
      program.parse_instruction(file)
    end
  end
end

if ARGV_WITHOUT_FLAGS[0] == nil
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
  puts "    0..2  |  register 3"
  puts "    3..5  |  register 2"
  puts "    6..8  |  register 1"
  puts "    9..16 |  opcode"
else
  program = Program.new
  file = BetterFile.open(ARGV_WITHOUT_FLAGS[0], 'r')
  process_file(file, program)
  file.close
  program.complete

  if ARGV_WITHOUT_FLAGS[1] == nil
    output_filename = "a.out"
  else
    output_filename = ARGV_WITHOUT_FLAGS[1]
  end
  program.display
  puts ""
  puts "Output:"
  puts "="*8
  program.display_raw
  IO.write(output_filename, program.render)
end
