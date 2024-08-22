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

signal mi_areset_n     : std_logic ;
signal mi_clk     	: std_logic ;

signal mi_WrAddress   : std_logic_vector(C_AddrSize-1 downto 0); 
signal mi_WrEn        : std_logic;                                                 
signal mi_WrData      : std_logic_vector(C_DataSize-1 downto 0); 
signal mi_RdAddress   : std_logic_vector(C_AddrSize-1 downto 0);                       
signal mi_RdEn        : std_logic;
signal mo_RdData      :  std_logic_vector(C_DataSize-1 downto 0);





begin

-- Instanciation
--******************
inst_Wrapper_Ram1c2p: Wrapper_Ram1c2p 
    generic map(
        g_AddrSize  => C_AddrSize,
        g_DataSize  => C_DataSize
        )
port map (
  i_areset_n  => mi_areset_n,
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
RESET_PROCESS : process
begin

  mi_areset_n <= '0'; wait for LATENCY;
  mi_areset_n <= '1'; wait;

end process RESET_PROCESS;

CLOCK_PROCESS : process
begin

  mi_clk <= '0'; wait for CLK_PERIOD;
  mi_clk <= '1'; wait for CLK_PERIOD;

end process CLOCK_PROCESS;


-- Read value
-----------------
READ_DATA_PROCESS : process

  -- For data_vit
  file file_data      		: text open READ_MODE is "$PATH_BIBLI_HDL/InferMem/tb/t01/data.in";
  variable line_data  		: line;
  variable val_WrData   		: std_logic_vector(15 downto 0);
  variable val_WrEn 		: std_logic;  
  variable val_WrAddress  	: std_logic_vector(7 downto 0);  
  variable val_RdAddress   : std_logic_vector(7 downto 0); 
  
begin

  -- Initialise input
  mi_WrData        <= (others => '0');
  mi_WrEn      <= '0';
  mi_WrAddress  <= (others => '0');
  mi_RdAddress <= (others => '0');
  mi_RdEn      <='0';
  
  for i in 0 to 5 loop
    wait until rising_edge(mi_clk);
  end loop;


  assert false report "Beginning to read files" severity note;

  -- Read all the file until the end
  while (endfile(file_data)=FALSE) loop

    readline(file_data,line_data);	-- lecture d'une ligne
    hread(line_data,val_WrData);
    read(line_data,val_WrEn);	
    hread(line_data,val_WrAddress);	
    hread(line_data,val_RdAddress);
	
    mi_WrData 			<= val_WrData;
    mi_WrEn 		<= val_WrEn;	
    mi_WrAddress 	<= val_WrAddress;	
    mi_RdAddress 	<= val_RdAddress;	
	 
    mi_RdEn<= val_WrEn; -- Care about that

    wait until rising_edge(mi_clk);
	
  end loop;

  assert false report "End of simulation" severity failure;

end process READ_DATA_PROCESS;

-- Write value
------------------
WRITE_DATA_PROCESS : process

  file file_data     : text open WRITE_MODE is "$PATH_BIBLI_HDL/InferMem/tb/t01/data.out";
  variable line_data : line;

  begin
  
	for i in 0 to 5 loop
		wait until rising_edge(mi_clk);
	end loop;	
	
	wait until rising_edge(mi_clk);
		
		--write data until the end of simulation
		while (true) loop 
		
			wait until rising_edge(mi_clk);
			
			hwrite(line_data,mo_RdData);
			writeline(file_data,line_data);			
			
		end loop;
 
end process WRITE_DATA_PROCESS;

end bench;