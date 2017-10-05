-- VGA driver
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz
--
-- Pixel clock:     31.5MHz
-- Resolution:      640x480 @ 73Hz
-- Text resolution: 80x30 chars
-- Char resolution: 16x8 px
--
-- Displayed text is stored in dual port video ram, in following order:
--
-- 0x0000 - 0x004F => first line
-- 0x0100 - 0x014F => second line
--        .
--        .
--        .
-- 0x1D00 - 0x1D4F => last line
--
--
-- In one line, charaters are stored as following:
--
-- 0x??00 => first character from left
-- 0x??01 => second character from left
--   .
--   .
--   .
-- 0x??4F => last character from left
--
--
-- All characters are using ASCII encoding, see full docs for more
-- details about charset.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
    );
    port(
        clk_bus: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(23 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic;
        --device
        clk_31M5: in std_logic;
        h_sync: out std_logic;
        v_sync: out std_logic;
        red: out std_logic_vector(1 downto 0);
        green: out std_logic_vector(1 downto 0);
        blue: out std_logic_vector(1 downto 0)
    );
end entity vga;

architecture vga_arch of vga is

    component font_rom is
        port(
            clk: in std_logic;
            addr: in unsigned(10 downto 0);
            data: out unsigned(7 downto 0)
        );
    end component font_rom;

    component vram is
        port(
            clk_a   : in std_logic;
            addr_a  : in unsigned(11 downto 0);
            data_a  : in unsigned(14 downto 0);
            we_a    : in std_logic;
            q_a     : out unsigned(14 downto 0);
            clk_b   : in std_logic;
            addr_b  : in unsigned(11 downto 0);
            q_b     : out unsigned(14 downto 0)
        );
    end component vram;

    --to vram
    signal tile_line: unsigned(4 downto 0);
    signal tile_row: unsigned(6 downto 0);

    --to pixel generator
    signal cell_line: unsigned(3 downto 0);
    signal cell_line_s: unsigned(3 downto 0);
    signal cell_row: unsigned(2 downto 0);
    signal cell_row_s: unsigned(2 downto 0);

    signal char_from_vram: unsigned(14 downto 0);
    signal line_from_charrom: unsigned(7 downto 0);
    signal pixel: std_logic;

    signal blank_r, blank, h_sync_r, v_sync_r: std_logic;

    signal bg_color, fg_color: unsigned(3 downto 0);

    --BUS interface
    signal addr_a  : unsigned(11 downto 0);
    signal data_a  : unsigned(14 downto 0);
    signal we_a    : std_logic;
    signal q_a     : unsigned(14 downto 0);
    signal cs: std_logic;
    
    type ack_fsm is (idle, set);
    signal ack_fsm_state: ack_fsm;
begin

    process(clk_31M5) is
        variable h_pos: integer range 0 to 832;
        variable v_pos: integer range 0 to 520;

        variable posx_v: unsigned(9 downto 0);
        variable posy_v: unsigned(8 downto 0);

    begin

        if rising_edge(clk_31M5) then

            if h_pos < 832 then
                h_pos := h_pos + 1;
            else
                h_pos := 0;
                if v_pos < 520 then
                    v_pos := v_pos + 1;
                else
                    v_pos := 0;
                end if;
            end if;

            if h_pos < 40 then
                h_sync_r <= '0';
            else
                h_sync_r <= '1';
            end if;

            if v_pos < 2 then
                v_sync_r <= '0';
            else
                v_sync_r <= '1';
            end if;

            if (h_pos > 168 and h_pos <= 808) and (v_pos > 31 and v_pos < 511) then
                blank_r <= '0';
            else
                blank_r <= '1';
            end if;

            if h_pos > 168 and h_pos < 808 then
                posx_v := posx_v + 1;
            else
                posx_v := (others => '0');
            end if;

            if v_pos > 31 and v_pos < 511 then
                if h_pos = 808 then
                    posy_v := posy_v + 1;
                end if;
            else
                posy_v := (others => '0');
            end if;

        end if;

        tile_row <= posx_v(9 downto 3);
        cell_row <= posx_v(2 downto 0);

        tile_line <= posy_v(8 downto 4);
        cell_line <= posy_v(3 downto 0);

    end process;

    process(clk_31M5, cell_line) is
        variable cell_line_var: unsigned(3 downto 0);
    begin
        if rising_edge(clk_31M5) then
            cell_line_var := cell_line;
        end if;
        cell_line_s <= cell_line_var;
    end process;

    process(clk_31M5, cell_row) is
        variable cell_row_s1_var: unsigned(2 downto 0);
        variable cell_row_s2_var: unsigned(2 downto 0);
    begin
        if rising_edge(clk_31M5) then
            cell_row_s2_var := cell_row_s1_var;
            cell_row_s1_var := cell_row;
        end if;
        cell_row_s <= cell_row_s2_var;
    end process;

    process(clk_31M5, h_sync_r, v_sync_r) is
        variable h_sync_s1: std_logic;
        variable h_sync_s2: std_logic;
        variable v_sync_s1: std_logic;
        variable v_sync_s2: std_logic;
        variable blank_s1: std_logic;
        variable blank_s2: std_logic;
    begin
        if rising_edge(clk_31M5) then
            h_sync_s2 := h_sync_s1;
            h_sync_s1 := h_sync_r;

            v_sync_s2 := v_sync_s1;
            v_sync_s1 := v_sync_r;

            blank_s2 := blank_s1;
            blank_s1 := blank_r;
        end if;

        v_sync <= v_sync_s2;
        h_sync <= h_sync_s2;
        blank <= blank_s2;
    end process;

    vram0: vram port map(clk_bus, addr_a, data_a, we_a, q_a, clk_31M5, tile_line & tile_row, char_from_vram);

    font_rom0: font_rom port map(clk_31M5, char_from_vram(6 downto 0) & cell_line_s, line_from_charrom);

    process(cell_row_s, line_from_charrom) is
    begin
        case cell_row_s is
            when "000" => pixel <= line_from_charrom(7);
            when "001" => pixel <= line_from_charrom(6);
            when "010" => pixel <= line_from_charrom(5);
            when "011" => pixel <= line_from_charrom(4);
            when "100" => pixel <= line_from_charrom(3);
            when "101" => pixel <= line_from_charrom(2);
            when "110" => pixel <= line_from_charrom(1);
            when "111" => pixel <= line_from_charrom(0);
        end case;
    end process;

    process(clk_31M5, char_from_vram) is
        variable fg_color_v, bg_color_v: unsigned(3 downto 0);
    begin
        if rising_edge(clk_31M5) then
            fg_color_v := char_from_vram(10 downto 7);
            bg_color_v := char_from_vram(14 downto 11);
        end if;
        fg_color <= fg_color_v;
        bg_color <= bg_color_v;
    end process;

    process(pixel, fg_color, bg_color, blank) is
    begin
        case pixel is
            when '1' =>
                red(0)   <= fg_color(0) and not(blank);
                green(0) <= fg_color(0) and not(blank);
                blue(0)  <= fg_color(0) and not(blank);
                red(1)   <= fg_color(1) and not(blank);
                green(1) <= fg_color(2) and not(blank);
                blue(1)  <= fg_color(3) and not(blank);
            when '0' =>
                red(0)   <= bg_color(0) and not(blank);
                green(0) <= bg_color(0) and not(blank);
                blue(0)  <= bg_color(0) and not(blank);
                red(1)   <= bg_color(1) and not(blank);
                green(1) <= bg_color(2) and not(blank);
                blue(1)  <= bg_color(3) and not(blank);
        end case;
    end process;

    --BUS interface
    process(address) is begin
        if (unsigned(address) >= BASE_ADDRESS and unsigned(address) <= (BASE_ADDRESS + 4095)) then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;

    process(clk_bus) is
    begin
        if rising_edge(clk_bus) then
            if res = '1' then
                ack_fsm_state <= idle;
            else
                case ack_fsm_state is
                    when idle =>
                        if ((WR = '1' and cs = '1') or (RD = '1' and cs = '1')) then
                            ack_fsm_state <= set;
                        else
                            ack_fsm_state <= idle;
                        end if;
                    when set =>
                        ack_fsm_state <= idle;
                end case;
            end if;
        end if;
    end process;

    process(ack_fsm_state) is
    begin
        case ack_fsm_state is
            when idle =>
                ack <= '0';
            when set =>
                ack <= '1';
        end case;
    end process;
    
    data_miso <= std_logic_vector(x"0000" & "0" & q_a) when ((RD = '1') and (cs = '1')) else (others => 'Z');
    data_a <= unsigned(data_mosi(14 downto 0));

    we_a <= WR and cs;

    addr_a <= unsigned(address(11 downto 0));

end architecture;
