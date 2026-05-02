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

architecture top_basys3_arch of top_basys3 is 

    -- ALU/FSM signals
    signal w_A, w_B : std_logic_vector(7 downto 0);
    signal w_op : std_logic_vector(2 downto 0);
    signal w_result : std_logic_vector(7 downto 0);
    signal w_flags : std_logic_vector(3 downto 0);
    signal w_cycle : std_logic_vector(3 downto 0);

    -- 7-seg signals
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal digit_select : std_logic;
    signal current_nibble : std_logic_vector(3 downto 0);

    -- decoder output
    signal seg_internal : std_logic_vector(6 downto 0);

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
            i_reset => btnU,
            i_adv   => btnC,
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
    led(11 downto 4) <= w_result;
    
    
    -- 7-SEGMENT USING DECODER

    -- clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    digit_select <= refresh_counter(19);

    -- choose digit
    process(digit_select, w_result)
    begin
        if digit_select = '0' then
            an <= "1110"; -- rightmost
            current_nibble <= w_result(3 downto 0);
        else
            an <= "1101"; -- next digit
            current_nibble <= w_result(7 downto 4);
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