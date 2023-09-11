LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;

entity reg_tb is
end entity;

architecture behavior of reg_tb is
	SIGNAL	wdata1			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	wadr1			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	wen1			:  Std_Logic;

	-- Write Port 2 non prioritaire
	SIGNAL	wdata2			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	wadr2			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	wen2			:  Std_Logic;

	-- Write CSPR Port
	SIGNAL	wcry			:  Std_Logic;
	SIGNAL	wzero			:  Std_Logic;
	SIGNAL	wneg			:  Std_Logic;
	SIGNAL	wovr			:  Std_Logic;
	SIGNAL	cspr_wb			:  Std_Logic;
		
	-- Read Port 1 32 bits
	SIGNAL	reg_rd1			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	radr1			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v1			:  Std_Logic;

	-- Read Port 2 32 bits
	SIGNAL	reg_rd2			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	radr2			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v2			:  Std_Logic;

	-- Read Port 3 32 bits
	SIGNAL	reg_rd3			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	radr3			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v3			:  Std_Logic;

	-- read CSPR Port
	SIGNAL	reg_cry			:  Std_Logic;
	SIGNAL	reg_zero		:  Std_Logic;
	SIGNAL	reg_neg			:  Std_Logic;
	SIGNAL	reg_cznv		:  Std_Logic;
	SIGNAL	reg_ovr			:  Std_Logic;
	SIGNAL	reg_vv			:  Std_Logic;
		
	-- Invalidate Port 
	SIGNAL	inval_adr1	:  Std_Logic_Vector(3 downto 0);
	SIGNAL	inval1		:  Std_Logic;

	SIGNAL	inval_adr2	:  Std_Logic_Vector(3 downto 0);
	SIGNAL	inval2		:  Std_Logic;

	SIGNAL	inval_czn	:  Std_Logic;
	SIGNAL	inval_ovr	:  Std_Logic;

	-- PC
	SIGNAL	reg_pc		:  Std_Logic_Vector(31 downto 0);
	SIGNAL	reg_pcv		:  Std_Logic;
	SIGNAL	inc_pc		:  Std_Logic;
	
	-- global interface
	SIGNAL	ck				:  Std_Logic;
	SIGNAL	reset_n			:  Std_Logic;
	SIGNAL	vdd				:  bit;
	SIGNAL	vss				:  bit;

	component reg is
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
		end component;

	begin 

		reg_stage: reg port map (
		-- Write Port 1 prioritaire
			wdata1 => wdata1,
			wadr1 => wadr1,
			wen1 => wen1,

		-- Write Port 2 non prioritaire
			wdata2 => wdata2,
			wadr2 => wadr2,
			wen2 => wen2,

		-- Write CSPR Port
			wcry => wcry,
			wzero => wzero,
			wneg => wneg,
			wovr => wovr,
			cspr_wb => cspr_wb,
			
		-- Read Port 1 32 bits
			reg_rd1 => reg_rd1,
			radr1 => radr1,
			reg_v1 => reg_v1,

		-- Read Port 2 32 bits
			reg_rd2 => reg_rd2,
			radr2 => radr2,
			reg_v2 => reg_v2,

		-- Read Port 3 32 bits
			reg_rd3 => reg_rd3,
			radr3 => radr3,
			reg_v3 => reg_v3,

		-- read CSPR Port
			reg_cry => reg_cry,
			reg_zero => reg_zero,
			reg_neg => reg_neg,
			reg_cznv => reg_cznv,
			reg_ovr => reg_ovr,
			reg_vv => reg_vv,
			
		-- Invalidate Port 
			inval_adr1 => inval_adr1,
			inval1 => inval1,

			inval_adr2 => inval_adr2,
			inval2 => inval2,

			inval_czn => inval_czn,
			inval_ovr => inval_ovr,

		-- PC
			reg_pc => reg_pc,
			reg_pcv => reg_pcv,
			inc_pc => inc_pc,
		
		-- global interface
			ck => ck,
			reset_n => reset_n,
			vdd => vdd,
			vss => vss
			);

	clock_process : PROCESS
	  begin 
	    ck <= '1';
	    WAIT FOR 2 ns;
	    ck <= '0';
	    WAIT FOR 2 ns;
  	end process;

  	reset: process
  		begin
  			reset_n <= '0';
  			wait for 10 ns;
  			reset_n <= '1';
  			wait;
  		end process;

	process
		--reg lecture
		variable reg_rd1_var : std_logic_vector(31 downto 0); 
		variable reg_rd2_var : std_logic_vector(31 downto 0); 
		variable reg_rd3_var : std_logic_vector(31 downto 0); 

		--flags
		variable reg_cry_var	 : std_logic;
		variable reg_zero_var : std_logic;	
		variable reg_neg_var	 : std_logic;	
		variable reg_cznv_var : std_logic;	
		variable reg_ovr_var	 : std_logic;
		variable reg_vv_var	 : std_logic;

		variable reg_pc_var : std_logic_vector(31 downto 0); 
	begin

        --
        inc_pc <= '0';
		-- test écriture et lecture
		inval_adr1 <= "1111";
		inval_adr2 <= "1111";
		inval1 <= '1';
		inval2 <= '1';

		wadr1 <= "1111";
		wen1 <= '1';
		wdata1 <= x"00000000";

		wadr2 <= "1111";
		wen2 <= '1';
		wdata2 <= x"00000008";

		radr1 <= "1111";
		radr2 <= "1111";
		radr3 <= "1111";


		--test flags
		wcry	<= '1';						
		wzero	<= '1';						
		wneg	<= '1';
		wovr	<= '1';
		cspr_wb	<= '1';


		reg_cry_var	 := '1';
		reg_zero_var := '1';	
		reg_neg_var	 := '1';	
		reg_cznv_var := '1';	
		reg_ovr_var	 := '1';
		reg_vv_var	 := '1';	

		reg_rd1_var := x"00000000";
		reg_rd2_var := x"00000000";
		reg_rd3_var := x"00000000";

		

		wait for 100 ns;
		assert reg_rd1_var = reg_rd1 report "Erreur sur reg_rd1" severity error;
		assert reg_rd2_var = reg_rd2 report "Erreur sur reg_rd2" severity error;
		assert reg_rd3_var = reg_rd3 report "Erreur sur reg_rd3" severity error;

		--test pc
        inval_adr1 <= "1111"; --invalid pc
		inval1 <= '1';--ivalid port1

		wadr1 <= "1111";
		wen1 <= '1';
		wdata1 <= x"00000000";

		radr1 <= "1111";


		inc_pc	<= '1';

		reg_pc_var := x"00000004";

		assert reg_cry_var  = reg_cry report "Erreur sur cry_var" severity error;
		assert reg_zero_var = reg_zero report "Erreur sur reg_zero" severity error;
		assert reg_neg_var  = reg_neg report "Erreur sur reg_neg" severity error;
		assert reg_cznv_var = reg_cznv report "Erreur sur reg_cznv" severity error;
		assert reg_ovr_var  = reg_ovr report "Erreur sur reg_ovr" severity error;
		assert reg_vv_var   = reg_vv report "Erreur sur reg_vv" severity error;

		wait for 10 ns;
		assert reg_pc_var   = reg_pc report "Erreur sur reg_pc" severity error;

		assert false report "marche" severity note;
    wait; 

	end process;



