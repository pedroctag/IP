class my_txn extends uvm_sequence_item;
  
  bit [31:0] addr;
  bit [31:0] data;
  bit [6:0] opcode;
  bit isMem;
  int tamanho_str;

  `uvm_object_utils(my_txn)

  function new(string name = "my_txn");
    super.new(name);
  endfunction
endclass
