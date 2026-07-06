class my_txn extends uvm_sequence_item;
  
  bit [31:0] addr; // Não será rand, será controlado pela sequence (i * 4)
  bit [31:0] data; // Resultado final montado

  // brancher
  bit flag_zero;
  bit flag_negativo;
  bit branch_taken;
  bit weChecker;
  
  //control
  bit Upper;
  bit [2:0] ImmSrcD;
  bit FPUAinSel;
  bit ALUSrc;
  bit MemSrc;
  bit [3:0] ALUControl;
  bit [7:0] FPUControl;
  bit [1:0] ResultSel;
  bit [1:0] ResultSrc;
  bit MemWrite;
  bit RegWrite;
  bit RegWriteF;
  bit Branch;
  bit Jump;

  // Sinais de prefetch
  bit isCompressed;
  bit isCompressedA;
  bit isCompressedD;
  bit PC1;

  //hazard unit
  bit lwStall;
  bit FlushD;
  bit FlushE;
  //bit FlushPF;
  //bit PFBStall;
  bit [1:0] ForwardAE;
  bit [1:0] ForwardBE;
  
  // Variáveis randomizáveis para montar a instrução
  rand bit [6:0]  opcode;
  rand bit [4:0]  rs1;
  rand bit [4:0]  rs2;
  rand bit [4:0]  rd;
  rand bit [2:0]  funct3;
  rand bit [6:0]  funct7;
  rand bit [31:0] imm;
  
  bit isMem;
  int tamanho_str;

  `uvm_object_utils(my_txn)

  function new(string name = "my_txn");
    super.new(name);
  endfunction

  // Constraint: Garante que os opcodes gerados sejam válidos
  constraint c_opcodes_validos {
    opcode inside {
      7'b0110011, // Tipo R
      7'b0010011, // Tipo I
      7'b0000011, // Loads
      7'b0100011, // Stores
      7'b1100011  // Branches
    };
  }

  // Constraint: Evita escrever no registrador x0
  constraint c_rd_util {
    if (opcode != 7'b1100011 && opcode != 7'b0100011) {
      rd != 5'd0;
    }
  }

  // Função nativa do SV: Executa automaticamente APÓS o randomize()
  function void post_randomize();
    case(opcode)
      7'b0110011: data = {funct7, rs2, rs1, funct3, rd, opcode}; // Tipo R
      7'b0010011,
      7'b0000011: data = {imm[11:0], rs1, funct3, rd, opcode};   // Tipo I / Load
      7'b0100011: data = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode}; // Store
      7'b1100011: data = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode}; // Branch
      default:    data = 32'h00000013; // NOP de segurança
    endcase
  endfunction

endclass