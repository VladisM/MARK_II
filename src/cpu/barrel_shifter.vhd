library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Direction
-- 1 -> LEFT
-- 0 -> RIGHT

-- Mode
-- 1 -> rotate
-- 0 -> shift


entity barrel_shifter is
    port(
        Data: in unsigned(31 downto 0);
        Result: out unsigned(31 downto 0);
        Distance: in std_logic_vector(3 downto 0);
        Direction: in std_logic;
        Mode: in std_logic
    );
end entity;

architecture barrel_shifter_arch of barrel_shifter is
    
    component shift_stage is
        port(
            A: in unsigned(31 downto 0);
            B: in unsigned(31 downto 0);
            AndEn: in unsigned(31 downto 0);
            Sel: in std_logic;
            Y: out unsigned(31 downto 0)
        );
    end component shift_stage;
    
    component swap_direction is
        port(
            A: in unsigned(31 downto 0);
            Y: out unsigned(31 downto 0)
        );
    end component swap_direction;
    
    signal stage_0, stage_1, stage_2, stage_3: unsigned(31 downto 0);
    signal swaped0, data_reverse0, data_reverse1: unsigned(31 downto 0);
  
begin
    
    sd0: swap_direction port map(Data, data_reverse0);
    
    with Direction select swaped0 <= Data when '0', data_reverse0 when others;
    
    shst0: shift_stage port map( swaped0(0) & swaped0(31 downto 1), swaped0, Mode & "111" & x"fffffff", Distance(0), stage_0);
    shst1: shift_stage port map( stage_0(1 downto 0) & stage_0(31 downto 2), stage_0, Mode & Mode & "11" & x"fffffff", Distance(1), stage_1);
    shst2: shift_stage port map( stage_1(3 downto 0) & stage_1(31 downto 4), stage_1, Mode & Mode & Mode & Mode & x"fffffff", Distance(2), stage_2);
    shst3: shift_stage port map( stage_2(7 downto 0) & stage_2(31 downto 8), stage_2, Mode & Mode & Mode & Mode & Mode & Mode & Mode & Mode & x"ffffff", Distance(3), stage_3);

    sd1: swap_direction port map(stage_3, data_reverse1);
    
    with Direction select Result <= stage_3 when '0', data_reverse1 when others;
    
end architecture barrel_shifter_arch;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_stage is
    port(
        A: in unsigned(31 downto 0);
        B: in unsigned(31 downto 0);
        AndEn: in unsigned(31 downto 0);
        Sel: in std_logic;
        Y: out unsigned(31 downto 0)
    );
end entity shift_stage;

architecture shift_stage_arch of shift_stage is
begin    
    
    with Sel select Y <= (A and AndEn) when '1', B when others;

end architecture shift_stage_arch;

    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity swap_direction is
    port(
        A: in unsigned(31 downto 0);
        Y: out unsigned(31 downto 0)
    );
end entity swap_direction;

architecture swap_direction_arch of swap_direction is
begin
    Y(0) <= A(31);
    Y(1) <= A(30);
    Y(2) <= A(29);
    Y(3) <= A(28);
    Y(4) <= A(27);
    Y(5) <= A(26);
    Y(6) <= A(25);
    Y(7) <= A(24);
    Y(8) <= A(23);
    Y(9) <= A(22);
    Y(10) <= A(21);
    Y(11) <= A(20);
    Y(12) <= A(19);
    Y(13) <= A(18);
    Y(14) <= A(17);
    Y(15) <= A(16);
    Y(16) <= A(15);
    Y(17) <= A(14);
    Y(18) <= A(13);
    Y(19) <= A(12);
    Y(20) <= A(11);
    Y(21) <= A(10);
    Y(22) <= A(9);
    Y(23) <= A(8);
    Y(24) <= A(7);
    Y(25) <= A(6);
    Y(26) <= A(5);
    Y(27) <= A(4);
    Y(28) <= A(3);
    Y(29) <= A(2);
    Y(30) <= A(1);
    Y(31) <= A(0);
end architecture swap_direction_arch;    
    
    



