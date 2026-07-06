class my_driver extends uvm_driver #(my_txn);
  virtual dut_if vif;

  `uvm_component_utils(my_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Interface nao encontrada")
    `uvm_info(get_type_name(), "Construido com sucesso", UVM_LOW);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tr;

    // Estado inicial dos pinos (Reset dos sinais de controle)
    vif.Instr_WA <= 32'h0;
    vif.Instr_din  <= 32'h0;

    `uvm_info(get_type_name(), "Driver ativo", UVM_LOW);
    
    forever begin
      seq_item_port.get_next_item(tr);
    @(posedge vif.clk);
      vif.Instr_WA <= tr.addr;     // Endereço alinhado (i * 4)
      vif.Instr_din  <= tr.data;     // Instrução lida do txt


      `uvm_info(get_type_name(), $sformatf("Carga Memoria -> Endereco: 0x%0h | Instrucao: 0x%0h", tr.addr, tr.data), UVM_LOW);
      
      // Avisa a sequence que este pacote foi processado com sucesso
      seq_item_port.item_done();
    end
  endtask
endclass
