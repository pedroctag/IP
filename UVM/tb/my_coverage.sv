class my_coverage extends uvm_subscriber #(my_txn);
 `uvm_component_utils(my_coverage)

  // variavel que vai guardar o item recebido para a covergroup "ler"
  my_txn tr;

  // Covergroup embutido de entrada de sinais
   covergroup g_cov;
    option.per_instance = 1;        // util quando ha multiplas instancias do mesmo cg
    // coverpoint no campo opcode
    cp_reg_det: coverpoint tr.data[11:7] {
      bins regs_0_a_7  = {[0:7]};
      bins regs_8_a_15  = {[8:15]};
      bins regs_16_a_23 = {[16:23]};
      bins regs_24_a_31 = {[24:31]};
    }
    // coverpoint no campo addr (ex.: ranges de interesse)
    cp_opcode: coverpoint tr.data[6:0] {
      bins tipo_r = {7'b0110011};
      bins tipo_i = {7'b0010011};
      bins tipo_s = {7'b0100011};
      bins tipo_b = {7'b1100011};
      bins tipo_u = {7'b0110111};
      bins tipo_j = {7'b1101111};
    }
  endgroup

  //covergroup de sinais de controle
  covergroup cg_control;
      cp_upper: coverpoint tr.Upper;
      cp_ImmScr: coverpoint tr.ImmSrcD{
        bins imm_i = {3'b000};
        bins imm_s = {3'b010};
        bins imm_b = {3'b100};
        bins imm_u = {3'b110};
        bins imm_j = {3'b111};
      }
      cp_FPUAinSel: coverpoint tr.FPUAinSel;
      cp_ALUSrc: coverpoint tr.ALUSrc;
      cp_MemSrc: coverpoint tr.MemSrc;
      cp_ALUControl: coverpoint tr.ALUControl{
        bins add = {4'b0000};
        bins sub = {4'b0001};
        bins sl = {4'b1010};
        bins slt = {4'b0110};
        bins XoR = {4'b0100};
        bins sra = {4'b1011};
        bins slr = {4'b1100};
        bins oR = {4'b0011};
        bins AnD = {4'b0010};
        bins lui = {4'b1001};
      }
      cp_FPUControl: coverpoint tr.FPUControl{
        bins add = {8'b00000_xxx};
        bins sub = {8'b00001_xxx};
        bins mul = {8'b00010_xxx};
        bins min = {8'b00101_000};
        bins max = {8'b00101_001};
        bins eq = {8'b10100_010};
        bins lt = {8'b10100_001};
        bins le = {8'b10100_000};
        bins mvwx = {8'b11110_xxx};
        bins mvxw = {8'b11100_000};
        bins cvtsw = {8'b11010_xxx};
        bins cvtws = {8'b11000_xxx};
      }
      cp_ResultSel: coverpoint tr.ResultSel;
      cp_ResultSrc: coverpoint tr.ResultSrc{
        bins ex = {2'b00};
        bins mem = {2'b01};
        bins jmp = {2'b10};
      }
      cp_MemWrite: coverpoint tr.MemWrite;
      cp_RegWrite: coverpoint tr.RegWrite;
      cp_RegWriteFW: coverpoint tr.RegWriteF;
      cp_Branch: coverpoint tr.Branch;
      cp_Jump: coverpoint tr.Jump;

  endgroup

  // covergroup de sinais de branch
  covergroup cg_branch;
      cp_zero: coverpoint tr.flag_zero;
      cp_neg: coverpoint tr.flag_negativo;
      cp_branch: coverpoint tr.branch_taken;
      cp_we: coverpoint tr.weChecker;
  endgroup

  // covergroup dos sinais de hazard
  covergroup cg_hazard;
      cp_fwdA: coverpoint tr.ForwardAE{
        bins no_fwd = {2'b00};
        bins fwd_wb = {2'b01};
        bins fwd_mem = {2'b10};
      }

      cp_fwdB: coverpoint tr.ForwardBE{
        bins no_fwd = {2'b00};
        bins fwd_wb = {2'b01};
        bins fwd_mem = {2'b10};
      }

      cp_lwStall: coverpoint tr.lwStall;
      //cp_PFBStall: coverpoint tr.PFBStall;
      cp_FlushD: coverpoint tr.FlushD;
      cp_FlushE: coverpoint tr.FlushE;

      cross_fwd_duplo: cross cp_fwdA, cp_fwdB;
      cross_stall_fwd: cross cp_lwStall, cp_fwdA;
      cross_flush_font: cross cp_FlushE, cp_lwStall;
  endgroup

  covergroup cg_PrefetchSignals;
      cp_isCompressed: coverpoint tr.isCompressed;
      cp_isCompressedA: coverpoint tr.isCompressedA;
      cp_isCompressedD: coverpoint tr.isCompressedD;
      cp_Misaligned: coverpoint tr.PC1;
  endgroup

  function new(string name = "my_coverage", uvm_component parent = null);
    super.new(name, parent);
    g_cov = new; // instancia o covergroup
    cg_branch = new;
    cg_hazard = new;
    cg_control = new;
    cg_PrefetchSignals = new;
  endfunction

  // write() e chamado automaticamente quando o monitor faz analysis_port.write(t)
  virtual function void write(input my_txn t);
    tr = t; // atualiza a variavel com o item recebido
    g_cov.sample(); // amostra o covergroup
    cg_branch.sample();
    cg_hazard.sample();
    cg_control.sample();
    cg_PrefetchSignals.sample();
  endfunction

  // Função auxiliar para calcular a fração de bins por engenharia reversa matemática
  function int get_hits(real pct, int total_bins);
    // Adiciona 0.5 para garantir um arredondamento perfeito antes de converter para Inteiro
    return $rtoi(((pct * total_bins) / 100.0) + 0.5);
  endfunction

  virtual function void report_phase(uvm_phase phase);
    // Variaveis para capturar as porcentagens individuais
    real pct_op, pct_reg;
    real pct_alu, pct_fpu, pct_imm, pct_res, pct_mem, pct_regw;
    real pct_zero, pct_neg, pct_btaken;
    real pct_fwA, pct_fwB, pct_stall, pct_fD, pct_fE, pct_cross_duplo, pct_cross_stall, pct_cross_flush;
    real pct_ic, pct_icA, pct_pc1;

    // Variaveis de medias customizadas
    real media_inst, media_ctrl, media_branch, media_hazard, media_prefetch, media_total;

    super.report_phase(phase);

    // --- 1. CAPTURA DOS DADOS ---
    pct_op   = g_cov.cp_opcode.get_inst_coverage();
    pct_reg  = g_cov.cp_reg_det.get_inst_coverage();
    
    pct_alu  = cg_control.cp_ALUControl.get_inst_coverage();
    pct_fpu  = cg_control.cp_FPUControl.get_inst_coverage();
    pct_imm  = cg_control.cp_ImmScr.get_inst_coverage();
    pct_res  = cg_control.cp_ResultSrc.get_inst_coverage();
    pct_mem  = cg_control.cp_MemWrite.get_inst_coverage();
    pct_regw = cg_control.cp_RegWrite.get_inst_coverage();

    pct_zero   = cg_branch.cp_zero.get_inst_coverage();
    pct_neg    = cg_branch.cp_neg.get_inst_coverage();
    pct_btaken = cg_branch.cp_branch.get_inst_coverage();

    pct_fwA         = cg_hazard.cp_fwdA.get_inst_coverage();
    pct_fwB         = cg_hazard.cp_fwdB.get_inst_coverage();
    pct_stall       = cg_hazard.cp_lwStall.get_inst_coverage();
    pct_fD          = cg_hazard.cp_FlushD.get_inst_coverage();
    pct_fE          = cg_hazard.cp_FlushE.get_inst_coverage();
    pct_cross_duplo = cg_hazard.cross_fwd_duplo.get_inst_coverage();
    pct_cross_stall = cg_hazard.cross_stall_fwd.get_inst_coverage();
    pct_cross_flush = cg_hazard.cross_flush_font.get_inst_coverage();

    pct_ic  = cg_PrefetchSignals.cp_isCompressed.get_inst_coverage();
    pct_icA = cg_PrefetchSignals.cp_isCompressedA.get_inst_coverage();
    pct_pc1 = cg_PrefetchSignals.cp_Misaligned.get_inst_coverage();

    // --- 2. CÁLCULO DAS MÉDIAS VISUAIS ---
    media_inst     = (pct_op + pct_reg) / 2.0;
    media_ctrl     = (pct_alu + pct_fpu + ((pct_imm + pct_res)/2.0) + ((pct_mem + pct_regw)/2.0)) / 4.0;
    media_branch   = (((pct_zero + pct_neg)/2.0) + pct_btaken) / 2.0;
    media_hazard   = (((pct_fwA + pct_fwB)/2.0) + ((pct_stall + pct_fD + pct_fE)/3.0) + pct_cross_duplo + pct_cross_stall + pct_cross_flush) / 5.0;
    media_prefetch = (((pct_ic + pct_icA)/2.0) + pct_pc1) / 2.0;
    
    media_total = (media_inst + media_ctrl + media_branch + media_hazard + media_prefetch) / 5.0;


    // --- 3. IMPRESSÃO DO RELATÓRIO COM FRAÇÕES ---
    `uvm_info("COV_REPORT", "============================================================", UVM_NONE)
    `uvm_info("COV_REPORT", "             RELATÓRIO DETALHADO DE COBERTURA               ", UVM_NONE)
    `uvm_info("COV_REPORT", "============================================================", UVM_NONE)
    
    `uvm_info("COV_REPORT", $sformatf(" [OVERALL] COBERTURA TOTAL DO SISTEMA:        %0.2f%%", media_total), UVM_NONE)
    `uvm_info("COV_REPORT", "------------------------------------------------------------", UVM_NONE)

    // Detalhamento: Instrucoes e Registradores
    `uvm_info("COV_REPORT", $sformatf(" [1] INSTRUÇÕES E REGISTRADORES:              %0.2f%%", media_inst), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Opcodes (Tipos R,I,S,B,U,J):          %0.2f%% (%0d/6)", pct_op, get_hits(pct_op, 6)), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Registradores (Destino 0 a 31):       %0.2f%% (%0d/4)", pct_reg, get_hits(pct_reg, 4)), UVM_NONE)
    `uvm_info("COV_REPORT", "------------------------------------------------------------", UVM_NONE)

    // Detalhamento: Sinais de Controle
    `uvm_info("COV_REPORT", $sformatf(" [2] SINAIS DE CONTROLE:                      %0.2f%%", media_ctrl), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> ULA (ALUControl):                     %0.2f%% (%0d/10)", pct_alu, get_hits(pct_alu, 10)), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> FPU (FPUControl):                     %0.2f%% (%0d/12)", pct_fpu, get_hits(pct_fpu, 12)), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Seletores de Entrada (Imm, Result):   %0.2f%%", (pct_imm + pct_res)/2.0), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Escrita (MemWrite, RegWrite):         %0.2f%%", (pct_mem + pct_regw)/2.0), UVM_NONE)
    `uvm_info("COV_REPORT", "------------------------------------------------------------", UVM_NONE)

    // Detalhamento: Branch e Flags
    `uvm_info("COV_REPORT", $sformatf(" [3] BRANCHES E FLAGS:                        %0.2f%%", media_branch), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Flags da ULA (Zero, Negativo):        %0.2f%%", (pct_zero + pct_neg)/2.0), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Tomada de Branch (Branch Taken):      %0.2f%%", pct_btaken), UVM_NONE)
    `uvm_info("COV_REPORT", "------------------------------------------------------------", UVM_NONE)

    // Detalhamento: Hazard Unit
    `uvm_info("COV_REPORT", $sformatf(" [4] HAZARD UNIT (STALLS E FLUSHES):          %0.2f%%", media_hazard), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Forwarding Básico (A e B):            %0.2f%%", (pct_fwA + pct_fwB)/2.0), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Bolhas (Stalls e Flushes):            %0.2f%%", (pct_stall + pct_fD + pct_fE)/3.0), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> CROSS: Forwarding A x B:              %0.2f%%", pct_cross_duplo), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> CROSS: Stall x Forwarding:            %0.2f%%", pct_cross_stall), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> CROSS: Flush x Stall:                 %0.2f%%", pct_cross_flush), UVM_NONE)
    `uvm_info("COV_REPORT", "------------------------------------------------------------", UVM_NONE)

    // Detalhamento: Prefetch
    `uvm_info("COV_REPORT", $sformatf(" [5] PREFETCH E COMPRESSÃO:                   %0.2f%%", media_prefetch), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Instruções Comprimidas:               %0.2f%%", (pct_ic + pct_icA)/2.0), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("     -> Misaligned Fetch (PC1):               %0.2f%%", pct_pc1), UVM_NONE)
    `uvm_info("COV_REPORT", "============================================================", UVM_NONE)
  endfunction
endclass
