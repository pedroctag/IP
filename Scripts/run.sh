#!/bin/bash
set -e

cd ~/Programas_asm
#riscv64-unknown-elf-gcc -march=rv32ifc -mabi=ilp32f -nostdlib -T link.ld exemplo.s -o exemplo.elf
#riscv64-unknown-elf-gcc -march=rv32ifc -mabi=ilp32 -O1 -mrelax -ffreestanding -nostdlib -S teste.c -o exemplo.s

riscv64-unknown-elf-gcc -O5 -march=rv32ifc -mabi=ilp32 -nostdlib -Wl,-e,_boot -Wl,-Ttext=0x80000000 /mnt/c/Users/Pedro/Desktop/IP/UVM/tb/exemplo.s -o exemplo.elf

spike --isa=rv32ifc -m0x7f000000:0x20000000  --instructions=2000 --log-commits exemplo.elf 2> gabarito.txt || true

python3 convert.py

riscv64-unknown-elf-objcopy -O binary exemplo.elf memoria.bin
hexdump -v -e '1/4 "%08x\n"' memoria.bin>instruction.txt

cp instruction.txt /mnt/c/Users/Pedro/Desktop/IP/RTL/lib/Core_FPU

echo "Gabarito gerado:" & cat /mnt/c/Users/Pedro/Desktop/IP/UVM/tb/esperado.txt
