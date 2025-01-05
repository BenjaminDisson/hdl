--   ----------------------------------------------------------------------------------------------
--   File name     : tb_Wrapper_Ram1c2p.vhd  
--   Description   : Test bench for Wrapper_Ram1c2p       
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson  : Creation
--
--
 
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_textio.all;
use work.InferMem_pkg.all;

library std;
use     std.textio.all;

entity tb_Wrapper_Ram1c2p is end tb_Wrapper_Ram1c2p;

architecture bench of tb_Wrapper_Ram1c2p is

-------------------------------------------------------------------------------
-- Components declaration
-------------------------------------------------------------------------------
-- see InferMem_pkg

-------------------------------------------------------------------------------
-- Constant
-------------------------------------------------------------------------------
-- Clock
constant CLK_PERIOD : time := 10 ns;
constant LATENCY    : time := 105 ns;
constant C_AddrSize : positive := 8;
constant C_DataSize : positive := 16;

-------------------------------------------------------------------------------
-- Signal declaration 
-------------------------------------------------------------------------------

signal mi_areset_n      : std_logic;
signal mi_sreset        : std_logic;
signal mi_clk           : std_logic;

signal mi_WrAddress     : std_logic_vector(C_AddrSize-1 downto 0); 
signal mi_WrEn          : std_logic;                                                 
signal mi_WrData        : std_logic_vector(C_DataSize-1 downto 0); 
signal mi_RdAddress     : std_logic_vector(C_AddrSize-1 downto 0);                       
signal mi_RdEn          : std_logic;
signal mo_RdData        :  std_logic_vector(C_DataSize-1 downto 0);





begin

-- Instanciation
--******************
inst_Wrapper_Ram1c2p: Wrapper_Ram1c2p 
    generic map(
        g_AsyncReset => False,
        g_SyncReset  => False,
        g_AddrSize  => C_AddrSize,
        g_DataSize  => C_DataSize
        )
port map (
  i_clk       => mi_clk,
  i_WrAddress => mi_WrAddress,
  i_WrEn      => mi_WrEn,      
  i_WrData    => mi_WrData,    
  i_RdAddress => mi_RdAddress, 
  i_RdEn      => mi_RdEn,      
  o_RdData    => mo_RdData    
);

-- Begin of stimulus
--******************

-- System clock
-------------------
CLOCK_PROCESS : process
begin

  mi_clk <= '0'; wait for CLK_PERIOD;
  mi_clk <= '1'; wait for CLK_PERIOD;

end process CLOCK_PROCESS;


-- Read value
-----------------
WR_DATA_PROCESS : process

  -- For data_vit
  file file1_data      		: text open READ_MODE is "$PATH_BIBLI_HDL/InferMem/tb/t01/data.in";
  variable line1_data  		: line;
  variable val_WrData   	: std_logic_vector(15 downto 0);
  variable val_WrEn 		  : std_logic;  
  variable val_WrAddress  : std_logic_vector(7 downto 0);  
  variable val_RdAddress  : std_logic_vector(7 downto 0); 
  variable ValCpt1         : integer range 0 to 2**C_AddrSize;
  variable ValCpt2         : integer range 0 to 2**C_AddrSize;
  file file2_data         : text open WRITE_MODE is "$PATH_BIBLI_HDL/InferMem/tb/t01/data.out";
  variable line2_data     : line;

begin

  -- Initialise input
  mi_WrData        <= (others => '0');
  mi_WrEn      <= '0';
  mi_WrAddress  <= (others => '0');
  mi_RdEn   <='0';
  mi_RdAddress <= (others => '0');

  ValCpt1    := 0;
  ValCpt2    := 0;
  
  for i in 0 to 5 loop
    wait until rising_edge(mi_clk);
  end loop;


  assert false report "Beginning to read files" severity note;

  -- Read all the file until the end
  while (endfile(file1_data)=FALSE) loop

    readline(file1_data,line1_data);	-- lecture d'une ligne
    hread(line1_data,val_WrData);
    read(line1_data,val_WrEn);	
    hread(line1_data,val_WrAddress);	
    hread(line1_data,val_RdAddress);
	
    mi_WrData 			<= val_WrData;
    mi_WrEn 		<= val_WrEn;	
    mi_WrAddress 	<= val_WrAddress;

    mi_RdAddress 	<= val_RdAddress;	
    mi_RdEn<= val_WrEn;
    hwrite(line2_data,mo_RdData);
    writeline(file2_data,line2_data); 
    wait until rising_edge(mi_clk);
	
  end loop;

while (ValCpt1 /= 2**C_AddrSize) loop  
      mi_WrData <= std_logic_vector(to_unsigned(ValCpt1, mi_WrData'length));
      mi_WrAddress <= std_logic_vector(to_unsigned(ValCpt1, mi_WrAddress'length));
      mi_WrEn   <= '1';
      ValCpt1 := ValCpt1 + 1;
      mi_RdEn   <= '0';
    wait until rising_edge(mi_clk);
  end loop;

  mi_WrEn   <= '0';

while (ValCpt2 /= 2**C_AddrSize) loop
      mi_RdEn   <= '1';
      mi_RdAddress <= std_logic_vector(to_unsigned(ValCpt2, mi_RdAddress'length));
      ValCpt2 := ValCpt2 + 1;
    wait until rising_edge(mi_clk);
  end loop;

wait until rising_edge(mi_clk);

-- FINISH COVERAGE
mi_WrAddress   <= std_logic_vector(to_unsigned(3, mi_WrAddress'length));         
mi_WrData      <= std_logic_vector(to_unsigned(4, mi_WrData'length)); 
mi_RdAddress   <= std_logic_vector(to_unsigned(5, mi_RdAddress'length)); 
wait until rising_edge(mi_clk);
mi_WrEn <= '0';                    
mi_RdEn <= '0'; 
wait until rising_edge(mi_clk);
mi_WrEn <= '0';                    
mi_RdEn <= '1'; 
wait until rising_edge(mi_clk);
mi_WrEn <= '1';                    
mi_RdEn <= '0'; 
wait until rising_edge(mi_clk);
mi_WrEn <= '1';                    
mi_RdEn <= '1'; 
wait until rising_edge(mi_clk);   

mi_WrAddress   <= std_logic_vector(to_unsigned(6, mi_WrAddress'length));         
mi_WrData      <= std_logic_vector(to_unsigned(7, mi_WrData'length)); 
mi_RdAddress   <= std_logic_vector(to_unsigned(3, mi_RdAddress'length)); 
wait until rising_edge(mi_clk);
mi_WrEn <= '0';                    
mi_RdEn <= '0'; 
wait until rising_edge(mi_clk);
mi_WrEn <= '0';                    
mi_RdEn <= '1'; 
wait until rising_edge(mi_clk);
mi_WrEn <= '1';                    
mi_RdEn <= '0'; 
wait until rising_edge(mi_clk);
mi_WrEn <= '1';                    
mi_RdEn <= '1'; 
wait until rising_edge(mi_clk);      

assert false report "End of simulation" severity failure;

end process WR_DATA_PROCESS;

end bench;