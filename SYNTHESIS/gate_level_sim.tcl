xrun -timescale 1ns/1ps /home/aluno/IP-main/SYNTHESIS/Sim/Netlists/PPA1/pipelined_processor_FPU.v /home/aluno/IP-main/RTL/lib/Core_no_FPU/cpuTB.v -v /home/aluno/IP-main/SYNTHESIS/LIB/slow_vdd1v0_basiccells.v -access +rwc
-sdf_file /home/aluno/IP-main/SYNTHESIS/Sim/sdf/delays_PPA1.sdf -sdf_verbose -mess -gui


xrun -timescale 1ns/1ps \
  /home/aluno/IP-main/SYNTHESIS/Sim/Netlists/PPA2/pipelined_processor_FPU.v \
  /home/aluno/IP-main/RTL/lib/Core_no_FPU/cpuTB.v \
  -v /home/aluno/IP-main/SYNTHESIS/LIB/slow_vdd1v0_basiccells.v \
  -access +rwc \
  -sdf_file /home/aluno/IP-main/SYNTHESIS/Sim/sdf/delays_PPA2.sdf \
  -sdf_verbose \
  -mess \
  -gui


xrun -timescale 1ns/1ps \
  /home/aluno/IP-main/SYNTHESIS/Sim/Netlists/PPA1/pipelined_processor_FPU.v \
  /home/aluno/IP-main/RTL/lib/misc/cpuTB.v \
  -v /home/aluno/IP-main/SYNTHESIS/LIB/slow_vdd1v0_basiccells.v \
  -access +rwc \
  -sdf_file /home/aluno/IP-main/SYNTHESIS/Sim/sdf/delays_PPA1.sdf \
  -sdf_instance cpuTB.dut \
  -sdf_verbose \
  -mess \
  -gui