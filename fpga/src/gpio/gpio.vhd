-- GPIO peripheral for MARK-II
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz
--
--GPIO regs are relative to base address, there are two individual ports
-- offset   reg
-- +0       outputs on WR, inputs on RD, port A
-- +1       direction reg for port A, 1 means output
-- +2       outputs on WR, inputs on RD, port B
-- +3       direction reg for port B, 1 means output

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gpio is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000";    --base address of the GPIO
        GPIO_WIDE: natural := 32       --wide of the gpios
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(23 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic;
        --outputs
        port_a: inout std_logic_vector((GPIO_WIDE-1) downto 0);
        port_b: inout std_logic_vector((GPIO_WIDE-1) downto 0)
    );
end entity gpio;

architecture gpio_arch of gpio is

    component pin_selector is
        port(
            pin: inout std_logic;
            dir: in std_logic;
            data_write: in std_logic;
            data_read: out std_logic
        );
    end component pin_selector;

    signal data_from_pin_pa, data_output_reg_pa, pin_direction_reg_pa: std_logic_vector((GPIO_WIDE -1) downto 0);
    signal data_from_pin_pb, data_output_reg_pb, pin_direction_reg_pb: std_logic_vector((GPIO_WIDE -1) downto 0);

    --internal chip select signal
    signal reg_sel: std_logic_vector(3 downto 0);

begin
    --this is just chip select decoder
    process(address) is begin
        if (unsigned(address) = BASE_ADDRESS) then
            reg_sel <= "0001";
        elsif (unsigned(address) = (BASE_ADDRESS + 1)) then
            reg_sel <= "0010";
        elsif (unsigned(address) = (BASE_ADDRESS + 2)) then
            reg_sel <= "0100";
        elsif (unsigned(address) = (BASE_ADDRESS + 3)) then
            reg_sel <= "1000";
        else
            reg_sel <= "0000";
        end if;
    end process;

    --buffers for bidir pins port A
    gen_buf_pa:
    for I in 0 to (GPIO_WIDE-1) generate
        pin_selector_x: pin_selector port map(port_a(I), pin_direction_reg_pa(I), data_output_reg_pa(I), data_from_pin_pa(I));
    end generate gen_buf_pa;

    --buffers for bidir pins port B
    gen_buf_pb:
    for I in 0 to (GPIO_WIDE-1) generate
        pin_selector_x: pin_selector port map(port_b(I), pin_direction_reg_pb(I), data_output_reg_pb(I), data_from_pin_pb(I));
    end generate gen_buf_pb;

    --register for data_output_reg_pa
    process(clk, res, WR, data_mosi, reg_sel) is begin

        if rising_edge(clk) then

            if res = '1' then
                data_output_reg_pa <= (others => '0');
                data_output_reg_pb <= (others => '0');
                pin_direction_reg_pa <= (others => '0');
                pin_direction_reg_pb <= (others => '0');
            elsif (WR = '1' and reg_sel = "0001") then
                data_output_reg_pa <= data_mosi((GPIO_WIDE - 1) downto 0);
            elsif (WR = '1' and reg_sel = "0010") then
                pin_direction_reg_pa <= data_mosi((GPIO_WIDE - 1) downto 0);
            elsif (WR = '1' and reg_sel = "0100") then
                data_output_reg_pb <= data_mosi((GPIO_WIDE - 1) downto 0);
            elsif (WR = '1' and reg_sel = "1000") then
                pin_direction_reg_pb <= data_mosi((GPIO_WIDE - 1) downto 0);
            end if;

        end if;

    end process;

    --output from registers
    data_miso((GPIO_WIDE - 1) downto 0) <=
        data_from_pin_pa     when (RD = '1' and reg_sel = "0001") else
        pin_direction_reg_pa when (RD = '1' and reg_sel = "0010") else
        data_from_pin_pb     when (RD = '1' and reg_sel = "0100") else
        pin_direction_reg_pb when (RD = '1' and reg_sel = "1000") else
        (others => 'Z');

    data_miso(31 downto GPIO_WIDE) <=
        (others => '0')      when (RD = '1' and reg_sel = "0001") else
        (others => '0')      when (RD = '1' and reg_sel = "0010") else
        (others => '0')      when (RD = '1' and reg_sel = "0100") else
        (others => '0')      when (RD = '1' and reg_sel = "1000") else
        (others => 'Z');

    ack <= '1' when ((WR = '1' and reg_sel /= "0000") or (RD = '1' and reg_sel /= "0000")) else '0';

end architecture gpio_arch;



library ieee;
use ieee.std_logic_1164.all;

entity pin_selector is
    port(
        pin: inout std_logic;
        dir: in std_logic;
        data_write: in std_logic;
        data_read: out std_logic
    );
end entity pin_selector;

architecture pin_selector_arch of pin_selector is begin

    pin <= data_write when dir = '1' else 'Z';
    data_read <= pin;

end architecture pin_selector_arch;
