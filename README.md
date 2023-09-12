# Description in VHDL of a 4-stage pipeline processor 

# Project architecture :

``Arm_v4_32bits_PROS ``\
├── ``C_model/`` : libraries for ASM program execution developped by Jean-Lou Desbarbieux\
├── ``src/``\
│   ├── ``CORE/`` : top level of the CPU\
│   ├── ``DECOD/`` : decode stage and bench register\
│   ├── ``EXEC/`` : execute stage\
│   ├── ``FIFO/`` : Data flow management between stages\
│   ├── ``IFETCH/`` : fetch stage\
│   ├── ``MEM/`` : memory access stage\
│   └── ``TB/`` : CPU test files\
