library ieee;
use ieee.std_logic_1164.all;

entity add4 is port (
    d1, d2: in bit_vector(3 downto 0);
    ci    : in bit;
    s     : out bit_vector(3 downto 0);
    co    : out bit
    );
end entity add4;

architecture add_4 of add4 is
component fullAdd
    port(
        x, y, cin: in bit;
        sum, cout: out bit
    );
end component;
signal c: bit_vector(3 downto 1);
begin
    FA0: fullAdd Port map(d1(0), d2(0), ci, s(0), c(1));
    FA1: fullAdd Port map(d1(1), d2(1), c(1), s(1), c(2));
    FA2: fullAdd Port map(d1(2), d2(2), c(2), s(2), c(3));
    FA3: fullAdd Port map(d1(3), d2(3), c(3), s(3), co);
end architecture add_4;



