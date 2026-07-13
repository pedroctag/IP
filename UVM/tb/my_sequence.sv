class my_sequence extends uvm_sequence #(my_txn);
  `uvm_object_utils(my_sequence)

  function new(string name = "my_sequence");
    super.new(name);
  endfunction

  task body();
    my_txn tr;
    integer fd;
    logic [31:0] instrucao_lida;
    int i = 0;

    `uvm_info(get_type_name(), "Sequence iniciada: Abrindo arquivo de instrucoes", UVM_LOW);

    fd = $fopen("/home/alvaro/UVM_IP/IP-main/RTL/lib/Core_FPU/instruction.txt", "r"); // encontrar o caminho correto do arquivo de instrucoes
    if (fd == 0) begin
      `uvm_fatal(get_type_name(), "Erro ao abrir o arquivo de instrucoes")
    end

    while ($fscanf(fd, "%h\n", instrucao_lida) == 1) begin

      tr = my_txn::type_id::create("tr");
      start_item(tr);
      tr.addr = i * 4;
      tr.data = instrucao_lida;

      `uvm_info(get_type_name(), $sformatf("Sequence leu do arquivo: Addr=%0d Data=%0h", tr.addr, tr.data), UVM_LOW);

      finish_item(tr);
      i++;
    end
    $fclose(fd);
    `uvm_info(get_type_name(), $sformatf("Sequence finalizada: %0d instrucoes enviadas ao driver\n\n\n\n\nIniciando comparacao com gabarito", i), UVM_LOW);
  endtask
  endclass
