----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
begin
    process(i_A, i_B, i_op)
        variable v_result : unsigned(8 downto 0); -- 9 bits for carry
        variable v_A, v_B : unsigned(7 downto 0);
        variable v_out : unsigned(7 downto 0);
        variable Z, C, N, V : std_logic;
    begin
        v_A := unsigned(i_A);
        v_B := unsigned(i_B);

        case i_op is
            when "000" => -- ADD
                v_result := ('0' & v_A) + ('0' & v_B);
            when "001" => -- SUB
                v_result := ('0' & v_A) - ('0' & v_B);
            when "010" => -- AND
                v_result := ('0' & (v_A and v_B));
            when "011" => -- OR
                v_result := ('0' & (v_A or v_B));
            when others =>
                v_result := (others => '0');
        end case;

        v_out := v_result(7 downto 0);

        -- Flags
        if v_out = 0 then
            Z := '1';
        else
            Z := '0';
        end if;

        C := v_result(8);
        N := v_out(7);

        -- Simple overflow detection (only valid for add/sub)
        if i_op = "000" then
            V := (i_A(7) and i_B(7) and not v_out(7)) or
                 (not i_A(7) and not i_B(7) and v_out(7));
        elsif i_op = "001" then
            V := (i_A(7) and not i_B(7) and not v_out(7)) or
                 (not i_A(7) and i_B(7) and v_out(7));
        else
            V := '0';
        end if;

        o_result <= std_logic_vector(v_out);
        o_flags <= Z & C & N & V;
    end process;
end Behavioral;