class my_coverage extends uvm_subscriber #(my_txn);
 `uvm_component_utils(my_coverage)

  // variavel que vai guardar o item recebido para a covergroup "ler"
  my_txn tr;

  // Covergroup embutido
   /*covergroup g_cov;
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

  endgroup*/

  function new(string name = "my_coverage", uvm_component parent = null);
    super.new(name, parent);
    //g_cov = new; // instancia o covergroup
  endfunction

  // write() e chamado automaticamente quando o monitor faz analysis_port.write(t)
  virtual function void write(input my_txn t);
    //tr = t; // atualiza a variavel com o item recebido
    //g_cov.sample(); // amostra o covergroup
  endfunction
endclass
