class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env m_env; // Instancia do ambiente de teste

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
    `uvm_info(get_type_name(), "Teste asm", UVM_LOW);
    m_env.m_agent.m_driver.vif.reset <= 1;
    m_env.m_agent.m_driver.vif.we <= 1;
    
    seq = my_sequence::type_id::create("seq");
    seq.start(m_env.m_agent.m_seq);

    m_env.m_agent.m_driver.vif.reset <= 0;
    m_env.m_agent.m_driver.vif.we <= 0;
    #5500;

    `uvm_info(get_type_name(), "Teste Aleatorio", UVM_LOW);
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
    //`uvm_info(get_type_name(),$sformatf("Cobertura de opcode: %0.2f%%", m_env.m_cov.g_cov.cp_opcode.get_coverage()), UVM_LOW);
    //`uvm_info(get_type_name(),$sformatf("Cobertura de addr:   %0.2f%%", m_env.m_cov.g_cov.cp_addr.get_coverage()), UVM_LOW);
    //`uvm_info(get_type_name(),$sformatf("Cobertura de cross:  %0.2f%%", m_env.m_cov.g_cov.cp_opcode_x_addr.get_coverage()), UVM_LOW);
    //`uvm_info(get_type_name(),$sformatf("Cobertura total:     %0.2f%%", m_env.m_cov.g_cov.get_inst_coverage()), UVM_LOW);
  endfunction

endclass
