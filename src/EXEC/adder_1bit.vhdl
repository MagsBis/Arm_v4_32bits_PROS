LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.numeric_std.all;

ENTITY add1 IS
    PORT(
        A:in std_logic;
        B:in std_logic;
        cin:in std_logic;
        cout : out std_logic;
        S:out std_logic
    );
END add1;


ARCHITECTURE archi OF add1 IS
    BEGIN
        S <= A xor B xor cin;
        cout <= (A and B) or (cin and B) or (A and cin);        
END archi;