end architecture behavior;




--Library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity Reg_tb is
--end Reg_tb;
--
--architecture archi of Reg_tb is
--
--component Reg
--
--port(
---- Write Port 1 prioritaire
--wdata1 : in Std_Logic_Vector(31 downto 0);
--wadr1 : in Std_Logic_Vector(3 downto 0);
--wen1 : in Std_Logic;
--
---- Write Port 2 non prioritaire
--wdata2 : in Std_Logic_Vector(31 downto 0);
--wadr2 : in Std_Logic_Vector(3 downto 0);
--wen2 : in Std_Logic;
--
---- Write CSPR Port
--wcry : in Std_Logic;
--wzero : in Std_Logic;
--wneg : in Std_Logic;
--wovr : in Std_Logic;
--cspr_wb : in Std_Logic;
--
---- Read Port 1 32 bits
--reg_rd1 : out Std_Logic_Vector(31 downto 0);
--radr1 : in Std_Logic_Vector(3 downto 0);
--reg_v1 : out Std_Logic;
--
---- Read Port 2 32 bits
--reg_rd2 : out Std_Logic_Vector(31 downto 0);
--radr2 : in Std_Logic_Vector(3 downto 0);
--reg_v2 : out Std_Logic;
--
---- Read Port 3 32 bits
--reg_rd3 : out Std_Logic_Vector(31 downto 0);
--radr3 : in Std_Logic_Vector(3 downto 0);
--reg_v3 : out Std_Logic;
--
---- read CSPR Port
--reg_cry : out Std_Logic;
--reg_zero : out Std_Logic;
--reg_neg : out Std_Logic;
--reg_cznv : out Std_Logic;
--reg_ovr : out Std_Logic;
--reg_vv : out Std_Logic;
--
---- Invalidate Port 
--inval_adr1 : in Std_Logic_Vector(3 downto 0);
--inval1 : in Std_Logic;
--
--inval_adr2 : in Std_Logic_Vector(3 downto 0);
--inval2 : in Std_Logic;
--
--inval_czn : in Std_Logic;
--inval_ovr : in Std_Logic;
--
---- PC
--reg_pc : out Std_Logic_Vector(31 downto 0);
--reg_pcv : out Std_Logic;
--inc_pc : in Std_Logic;
--
---- global interface
--ck : in Std_Logic;
--reset_n : in Std_Logic;
--vdd : in bit;
--vss : in bit);
--end component;
--
--
--signal WDATA1,WDATA2,REG_RD1,REG_RD2,REG_RD3,REG_PC : std_logic_vector(31 downto 0);
--signal WADR1,WADR2,RADR1,RADR2,RADR3,INVAL_ADR1,INVAL_ADR2 : std_logic_vector(3 downto 0);
--signal WEN1,WEN2,WCRY,WZERO,WNEG,WOVR,CSPR_WB,REG_V1,REG_V2,REG_V3,REG_CRY,REG_ZERO,REG_NEG,REG_CZNV,REG_OVR,REG_VV,INVAL1,INVAL2,INVAL_CZN,INVAL_OVR,REG_PCV,INC_PC,CK,RESET_N : std_logic;
--signal VDD,VSS : bit;
--
--begin
--
--
--
--Reg_test : Reg port map(
--WDATA1, 
--WADR1,
--WEN1, 
--WDATA2,
--WADR2,
--WEN2,
--WCRY,
--WZERO,
--WNEG,
--WOVR,
--CSPR_WB,
--REG_RD1,
--RADR1,
--REG_V1,
--REG_RD2,
--RADR2,
--REG_V2,
--REG_RD3,
--RADR3,
--REG_V3,
--REG_CRY,
--REG_ZERO,
--REG_NEG,
--REG_CZNV,
--REG_OVR,
--REG_VV,
--INVAL_ADR1,
--INVAL1,
--INVAL_ADR2,
--INVAL2,
--INVAL_CZN,
--INVAL_OVR,
--REG_PC,
--REG_PCV,
--INC_PC,
--CK,
--RESET_N,
--VDD,
--VSS);
--
--
--
--
----ecrirture
--WEN1 <= '1' after 0 ns;
--WDATA1 <= x"005F0000" after 0 ns;
--WADR1 <= "1111" after 0 ns ;
--INVAL_ADR1 <= "1111" after 0 ns;
--INVAL1 <= '1' after 0 ns;
--INVAL_CZN <= '1' after 0 ns;
--INVAL_OVR <= '1' after 0 ns;
--CSPR_WB <= '1' after 0 ns;
--WCRY <= '1' after 0 ns;
--WOVR <= '1' after 0 ns; 
--WZERO <= '0' after 0 ns;
--WNEG <= '0' after 0 ns;
--INC_PC <= '1' after 6 ns;
--
----lecture
--  RADR1 <= "1111" after 0 ns;
--
--CK <= '0' after 0 ns , '1' after 1 ns , '0' after 2 ns , '1' after 3 ns , '0' after 4 ns , '1' after 5 ns, '0' after 6 ns , '1' after 7 ns , '0' after 8 ns, '1' after 9 ns , '0' after 10 ns   ;
--RESET_N <= '0' after 0 ns;
--
--
--end archi;
--