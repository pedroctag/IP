class my_random_sequence extends uvm_sequence #(my_txn);
  `uvm_object_utils(my_random_sequence)

  function new(string name = "my_random_sequence");
    super.new(name);
  endfunction

  task body();
    my_txn tr;
    int num_instrucoes = 1023; // Quantidade de instruções de lixo a gerar

    `uvm_info(get_type_name(), "Sequence Aleatória Iniciada", UVM_LOW);

    for (int i = 0; i < num_instrucoes; i++) begin
      tr = my_txn::type_id::create("tr");

      start_item(tr);

      // Sorteia os campos da instrução. Se falhar, avisa.
      if (!tr.randomize()) begin
        `uvm_fatal(get_type_name(), "Falha ao randomizar item!")
      end

      // Força o endereço alinhado para o Driver carregar na memória corretamente
      tr.addr = i * 4;

      `uvm_info(get_type_name(), $sformatf("Aleatorio gerado: Addr=%0d Data=%0h", tr.addr, tr.data), UVM_HIGH);

      finish_item(tr);
    end

    `uvm_info(get_type_name(), $sformatf("Sequence Aleatoria finalizada: %0d enviadas", num_instrucoes), UVM_LOW);
  endtask
endclass
