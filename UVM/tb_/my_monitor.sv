class my_monitor extends uvm_monitor;
  virtual dut_if vif;

  `uvm_component_utils(my_monitor)

  uvm_analysis_port #(my_txn) analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_port = new("analysis_port", this);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Interface nao encontrada")
    `uvm_info(get_type_name(), "Construido com sucesso", UVM_LOW);
  endfunction

  // Exemplo simples: gera transacoes a partir de sinais (substitua por leitura real do vif)
  task run_phase(uvm_phase phase);
    my_txn t;
    `uvm_info(get_type_name(), "Monitor ativo e escutando o Writeback do RISC-V...", UVM_LOW);

    forever begin
      @(posedge vif.clk);
      //$display("TEMPO: %0t | Interface: 0x%h | RTL: 0x%h", $time, vif.Monitor_ResultW, top_tb.dut.W.ResultW);
      if (vif.Monitor_RegWriteW | vif.Monitor_RegWriteFW) begin
        t = my_txn::type_id::create("t");
        t.addr = vif.Monitor_RdW;       // Registrador de destino
        t.data = vif.Monitor_ResultW;   // Valor escrito no registrador
        t.isMem = 0;                   // Indica que é uma operação de escrita em registrador
        
        analysis_port.write(t);
       `uvm_info(get_type_name(), $sformatf("[MONITOR] RISC-V Reg x%0d | valor: 0x%0h", vif.Monitor_RdW, vif.Monitor_ResultW), UVM_MEDIUM);
      end
      if (vif.MemWriteM) begin
        t = my_txn::type_id::create("t");
        t.addr = vif.Monitor_ALUResultM; // Endereço de memória acessado
        t.data = vif.WriteDataM;          // Dado escrito na memória
        t.isMem = 1;                     // Indica que é uma operação de escrita em memória
        
        analysis_port.write(t);
       `uvm_info(get_type_name(), $sformatf("[MONITOR] RISC-V Store 0x%0h | 0x%0h", vif.Monitor_ALUResultM, vif.WriteDataM), UVM_MEDIUM);
      end
    end
  endtask
endclass
