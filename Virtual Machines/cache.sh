#!/bin/bash

declare -a benchmarks=("ackermann" "fasta" "reversecomplement" "mersenne" "fannkuch" "primesieve" "mandelbrot")

declare -a vms=("Register Mapped" "Normal" "Table Only")
n=1

for bench in "${benchmarks[@]}"; do
    echo $bench

    cd ../../benchmarks/benchmarks/
    echo " C"
    gcc -g -O3 -std=c99 $bench.c

    for i in `seq 1 $n`; do
        echo -n "  "
        if [ "$bench" = "reversecomplement" ]; then
            (valgrind --tool=cachegrind --branch-sim=yes --cachegrind-out-file="cachegrind-$bench" -- ./a.out < reversecomplement-input.txt) 2>&1 1>&2 > /dev/null
        else
            (valgrind --tool=cachegrind --branch-sim=yes --cachegrind-out-file="cachegrind-$bench" -- ./a.out) 2>&1 1>&2 > /dev/null
        fi
    done
    
    cd ../../Work/Virtual\ Machines/
    
    for vm in "${vms[@]}"; do
        echo " $vm"
        cd "$vm"
        ./compile benchmarks/$bench.asm > /dev/null

        if [ "$vm" = "Normal" ]; then
            bytecode="a.out"
        else
            bytecode="../Common/a.out"
        fi

        for i in `seq 1 $n`; do
            echo -n "  "
            if [ "$bench" = "reversecomplement" ]; then
                (valgrind --tool=cachegrind --branch-sim=yes --cachegrind-out-file="cachegrind-$bench" -- ./vm $bytecode < ../../../benchmarks/benchmarks/reversecomplement-input.txt) 2>&1 1>&2 > /dev/null
            else
                (valgrind --tool=cachegrind  --branch-sim=yes --cachegrind-out-file="cachegrind-$bench" -- ./vm $bytecode) 2>&1 1>&2 > /dev/null
            fi
        done
        cd ../
    done
    echo
done
