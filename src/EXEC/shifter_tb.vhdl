library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter_tb is
end shifter_tb;

architecture archi of shifter_tb is
--    signal shift_lsl    :  Std_Logic:= '0';
--    signal shift_lsr    :  Std_Logic:= '0';
--    signal shift_asr    :  Std_Logic:= '0';
--    signal shift_ror    :  Std_Logic:= '0';
--    signal shift_rrx    :  Std_Logic:= '0';
--    signal shift_val    :  Std_Logic_Vector(4 downto 0) := (others => '0');
--    signal din  		:  Std_Logic_Vector(31 downto 0):= (others => '0');
--    signal cin  		:  Std_Logic:= '0';
--    signal dout  		:  Std_Logic_Vector(31 downto 0):= (others => '0');
--    signal cout 		:  Std_Logic:= '0';
--    signal vdd  		:   bit:= '0';
--    signal vss  		:   bit:= '0';
--begin
--    my_shifter : entity work.shifter
--                port map(
--                    shift_lsl => shift_lsl,
--                    shift_lsr => shift_lsr,
--                    shift_asr => shift_asr,
--                    shift_ror => shift_ror,
--                    shift_rrx => shift_rrx,
--                    shift_val => shift_val,
--                    din => din,
--                    cin => cin,
--                    dout => dout,
--                    cout => cout,
--                    vdd => vdd,
--                    vss => vss);
--    
--    
--    --TEST DECALAGE GAUCHE LOGIQUE
--	--shift_val <= "01100" after 10 ns, "01000" after 20 ns, "11111" after 30 ns,"10000" after 40 ns;
--    --cin <= '1';
--    --din <= x"00000001" after 8 ns, x"00000003" after 16 ns, x"0000000f" after 25 ns;
--    --shift_lsl <= '1';
--
--    --cmd <= "01" after 10 ns, "00" after 20 ns, "11" after 30 ns;
--    --op1 <= x"00000001" after 8 ns, x"00000003" after 16 ns, x"0000000f" after 25 ns;
--    --op2 <= x"00000002" after 8 ns, x"00000004" after 16 ns, x"00000003" after 25 ns;
--
--
--    --TEST DECALAGE DROITE LOGIQUE
--	shift_val <= "01100" after 10 ns, "01000" after 20 ns, "11111" after 30 ns,"10000" after 40 ns;
--    cin <= '1';
--    din <= x"80000000" after 8 ns, x"30000000" after 16 ns, x"f0000000" after 25 ns;
--    shift_lsr <= '1';
--
--
--
--
--    shift_val <= "00011" after 10 ns, "01000" after 20 ns, "11111" after 30 ns,"10000" after 40 ns;
--   
--    cin <= '1';
--    --din <= x"00000001" after 8 ns, x"00000003" after 16 ns, x"0000000f" after 25 ns;
--    din <= x"10000000" after 8 ns, x"00000003" after 16 ns, x"01010101" after 25 ns;
--    --shift_lsl <= '1';
--    --shift_lsr <= '1';
--    --shift_asr <= '1';
--    --shift_ror <= '1';
--    shift_rrx <= '1';
--

component shifter
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
    end component;

    signal shift_lsl    :  Std_Logic;
    signal shift_lsr    :  Std_Logic;
    signal shift_asr    :  Std_Logic;
    signal shift_ror    :  Std_Logic;
    signal shift_rrx    :  Std_Logic;
    signal shift_val    :  Std_Logic_Vector(4 downto 0) ;
    signal din  		:  Std_Logic_Vector(31 downto 0);
    signal cin  		:  Std_Logic;
    signal dout  		:  Std_Logic_Vector(31 downto 0);
    signal cout 		:  Std_Logic;
    signal vdd  		:   bit;
    signal vss  		:   bit;

    begin
        my_shifter : shifter
                    port map(
                        shift_lsl => shift_lsl,
                        shift_lsr => shift_lsr,
                        shift_asr => shift_asr,
                        shift_ror => shift_ror,
                        shift_rrx => shift_rrx,
                        shift_val => shift_val,
                        din => din,
                        cin => cin,
                        dout => dout,
                        cout => cout,
                        vdd => vdd,
                        vss => vss);

    process

        variable vdout : std_logic_vector(31 downto 0);
        variable vcout : std_logic;

    begin
        -- LSL
            shift_val <= "00011";
            cin <= '1';
            din <= x"10000000";
            shift_lsl <= '1';
            shift_lsr <= '0';
            shift_asr <= '0';
            shift_ror <= '0';
            shift_rrx <= '0';

            vdout := x"80000000";
            vcout := '1';
            wait for 1 ns;
            assert vdout = dout report "Erreur sur dout" severity error;
            assert vcout = cout report "Erreur sur cout" severity error;

            --shift_val <= "01000";
            --cin <= '1';
            --din <= x"00000003";
