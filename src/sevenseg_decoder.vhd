library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevenseg_decoder is
    Port (
        i_Hex   : in  STD_LOGIC_VECTOR(3 downto 0);
        o_seg_n : out STD_LOGIC_VECTOR(6 downto 0)
    );
end sevenseg_decoder;

architecture Behavioral of sevenseg_decoder is
begin

    process(i_Hex)
    begin
        case i_Hex is
            --        abcdefg
            when "0000" => o_seg_n <= "1000000"; -- 0
            when "0001" => o_seg_n <= "1111001"; -- 1
            when "0010" => o_seg_n <= "0100100"; -- 2
            when "0011" => o_seg_n <= "0110000"; -- 3
            when "0100" => o_seg_n <= "0011001"; -- 4
            when "0101" => o_seg_n <= "0010010"; -- 5
            when "0110" => o_seg_n <= "0000010"; -- 6
            when "0111" => o_seg_n <= "1111000"; -- 7
            when "1000" => o_seg_n <= "0000000"; -- 8
            when "1001" => o_seg_n <= "0011000"; -- 9
            when "1010" => o_seg_n <= "0001000"; -- A
            when "1011" => o_seg_n <= "0000011"; -- b
            when "1100" => o_seg_n <= "0100111"; -- C
            when "1101" => o_seg_n <= "0100001"; -- d
            when "1110" => o_seg_n <= "0000110"; -- E
            when "1111" => o_seg_n <= "0001110"; -- F
            when others => o_seg_n <= "1111111"; -- all segments off
        end case;
    end process;

end Behavioral;