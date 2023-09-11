library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
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
    end alu;

architecture archi of alu is
  signal result : std_Logic_Vector(31 downto 0);
  SIGNAL carry : std_logic_vector(32 downto 0);
  component add1
  PORT(
      A:in std_logic;
      B:in std_logic;
      cin:in std_logic;
      cout : out std_logic;
      S:out std_logic
  );
  end component;

  begin
      
          my_adder_1 : add1
          port map(a => op1(0),
                  b => op2(0),
                  cin => cin,
                  s => result(0),
                  cout => carry(1)
                  );


   boucle :   for i in 1 to 30 generate
          my_adder_2 : add1
              port map(a => op1(i),
                      b => op2(i),
                      cin => carry(i),
                      s => result(i),
                      cout => carry(i+1)
                      );      
      end generate;

      my_adder_3 : add1
        port map(a => op1(31),
                b => op2(31),
                cin => carry(31),
                s => result(31),
                cout => carry(32)
                );

      res <= result when cmd="00" 
              else (op1 and op2) when cmd="01" 
              else (op1 or op2) when cmd="10"
              else (op1 xor op2);       
               
  --cout <= carry(32);
  carry(0) <= cin;
  cout <= carry(32) when cmd="00" else cin;
  v <= carry(32);
  n <= result(31);
  z <= '1' when result=x"00000000" else '0';
end archi;