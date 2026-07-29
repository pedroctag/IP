.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
li t0, 0x00006000      # Máscara correspondente aos bits 13 e 14 (FS = 11)
csrs mstatus, t0       # Seta esses bits no registrador mstatus
lui x31, 0x80010
# Comeca aqui

addi x1, x0, 10      # x1 = 10
addi x2, x0, 20      # x2 = 20
addi x3, x0, 5       # x3 = 5
add  x4, x1, x2
sub  x5, x4, x3
fcvt.s.w f3, x3
fcvt.s.w f5, x5 
fmul.s f6, f3, f5
fmv.x.w x6, f6
sw x1, 0(x31)
sw x2, 4(x31)
sw x3, 8(x31)
sw x4, 12(x31)
sw x5, 16(x31)
sw x6, 20(x31)
addi x1, x1, 1
addi x2, x2, 2
addi x3, x3, 1
addi x1,  x0, 10          # x1 = 10
addi x2,  x0, 20          # x2 = 20
addi x3,  x0, 5           # x3 = 5
add  x4, x1, x2           # 30
sub  x5, x4, x3           # 25
and  x6, x1, x2
or   x7, x1, x2
xor  x8, x1, x2
slli x9,  x1, 2           # 10 << 2 = 40
srli x10, x2, 1           # 20 >> 1 = 10
srai x11, x5, 1           # 25 >> 1 = 12  // resultado deu 0
slt  x12, x1, x2          # 1
slt  x13, x2, x1          # 0
fcvt.s.w f1, x1
fcvt.s.w f2, x2
fcvt.s.w f3, x3
fadd.s f4, f1, f2         # 30.0
fsub.s f5, f2, f3         # 15.0
fmul.s f6, f3, f5         # 75.0
fadd.s f7, f2, f3
fmv.x.w x17, f4
fmv.x.w x18, f5
fmv.x.w x19, f6
fmv.x.w x20, f7
sw x4,   0(x31)
sw x5,   4(x31)
sw x6,   8(x31)
sw x7,  12(x31)
sw x8,  16(x31)
sw x9,  20(x31)
sw x10, 24(x31)
sw x11, 28(x31)
sw x12, 32(x31)
sw x13, 36(x31)
sw x14, 40(x31)
sw x15, 44(x31)
sw x16, 48(x31)
sw x17, 52(x31)
sw x18, 56(x31)
sw x19, 60(x31)
lw x21, 0(x31)
lw x22, 4(x31)
lw x23, 40(x31)
addi x24, x0, 0           # contador
addi x25, x0, 10          # limite
loop3:
addi x24, x24, 1
blt x24, x25, loop3
beq x24, x25, equal_ok
addi x26, x0, 111         # erro
equal_ok:
addi x26, x0, 222

addi x1, x0, 5
addi x2, x1, 1
addi x3, x2, 1
addi x4, x3, 1
addi x5, x4, 1
addi x6, x5, 1
sw x6,0(x31)
addi x7,x0,20
add  x8,x7,x7
sub  x9,x8,x7
add  x10,x9,x8
sw x10,4(x31)
lw x11,0(x31)
add x12,x11,x11
sw x12,8(x31)
addi x13,x0,1
sw x13,12(x31)
addi x14,x0,-16
srai x15,x14,2
sw x15,16(x31)
addi x16,x0,-1
addi x17,x0,1
slt x18,x16,x17
sw x18,20(x31)
addi x19,x0,5
addi x20,x0,5
sub x21,x19,x20
beq x21,x0,ok1
addi x22,x0,111
ok1:
addi x22,x0,222
sw x22,24(x31)
beq x0,x0,skip3
addi x23,x0,999
addi x24,x0,999
skip3:
addi x23,x0,333
sw x23,28(x31)
fcvt.s.w f1,x1
fcvt.s.w f2,x2
fadd.s f3,f1,f2
fmul.s f4,f3,f1
fmv.x.w x26,f4
sw x26,32(x31)

