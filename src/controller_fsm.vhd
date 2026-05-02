----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller_fsm is
    Port ( clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    signal state : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    signal btn_sync_0, btn_sync_1 : std_logic := '0';
    signal step_pulse : std_logic := '0';
begin
    if rising_edge(clk) then

            -- reset
            if i_reset = '1' then
                state <= "0001";

            else
                -- 1. synchronize button
                btn_sync_0 <= i_adv;
                btn_sync_1 <= btn_sync_0;

                -- 2. rising edge detect (one-cycle pulse)
                step_pulse <= btn_sync_0 and not btn_sync_1;

                -- 3. FSM advance on clean pulse
                if step_pulse = '1' then
                    case state is
                        when "0001" => state <= "0010"; -- fetch
                        when "0010" => state <= "0100"; -- decode
                        when "0100" => state <= "1000"; -- execute
                        when "1000" => state <= "0001"; -- writeback
                        when others => state <= "0001";
                    end case;
                end if;

            end if;
        end if;
    end process;

    o_cycle <= state;


end FSM;