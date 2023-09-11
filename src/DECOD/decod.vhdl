library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;

			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic;
			exe_pop			: in Std_logic;

	-- Alu command
            dec_alu_cmd		: out Std_Logic_Vector(1 downto 0);

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c				: in Std_Logic;
			exe_v				: in Std_Logic;
			exe_n				: in Std_Logic;
			exe_z				: in Std_Logic;

			exe_dest			: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir				: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest			: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component Reg
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
        reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
        reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 5 bits (for shift)
        reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry			: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg			: out Std_Logic;
		
		reg_cznv		: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;

	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck					: in Std_Logic;
		reset_n			: in Std_Logic;
		vdd				: in bit;
		vss				: in bit);
end component;

component fifo_127b
	port(
		din		: in std_logic_vector(126 downto 0);
		dout		: out std_logic_vector(126 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

component fifo_32b
	port(
		din		: in std_logic_vector(31 downto 0);
		dout		: out std_logic_vector(31 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

signal cond	: Std_Logic;
signal condv	: Std_Logic;

signal regop_t  : Std_Logic;
signal mult_t   : Std_Logic;
signal swap_t   : Std_Logic;
signal trans_t  : Std_Logic;
signal mtrans_t : Std_Logic;
signal branch_t : Std_Logic;

signal I : Std_Logic;
signal S : Std_Logic;

-- regop instructions
signal and_i  : Std_Logic;
signal eor_i  : Std_Logic;
signal sub_i  : Std_Logic;
signal rsb_i  : Std_Logic;
signal add_i  : Std_Logic;
signal adc_i  : Std_Logic;
signal sbc_i  : Std_Logic;
signal rsc_i  : Std_Logic;
signal tst_i  : Std_Logic;
signal teq_i  : Std_Logic;
signal cmp_i  : Std_Logic;
signal cmn_i  : Std_Logic;
signal orr_i  : Std_Logic;
signal mov_i  : Std_Logic;
signal bic_i  : Std_Logic;
signal mvn_i  : Std_Logic;

signal Opv  : Std_Logic;

-- mult instruction
signal mul_i  : Std_Logic;
signal mla_i  : Std_Logic;

-- trans instruction
signal ldr_i  : Std_Logic;
signal str_i  : Std_Logic;
signal ldrb_i : Std_Logic;
signal strb_i : Std_Logic;

-- mtrans instruction
signal ldm_i  : Std_Logic;
signal stm_i  : Std_Logic;

-- branch instruction
signal b_i    : Std_Logic;
signal bl_i   : Std_Logic;

-- Multiple transferts
signal mtrans_shift     : Std_Logic;
signal mtrans_loop_adr  : Std_Logic;

-- RF read ports

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;


-- DECOD FSM

signal dec2if_push : std_logic;
signal if2dec_pop  : std_logic; 
signal dec2exe_push: std_logic;


--fifo 32b
signal pc_dec2if_in : std_logic_vector(31 downto 0);
signal pc_dec2if_out : std_logic_vector(31 downto 0);
signal dec2if_full  : std_logic; 

--fifo 127b

-- Decode to exe interface operands
signal dec2exe_op1	: std_logic_vector(31 downto 0);		 -- first alu input
signal dec2exe_op2	: std_logic_vector(31 downto 0);		 -- shifter input
signal dec2exe_dest : std_logic_vector(3 downto 0);	 -- Rd destination
signal dec2exe_wb	: std_logic;  -- Rd destination write back
signal dec2exe_flag_wb	: std_logic; -- CSPR modifiy

-- Decode to mem interface 
signal dec2mem_data : std_logic_vector(31 downto 0);	 -- data to MEM W
signal dec2mem_dest : std_logic_vector(3 downto 0);	 -- Destination MEM R
signal dec2mem_pre_index : std_logic; 

signal dec2mem_lw : std_logic; 
signal dec2mem_lb : std_logic; 
signal dec2mem_sw : std_logic; 
signal dec2mem_sb : std_logic; 

-- Shifter command
signal dec2exe_shift_lsl : std_logic;
signal dec2exe_shift_lsr : std_logic;
signal dec2exe_shift_asr : std_logic;
signal dec2exe_shift_ror : std_logic;
signal dec2exe_shift_rrx : std_logic;
signal dec2exe_shift_val : std_logic_vector(4 downto 0);
signal dec2exe_cy : std_logic; 

signal shift_type : std_logic_vector(1 downto 0);

-- Alu operand selection
signal dec2exe_comp_op1 : std_logic;	
signal dec2exe_comp_op2 : std_logic;	
signal dec2exe_alu_cy : std_logic;	

-- Alu command
signal dec2exe_alu_cmd : std_logic_vector(1 downto 0);
signal dec2exe_full  : std_logic; 


--link


--signaux reg
signal reg_rd1_s : std_logic_vector(31 downto 0);
signal radr1_s   : std_logic_vector(3 downto 0);
signal reg_v1_s	 : std_logic;

signal reg_rd2_s : std_logic_vector(31 downto 0);
signal radr2_s	 : std_logic_vector(3 downto 0);
signal reg_v2_s	 : std_logic;

signal reg_rd3_s : std_logic_vector(31 downto 0);
signal radr3_s	 : std_logic_vector(3 downto 0);
signal reg_v3_s	 : std_logic;

signal reg_cznv_s : std_logic;
signal reg_vv_s : std_logic;

signal inval_adr1_s : std_logic_vector(3 downto 0);
signal inval1_s : std_logic;

signal inval_adr2_s : std_logic_vector(3 downto 0);
signal inval2_s : std_logic;

signal inval_czn_s : std_logic;
signal inval_ovr_s : std_logic;

signal reg_pc_s : std_logic_vector(31 downto 0);
signal reg_pcv_s : std_logic;
signal inc_pc_s : std_logic;

--mae
type etat is(FETCH,RUN);--(FETCH,RUN,LINK,MTRANS,BRANCH);
signal EP, EF: etat;
    

begin

    my_reg : reg
            port map(

                wdata1		=> exe_res,
                wadr1		=> exe_dest,
                wen1		=> exe_wb,

                wdata2		=> mem_res,
                wadr2		=> mem_dest,
                wen2		=> mem_wb,

                wcry	=> exe_c,
                wzero	=> exe_z,
                wneg	=> exe_n,
                wovr	=> exe_v,
                cspr_wb	    => exe_flag_wb,    

                reg_rd1		=> reg_rd1_s,
                radr1		=> radr1_s,
                reg_v1		=> reg_v1_s,

                reg_rd2		=> reg_rd2_s,
                radr2		=> radr2_s,
                reg_v2	=> reg_v2_s,

                reg_rd3	=> reg_rd3_s,
                radr3		=> radr3_s,
                reg_v3		=> reg_v3_s,

                reg_cry	=> cry,
                reg_zero	=> zero,
                reg_neg		=> neg,
                reg_ovr		    => ovr,  

                reg_cznv	=> reg_cznv_s,
                reg_vv	=> reg_vv_s,

                inval_adr1	=> inval_adr1_s,
                inval1	=> inval1_s,

                inval_adr2	=> inval_adr2_s,
                inval2		=> inval2_s,

                inval_czn	=> inval_czn_s,
                inval_ovr	=> inval_ovr_s,

                reg_pc	=> reg_pc_s,
                reg_pcv		=> reg_pcv_s,
                inc_pc	=> inc_pc_s,

                ck			=> ck,	
                reset_n		=> reset_n,	
                vdd			=> vdd,	
                vss			=> vss	
            );

           
    my_fifo_32b : fifo_32b
            port map(
            din		=> pc_dec2if_in,
            dout		=> pc_dec2if_out,

            --commands
            push		=> dec2if_push,
            pop		=> if_pop,
                        
            --flags   
            full		=> dec2if_full,
            empty		=> dec2if_empty,
                    
            reset_n	=> reset_n,
            ck		=> ck,
            vdd		=> vdd,
            vss		=> vss
            );

						
						
    my_fifo_127b : fifo_127b
            port map(

            -- Decode to exe interface operands
            din(126 downto 95)	 =>dec2exe_op1	,		 -- first alu input
            din(94 downto 63)	 =>dec2exe_op2	,		 -- shifter input
            din(62 downto 59)	 =>dec2exe_dest,	 -- Rd destination
            din(58)	 =>dec2exe_wb	, -- Rd destination write back
            din(57)	 =>dec2exe_flag_wb	, -- CSPR modifiy

            -- Decode to mem interface 
            din(56 downto 25)	 =>dec2mem_data,	 -- data to MEM W
            din(24 downto 21)	 =>dec2mem_dest,	 -- Destination MEM R
            din(20)	 =>dec2mem_pre_index ,

            din(19)	 =>dec2mem_lw,
            din(18)	 =>dec2mem_lb,
            din(17)	 =>dec2mem_sw,
            din(16)	 =>dec2mem_sb,

            -- Shifter command
            din(15)	 =>dec2exe_shift_lsl,
            din(14)	 =>dec2exe_shift_lsr,
            din(13)	 => dec2exe_shift_asr,
            din(12)	 =>dec2exe_shift_ror,
            din(11)	 =>dec2exe_shift_rrx,
            din(10 downto 6) =>dec2exe_shift_val,
            din(5)	 => dec2exe_cy,

            -- Alu operand selection
            din(4)	 => dec2exe_comp_op1,	
            din(3)	 => dec2exe_comp_op2,	
            din(2)	 => dec2exe_alu_cy ,	

            -- Alu command
            din(1 downto 0)	 => dec2exe_alu_cmd	,



            -- Exec  operands
            dout(126 downto 95)	 => dec_op1,
            dout(94 downto 63)	 => dec_op2,
            dout(62 downto 59)	 => dec_exe_dest,
            dout(58)	 => dec_exe_wb,
            dout(57)	 => dec_flag_wb,

            -- Decod to mem via exec
            dout(56 downto 25)	 =>dec_mem_data,
            dout(24 downto 21)	 =>dec_mem_dest,
            dout(20)	 =>dec_pre_index, 

            dout(19)	 =>dec_mem_lw,	
            dout(18)	 =>dec_mem_lb,	
            dout(17)	 =>dec_mem_sw,	
            dout(16)	 =>dec_mem_sb,	

            -- Shifter command
            dout(15)	 =>dec_shift_lsl,	
            dout(14)	 =>dec_shift_lsr,	
            dout(13)	 =>dec_shift_asr,	
            dout(12)	 =>dec_shift_ror,	
            dout(11)	 =>dec_shift_rrx,	
            dout(10 downto 6)	 =>dec_shift_val,	
            dout(5)	 =>dec_cy,	

            -- Alu operand selection
			dout(4)	 =>dec_comp_op1,	
			dout(3)	 =>dec_comp_op2,	
			dout(2)	 =>dec_alu_cy,	
            dout(1 downto 0) => dec_alu_cmd,

            push		 => dec2exe_push,
            pop		 	=> exe_pop,

            empty		 => dec2exe_empty,
            full		 => dec2exe_full,

            reset_n	 => reset_n,
            ck			 => ck,
            vdd		 => vdd,
            vss		 => vss);


-- Execution condition

	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or   -- equal
                        (if_ir(31 downto 28) = X"1" and zero = '0') or   -- not equal
                        (if_ir(31 downto 28) = X"2" and cry = '1') or    -- unsigned higher or same
                        (if_ir(31 downto 28) = X"3" and cry = '0') or    --
                        (if_ir(31 downto 28) = X"4" and neg = '0') or    --
                        (if_ir(31 downto 28) = X"5" and neg = '0') or    --
                        (if_ir(31 downto 28) = X"6" and ovr = '0') or    --
                        (if_ir(31 downto 28) = X"7" and ovr = '0') or    --
                        (if_ir(31 downto 28) = X"8" and cry = '1' and zero = '0') or    --
                        (if_ir(31 downto 28) = X"9" and cry = '0' and zero = '1') or
                        (if_ir(31 downto 28) = X"A" and neg=ovr  )  or
                        (if_ir(31 downto 28) = X"B" and neg /= ovr) or
                        (if_ir(31 downto 28) = X"C" and (zero='0' and (neg=ovr))) or
                        (if_ir(31 downto 28) = X"D" and (zero = '1' or (neg /= ovr))) or
						(if_ir(31 downto 28) = X"E") else '0';

	condv <= '1'	    when    if_ir(31 downto 28) = X"E" else
		reg_cznv_s	    when    (if_ir(31 downto 28) = X"0" or
                                if_ir(31 downto 28) = X"1" or
                                if_ir(31 downto 28) = X"2" or
                                if_ir(31 downto 28) = X"3" or
                                if_ir(31 downto 28) = X"4" or
                                if_ir(31 downto 28) = X"5" or
                                if_ir(31 downto 28) = X"8" or
                                if_ir(31 downto 28) = X"9") else
            reg_vv_s    when    (if_ir(31 downto 28) = X"6" or
                                if_ir(31 downto 28) = X"7") else                   
reg_cznv_s and reg_vv_s when    (if_ir(31 downto 28) = X"A" or
                                if_ir(31 downto 28) = X"B" or
                                if_ir(31 downto 28) = X"C" or
                                if_ir(31 downto 28) = X"D") 
                                else '0';


-- decod instruction type

	regop_t <= '1' when	if_ir(27 downto 26) = "00" else '0';
    mult_t <= '1' when	if_ir(27 downto 22) = "000000" else '0';
    --swap_t <= '1' when	if_ir(27 downto 23) = "00010" else '0';
    trans_t <= '1' when	if_ir(27 downto 26) = "01" else '0';
    mtrans_t <= '1' when	if_ir(27 downto 26) = "100" else '0';
    branch_t <= '1' when	if_ir(27 downto 25) = "101" else '0';
    



-- decod regop opcode

	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
    eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
    sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
    rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
    add_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"4" else '0';
    adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
    sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
    rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
    tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
    teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
    cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"A" else '0';
    cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"B" else '0';
    orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"C" else '0';
    mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"D" else '0';
    bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"E" else '0';
    mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"F" else '0';


-- mult instruction
    mul_i <= '1' when mult_t = '1' and if_ir(21) = '0' else '0';
    mla_i <= '1' when mult_t = '1' and if_ir(21) = '1' else '0';

-- trans instruction
    ldr_i <= '1' when trans_t = '1' and if_ir(20) = '1' else '0';
    str_i <= '1' when trans_t = '1' and if_ir(20) = '0' else '0';
    ldrb_i <= '1' when trans_t = '1' and if_ir(22) = '1' and if_ir(20) = '1' else '0';
    strb_i <= '1' when trans_t = '1' and if_ir(22) = '1' and if_ir(20) = '0' else '0';

-- mtrans instruction
    ldm_i <= '1' when mtrans_t = '1' and if_ir(20) = '1' else '0';
    stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else '0';

-- branch instruction 
    b_i <= '1' when branch_t = '1' and if_ir(24) = '0' else '0';
    bl_i <= '1' when branch_t = '1' and if_ir(24) = '1' else '0';

-- Multiple transferts
    --mtrans_shift     
    --mtrans_loop_adr  

    --Immediat
    I <= '0' when (if_ir(25) = '0' and regop_t = '1') or (if_ir(25) = '1' and trans_t = '1') else '1';
    S <= '1' when (if_ir(20) = '1' and regop_t = '1') else '0';

    --registre de destination Rd
    dec2exe_dest <= if_ir(15 downto 12) when regop_t = '1' or trans_t = '1' else "UUUU";

    --registre de base Rn
    radr1_s <= if_ir(19 downto 16) when regop_t = '1' or trans_t = '1' or mtrans_t = '1' else "0000";

    --second opérande Rm
    radr2_s <= if_ir(3 downto 0) when I = '0' else "0000"; 

    --registre source Rs pour décalages LSL,LSR,ASR et ROR
    radr3_s <= if_ir(11 downto 8) when (I = '0' and if_ir(4) = '1' and if_ir(7) = '0') else "0000";

    --On s'assure de la validité des Opérandes Rn, Rm et Rs lorsqu'ils sont utilsés
    --regop_t
        --1) Rn
        --2) Rn, Rm
        --3) Rn, Rm et Rs
    --trans_t
        --1) Rn
        --2) Rn, Rm
        --3) Rn, Rm et Rs
    Opv <=  reg_v1_s                            when I = '1' and regop_t = '1' else
            reg_v1_s and reg_v2_s               when I = '0' and if_ir(4) = '0' and regop_t = '1' else
            reg_v1_s and reg_v2_s and reg_v3_s  when I = '0' and if_ir(4) = '1' and regop_t = '1' else
            reg_v1_s                            when I = '0' and trans_t = '1' else
            reg_v1_s and reg_v2_s               when I = '1' and if_ir(4) = '0' and trans_t = '1' else
            reg_v1_s and reg_v2_s and reg_v3_s  when I = '1' and if_ir(4) = '1' and trans_t = '1' else '0';
        

    --DECALAGES de trans_t
    shift_type <= if_ir(6 downto 5) when I = '0' else "00"; 
                 
    
    dec2exe_shift_lsl <= '1' when shift_type="00" else '0';
    dec2exe_shift_lsr <= '1' when shift_type="01" else '0';
    dec2exe_shift_asr <= '1' when shift_type="10" else '0';
    dec2exe_shift_ror <= '1' when shift_type="11" else '0';
    dec2exe_shift_rrx <= '1' when shift_type="11" and dec2exe_shift_val = "00000" else '0';

    dec2exe_shift_val <= if_ir(11 downto 7) when (I = '0' and if_ir(4) = '0') else 
                         reg_rd3_s(4 downto 0) when (I = '0' and if_ir(4) = '1') else "00000"; 
 

