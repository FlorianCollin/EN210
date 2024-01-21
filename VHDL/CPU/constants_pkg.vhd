library ieee;
use ieee.std_logic_1164.all;

package constants_pkg is

    constant INSTR_LENGTH     : integer := 16; -- instruction de 16 bits
    
    constant ACCU_LENGTH      : integer := 16; -- change at the end

    -- nombre de bits de l'addresse de la mémoire (Von New.)
    constant INSTR_DATA_MEM_LENGTH : integer := 6; -- 64 address pour la memoire data + instr

    constant DATA_LENGTH      : integer := 16; -- Same ACCU_LENGTH

    -- LEROUX ISA V1 8 bits
    -- 2 bits OPCODE
    constant OPCODE_LENGTH : integer := 2;
    constant OPCODE_H : integer := 7;
    constant OPCODE_L : integer := 6;

    -- AAAAAA
    constant MEM_ADD_H : integer := 5;
    constant MEM_ADD_L : integer := 0;


    -- RISCV
    --constant FUNCT7_H       : integer := 31;
    --constant FUNCT7_L       : integer := 25;

    --constant RS2_H          : integer := 24;
    --constant RS2_L          : integer := 20;

    --constant RS1_H          : integer := 19;
    --constant RS1_L          : integer := 15;

    --constant RD_H           : integer := 11;
    --constant RD_L           : integer := 7;

    --constant OPCODE_H       : integer := 6;
    --constant OPCODE_L       : integer := 0;
    --constant IMM_H          : integer := 31;
    --constant I_IMM_L        : integer := 20;
    --constant S_SB_IMM_L     : integer := 25;
    
end package constants_pkg;

package body constants_pkg is
end package body constants_pkg;
