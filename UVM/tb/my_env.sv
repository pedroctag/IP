class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent m_agent;
  my_coverage m_cov;
  my_scoreboard m_scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent = my_agent::type_id::create("m_agent", this);
    m_cov   = my_coverage::type_id::create("m_cov", this);
    m_scoreboard = my_scoreboard::type_id::create("m_scoreboard", this);
    `uvm_info(get_type_name(), "Construido com sucesso", UVM_LOW);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agent.m_monitor.coverage_port.connect(m_cov.analysis_export);
    m_agent.m_monitor.scoreboard_port.connect(m_scoreboard.item_collected_export);
    `uvm_info(get_type_name(), "Conexoes realizadas", UVM_LOW);
  endfunction

endclass
