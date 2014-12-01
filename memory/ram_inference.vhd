---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library	ieee;
    use ieee.std_logic_1164.all;  
    use ieee.std_logic_arith.all;			   
    use ieee.std_logic_unsigned.all;			   

library common_lib;
    use common_lib.common_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity ram_inference is
    generic (
        ADDR_WIDTH         : positive := 16;
        DATA_WIDTH         : positive := 16;
        EXTRA_OUTPUT_DELAY : natural  := 0
    );
    port (
        -- Port A
        clk_a     : in  std_logic;
        clken_a   : in  std_logic;
        wren_a    : in  std_logic;
        addr_a    : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        wrdata_a  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        rddata_a  : out std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- Port B
        clk_b     : in  std_logic;
        clken_b   : in  std_logic;
        addr_b    : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        rddata_b  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end ram_inference;

architecture ram_inference of ram_inference is

    -----------
    -- Types --
    -----------
    type data_type is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    -------------
    -- Signals --
    -------------
    shared variable ram : data_type(2**ADDR_WIDTH - 1 downto 0);
    signal rddata_a_i   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal rddata_b_i   : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    -------------------
    -- Port mappings --
    -------------------
    rddata_a_delay : entity common_lib.sr_delay
        generic map (
            DELAY_CYCLES => EXTRA_OUTPUT_DELAY,
            DATA_WIDTH   => DATA_WIDTH
            )
        port map (
            clk     => clk_a,
            clken   => clken_a,

            din     => rddata_a_i,
            dout    => rddata_a
        );

    rddata_b_delay : entity common_lib.sr_delay
        generic map (
            DELAY_CYCLES => EXTRA_OUTPUT_DELAY,
            DATA_WIDTH   => DATA_WIDTH
            )
        port map (
            clk     => clk_b,
            clken   => clken_b,

            din     => rddata_b_i,
            dout    => rddata_b
        );

    -----------------------------
    -- Asynchronous asignments --
    -----------------------------

    ---------------
    -- Processes --
    ---------------
    port_a : process(clk_a)
    begin
        if clk_a'event and clk_a = '1' then
            if clken_a = '1' then
                if wren_a = '1' then
                    ram(conv_integer(addr_a)) := wrdata_a;
                end if;
                rddata_a_i <= ram(conv_integer(addr_a));
            end if;
        end if;
    end process;

    port_b : process(clk_b)
    begin
        if clk_b'event and clk_b = '1' then
            if clken_b = '1' then
                rddata_b_i <= ram(conv_integer(addr_b));
            end if;
        end if;
    end process;

end ram_inference;


