package my_pkg;

  // Importa o pacote UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Inclui os componentes do testbench
  `include "my_txn.sv"
  `include "my_sequence.sv"
  `include "my_driver.sv"
  `include "my_monitor.sv"
  `include "my_sequencer.sv"
  `include "my_scoreboard.sv"
  `include "my_agent.sv"
  `include "my_coverage.sv"
  `include "my_env.sv"
  `include "my_test.sv"

endpackage
