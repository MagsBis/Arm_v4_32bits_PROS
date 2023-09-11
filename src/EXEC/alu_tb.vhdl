library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture archi of alu_tb is

    component alu
        port ( op1  : in  Std_Logic_Vector(31 downto 0);
            op2  : in  Std_Logic_Vector(31 downto 0);
            cin  : in  Std_Logic;
            cmd  : in  Std_Logic_Vector(1 downto 0);
            res  : out Std_Logic_Vector(31 downto 0);
            cout : out Std_Logic;
            z    : out Std_Logic;
            n    : out Std_Logic;
            v    : out Std_Logic;
            vdd  : in  bit;
            vss  : in  bit );
    end component;
   
    signal op1  :   Std_Logic_Vector(31 downto 0);
    signal op2  :   Std_Logic_Vector(31 downto 0);
    signal cin  :   Std_Logic;
    signal cmd  :   Std_Logic_Vector(1 downto 0);
    signal res  :   Std_Logic_Vector(31 downto 0);
    signal cout :   Std_Logic;
    signal z    :   Std_Logic;
    signal n    :   Std_Logic;
    signal v    :   Std_Logic;
    signal vdd  :   bit;
    signal vss  :   bit;

    begin
    my_alu : alu
                port map(
                    op1 => op1,
                    op2 => op2,
                    cin => cin,
                    cmd => cmd,
                    res => res,
                    cout => cout,
                    z => z,
                    n => n,
                    vdd => vdd,
                    vss => vss);

    process 
        variable vres  : Std_Logic_Vector(31 downto 0);
        variable vcout : Std_Logic;
        variable vz    : Std_Logic;
        variable vn    : Std_Logic;
        variable vv    : Std_Logic;

    begin
        --add
        cmd <= "00";
        op1 <= x"00000003";
        op2 <= x"00000004";
        cin <= '1';

        vres  := x"00000008";
        vcout := '0';
        vz    := '0';
        vn    := '0';
        vv    := '0';
        wait for 1 ns;

        assert vres = res report "Erreur sur res" severity error;
        assert vcout = cout report "Erreur sur cout" severity error;
        assert vz = z report "Erreur sur z" severity error;
        assert vn = n report "Erreur sur n" severity error;
        assert vv = v report "Erreur sur v" severity error;

        --and
        cmd <= "01";
        op1 <= x"0000000F";
        op2 <= x"0000000A";
        cin <= '1';

        vres  := x"0000000A";
        vcout := '1';
        vz    := '0';
        vn    := '0';
        vv    := '0';
        wait for 1 ns;

        assert vres = res report "Erreur sur res" severity error;
        assert vcout = cout report "Erreur sur cout" severity error;
        assert vz = z report "Erreur sur z" severity error;
        assert vn = n report "Erreur sur n" severity error;
        assert vv = v report "Erreur sur v" severity error;

        --or
        cmd <= "10";
        op1 <= x"0000000F";
        op2 <= x"0000003A";
        cin <= '0';

        vres  := x"0000003F";
        vcout := '0';
        vz    := '0';
        vn    := '0';
        vv    := '0';
        wait for 1 ns;

        assert vres = res report "Erreur sur res" severity error;
        assert vcout = cout report "Erreur sur cout" severity error;
        assert vz = z report "Erreur sur z" severity error;
        assert vn = n report "Erreur sur n" severity error;
        assert vv = v report "Erreur sur v" severity error;

        --xor
        cmd <= "11";
        op1 <= x"0000000F";
        op2 <= x"0000003A";
        cin <= '0';

        vres  := x"00000035";
        vcout := '0';
        vz    := '0';
        vn    := '0';
        vv    := '0';
        wait for 1 ns;

        assert vres = res report "Erreur sur res" severity error;
        assert vcout = cout report "Erreur sur cout" severity error;
        assert vz = z report "Erreur sur z" severity error;
        assert vn = n report "Erreur sur n" severity error;
        assert vv = v report "Erreur sur v" severity error;


        assert false report "end of test" severity note;


    wait;
    end process;
    --cmd <= "11" after 1 ns, "01" after 2 ns, "10" after 3 ns, "11" after 4 ns,"11" after 10 ns;
    --op1 <= x"00000003" after 1 ns, x"00000003" after 2 ns, x"00000060" after 3 ns, x"00000040" after 4 ns, x"00000040" after 10 ns;
    --op2 <= x"00000006" after 1 ns, x"00000004" after 2 ns, x"00000009" after 3 ns, x"00000030" after 4 ns,x"00000040" after 10 ns;

end archi;
