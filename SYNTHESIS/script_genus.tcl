###############################################################
## Configuração Geral (Bibliotecas)
###############################################################

set_db init_lib_search_path /LIB/
set_db init_hdl_search_path ../../RTL/lib/misc
set_db init_hdl_search_path ../../RTL/lib/common
set_db init_hdl_search_path ../../RTL/lib/Core_FPU
set_db init_hdl_search_path ../../RTL/lib/Core_FPU/memory

# Carrega a biblioteca
read_libs fast_vdd1v0_basicCells.lib

# Lista de arquivos
set rtl_list {
    mux_3x1.v
    mux_2x1.v
    multiply.v
    memory_write_first.v
    memReadManager.v
    memByteAddressable32WF.v
    byteEnableDecoder.v
    memTopo32LittleEndian.v
    int2fp.v
    fp2int.v
    adder.v
    Cflag.v
    PC_Plus_4.v
    Main_Deocder.v
    M_W_flipflop.v
    InstructionAlign.v
    F_D_flipflop.v
    FPU_Decoder.v
    FPU.v
    E_M_flipflop.v
    Decompressor.v
    D_E_flipflop.v
    Brancher.v
    Writeback.v
    Register_File.v
    PC_Target.v
    PC_Mux.v
    PC.v
    Memory.v
    Instruction_Memory.v
    Fetch.v
    Hazard_unit.v
    Extend.v
    Decode.v
    ALU_decoder.v
    Control_Unit.v
    ALU.v
    Execute.v
    pipelined_processor_FPU.v
}

###############################################################
## CENÁRIO 1: BASELINE (30ns)
###############################################################
puts "=== Iniciando Baseline ==="

# Leitura com a macro SYNTHESIS
read_hdl -define SYNTHESIS $rtl_list

set_db max_cpus 22

elaborate pipelined_processor_FPU.v
check_design -unresolved

# Constraints Baseline
read_sdc /constraints/constraints_top.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

#set_db optimize_constant_0_flops false
#set_db optimize_constant_feedback_seqs false
# --- ETAPA 1: SYN_GENERIC ---
syn_generic
puts "--- Gerando Relatórios Baseline (Generic) ---"
report_timing > Sim/Timing/baseline/report_timing_generic.rpt
report_power  > Sim/Power/baseline/report_power_generic.rpt
report_area   > Sim/Area/baseline/report_area_generic.rpt
report_qor    > Sim/QoR/baseline/report_qor_generic.rpt

# --- ETAPA 2: SYN_MAP ---
syn_map
puts "--- Gerando Relatórios Baseline (Map) ---"
report_timing > Sim/Timing/baseline/report_timing_map.rpt
report_power  > Sim/Power/baseline/report_power_map.rpt
report_area   > Sim/Area/baseline/report_area_map.rpt
report_qor    > Sim/QoR/baseline/report_qor_map.rpt

# --- ETAPA 3: SYN_OPT (Final) ---
syn_opt
puts "--- Gerando Relatórios Baseline (Final/Opt) ---"
report_timing > Sim/Timing/baseline/report_timing_opt.rpt
report_power  > Sim/Power/baseline/report_power_opt.rpt
report_area   > Sim/Area/baseline/report_area_opt.rpt
report_qor    > Sim/QoR/baseline/report_qor_opt.rpt

# Outputs Finais
write_db pipelined_processor_FPU -to_file Sim/db/design_baseline.db
write_hdl > Sim/Netlists/baseline/pipelined_processor_FPU.v
write_sdc > Sim/sdc/baseline/x_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > Sim/sdf/delays_baseline.sdf

###############################################################
## CENÁRIO 2: PPA 1 (20ns)
###############################################################
puts "=== Iniciando PPA 1 ==="

delete_obj [get_db designs *]

read_hdl -define SYNTHESIS $rtl_list

elaborate pipelined_processor_FPU.v

read_sdc /constraints/constraints_top_ppa1.sdc

# --- ETAPA 1: SYN_GENERIC ---
syn_generic
puts "--- Gerando Relatórios PPA1 (Generic) ---"
report_timing > Sim/Timing/PPA1/report_timing_generic.rpt
report_power  > Sim/Power/PPA1/report_power_generic.rpt
report_area   > Sim/Area/PPA1/report_area_generic.rpt
report_qor    > Sim/QoR/PPA1/report_qor_generic.rpt


# --- ETAPA 2: SYN_MAP ---
syn_map
puts "--- Gerando Relatórios PPA1 (Map) ---"
report_timing > Sim/Timing/PPA1/report_timing_map.rpt
report_power  > Sim/Power/PPA1/report_power_map.rpt
report_area   > Sim/Area/PPA1/report_area_map.rpt
report_qor    > Sim/QoR/PPA1/report_qor_map.rpt

# --- ETAPA 3: SYN_OPT (Final) ---
syn_opt
puts "--- Gerando Relatórios PPA1 (Final/Opt) ---"
report_timing > Sim/Timing/PPA1/report_timing_opt.rpt
report_power  > Sim/Power/PPA1/report_power_opt.rpt
report_area   > Sim/Area/PPA1/report_area_opt.rpt
report_qor    > Sim/QoR/PPA1/report_qor_opt.rpt

# Outputs Finais
write_db pipelined_processor_FPU -to_file Sim/db/design_baseline.db
write_hdl > Sim/Netlists/baseline/pipelined_processor_FPU.v
write_sdc > Sim/sdc/baseline/x_sdc_baseline.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > Sim/sdf/delays_baseline.sdf

###############################################################
## CENÁRIO 3: PPA 2 (10ns)
###############################################################
puts "=== Iniciando PPA 2 ==="

delete_obj [get_db designs *]

read_hdl -define SYNTHESIS $rtl_list

elaborate pipelined_processor_FPU.v

read_sdc /constraints/constraints_top_ppa2.sdc

# --- ETAPA 1: SYN_GENERIC ---
syn_generic
puts "--- Gerando Relatórios PPA2 (Generic) ---"
report_timing > Sim/Timing/PPA2/report_timing_generic.rpt
report_power  > Sim/Power/PPA2/report_power_generic.rpt
report_area   > Sim/Area/PPA2/report_area_generic.rpt
report_qor    > Sim/QoR/PPA2/report_qor_generic.rpt


# --- ETAPA 2: SYN_MAP ---
syn_map
puts "--- Gerando Relatórios PPA2 (Map) ---"
report_timing > Sim/Timing/PPA2/report_timing_map.rpt
report_power  > Sim/Power/PPA2/report_power_map.rpt
report_area   > Sim/Area/PPA2/report_area_map.rpt
report_qor    > Sim/QoR/PPA2/report_qor_map.rpt

# --- ETAPA 3: SYN_OPT (Final) ---
syn_opt
puts "--- Gerando Relatórios PPA2 (Final/Opt) ---"
report_timing > Sim/Timing/PPA2/report_timing_opt.rpt
report_power  > Sim/Power/PPA2/report_power_opt.rpt
report_area   > Sim/Area/PPA2/report_area_opt.rpt
report_qor    > Sim/QoR/PPA2/report_qor_opt.rpt

# Outputs Finais
write_db pipelined_processor_FPU -to_file Sim/db/design_PPA2.db
write_hdl > Sim/Netlists/PPA2/pipelined_processor_FPU.v
write_sdc > Sim/sdc/PPA2/x_sdc_PPA2.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > Sim/sdf/delays_PPA2.sdf


puts "=== Fim de todas as etapas ==="