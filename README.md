# A JIT-less, Register-Mapped, Statically-Typed Virtual Machine for Interpreters

These are the source files and results of my BSc Hons Computer Science project.

The treatise on the project can be found in `Treatise.pdf`

## Directory Layout
* `Paper`: Contains LaTeX source files for the treatise on the project
* `Virtual Machines`: Contains virtual machine source code
* `benchmarks/assembler`: Contains a Ruby assembler for assembling bytecode for the VMs
* `benchmarks/benchmarks`: Contains source code to the benchmark programs used to test the VMs
* `benchmarks/tests`: Some example code demonstrating the assembly format
* `benchmarks/stdlib.asm`: Standard library for VM bytecode
* `results`: Contains results of benchmarking experiments

## Running the Assembler
The assembler can be found at `benchmarks/assembler/assembler.rb`. Run `ruby assembler.rb` for usage information.

## Building and Running Virtual Machines
### Prerequisites for building the virtual machines:
The virtual machines were designed with these prerequisites. Other versions may work also.
* GNU Make 4.0
* GNU Compiler Collection v5.1.1
* GNU C Standard Library v2.21
* Ruby v2.2.3
* Liquid Templating Engine for Ruby v3.01

To compile a virtual machine, run `make` in the directory of the virtual machine.

### Invocation of Virtual Machines
All virtual machines expect a single argument: the path to the bytecode file to be run. These files are expected to be raw binary files as generated by the assembler
