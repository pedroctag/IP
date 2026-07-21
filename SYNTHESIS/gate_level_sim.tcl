  xrun -timescale 1ns/1ps \
/home/aluno/IP/SYNTHESIS/Sim/Netlists/PPA1/pipelined_processor_FPU.v \
/home/aluno/IP/RTL/lib/misc/cpuTB.v \
-v /home/aluno/IP/SYNTHESIS/LIB/slow_vdd1v0_basicCells.v \
-access +rwc \
-sdf_file /home/aluno/IP/SYNTHESIS/Sim/sdf/delays_PPA1.sdf \
-maxdelays \
-sdf_verbose \
-mess