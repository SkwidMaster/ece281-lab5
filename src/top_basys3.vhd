--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity top_basys3 is
    port(
        -- inputs
        clk     : in std_logic; -- 100 MHz clock
        sw      : in std_logic_vector(7 downto 0); -- switches
        btnU    : in std_logic; -- reset
        btnC    : in std_logic; -- FSM advance

        -- outputs
        led     : out std_logic_vector(15 downto 0);
        seg     : out std_logic_vector(6 downto 0);
        an      : out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 

    -- ALU/FSM signals
    signal w_A, w_B : std_logic_vector(7 downto 0);
    signal w_op : std_logic_vector(2 downto 0);
    signal w_result : std_logic_vector(7 downto 0);
    signal w_flags : std_logic_vector(3 downto 0);
    signal w_cycle : std_logic_vector(3 downto 0);
    
    signal w_result_reg : std_logic_vector(7 downto 0); -- used for displaying to the 7-seg display
signal bcd_tens  : std_logic_vector(3 downto 0);
signal bcd_ones  : std_logic_vector(3 downto 0);

    -- 7-seg signals
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal digit_select : std_logic;
    signal current_nibble : std_logic_vector(3 downto 0);

    -- decoder output
    signal seg_internal : std_logic_vector(6 downto 0);
    
    signal btnC_sync : std_logic_vector(1 downto 0) := "00";
    signal btnC_pulse : std_logic;

    -- component declaration
    component sevenseg_decoder
        Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
               o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

begin

    -- Operand mapping
    w_A <= "0000" & sw(7 downto 4);
    w_B <= "0000" & sw(3 downto 0);
    w_op <= sw(2 downto 0);

    -- FSM
    FSM_inst : entity work.controller_fsm
    port map (
        i_clk   => clk,
        i_reset => btnU,
        i_adv   => btnC_pulse,
        o_cycle => w_cycle
    );

    -- ALU
    ALU_inst : entity work.ALU
        port map (
            i_A => w_A,
            i_B => w_B,
            i_op => w_op,
            o_result => w_result,
            o_flags => w_flags
        );

    -- LEDs
    led(3 downto 0) <= w_cycle;
    led(15 downto 12) <= w_flags;
--    led(11 downto 4) <= w_result_reg;
    
    
    -- 7-SEGMENT USING DECODER
process(w_result_reg)
    variable bin   : unsigned(7 downto 0);
    variable bcd   : unsigned(11 downto 0); -- tens + ones
    variable i     : integer;
begin
    bin := unsigned(w_result_reg);
    bcd := (others => '0');

    for i in 0 to 7 loop
        -- shift left BCD + input
        bcd := bcd(10 downto 0) & bin(7);
        bin := bin(6 downto 0) & '0';

        -- add 3 if needed
        if bcd(3 downto 0) > 4 then
            bcd(3 downto 0) := bcd(3 downto 0) + 3;
        end if;

        if bcd(7 downto 4) > 4 then
            bcd(7 downto 4) := bcd(7 downto 4) + 3;
        end if;

        if bcd(11 downto 8) > 4 then
            bcd(11 downto 8) := bcd(11 downto 8) + 3;
        end if;
    end loop;

    bcd_ones <= std_logic_vector(bcd(3 downto 0));
    bcd_tens <= std_logic_vector(bcd(7 downto 4));
end process;

-- update the visible register
process(clk)
begin
    if rising_edge(clk) then
        if btnU = '1' then
            w_result_reg <= (others => '0');
        elsif btnC_pulse = '1' then
            w_result_reg <= w_result;
        end if;
    end if;
end process;

    -- clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;
    
    process(clk)
begin
    if rising_edge(clk) then
        btnC_sync(0) <= btnC;
        btnC_sync(1) <= btnC_sync(0);
    end if;
end process;

btnC_pulse <= btnC_sync(0) and not btnC_sync(1);

    digit_select <= refresh_counter(19);

    -- choose digit
    process(digit_select, w_result)
    begin
if digit_select = '0' then
    an <= "1110";
    current_nibble <= bcd_ones;
else
    an <= "1101";
    current_nibble <= bcd_tens;
end if;
    end process;

    -- instantiate decoder
    sevenseg_inst : sevenseg_decoder
        port map (
            i_Hex => current_nibble,
            o_seg_n => seg_internal
        );

    seg <= seg_internal;

end top_basys3_arch;