library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);  	--donnée1 à écrire
		wadr1			: in Std_Logic_Vector(3 downto 0);  --registre d'écriture
		wen1			: in Std_Logic;						--on écrit si  égal à 1

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);		--donnée2 à écrire
		wadr2			: in Std_Logic_Vector(3 downto 0);  --registre d'écriture
		wen2			: in Std_Logic;						--on écrit si  égal à 1

	-- Write CSPR Port
		wcry			: in Std_Logic;						
		wzero			: in Std_Logic;						
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb			: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);	--donnée lue dans le registre
		radr1			: in Std_Logic_Vector(3 downto 0);  --registre de lecture
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
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
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is
    --16 registres 
    signal reg_0  : std_logic_vector(31 downto 0);
    signal reg_1  : std_logic_vector(31 downto 0);
    signal reg_2  : std_logic_vector(31 downto 0);
    signal reg_3  : std_logic_vector(31 downto 0);
    signal reg_4  : std_logic_vector(31 downto 0);
    signal reg_5  : std_logic_vector(31 downto 0);
    signal reg_6  : std_logic_vector(31 downto 0);
    signal reg_7  : std_logic_vector(31 downto 0);
    signal reg_8  : std_logic_vector(31 downto 0);
    signal reg_9  : std_logic_vector(31 downto 0);
    signal reg_10 : std_logic_vector(31 downto 0);
    signal reg_11 : std_logic_vector(31 downto 0);
    signal reg_12 : std_logic_vector(31 downto 0);
    signal reg_SP : std_logic_vector(31 downto 0);
    signal reg_LR : std_logic_vector(31 downto 0);
    signal reg_PC_s : std_logic_vector(31 downto 0);

    --bits de validité des registres
    signal reg_0_v  : std_logic;
    signal reg_1_v  : std_logic;
    signal reg_2_v  : std_logic;
    signal reg_3_v  : std_logic;
    signal reg_4_v  : std_logic;
    signal reg_5_v  : std_logic;
    signal reg_6_v  : std_logic;
    signal reg_7_v  : std_logic;
    signal reg_8_v  : std_logic;
    signal reg_9_v  : std_logic;
    signal reg_10_v : std_logic;
    signal reg_11_v : std_logic;
    signal reg_12_v : std_logic;
    signal reg_SP_v : std_logic;
    signal reg_LR_v : std_logic;
    signal reg_PC_v : std_logic;

    --flag C,Z,N et V
    signal c  : std_logic;
    signal z  : std_logic;
    signal n  : std_logic;
    signal ovr: std_logic;

    --bit de validité des flags
    signal czn_v  : std_logic;
    signal ovr_v  : std_logic;

	signal inval_reg : std_logic_vector(15 downto 0);
	signal wadr1_v : std_logic_vector(15 downto 0);
	signal wadr2_v : std_logic_vector(15 downto 0);

	begin
		--Invalidation des registres
		inval_reg(0)  <= '1' when (inval_adr1=x"0" and inval1='1') or (inval_adr2=x"0" and inval2='1') else '0';
		inval_reg(1)  <= '1' when (inval_adr1=x"1" and inval1='1') or (inval_adr2=x"1" and inval2='1') else '0';
		inval_reg(2)  <= '1' when (inval_adr1=x"2" and inval1='1') or (inval_adr2=x"2" and inval2='1') else '0';
		inval_reg(3)  <= '1' when (inval_adr1=x"3" and inval1='1') or (inval_adr2=x"3" and inval2='1') else '0';
		inval_reg(4)  <= '1' when (inval_adr1=x"4" and inval1='1') or (inval_adr2=x"4" and inval2='1') else '0';
		inval_reg(5)  <= '1' when (inval_adr1=x"5" and inval1='1') or (inval_adr2=x"5" and inval2='1') else '0';
		inval_reg(6)  <= '1' when (inval_adr1=x"6" and inval1='1') or (inval_adr2=x"6" and inval2='1') else '0';
		inval_reg(7)  <= '1' when (inval_adr1=x"7" and inval1='1') or (inval_adr2=x"7" and inval2='1') else '0';
		inval_reg(8)  <= '1' when (inval_adr1=x"8" and inval1='1') or (inval_adr2=x"8" and inval2='1') else '0';
		inval_reg(9)  <= '1' when (inval_adr1=x"9" and inval1='1') or (inval_adr2=x"9" and inval2='1') else '0';
		inval_reg(10) <= '1' when (inval_adr1=x"A" and inval1='1') or (inval_adr2=x"A" and inval2='1') else '0';
		inval_reg(11) <= '1' when (inval_adr1=x"B" and inval1='1') or (inval_adr2=x"B" and inval2='1') else '0';
		inval_reg(12) <= '1' when (inval_adr1=x"C" and inval1='1') or (inval_adr2=x"C" and inval2='1') else '0';
		inval_reg(13) <= '1' when (inval_adr1=x"D" and inval1='1') or (inval_adr2=x"D" and inval2='1') else '0';
		inval_reg(14) <= '1' when (inval_adr1=x"E" and inval1='1') or (inval_adr2=x"E" and inval2='1') else '0';
		inval_reg(15) <= '1' when (inval_adr1=x"F" and inval1='1') or (inval_adr2=x"F" and inval2='1') else '0';

		--Autorisation à écrire dans les registres via le port 1
		wadr1_v(0)  <= '1' when (wadr1=x"0" and inval_reg(0)='1'  and wen1='1') else '0';
		wadr1_v(1)  <= '1' when (wadr1=x"1" and inval_reg(1)='1'  and wen1='1') else '0';		
		wadr1_v(2)  <= '1' when (wadr1=x"2" and inval_reg(2)='1'  and wen1='1') else '0';
		wadr1_v(3)  <= '1' when (wadr1=x"3" and inval_reg(3)='1'  and wen1='1') else '0';
		wadr1_v(4)  <= '1' when (wadr1=x"4" and inval_reg(4)='1'  and wen1='1') else '0';
		wadr1_v(5)  <= '1' when (wadr1=x"5" and inval_reg(5)='1'  and wen1='1') else '0';
		wadr1_v(6)  <= '1' when (wadr1=x"6" and inval_reg(6)='1'  and wen1='1') else '0';
		wadr1_v(7)  <= '1' when (wadr1=x"7" and inval_reg(7)='1'  and wen1='1') else '0';		
		wadr1_v(8)  <= '1' when (wadr1=x"8" and inval_reg(8)='1'  and wen1='1') else '0';
		wadr1_v(9)  <= '1' when (wadr1=x"9" and inval_reg(9)='1'  and wen1='1') else '0';
		wadr1_v(10) <= '1' when (wadr1=x"A" and inval_reg(10)='1' and wen1='1') else '0';
		wadr1_v(11) <= '1' when (wadr1=x"B" and inval_reg(11)='1' and wen1='1') else '0';
		wadr1_v(12) <= '1' when (wadr1=x"C" and inval_reg(12)='1' and wen1='1') else '0';
		wadr1_v(13) <= '1' when (wadr1=x"D" and inval_reg(13)='1' and wen1='1') else '0';
		wadr1_v(14) <= '1' when (wadr1=x"E" and inval_reg(14)='1' and wen1='1') else '0';
		wadr1_v(15) <= '1' when (wadr1=x"F" and inval_reg(15)='1' and wen1='1') else '0';

		--Autorisation à écrire dans les registres via le port 2
		wadr2_v(0)  <= '1' when (wadr2=x"0" and inval_reg(0)='1'  and wen2='1') else '0';
		wadr2_v(1)  <= '1' when (wadr2=x"1" and inval_reg(1)='1'  and wen2='1') else '0';		
		wadr2_v(2)  <= '1' when (wadr2=x"2" and inval_reg(2)='1'  and wen2='1') else '0';
		wadr2_v(3)  <= '1' when (wadr2=x"3" and inval_reg(3)='1'  and wen2='1') else '0';
		wadr2_v(4)  <= '1' when (wadr2=x"4" and inval_reg(4)='1'  and wen2='1') else '0';
		wadr2_v(5)  <= '1' when (wadr2=x"5" and inval_reg(5)='1'  and wen2='1') else '0';
		wadr2_v(6)  <= '1' when (wadr2=x"6" and inval_reg(6)='1'  and wen2='1') else '0';
		wadr2_v(7)  <= '1' when (wadr2=x"7" and inval_reg(7)='1'  and wen2='1') else '0';		
		wadr2_v(8)  <= '1' when (wadr2=x"8" and inval_reg(8)='1'  and wen2='1') else '0';
		wadr2_v(9)  <= '1' when (wadr2=x"9" and inval_reg(9)='1'  and wen2='1') else '0';
		wadr2_v(10) <= '1' when (wadr2=x"A" and inval_reg(10)='1' and wen2='1') else '0';
		wadr2_v(11) <= '1' when (wadr2=x"B" and inval_reg(11)='1' and wen2='1') else '0';
		wadr2_v(12) <= '1' when (wadr2=x"C" and inval_reg(12)='1' and wen2='1') else '0';
		wadr2_v(13) <= '1' when (wadr2=x"D" and inval_reg(13)='1' and wen2='1') else '0';
		wadr2_v(14) <= '1' when (wadr2=x"E" and inval_reg(14)='1' and wen2='1') else '0';
		wadr2_v(15) <= '1' when (wadr2=x"F" and inval_reg(15)='1' and wen2='1') else '0';



	--Ecriture dans les registres
	process(ck,reset_n)
		variable reg_PC_var : std_logic_vector(31 downto 0);
		variable reg_PC_v_var : std_logic;
		variable pc_val_var : integer;

		begin

		if rising_edge(ck) then
			if reset_n = '0' then

				--Initialisation des bits de validité asociés aux registres
				reg_0_v  <= '1';
				reg_1_v  <= '1';
				reg_2_v  <= '1';
				reg_3_v  <= '1';
				reg_4_v  <= '1';
				reg_5_v  <= '1';
				reg_6_v  <= '1';
				reg_7_v  <= '1';
				reg_8_v  <= '1';
				reg_9_v  <= '1';
				reg_10_v <= '1';
				reg_11_v <= '1';
				reg_12_v <= '1';
				reg_SP_v <= '1';
				reg_LR_v <= '1';
				--reg_PC_v <= '1';
				reg_PC_v_var := '1';

				
				--Initialisation des flags C,Z,N et V
				c  <= '0';
				z  <= '0';
				n  <= '0';
				ovr  <= '0';
				
				--Initialisation des des bits de validité associés aux flags
				czn_v <= '1';
    			ovr_v   <= '1';

			else
				--gestion bits de validité des registres
				if inval_reg(0)='1' then
					reg_0_v <= '0';
				end if;

				if inval_reg(1)='1' then
					reg_1_v <= '0';
				end if;

				if inval_reg(2)='1' then
					reg_2_v <= '0';
				end if;

				if inval_reg(3)='1' then
					reg_3_v <= '0';
				end if;

				if inval_reg(4)='1' then
					reg_4_v <= '0';
				end if;

				if inval_reg(5)='1' then
					reg_5_v <= '0';
				end if;

				if inval_reg(6)='1' then
					reg_6_v <= '0';
				end if;

				if inval_reg(7)='1' then
					reg_7_v <= '0';
				end if;

				if inval_reg(8)='1' then
					reg_8_v <= '0';
				end if;

				if inval_reg(9)='1' then
					reg_9_v <= '0';
				end if;

				if inval_reg(10)='1' then
					reg_10_v <= '0';
				end if;

				if inval_reg(11)='1' then
					reg_11_v <= '0';
				end if;

				if inval_reg(12)='1' then
					reg_12_v <= '0';
				end if;

				if inval_reg(13)='1' then
					reg_SP_v <= '0';
				end if;

				if inval_reg(14)='1' then
					reg_LR_v <= '0';
				end if;

				if inval_reg(15)='1' then
					--reg_PC_v <= '0';
					reg_PC_v_var := '0';  
				end if;

				--Gestion des bits de validité des flags
				if inval_czn='1' then
					czn_v <= '0';
				end if;

				if inval_ovr='1' then
					ovr_v <= '0';
				end if;

				--ECRITURE dans les registres
				if wadr1_v(0)='1' then
					reg_0 <= wdata1;--on écrit dans le registre 0 la donnée 1
					reg_0_v <= '1'; --on valide le registre 0
				elsif wadr2_v(0)='1' and wadr1_v(0)='0' then
					reg_0 <= wdata2;--on écrit dans le registre 0 la donnée 2
					reg_0_v <= '1'; 
				end if;

				if wadr1_v(1)='1' then
					reg_1 <= wdata1; 
					reg_1_v <= '1';  
				elsif wadr2_v(1)='1' and wadr1_v(1)='0' then
					reg_1 <= wdata2; 
					reg_1_v <= '1';  
				end if;

				if wadr1_v(2)='1' then
					reg_2 <= wdata1; 
					reg_2_v <= '1';  
				elsif wadr2_v(0)='1' and wadr1_v(2)='0' then
					reg_2 <= wdata2; 
					reg_2_v <= '1';  
				end if;

				if wadr1_v(3)='1' then
					reg_3 <= wdata1; 
					reg_3_v <= '1';  
				elsif wadr2_v(3)='1' and wadr1_v(3)='0' then
					reg_3 <= wdata2; 
					reg_3_v <= '1';  
				end if;

				if wadr1_v(4)='1' then
					reg_4 <= wdata1; 
					reg_4_v <= '1';  
				elsif wadr2_v(4)='1' and wadr1_v(4)='0' then
					reg_4 <= wdata2; 
					reg_4_v <= '1';  
				end if;

				if wadr1_v(5)='1' then
					reg_5 <= wdata1; 
					reg_5_v <= '1';  
				elsif wadr2_v(5)='1' and wadr1_v(5)='0' then
					reg_5 <= wdata2; 
					reg_5_v <= '1';  
				end if;

				if wadr1_v(6)='1' then
					reg_6 <= wdata1; 
					reg_6_v <= '1';  
				elsif wadr2_v(6)='1' and wadr1_v(6)='0' then
					reg_6 <= wdata2; 
					reg_6_v <= '1';  
				end if;

				if wadr1_v(7)='1' then
					reg_7 <= wdata1; 
					reg_7_v <= '1';  
				elsif wadr2_v(7)='1' and wadr1_v(7)='0' then
					reg_7 <= wdata2; 
					reg_7_v <= '1'; 
				end if;

				if wadr1_v(8)='1' then
					reg_8 <= wdata1; 
					reg_8_v <= '1';  
				elsif wadr2_v(8)='1' and wadr1_v(8)='0' then
					reg_8 <=  wdata2; 
					reg_8_v <= '1';  
				end if;

				if wadr1_v(9)='1' then
					reg_9 <= wdata1; 
					reg_9_v <= '1';  
				elsif wadr2_v(9)='1' and wadr1_v(9)='0' then
					reg_9 <=  wdata2; 
					reg_9_v <= '1';  
				end if;

				if wadr1_v(10)='1' then
					reg_10 <= wdata1; 
					reg_10_v <= '1';  
				elsif wadr2_v(10)='1' and wadr1_v(10)='0' then
					reg_10 <= wdata1; 
					reg_10_v <= '1'; 
				end if;

				if wadr1_v(11)='1' then
					reg_11 <=  wdata1; 
					reg_11_v <= '1';  
				elsif wadr2_v(11)='1' and wadr1_v(11)='0' then
					reg_11 <= wdata2; 
					reg_11_v <= '1'; 
				end if;

				if wadr1_v(12)='1' then
					reg_12 <= wdata1; 
					reg_12_v <= '1';  
				elsif wadr2_v(12)='1' and wadr1_v(12)='0' then
					reg_12 <=  wdata2; 
					reg_12_v <= '1';  
				end if;

				if wadr1_v(13)='1' then
					reg_SP <= wdata1; 
					reg_SP_v <= '1';  
				elsif wadr2_v(13)='1' and wadr1_v(13)='0' then
					reg_SP <=  wdata2; 
					reg_SP_v <= '1';  
				end if;

				if wadr1_v(14)='1' then
					reg_LR <= wdata1; 
					reg_LR_v <= '1';  
				elsif wadr2_v(14)='1' and wadr1_v(14)='0' then
					reg_LR <= wdata2; 
					reg_LR_v <= '1';  
				end if;

				if wadr1_v(15)='1' then
					--reg_PC_s <= wdata1;
					reg_PC_var := wdata1;
					--reg_PC_v <= '1';  
					reg_PC_v_var := '1';  
				elsif wadr2_v(15)='1' and wadr1_v(15)='0' then
					--reg_PC_s <= wdata2; 
					reg_PC_var := wdata2;
					--reg_PC_v <= '1';
					reg_PC_v_var := '1';  
				end if;

				--MAJ des flags
				if cspr_wb='1' then
					czn_v  <= '1';
    				ovr_v  <= '1';
					c <= wcry;						
					z <= wzero;						
					n <= wneg;
					ovr <= wovr;
				end if;

				--Gestion de PC
				--------------------
				if inc_pc = '1' then 
					pc_val_var := to_integer(signed(reg_PC_var));
					pc_val_var := pc_val_var + 4;
					reg_PC_var := std_logic_vector(to_signed(pc_val_var, 32));  --pc_val_var'length
                end if;

				--------------------
				reg_pc_s <= reg_PC_var;
				reg_pc <= reg_PC_var;
				reg_PC_v <= reg_PC_v_var;
			end if;
		end if;
	end process;

	reg_pcv <= reg_pc_v;

	--Port de lecture CSPR et bits de validité associés
	reg_cry	 <= c;
	reg_zero <= z;	
	reg_neg	 <= n;	
	reg_cznv <= czn_v;	
	reg_ovr	 <= ovr;	
	reg_vv	 <= ovr_v;	
				
	
	reg_rd1 <= 	reg_0    when radr1=x"0" else
			   	reg_1    when radr1=x"1" else
			   	reg_2    when radr1=x"2" else
			   	reg_3    when radr1=x"3" else
			   	reg_4    when radr1=x"4" else
			   	reg_5    when radr1=x"5" else
			   	reg_6    when radr1=x"6" else
			   	reg_7    when radr1=x"7" else
			   	reg_8    when radr1=x"8" else
			   	reg_9    when radr1=x"9" else
			   	reg_10   when radr1=x"A" else
			   	reg_11   when radr1=x"B" else
			   	reg_12   when radr1=x"C" else
			   	reg_SP   when radr1=x"D" else
			   	reg_LR   when radr1=x"E" else
				reg_pc_s when radr1=x"F" else X"00000000";

	reg_v1  <=  reg_0_v   when radr1=x"0" else
				reg_1_v   when radr1=x"1" else
				reg_2_v   when radr1=x"2" else
				reg_3_v   when radr1=x"3" else
				reg_4_v   when radr1=x"4" else
				reg_5_v   when radr1=x"5" else
				reg_6_v   when radr1=x"6" else
				reg_7_v   when radr1=x"7" else
				reg_8_v   when radr1=x"8" else
				reg_9_v   when radr1=x"9" else
				reg_10_v  when radr1=x"A" else
				reg_11_v  when radr1=x"B" else
				reg_12_v  when radr1=x"C" else
				reg_SP_v  when radr1=x"D" else
				reg_LR_v  when radr1=x"E" else
				reg_pc_v  when radr1=x"F" else '0';

	reg_rd2 <= 	reg_0    when radr2=x"0" else
				reg_1    when radr2=x"1" else
				reg_2    when radr2=x"2" else
				reg_3    when radr2=x"3" else
				reg_4    when radr2=x"4" else
				reg_5    when radr2=x"5" else
				reg_6    when radr2=x"6" else
				reg_7    when radr2=x"7" else
				reg_8    when radr2=x"8" else
				reg_9    when radr2=x"9" else
				reg_10   when radr2=x"A" else
				reg_11   when radr2=x"B" else
				reg_12   when radr2=x"C" else
				reg_SP   when radr2=x"D" else
				reg_LR   when radr2=x"E" else
				reg_pc_s when radr2=x"F" else X"00000000";

	reg_v2  <=  reg_0_v   when radr2=x"0" else
				reg_1_v   when radr2=x"1" else
				reg_2_v   when radr2=x"2" else
				reg_3_v   when radr2=x"3" else
				reg_4_v   when radr2=x"4" else
				reg_5_v   when radr2=x"5" else
				reg_6_v   when radr2=x"6" else
				reg_7_v   when radr2=x"7" else
				reg_8_v   when radr2=x"8" else
				reg_9_v   when radr2=x"9" else
				reg_10_v  when radr2=x"A" else
				reg_11_v  when radr2=x"B" else
				reg_12_v  when radr2=x"C" else
				reg_SP_v  when radr2=x"D" else
				reg_LR_v  when radr2=x"E" else
				reg_pc_v  when radr2=x"F" else '0';


	reg_rd3 <= 	reg_0    when radr3=x"0" else
				reg_1    when radr3=x"1" else
				reg_2    when radr3=x"2" else
				reg_3    when radr3=x"3" else
				reg_4    when radr3=x"4" else
				reg_5    when radr3=x"5" else
				reg_6    when radr3=x"6" else
				reg_7    when radr3=x"7" else
				reg_8    when radr3=x"8" else
				reg_9    when radr3=x"9" else
				reg_10   when radr3=x"A" else
				reg_11   when radr3=x"B" else
				reg_12   when radr3=x"C" else
				reg_SP   when radr3=x"D" else
				reg_LR   when radr3=x"E" else
				reg_pc_s when radr3=x"F" else X"00000000";

	reg_v3  <=  reg_0_v   when radr3=x"0" else
				reg_1_v   when radr3=x"1" else
				reg_2_v   when radr3=x"2" else
				reg_3_v   when radr3=x"3" else
				reg_4_v   when radr3=x"4" else
				reg_5_v   when radr3=x"5" else
				reg_6_v   when radr3=x"6" else
				reg_7_v   when radr3=x"7" else
				reg_8_v   when radr3=x"8" else
				reg_9_v   when radr3=x"9" else
				reg_10_v  when radr3=x"A" else
				reg_11_v  when radr3=x"B" else
				reg_12_v  when radr3=x"C" else
				reg_SP_v  when radr3=x"D" else
				reg_LR_v  when radr3=x"E" else
				reg_pc_v  when radr3=x"F" else '0';

    
end Behavior;