--ALU
    --commande alu
    dec2exe_alu_cmd <= "01" when (and_i = '1' or tst_i = '1' or bic_i = '1') else
                       "10" when (orr_i = '1') else
                       "11" when (eor_i = '1' or teq_i = '1') else "00";
    
    --la retenue d'entrée de l'alu vaut 1 pour les opérations avec soustractions 
    dec2exe_alu_cy <= '1' when (sub_i='1' or rsb_i='1' or sbc_i='1' or rsc_i='1' or cmp_i='1') else '0';

    --cas où l'opérande 1 (Rn) est négatif
    dec2exe_comp_op1 <= '1' when (rsb_i='1' or rsc_i='1') else '0';
    --cas où l'opérande 2 (Op2) est négatif ou Op2 est juste complémenté
    dec2exe_comp_op2 <= '1' when (sub_i='1' or sbc_i='1' or cmp_i='1' or bic_i='1' or mvn_i='1') else '0';

    
-- machine a état mealy (FETCH,RUN,LINK,MTRANS,BRANCH) 
    process(ck)
        begin
        if(rising_edge(ck))then
            if(reset_n='0')then
            EP <= FETCH;
            else
            EP <= EF;
            end if;
        end if;
    end process;
    
    --entrée possible : dec2if_write,link
    process(dec2if_full,if2dec_empty,dec2exe_full,condv,cond,dec2if_push,branch_t,mtrans_t)
        begin
            case EP is
                when FETCH =>
                    dec2exe_push <= '0';
                    if2dec_pop <= '0';
                    
                    if dec2if_full = '1' then --T1
                        dec2if_push <= '0';
                        EF <= FETCH;
                    elsif dec2if_full = '0' and reg_pcv_s = '1' then -- T2 OU à écrire le signal  dec2if_write = '1'
                        dec2if_push <= '1';
                        EF <= RUN;
                    end if;

                when RUN =>
                    if (if2dec_empty = '1' and dec2exe_full = '1') or condv = '0' or Opv='0' then --(if2dec_empty = '1' and dec2exe_full = '1') or (condv = '0' and dec2if_push = '1' and dec2if_full='0')
                        EF <= RUN;
                        if2dec_pop <= '0';
                        dec2exe_push <= '0';

                        if dec2if_full = '0' then --nouvelle valeur de pc peut être envoyée
                            dec2if_push <= '1';
                        else
                            dec2if_push <= '0';
                        end if;
                    
                    --prédicat faux, instruction à jeter
                    elsif cond = '0' then
                        EF <= RUN;
                        if2dec_pop <= '1';

                        if dec2if_full = '0' then --nouvelle valeur de pc peut être envoyée
                            dec2if_push <= '1';
                        else
                            dec2if_push <= '0';
                        end if;

                    elsif cond = '1' then
                        EF <= RUN;
                        if2dec_pop <= '1';
                        dec2exe_push <= '1';
                        if dec2if_full = '0' then --nouvelle valeur de pc peut être envoyée
                            dec2if_push <= '1';
                        else
                            dec2if_push <= '0';
                        end if;
--                    elsif link = '1' then
--                        EF <= LINK
--                    elsif branch_t = '1' then
--                        EF <= BRANCH;
--                    end if;
--                    
--                when LINK =>                    --aucune condition
--                        EF <= BRANCH;           
--                    end if;
--
--                when BRANCH=>
--                    if if2dec_empty = '1' then
--                        EF<=BRANCH;
--                    else
--                        EF<=BRANCH;
--                    end if;
--                
--                when BRANCH=>
--                    if if2dec_empty = '0'then
--                        EF<=BRANCH;
--                    else
--                        EF<=BRANCH;
                    end if;
            end case;
    end process;
    
    -- execution regop_t
    --dec_op1 <=    if dec2exe_push = '1' and and_i = '1' 
    
    inc_pc_s <= dec2if_push; --à chaque fois qu'on fait un push on incrémente pc
    dec_pop <= if2dec_pop;
end Behavior;