addi x1, x0, 0
addi x2, x0, 0
addi x3, x0, 0
addi x4, x0, 0
sw x0,0(x31)
sw x0,4(x31)
sw x0,8(x31)
sw x0,12(x31)
addi x1,x0,17        # 0x11
sb x1,0(x31)
addi x2,x0,34        # 0x22
sb x2,1(x31)
addi x3,x0,51        # 0x33
sb x3,2(x31)
addi x4,x0,68        # 0x44
sb x4,3(x31)
lw x5,0(x31)
lui x6,0xAABBC
addi x6,x6,0xCD
sh x6,4(x31)
lh  x7,4(x31)
lhu x8,4(x31)
addi x9,x0,0x12
slli x9,x9,8
addi x9,x9,0x34
sh x9,6(x31)
lw x10,4(x31)
addi x11,x0,-1
sb x11,8(x31)
lb  x12,8(x31)
lbu x13,8(x31)
addi x14,x0,-16
sh x14,10(x31)
lh  x15,10(x31)
lhu x16,10(x31)
lb x17,1(x31)
add x18,x17,x17
lh x19,10(x31)
addi x20,x19,1
lw x21,0(x31)
lw x22,4(x31)
lw x23,8(x31)
sw x5,16(x31)
sw x7,20(x31)
sw x8,24(x31)
sw x10,28(x31)
sw x12,32(x31)
sw x13,36(x31)
sw x15,40(x31)
sw x16,44(x31)
sw x18,48(x31)
sw x20,52(x31)
sw x21,56(x31)
sw x22,60(x31)

lui x31, 0x80010
addi x1, x0, -1          # 0xFFFFFFFF
sb x1,0(x31)
lb  x2,0(x31)
lbu x3,0(x31)
lui x4,0x1
addi x4,x4,564 
sh x4,4(x31)
lh  x5,4(x31)
lhu x6,4(x31)
addi x7,x0,-16
sh x7,8(x31) 
lh  x8,8(x31)
lhu x9,8(x31) # ultima inst executada no gabarito
lui x10, 0x12345
addi x10,x10, 0x0678
sw x10,12(x31)
lb x11,12(x31)
lb x12,13(x31)
lb x13,14(x31)
lb x14,15(x31)
addi x15,x0,99
sb x15,13(x31)
lw x16,12(x31)
lb x17,13(x31)
add x18,x17,x17
addi x19,x0,777
sh x19,14(x31)
lw x20,12(x31)
sw x2,32(x31)
sw x3,36(x31)
sw x5,40(x31)
sw x6,44(x31)
sw x8,48(x31)
sw x9,52(x31)
sw x11,56(x31)
sw x12,60(x31)

addi x1,x0,10
c.addi x1,5
c.addi x1,15
add x9,x1,x0
lui x8, 0x80010
c.sw x9,4(x8)
c.lw x8,4(x8)
sub x10,x8,x9
sw x1,0(x31)
sw x8,4(x31)

sw x10,8(x31)

c.li x1,1
c.addi x1,2
add x2,x1,x1
c.li x3, 5
c.addi x3,4
c.addi x3,5
sub x4,x2,x3
sw x1,0(x31)
sw x2,4(x31)
sw x3,8(x31)
sw x4,12(x31)

c.li x1,1
add x2,x1,x1
c.li x3,1
c.addi x3,1
sub x4,x2,x3
sw x4,0(x31)

addi x1,x0,0
addi x5,x0,5
loop4:
c.addi x1,1
blt x1,x5,loop4
sw x1,0(x31)

c.li x9, -31
c.add x8, x9
lui x10, 0x80010
c.addi x10, 0x8
c.sw x8, 0(x10)
c.lw x11, 0(x10)
c.and x10, x9
c.sub x11, x8

