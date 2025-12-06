-- Dexbibuff.vhd

library IEEE;
use IEEE.std_logic_1164.all;

entity bidir_buff is

  port (-- inoput pad of didir
              MDIO : inout std_logic;
              
              --input signal 
              MDI : in std_logic;
			  --control signal
              OE: in std_logic;
              -- output signal.
              MDO : out std_logic
             );

end bidir_buff;

architecture bidir_buff_arch of bidir_buff is
begin
    process (OE, MDI)
    begin
        case OE is
            when '1' => MDIO <= MDI;
            --when '0' => MDIO <=  'Z';
            when others => MDIO <=  'Z';
        end case;
    end process;

MDO <= MDIO;

end bidir_buff_arch;

-------------------------------------------------------------------------------
--                       End Of File
-------------------------------------------------------------------------------