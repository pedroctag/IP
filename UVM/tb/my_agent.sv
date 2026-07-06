class my_agent extends uvm_component;
  my_driver m_driver;
  my_monitor m_monitor;
  my_sequencer m_seq;

  `uvm_component_utils(my_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_driver  = my_driver::type_id::create("m_driver", this);
    m_monitor = my_monitor::type_id::create("m_monitor", this);
    m_seq     = my_sequencer::type_id::create("m_seq", this);
    `uvm_info(get_type_name(), "Construido com sucesso", UVM_LOW);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_seq.seq_item_export);
    `uvm_info(get_type_name(), "Conexoes realizadas", UVM_LOW);
  endfunction
endclass
