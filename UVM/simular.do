if [file exists work] {
    vdel -all
}
vlib work

# mapeia onde esta o codigo fonte da uvm
set UVM_SRC "C:/intelFPGA/18.1/modelsim_ase/verilog_src/uvm-1.2/src"

# isso gera o uvm_pkg e macros
vlog -work work +acc +define+UVM_NO_DPI "+incdir+$UVM_SRC" "$UVM_SRC/uvm.sv"

# compila tudo o que está em files.f
vlog -work work +acc +define+UVM_NO_DPI "+incdir+$UVM_SRC" -f files.f

# chama o simulador em texto com o -c, utilizando o suporte ao UVM com -uvm. O top_tb tem de ser substituido poelo topo do tb e meu_teste substituido pela classe de teste UVM
vsim -voptargs="+acc" +UVM_TESTNAME=my_test +UVM_VERBOSITY=UVM_LOW work.top_tb


# no xcelium isso vai para o lixo e se executa xrun -f files.f -uvm +UVM_TESTNAME=my_test +UVM_VERBOSITY=UVM_LOW -access +rwc
# pode se colocar um -gui se quiser
run -all
quit