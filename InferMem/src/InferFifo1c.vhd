--   ----------------------------------------------------------------------------------------------
--   File name     : Fifo1c.vhd     
--   Description   : Single clock fifo  
--                 : There is no reset as an init would signify write accesss to each address 
--                 : There is a synchronous and asynchronous reset depending on the technology.
--                 : Optionnal flags are full, almost_full, empty, almost_empty and word counter 
--                 : Queuing mode : When full, no write can be done
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author            : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson   : Creation
--   01/05/2025 : 1.1   : Benjamin Disson   : Add flag output
--                                          : s_WrEn must be re-synchronized in RAM module
--                                          : s_RdEn must be re-synchronized in RAM module
--                                          : o_StatusEmpty must be registered for better speed 
--                                          : o_StatusFull must be registered for better speed 
--
-- FIFO 4 data // almost (both) = 1
--           __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __
--  Clk   __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__| 
--                            1     2     3     4     5     6                 1     2     3     4     5     6
--                            |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
-- Wrreq                    ___________________________________   |     |     |     |     |     |     |     |     |
--        _________________|                                   |_____________________________________________________
--                            |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
--                          __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__ __|__
-- IData  xxxxxxxxxxxxxxxxx|_D1__|_D2__|_D3__|_D4__|__x__|__x__|__x__|__x__|__x__|__x__|__x__|__x__|__x__|__x__|__x__|
--                            |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
--                            |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
-- Rdreq                      |     |     |     |     |     |     |     |   ___________________________________
--       __________________________________________________________________|                                   |_____
--                            |     |     |     |     |     |     |     |     |     |     |     |     |     |      
--        __ _____ _____ _____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____ __
-- OData  __/__x__/__x__/__x__/__x__/__x__/__x__/__x__/__x__/__x__/__x__/__x__/_D1__/_D2__/_D3__/_D4__/_D4__/_D4__/_D
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
-- Empty  ____________________      |     |     |     |     |     |     |     |     |     |     |      ______________
--                            |_______________________________________________________________________|
--
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
-- Almost __________________________      |     |     |     |     |     |     |     |     |      ____________________
-- Empty                        g1  |___________________________________________________________|  g1
--
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
-- Under                      |     |     |     |     |     |     |     |     |     |     |     |      ___________
-- flow_______________________________________________________________________________________________|  o  |  o  |__
--                            
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
-- Full                       |     |     |     |      _______________________
--      ______________________________________________|                       |______________________________________
--                            |     |     |     |     |     |     |     |     
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
-- Almost                                        ___________________________________
-- Full ________________________________________|  g1                           g1  |________________________________
--                            |     |     |     |     |     |     |     |     |     
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
-- Over                                                ___________
-- flow ______________________________________________|  o  |  o  |__________________________________________________
--
--                            |     |     |     |     |     |     |     |     |     |     |     |     |
--      ______________________ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ __
-- Count________0_____________X__1__X__2__X__3__X__4__X__4__X__4__X__4__X__4__X__3__X__2__X__1__X__0__X__0__X__0__X__
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.InferMem_pkg.all;

  entity InferFifo1c is
    generic (
    g_AsyncReset        : boolean   := False;
    g_SyncReset         : boolean   := False; 
    g_AddrSize          : positive  := 16;                             -- Address bus        
    g_DataSize          : positive  := 8 ;	                           -- Data bus
    g_AlmostFullLevel   : natural   := 2;	                           -- "almost_full" level
    g_AlmostEmptyLevel  : natural   := 3	                           -- "almost_empty" level
    );
    port ( 
    i_clk               : in  std_logic;  							   -- Single clock
	i_areset_n          : in  std_logic;  						       -- Asynchrous Reset
    i_sreset            : in  std_logic; 						 	   -- Synchronous Reset

    i_WrData            : in  std_logic_vector(g_DataSize-1 downto 0); -- Input data to write
    i_WrReq             : in  std_logic;  							   -- Write request    
    i_RdReq             : in  std_logic;  							   -- Read request
    o_RdData            : out std_logic_vector(g_DataSize-1 downto 0); -- Output data to read
    
    o_StatusFull        : out std_logic;  							   -- Flag: fifo is full
    o_StatusEmpty       : out std_logic;  							   -- Flag: fifo is empty
    o_StatusAlmostFull  : out std_logic;  							   -- Flag: fifo nearly full
    o_StatusAlmostEmpty : out std_logic;  							   -- Flag: fifo nearly empty
    o_Overflow         	: out std_logic;                           	   -- Flag: Fifo is full and trying to push data
    o_Underflow        	: out std_logic; 							   -- Flag: Fifo is empty and trying to pull data
    o_StatusWordCounter : out std_logic_vector(g_AddrSize downto 0)    -- Flag: number of word in the fifo
    );
  end InferFifo1c;

  architecture Behavior of InferFifo1c is
	