--
            --vdout := x"00000300";
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;

            --shift_val <= "10000";
            --cin <= '1';
            --din <= x"81010101";
--
            --vdout := x"01010000";
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;
            
            assert false report "LSL marche" severity note;



        -- LSR
            --shift_val <= "00011";
            --cin <= '1';
            --din <= x"10000000";
            shift_lsl <= '0';
            shift_lsr <= '1';
            shift_asr <= '0';
            shift_ror <= '0';
            shift_rrx <= '0';
--
            --vdout := x"02000000";
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;
--
            --shift_val <= "01000";
            --cin <= '1';
            --din <= x"00000003";
--
            --vdout := x"00000000" ;
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;

            shift_val <= "10000";
            cin <= '1';
            din <= x"81010101";

            vdout := x"00008101";
            vcout := '1';
            wait for 1 ns;
            assert vdout = dout report "Erreur sur dout" severity error;
            assert vcout = cout report "Erreur sur cout" severity error;

            assert false report "LSR marche" severity note;

            

        -- ASR
            --shift_val <= "00011";
            --cin <= '1';
            --din <= x"10000000";
            shift_lsl <= '0';
            shift_lsr <= '0';
            shift_asr <= '1';
            shift_ror <= '0';
            shift_rrx <= '0';
--
            --vdout := x"02000000";
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;
--
            --shift_val <= "01000";
            --cin <= '1';
            --din <= x"00000003";
--
            --vdout := x"00000000" ;
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;

            shift_val <= "10000";
            cin <= '1';
            din <= x"81010101";

            vdout := x"FFFF8101" ;
            vcout := '1';
            wait for 1 ns;
            assert vdout = dout report "Erreur sur dout" severity error;
            assert vcout = cout report "Erreur sur cout" severity error;

            assert false report "ASR marche" severity note;


        -- ROR
            --shift_val <= "00011";
            --cin <= '1';
            --din <= x"10000000";
            shift_lsl <= '0';
            shift_lsr <= '0';
            shift_asr <= '0';
            shift_ror <= '1';
            shift_rrx <= '0';
--
            --vdout := x"02000000";
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;

            shift_val <= "01000";
            cin <= '1';
            din <= x"00000003";

            vdout := x"03000000";
            vcout := '0';
            wait for 1 ns;
            assert vdout = dout report "Erreur sur dout" severity error;
            assert vcout = cout report "Erreur sur cout" severity error;

            --shift_val <= "10000";
            --cin <= '1';
            --din <= x"81010101";
--
            --vdout := x"01018101";
            --vcout := '1';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;

            assert false report "ROR marche" severity note;



        -- RRX
            shift_val <= "00011";
            cin <= '1';
            din <= x"10000000";
            shift_lsl <= '0';
            shift_lsr <= '0';
            shift_asr <= '0';
            shift_ror <= '0';
            shift_rrx <= '1';

            vdout := x"88000000";
            vcout := '0';
            wait for 1 ns;
            assert vdout = dout report "Erreur sur dout" severity error;
            assert vcout = cout report "Erreur sur cout" severity error;

            --shift_val <= "01000";
            --cin <= '1';
            --din <= x"00000003";
--
            --vdout := x"80000001";
            --vcout := '1';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;
--
            --shift_val <= "10000";
            --cin <= '1';
            --din <= x"81010101";
--
            --vdout := x"c0808080";
            --vcout := '0';
            --wait for 1 ns;
            --assert vdout = dout report "Erreur sur dout" severity error;
            --assert vcout = cout report "Erreur sur cout" severity error;

            assert false report "RRX marche" severity note;

            assert false report "end of test" severity note;
    wait;
    end process;

end archi;