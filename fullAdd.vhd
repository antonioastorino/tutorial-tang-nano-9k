library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all; -- not working, using numeric_std instead

entity fullAdd is port (
    x, y, cin  : in bit;
    sum, cout  : out bit 
    );
end entity fullAdd;

architecture full_add of fullAdd is
begin
    sum     <= x xor y xor cin;
    cout    <= (x and y) or (y and cin) or (x and cin);
end architecture full_add;