-------------------------------------------------------------------------------
--
-- Signals declaration
--
-------------------------------------------------------------------------------
    signal s_WrAddress          : std_logic_vector(g_AddrSize-1 downto 0); 
    signal s_WrEn               : std_logic;
    signal s_RdAddress          : std_logic_vector(g_AddrSize-1 downto 0); 
    signal s_RdEn               : std_logic;        
    signal s_StatusFull         : std_logic;                           
    signal s_StatusEmpty        : std_logic; 
    signal s_StatusAlmostFull   : std_logic; 
    signal s_StatusAlmostEmpty  : std_logic; 
    signal s_StatusWordCounter  : std_logic_vector(g_AddrSize downto 0);
    signal s_Overflow         	: std_logic;                           
    signal s_Underflow        	: std_logic; 
    signal s_Loop               : std_logic; 
	
    begin
-------------------------------------------------------------------------------
--
-- Port map of the component
--
-------------------------------------------------------------------------------
inst_WrapperRam1c2p : Wrapper_Ram1c2p
    generic map(
        g_AsyncReset => g_AsyncReset,
        g_SyncReset  => g_SyncReset,
        g_AddrSize   => g_AddrSize,
        g_DataSize   => g_DataSize
        )
	port map
	(
		i_areset_n		=> open,
        i_sreset        => open,	
		i_clk		    => i_clk,
		i_WrAddress		=> s_WrAddress,
		i_WrEn		    => s_WrEn, -- s_WrEn asynchronous but re-synchronized in RAM module
		i_WrData		=> i_WrData,	        
		i_RdAddress		=> s_RdAddress,	
		i_RdEn		    => s_RdEn, -- s_RdEn asynchronous but re-synchronized in RAM module	
		o_RdData		=> o_RdData
	);


-- -------------------------------------------------------------------------------
-- --
-- -- Process        : AccessProcess
-- -- Type           : Synchronous
-- -- Description    : Check the read / write operation by taken into account 
-- --                : StatusEmpty and StatusFull 
-- --
-- -------------------------------------------------------------------------------  
--ASYNC_GUARD_GENERATE: if (g_AsyncReset = True) generate   
--GuardAccess : process(i_areset_n, i_clk)
--end generate ASYNC_GUARD_GENERATE;

--NOTASYNC_GUARD_GENERATE: if g_AsyncReset = False generate
--GuardAccess : process(i_clk)
--end generate NOTASYNC_GUARD_GENERATE;
AccessProcess : process(i_areset_n, i_clk)
begin
    if i_areset_n = '0' and g_AsyncReset = True then
        s_WrAddress             <= (others =>'0');
        s_RdAddress             <= (others =>'0');
        s_Loop                  <= '0';
--                s_StatusFull            <= '0';
--                s_StatusEmpty           <= '1';       


    elsif rising_edge(i_clk) then
