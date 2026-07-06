class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // Porta por onde os dados chegam do Monitor
  uvm_analysis_imp #(my_txn, my_scoreboard) item_collected_export;

  // Fila para guardar as transacoes esperadas (o Gabarito)
  my_txn fila_esperada[$]; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
    carregar_gabarito(); // Chama a função para ler o txt
    `uvm_info(get_type_name(), "Scoreboard construido e gabarito carregado", UVM_LOW);
  endfunction

  // Tarefa para ler o arquivo esperado.txt
  function void carregar_gabarito();
    int fd;
    bit isMem_lido;
    bit [31:0] addr_lido, data_lido;
    string data_str;
    my_txn tr_esperada;

    // Crie este arquivo com o formato: ADDR DATA (em hexa)
    fd = $fopen("./esperado.txt", "r");
    if (fd == 0) `uvm_fatal("NO_FILE", "Erro ao abrir esperado.txt");

    // Lê linha por linha até o fim do arquivo
    while ($fscanf(fd, "%b %h %s\n", isMem_lido ,addr_lido, data_str) == 3) begin
      tr_esperada = my_txn::type_id::create("tr_esperada");
      tr_esperada.addr = addr_lido;
      //tr_esperada.data = data_lido;
      tr_esperada.isMem = isMem_lido; // Indica que é uma operação de escrita em registrador

      tr_esperada.tamanho_str = data_str.len(); // Armazena o comprimento da string lida para comparação futura
      tr_esperada.data = data_str.atohex(); // Converte a string hexadecimal para um valor numérico

      fila_esperada.push_back(tr_esperada); // Coloca no fim da fila
    end
    $fclose(fd);
  endfunction


  // Contadores para as estatísticas
  int total_checagens = 0;
  int acertos = 0;
  int erros = 0;
  bit is_match = 0;
  // Esta funcao é chamada AUTOMATICAMENTE toda vez que o Monitor faz um .write()
  virtual function void write(my_txn tr_hardware);
    my_txn tr_gabarito;

    if (fila_esperada.size() == 0) begin
      `uvm_error("SCOREBOARD", "Hardware gerou uma saida a mais do que o esperado!")
      return;
    end

    // Tira o primeiro elemento do topo da fila (em ordem cronológica)
    tr_gabarito = fila_esperada.pop_front();

    total_checagens++;
    // Compara o Endereco (Registrador) e o Dado
      if(tr_gabarito.isMem) begin
          case (tr_gabarito.tamanho_str)
            1,2 : is_match = (tr_hardware.data[7:0] == tr_gabarito.data);
            3,4 : is_match = (tr_hardware.data[15:0] == tr_gabarito.data[15:0]);
            default: is_match = (tr_hardware.data == tr_gabarito.data);
          endcase
      end else is_match = (tr_hardware.data == tr_gabarito.data);
      if (tr_gabarito.addr == tr_hardware.addr && is_match) begin
      if(tr_gabarito.isMem)
        `uvm_info("PASS", $sformatf("%d RAM[0x%0h] | Valor: 0x%0h", total_checagens-1, tr_hardware.addr, tr_hardware.data), UVM_LOW)
      else
        `uvm_info("PASS", $sformatf("%d Reg x%0d | Valor: 0x%0h", total_checagens-1, tr_hardware.addr, tr_hardware.data), UVM_LOW)
      acertos++;
    end else begin
      if(tr_gabarito.isMem)
        `uvm_error("FAIL", $sformatf("%d Esp: RAM[0x%0h]=0x%0h | Rec: RAM[0x%0h]=0x%0h", 
                                   total_checagens-1, tr_gabarito.addr, tr_gabarito.data, tr_hardware.addr, tr_hardware.data))
      else
      `uvm_error("FAIL", $sformatf("%d Esp: Reg x%0d=0x%0h | Rec: Reg x%0d=0x%0h", 
                                   total_checagens-1, tr_gabarito.addr, tr_gabarito.data, tr_hardware.addr, tr_hardware.data))
      erros++;
    end
  endfunction

  // Imprime o relatório final
  virtual function void report_phase(uvm_phase phase);
    real porcentagem;
    super.report_phase(phase);
    
    if (total_checagens > 0)
      porcentagem = (real'(acertos) / real'(total_checagens)) * 100.0;
    else
      porcentagem = 0.0;

    `uvm_info("SCOREBOARD_REPORT", "========================================", UVM_NONE)
    `uvm_info("SCOREBOARD_REPORT", $sformatf("Total de Instrucoes Avaliadas: %0d", total_checagens), UVM_NONE)
    `uvm_info("SCOREBOARD_REPORT", $sformatf("Acertos: %0d", acertos), UVM_NONE)
    `uvm_info("SCOREBOARD_REPORT", $sformatf("Erros: %0d", erros), UVM_NONE)
    `uvm_info("SCOREBOARD_REPORT", $sformatf("Taxa de Sucesso: %0.2f%%", porcentagem), UVM_NONE)
    `uvm_info("SCOREBOARD_REPORT", "========================================", UVM_NONE)
  endfunction

endclass