c.li x1, 5 #
c.li x2, 6
c.li x3, 7
c.li x4, 8
c.li x5, 9
c.li x6, 10
sw x6,0(x31)
c.li x7, 20
add  x8,x7,x7
sub  x9,x8,x7
add  x10,x9,x8
sw x10,4(x31)
lw x11,0(x31)
add x12,x11,x11
sw x12,8(x31)
c.li x13, 1
sw x13,12(x31)
c.li x14, -16
srai x15,x14,2
sw x15,16(x31)
c.li x16, -1
c.li x17, 1
slt x18,x16,x17
sw x18,20(x31)
c.li x19, 5
c.li x20, 5
sub x21,x19,x20
beq x21,x0,ok2
addi x22,x0,111
ok2:
addi x22,x0,222
sw x22,24(x31)
beq x0,x0,skip1
addi x23,x0,999
addi x24,x0,999
skip1:
addi x23,x0,333
sw x23,28(x31)
fcvt.s.w f1,x1
fcvt.s.w f2,x2
fadd.s f3,f1,f2
fmul.s f4,f3,f1
fmv.x.w x26,f4
sw x26,32(x31)

c.li        x5, 17
c.slli      x5, 12
addi        x5, x5, 2000
addi        x5, x5, 458
c.li        x6, 5
c.slli      x6, 15
lui         x7, 1048516
lui         x8, 66
fcvt.s.w    f1, x5
fcvt.s.w    f2, x6
fcvt.s.w    f3, x7
fcvt.s.w    f4, x8
lui         x10, 227328
addi        x10, x10, 0x74
fmv.w.x     f9, x10
fmul.s      f1, f1, f9
fmul.s      f2, f2, f9
fmul.s      f3, f3, f9
fmul.s      f4, f4, f9
fadd.s      f5, f1, f2
fadd.s      f6, f5, f3
fadd.s      f7, f6, f4
fsw         f7, 0(x31)
fcvt.w.s    x9, f7
sw          x9, 4(x31)

addi x1, x0, 5
addi x2, x1, 1
addi x3, x2, 1
addi x4, x3, 1
addi x5, x4, 1
addi x6, x5, 1
sw x6,0(x31)
addi x7,x0,20
add  x8,x7,x7
sub  x9,x8,x7
add  x10,x9,x8
sw x10,4(x31)
lw x11,0(x31)
add x12,x11,x11
sw x12,8(x31)
addi x13,x0,1
sw x13,12(x31)
addi x14,x0,-16
srai x15,x14,2
sw x15,16(x31)
addi x16,x0,-1
addi x17,x0,1
slt x18,x16,x17
sw x18,20(x31)
addi x19,x0,5
addi x20,x0,5
sub x21,x19,x20
beq x21,x0,ok3
addi x22,x0,111
ok3:
addi x22,x0,222
sw x22,24(x31)
beq x0,x0,skip2
addi x23,x0,999
addi x24,x0,999
skip2:
addi x23,x0,333
sw x23,28(x31)
fcvt.s.w f1,x1
fcvt.s.w f2,x2
fadd.s f3,f1,f2
fmul.s f4,f3,f1
fmv.x.w x26,f4
sw x26,32(x31)

jal     x30, func1
ret_func2:
jal     x30, bloco_frente
bloco_retorno:
jal     x31, pre_fim
func1:
addi    x25, x0, 1
jalr    x0, 0(x30)
func2:
addi    x24, x0, 222
jalr    x0, 0(x30)
bloco_frente:
addi    x23, x0, 333
jal     x31, bloco_retorno

pre_fim:
li x1, 5
li x2, 10
li x3, 5
blt x1, x2, less
addi x4, x0, 0
less:
addi x4, x0, 1
beq x1, x3, equal
addi x5, x0, 0
equal:
addi x5, x0, 1
bne x1, x2, notequal
addi x6, x0, 0
notequal:
addi x6, x0, 1
jal x7, func
addi x24, x0, 1
addi x8, x0, 123

# Acaba aqui
fim:
beq x0, x0, fim

func:
addi x9, x0, 42
jalr x0, 0(x7)
