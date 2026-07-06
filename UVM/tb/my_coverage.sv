class my_coverage extends uvm_subscriber #(my_txn);
 `uvm_component_utils(my_coverage)

  // variavel que vai guardar o item recebido para a covergroup "ler"
  my_txn tr;

  // Covergroup embutido de entrada de sinais
   covergroup g_cov;
    // option.per_instance = 1;        // util quando ha multiplas instancias do mesmo cg
    // coverpoint no campo opcode
    cp_reg_det: coverpoint tr.addr {
      bins regs_0_a_7  = {[0:7]};
      bins regs_8_a_15  = {[8:15]};
      bins regs_16_a_23 = {[16:23]};
      bins regs_24_a_31 = {[24:31]};
    }
    // coverpoint no campo addr (ex.: ranges de interesse)
    cp_opcode: coverpoint tr.opcode {
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

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
    `uvm_info("COV_REPORT", "        RELATÓRIO FINAL DE COBERTURA FUNCIONAL    ", UVM_NONE)
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
    
    // Acessando os percentuais de cobertura diretamente
    `uvm_info("COV_REPORT", $sformatf("  -> Opcodes testados:         %0.2f%%", g_cov.cp_opcode.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("  -> Registradores testados:   %0.2f%%", g_cov.cp_reg_det.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("  -> Sinais de Controle ativos:%0.2f%%", cg_control.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("  -> Sinais de Branch ativos:   %0.2f%%", cg_branch.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("  -> Sinais de Hazard:          %0.2f%%", cg_hazard.cross_stall_fwd.get_inst_coverage()), UVM_NONE)
    
    
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
  endfunction
endclass