--end generate ASYNC_GUARD_GENERATE;    
--elsif g_AsyncReset = False generate   

--end generate ASYNC_GUARD_GENERATE;

-- SYNC_GUARD_GENERATE : if g_SyncReset = True generate
        if i_sreset = '1' and g_SyncReset = True then
            s_WrAddress             <= (others =>'0');
            s_RdAddress             <= (others =>'0');
--            s_StatusFull            <= '0';
--            s_StatusEmpty           <= '1';            

        else
--end generate SYNC_GUARD_GENERATE;
            -- If write request and not full
            if s_StatusFull='0' and i_WrReq = '1' then
                if unsigned(s_WrAddress) = 2**g_AddrSize-1 then
                    s_WrAddress <= (others =>'0');
                    s_Loop      <= '1';
                else
                    s_WrAddress <= std_logic_vector(unsigned(s_WrAddress) + 1);
                end if;
            else
                s_WrAddress     <= s_WrAddress;
            end if;


            if s_StatusEmpty='0' and i_RdReq = '1' then
                if unsigned(s_RdAddress) = 2**g_AddrSize-1 then
                    s_RdAddress <= (others =>'0');
                    s_Loop      <= '0';
                else
                    s_RdAddress <= std_logic_vector(unsigned(s_RdAddress) + 1);
                end if;
            else                                
                s_RdAddress     <= s_RdAddress; 
            end if;

-- SYNC_GUARDEND_GENERATE : if g_SyncReset = True generate
        end if;
-- end generate SYNC_GUARDEND_GENERATE;
    end if;
end process AccessProcess;


-- -------------------------------------------------------------------------------
-- --
-- -- Process        : -
-- -- Type           : Asynchronous
-- -- Description    : Enable access request depending on Full and Empty status  
-- --                : Registered when used by RAM
-- ------------------------------------------------------------------------------- 
s_WrEn      <=  '1' when (s_StatusFull='0' and i_WrReq = '1') else 
                '0';
s_RdEn      <=  '1' when (s_StatusEmpty='0' and i_RdReq = '1') else 
                '0';


-- -------------------------------------------------------------------------------
-- --
-- -- Process        : -
-- -- Type           : Asynchronous
-- -- Description    : Full and Empty status  
-- --                : Must be registered for better speed 
-- ------------------------------------------------------------------------------- 
-- (s_WrAddress = s_RdAddress) => full or empty ?
-- Case 1: 0.1.2...s_RdAddress.s_WrAddress...       => nearly empty     => s_RdAddress < s_WrAddress => Loop = 0
-- Case 1: 0.1.2...s_WrAddress.s_RdAddress...       => nearly full      => s_WrAddress < s_RdAddress => Loop = 1
-- Case 1: s_WrAddress...6.7.8.9.10...s_RdAddress   => nearly empty     => s_WrAddress < s_RdAddress => Loop = 0
-- Case 1: s_RdAddress...6.7.8.9.10...s_WrAddress   => nearly full      => s_RdAddress < s_WrAddress => Loop = 1
s_StatusEmpty           <= '1' when (unsigned(s_RdAddress) = unsigned(s_WrAddress) and s_Loop = '0') else '0';
s_StatusFull            <= '1' when (unsigned(s_RdAddress) = unsigned(s_WrAddress) and s_Loop = '1') else '0';
o_StatusEmpty           <= s_StatusEmpty;
o_StatusFull            <= s_StatusFull;



-- -------------------------------------------------------------------------------
-- --
-- -- Process        : OptionProcess
-- -- Type           : Synchronous
-- -- Description    : Compute the number of word in the Fifo and manage the flags
-- --
-- -------------------------------------------------------------------------------  
--ASYNC_GUARD_GENERATE: if (g_AsyncReset = True) generate   
--GuardAccess : process(i_areset_n, i_clk)
--end generate ASYNC_GUARD_GENERATE;

