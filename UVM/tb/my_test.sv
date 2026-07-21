class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env m_env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = my_env::type_id::create("m_env", this);
    `uvm_info(get_type_name(), "Construido com sucesso", UVM_LOW);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "Simulacao iniciando...", UVM_LOW);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    my_sequence seq;
    my_random_sequence seq_rand;

    phase.raise_objection(this);
    m_env.m_cov.g_cov.start();

    // =========================================================
    // TESTE 1: SEQUÊNCIA ASM DIRECIONADA
    // =========================================================
    `uvm_info(get_type_name(), "Teste asm - Iniciando...", UVM_LOW);

    // Garante que o scoreboard está ativo e carrega o arquivo
    m_env.m_scoreboard.enable_checking = 1;
    m_env.m_scoreboard.carregar_gabarito("/home/aluno/IP/UVM/tb/esperado.txt");

    @(posedge m_env.m_agent.m_driver.vif.clk);
    m_env.m_agent.m_driver.vif.reset <= 1;
    m_env.m_agent.m_driver.vif.we <= 1;

    seq = my_sequence::type_id::create("seq");
    seq.start(m_env.m_agent.m_seq);

    m_env.m_agent.m_driver.vif.reset <= 0;
    m_env.m_agent.m_driver.vif.we <= 0;

    // Aguarda o pipeline do processador terminar as últimas instruções
    #5500;

    // =========================================================
    // BARREIRA DE ISOLAMENTO
    // =========================================================
    `uvm_info(get_type_name(), "Desativando Scoreboard para o Teste Aleatorio...", UVM_LOW);

    // Limpa estado residual e desliga as checagens (evita UVM_ERROR de tamanho da fila)
    m_env.m_scoreboard.limpar_estado();
    m_env.m_scoreboard.enable_checking = 0;

    // =========================================================
    // TESTE 2: SEQUÊNCIA ALEATÓRIA (Apenas para Coverage)
    // =========================================================
    `uvm_info(get_type_name(), "Teste Aleatorio - Iniciando...", UVM_LOW);

    // Alinha ao clock e injeta um reset rígido para zerar o RTL
    @(posedge m_env.m_agent.m_driver.vif.clk);
    m_env.m_agent.m_driver.vif.reset <= 1;
    m_env.m_agent.m_driver.vif.we <= 1;

    seq_rand = my_random_sequence::type_id::create("seq_rand");
    seq_rand.start(m_env.m_agent.m_seq);

    m_env.m_agent.m_driver.vif.reset <= 0;
    m_env.m_agent.m_driver.vif.we <= 0;

    #5500;

    phase.drop_objection(this);
    m_env.m_cov.g_cov.stop();
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction
endclass