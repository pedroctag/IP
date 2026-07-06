class my_monitor extends uvm_monitor;
  virtual dut_if vif;

  `uvm_component_utils(my_monitor)

  // Dois portos independentes para evitar conflito de lógica
  uvm_analysis_port #(my_txn) scoreboard_port;
  uvm_analysis_port #(my_txn) coverage_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scoreboard_port = new("scoreboard_port", this);
    coverage_port   = new("coverage_port", this);
    
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Interface nao encontrada")
    `uvm_info(get_type_name(), "Construido com sucesso", UVM_LOW);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn t_cov;
    my_txn t_sb;
    `uvm_info(get_type_name(), "Monitor ativo e escutando o Writeback do RISC-V...", UVM_LOW);

    forever begin
      @(posedge vif.clk);
      
      // -------------------------------------------------------------
      // 1. AMOSTRAGEM DE COBERTURA (Executa a cada ciclo de clock)
      // -------------------------------------------------------------
      t_cov = my_txn::type_id::create("t_cov");
      
      // Sinais do Checker / Branch
      t_cov.flag_zero     = vif.Monitor_flag_zero;
      t_cov.flag_negativo = vif.Monitor_flag_negativo;
      t_cov.branch_taken  = vif.Monitor_branch_taken;
      t_cov.weChecker     = vif.Monitor_weChecker;
      
      // Sinais de Hazard Unit (Corrigido com o prefixo Monitor_)
      t_cov.lwStall       = vif.Monitor_lwStall;
      t_cov.FlushD        = vif.Monitor_FlushD;
      t_cov.FlushE        = vif.Monitor_FlushE;
      //t_cov.FlushPF       = vif.Monitor_FlushPF;
      //t_cov.PFBStall      = vif.Monitor_PFBStall;
      t_cov.ForwardAE     = vif.Monitor_ForwardAE;
      t_cov.ForwardBE     = vif.Monitor_ForwardBE;
      
      // Sinais de Controlo (Maiúsculas alinhadas com my_txn)
      t_cov.Upper         = vif.Monitor_upper;
      t_cov.ImmSrcD       = vif.Monitor_Imm;
      t_cov.FPUAinSel     = vif.Monitor_FPUAinSel;
      t_cov.ALUSrc        = vif.Monitor_ALUSrc;
      t_cov.MemSrc        = vif.Monitor_MemSrc;
      t_cov.ALUControl    = vif.Monitor_ALUControl;
      t_cov.FPUControl    = vif.Monitor_FPUControl;
      t_cov.ResultSel     = vif.Monitor_ResultSel;
      t_cov.ResultSrc     = vif.Monitor_ResultSrc;
      t_cov.MemWrite      = vif.Monitor_MemWrite;
      t_cov.RegWrite      = vif.Monitor_RegWrite;
      t_cov.RegWriteF     = vif.Monitor_RegWriteF;
      t_cov.Branch        = vif.Monitor_Branch;
      t_cov.Jump          = vif.Monitor_Jump;

      // Sinais de Prefetch
      t_cov.isCompressed  = vif.Monitor_isCompressed;
      t_cov.isCompressedA = vif.Monitor_isCompressedA;
      t_cov.isCompressedD = vif.Monitor_isCompressedD;
      t_cov.PC1           = vif.Monitor_PC1;
      
      // Envia exclusivamente para o componente de Cobertura Functional
      coverage_port.write(t_cov);

      // -------------------------------------------------------------
      // 2. AMOSTRAGEM DO SCOREBOARD (Apenas em caso de escrita efetiva)
      // -------------------------------------------------------------
      if (vif.Monitor_RegWriteW | vif.Monitor_RegWriteFW) begin
        t_sb = my_txn::type_id::create("t_sb");
        t_sb.addr  = vif.Monitor_RdW;       
        t_sb.data  = vif.Monitor_ResultW;   
        t_sb.isMem = 0;                   
        scoreboard_port.write(t_sb);
        `uvm_info(get_type_name(), $sformatf("[MONITOR] RISC-V Reg x%0d | valor: 0x%0h", vif.Monitor_RdW, vif.Monitor_ResultW), UVM_MEDIUM);
      end
      
      if (vif.MemWriteM) begin
        t_sb = my_txn::type_id::create("t_sb");
        t_sb.addr  = vif.Monitor_ALUResultM; 
        t_sb.data  = vif.WriteDataM;          
        t_sb.isMem = 1;                   
        scoreboard_port.write(t_sb);
        `uvm_info(get_type_name(), $sformatf("[MONITOR] RAM Write [0x%0h] | valor: 0x%0h", vif.Monitor_ALUResultM, vif.WriteDataM), UVM_MEDIUM);
      end
    end
  endtask
endclass