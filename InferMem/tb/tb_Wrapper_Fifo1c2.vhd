library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.all;

entity tb_Wrapper_Fifo1c2 is
end entity tb_Wrapper_Fifo1c2;


-- Options
-- Questa: Toggle leaf name for wave
-- questa: vsim -voptargs="+acc" -t ps pour avoir tous les signaux et empêcher l'optimisation

architecture bench of tb_Wrapper_Fifo1c2 is
-------------------------------------------------------------------------------
-- Components declaration
-------------------------------------------------------------------------------
-- see InferMem_pkg

-------------------------------------------------------------------------------
-- Constants declaration
-------------------------------------------------------------------------------
constant CLK_PERIOD         : time := 10 ns;
constant LATENCY            : time := 105 ns;
constant C_AddrSize         : positive := 8;
constant C_DataSize         : positive := 16;
constant C_AlmostFullLevel  : positive := 1;--(2**8)-1-3;
constant C_AlmostEmptyLevel : positive := 1;
-------------------------------------------------------------------------------
-- Signals declaration 
-------------------------------------------------------------------------------
signal mi_clk               : std_logic;              
signal mi_areset_n          : std_logic; 
signal mi_sreset            : std_logic;                    
signal mi_WrData            : std_logic_vector(C_DataSize-1 downto 0);         
signal mi_WrReq             : std_logic;            
signal mi_RdReq             : std_logic;            
signal mo_RdData            : std_logic_vector(C_DataSize-1 downto 0);            
signal mo_StatusFull        : std_logic;        
signal mo_StatusEmpty       : std_logic;       
signal mo_StatusAlmostFull  : std_logic;  
signal mo_StatusAlmostEmpty : std_logic; 
signal mo_Overflow         	: std_logic; 
signal mo_Underflow        	: std_logic; 	
signal mo_StatusWordCounter : std_logic_vector(C_AddrSize downto 0);


-------------------------------------------------------------------------------
-- Architecture 
-------------------------------------------------------------------------------
begin 

--******************
-- Instanciation
--******************
inst_Wrapper_Fifo1c : entity Wrapper_Fifo1c
    generic map (
    g_AsyncReset        =>  True,
    g_SyncReset         =>  True,     
    g_AddrSize          => C_AddrSize,         
    g_DataSize          => C_DataSize,                            
    g_AlmostFullLevel   => C_AlmostFullLevel,                  
    g_AlmostEmptyLevel  => C_AlmostEmptyLevel                 
    )
    port map( 
    i_clk               => mi_clk,              
    i_areset_n          => mi_areset_n, 
    i_sreset            => mi_sreset,                    
    i_WrData            => mi_WrData,          
    i_WrReq             => mi_WrReq,            
    i_RdReq             => mi_RdReq,            
    o_RdData            => mo_RdData,           
    o_StatusFull        => mo_StatusFull,       
    o_StatusEmpty       => mo_StatusEmpty,      
    o_StatusAlmostFull  => mo_StatusAlmostFull, 
    o_StatusAlmostEmpty => mo_StatusAlmostEmpty,
    o_Overflow         	=> mo_Overflow, 
    o_Underflow        	=> mo_Underflow, 	
    o_StatusWordCounter => mo_StatusWordCounter);

--******************
-- Process
--******************

    -- System clock & reset
    -----------------------
    ARESET_PROCESS : process
    begin

      mi_areset_n <= '0'; wait for LATENCY;
      mi_areset_n <= '1'; wait;

    end process ARESET_PROCESS;


    SRESET_PROCESS : process
    begin

      mi_sreset <= '0'; wait for LATENCY/2;
      mi_sreset <= '1'; wait for LATENCY + LATENCY/2;
      mi_sreset <= '0'; wait;

    end process SRESET_PROCESS;


    CLOCK_PROCESS : process
    begin

      mi_clk <= '0'; wait for CLK_PERIOD;
      mi_clk <= '1'; wait for CLK_PERIOD;

    end process CLOCK_PROCESS;


    -- Data
    -----------------------
    DATA_PROCESS : process
        variable ValCptData : natural range 1 to 2**C_AddrSize+30;
    begin
        -- Initialise input
        mi_WrData   <= (others => '0');             
        ValCptData    := 01;
		
		wait for LATENCY/2;
		
		while(true) loop
			wait until rising_edge(mi_clk);
			wait for CLK_PERIOD;
			if ValCptData =  2**C_AddrSize+30 then
				ValCptData := 1;
			else
				ValCptData := ValCptData + 1;
			end if;
			mi_WrData <= std_logic_vector(to_unsigned(ValCptData, mi_WrData'length));
		end loop;
		
    end process DATA_PROCESS;
	

    -- Wr_req and Rd_req
    -----------------------
    REQ_DATA_PROCESS : process
        variable ValCpt : natural range 0 to 2**C_AddrSize+25;
    begin
        -- Initialise input        
        mi_WrReq    <='0';           
        mi_RdReq   <='0';   
		ValCpt    := 0;
    
        wait for LATENCY*2;

        for i in 0 to 5 loop
            wait until rising_edge(mi_clk);
        end loop;
		
    	wait for CLK_PERIOD;
		

        assert false report "CONTROLE WRITE" severity note;
        
        while (ValCpt /= 2**C_AddrSize+25) loop 
            ValCpt := ValCpt + 1;
            mi_RdReq   <= '0';

            if (ValCpt < 2**C_AddrSize+25) then              
                mi_WrReq   <= '1';
            else
                mi_WrReq   <= '0';
            end if;

            wait until rising_edge(mi_clk);
    		wait for CLK_PERIOD;
            
        end loop;

        mi_WrReq   <= '0';
        ValCpt    := 0;
        mi_RdReq   <= '1';
        wait until rising_edge(mi_clk);

        assert false report "CONTROLE READ" severity note;

		wait for CLK_PERIOD;
        while (ValCpt /= 2**C_AddrSize) loop
            mi_RdReq   <= '1';
            ValCpt := ValCpt + 1;
			wait for CLK_PERIOD;
            wait until rising_edge(mi_clk);
          end loop;
		  
        mi_WrReq   <= '0';
        ValCpt    := 0;
        mi_RdReq   <= '1';

        wait until rising_edge(mi_clk);       

    end process REQ_DATA_PROCESS;

end architecture bench;