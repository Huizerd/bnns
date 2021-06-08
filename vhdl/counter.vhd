library ieee;
use ieee.std_logic_1164.all;

entity counter is
-- generic (
--     length : integer
-- );
port (
    A    : in std_logic_vector (15 downto 0);
    -- I think we discussed a 16 to 4-bit counter, but aren't 5 bits necessary to represent 16?
    Cout : out std_logic_vector (4 downto 0)
);
end counter;

architecture behavioural of counter is

component FA is 
port (
    A    : in std_logic;
    B    : in std_logic;
    Cin  : in std_logic;
    S    : out std_logic;
    Cout : out std_logic
);
end component;

component HA is 
port (
    A    : in std_logic;
    B    : in std_logic;
    S    : out std_logic;
    Cout : out std_logic
);
end component;

signal S,C : std_logic_vector(17 downto 0);

begin

    fa0 : FA port map(A(0),A(1),A(2),S(0),C(0));
    fa1 : FA port map(A(3),A(4),A(5),S(1),C(1));
    fa2 : FA port map(A(6),A(7),A(8),S(2),C(2));
    fa3 : FA port map(A(9),A(10),A(11),S(3),C(3));
    fa4 : FA port map(A(12),A(13),A(14),S(4),C(4));

    fa5 : FA port map(S(0),S(1),S(2),S(5),C(5));
    fa6 : FA port map(S(3),S(4),A(15),S(6),C(6));
    fa7 : FA port map(C(0),C(1),C(2),S(7),C(7));
    ha8 : HA port map(C(3),C(4),S(8),C(8));

    ha9  : HA port map(S(5),S(6),S(9),C(9));
    ha10 : HA port map(S(7),S(8),S(10),C(10));
    ha11 : HA port map(C(5),C(6),S(11),C(11));
    ha12 : HA port map(C(7),C(8),S(12),C(12));

    fa13 : FA port map(S(10),S(11),C(9),S(13),C(13));
    fa14 : FA port map(S(12),C(10),C(11),S(14),C(14));

    ha15 : HA port map(S(14),C(13),S(15),C(15));
    ha16 : HA port map(C(12),C(14),S(16),C(16));

    ha17 : HA port map(S(16),C(15),S(17),C(17));

    Cout <= C(17) & S(17) & S(15) & S(13) & S(9);

end behavioural;