--NOTASYNC_GUARD_GENERATE: if g_AsyncReset = False generate
--GuardAccess : process(i_clk)
--end generate NOTASYNC_GUARD_GENERATE;
OptionProcess : process(i_areset_n, i_clk)
begin
    if i_areset_n = '0' and g_AsyncReset = True then
        o_StatusAlmostFull      <= '0';
        o_StatusAlmostEmpty     <= '1';
        s_StatusWordCounter     <= (others =>'0');
		s_Overflow 				<= '0';
		s_Underflow 			<= '0';

    elsif rising_edge(i_clk) then
--end generate ASYNC_GUARD_GENERATE;    
--elsif g_AsyncReset = False generate   

--end generate ASYNC_GUARD_GENERATE;

-- SYNC_GUARD_GENERATE : if g_SyncReset = True generate
        if i_sreset = '1' and g_SyncReset = True then        
            o_StatusAlmostFull      <= '0';
            o_StatusAlmostEmpty     <= '1';
            s_StatusWordCounter     <= (others =>'0');
            s_Overflow 				<= '0';
            s_Underflow 			<= '0';
        
        else
--end generate SYNC_GUARD_GENERATE;

            -- Introduce Latency
    		if s_Loop = '0' then --unsigned(s_WrAddress) >= unsigned(s_RdAddress) then
    			s_StatusWordCounter <= std_logic_vector(("0"& unsigned(s_WrAddress)) - ("0"& unsigned(s_RdAddress)));
    		else
    			s_StatusWordCounter <= std_logic_vector(to_unsigned(2**g_AddrSize,s_StatusWordCounter'length) - ("0"& unsigned(s_RdAddress) + ("0"& unsigned(s_WrAddress))));
    		end if;


            if s_StatusEmpty='1' and i_RdReq = '1' then
    			s_Underflow 			<= '1';
    		else 
    			s_Underflow 			<= '0';
    		end if;
    		
        	if s_StatusFull='1' and i_WrReq = '1' then
    			s_Overflow <= '1';
    		else
    			s_Overflow <= '0';
    		end if;

        o_StatusAlmostEmpty     <= s_StatusAlmostEmpty;
        o_StatusAlmostFull      <= s_StatusAlmostFull;		

-- SYNC_GUARDEND_GENERATE : if g_SyncReset = True generate
        end if;
-- end generate SYNC_GUARDEND_GENERATE;
    end if;
end process OptionProcess;

o_StatusWordCounter     <= s_StatusWordCounter; -- registered
o_Overflow              <= s_Overflow;          -- registered
o_Underflow             <= s_Underflow;	        -- registered


-- -------------------------------------------------------------------------------
-- --
-- -- Process        : -
-- -- Type           : Asynchronous
-- -- Description    : AlmostFull and AlmostEmpty status (registered before output) 
-- --
-- -------------------------------------------------------------------------------
s_StatusAlmostEmpty     <= 	'1' when (((unsigned(s_RdAddress) + to_unsigned(g_AlmostEmptyLevel,s_RdAddress'length)) >= unsigned(s_WrAddress)) and s_Loop = '0') else 
							'1' when ( ((to_unsigned(2**g_AddrSize-1,s_WrAddress'length) - unsigned(s_RdAddress) + unsigned(s_WrAddress)) <= to_unsigned(g_AlmostEmptyLevel,s_RdAddress'length)) and s_Loop = '1') else
							'0';
							
s_StatusAlmostFull      <= 	'1' when (((unsigned(s_RdAddress) - unsigned(s_WrAddress)) <=  g_AlmostFullLevel) and s_Loop = '1') else
							'1' when ( ( (to_unsigned(2**g_AddrSize-1,s_WrAddress'length) - unsigned(s_WrAddress)) <=  (unsigned(s_RdAddress) + to_unsigned(g_AlmostFullLevel,s_RdAddress'length) ) ) and s_Loop = '0') else
							'0';

end Behavior;