library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Shifter is
  port(
    shift_lsl : in  Std_Logic;
    shift_lsr : in  Std_Logic;
    shift_asr : in  Std_Logic;
    shift_ror : in  Std_Logic;
    shift_rrx : in  Std_Logic;
    shift_val : in  Std_Logic_Vector(4 downto 0);
    din       : in  Std_Logic_Vector(31 downto 0);
    cin       : in  Std_Logic;
    dout      : out Std_Logic_Vector(31 downto 0);
    cout      : out Std_Logic;
    -- global interface
    vdd       : in  bit;
    vss       : in  bit );
end Shifter;

architecture archi of Shifter is
    signal bit_31	: std_logic_vector(31 downto 0);	
    signal dout_tempo_0	: std_logic_vector(31 downto 0);
    signal dout_tempo_1	: std_logic_vector(31 downto 0);
    signal dout_tempo_2	: std_logic_vector(31 downto 0);
    signal dout_tempo_3	: std_logic_vector(31 downto 0);
    signal dout_tempo_4	: std_logic_vector(31 downto 0);
    
    begin 
    bit_31 <= x"FFFFFFFF" when din(31) = '1' else x"00000000";	
	dout_tempo_0 <= 
    		 din(30 downto 0) & '0' 
             	when shift_lsl = '1' and shift_val(0) = '1' 		    --lsl
        else '0' & din(31 downto 1) 
        		when shift_lsr = '1' and shift_val(0) = '1'				--lsr
        else (din(31) & din(31 downto 1))
                when shift_asr = '1' and shift_val(0) = '1'				--asr
        else (din(0) & din(31 downto 1))
                when shift_ror = '1' and shift_val(0) = '1'				--ror
        else din;
        
	dout_tempo_1 <= 
    		dout_tempo_0(29 downto 0)& "00" 
    			when shift_lsl = '1' and shift_val(1) = '1' 			--lsl
        else "00" & dout_tempo_0 (31 downto 2)
        		when shift_lsr = '1' and shift_val(1) = '1' 			--lsr
        else (bit_31(1 downto 0) & dout_tempo_0(31 downto 2))
                when shift_asr = '1' and shift_val(1) = '1'				--asr
        else (dout_tempo_0(1 downto 0) & dout_tempo_0(31 downto 2))
                when shift_ror = '1' and shift_val(1) = '1'				--ror
        else dout_tempo_0; 
        
	dout_tempo_2 <= 
    		dout_tempo_1(27 downto 0)& x"0" 
    			when shift_lsl = '1' and shift_val(2) = '1' 			--lsl
        else x"0" & dout_tempo_1(31 downto 4)
        		when shift_lsr = '1' and shift_val(2) = '1' 			--lsr
        else (bit_31(3 downto 0) & dout_tempo_1(31 downto 4))
                when shift_asr = '1' and shift_val(2) = '1'				--asr
        else (dout_tempo_1(3 downto 0) & dout_tempo_1(31 downto 4))
                when shift_ror = '1' and shift_val(2) = '1'				--ror
        else dout_tempo_1;	
        
	dout_tempo_3 <= 
    		dout_tempo_2(23 downto 0)& x"00"
    			when shift_lsl = '1' and shift_val(3) = '1' 			--lsl
       	else x"00" & dout_tempo_2(31 downto 8) 
        		when shift_lsr = '1' and shift_val(3) = '1' 			--lsr
        else (bit_31(7 downto 0) & dout_tempo_2(31 downto 8))
                when shift_asr = '1' and shift_val(3) = '1'				--asr
        else (dout_tempo_2(7 downto 0) & dout_tempo_2(31 downto 8))
                when shift_ror = '1' and shift_val(3) = '1'				--ror
        else dout_tempo_2; 
        
	dout_tempo_4 <= 
    		dout_tempo_3 (15 downto 0)& x"0000" 
    		when shift_lsl = '1' and shift_val(4) = '1' 				--lsl
    	else x"0000" & dout_tempo_3 (31 downto 16)  
    		when shift_lsr = '1' and shift_val(4) = '1' 				--lsr
   	else (bit_31(15 downto 0) & dout_tempo_3(31 downto 16))
            	when shift_asr = '1' and shift_val(4) = '1'				--asr
    	else (dout_tempo_3(15 downto 0) & dout_tempo_3(31 downto 16))
            	when shift_ror = '1' and shift_val(4) = '1'				--ror
    	else cin & dout_tempo_3(31 downto 1) 
    			when shift_rrx = '1' and shift_lsl = '0'   
    	else dout_tempo_3; 
	
	dout <= dout_tempo_4;
        
    --cout
    cout <= dout_tempo_4(31) when shift_lsl = '1' 
       else dout_tempo_4(0) ;
end archi;
