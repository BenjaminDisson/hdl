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
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson  : Creation
--
--
--  Clk         0|                1|                   2|                     3|
--           Request        get fifo status     
--           i_WrReq  =>          s_WrEn    ===============||
--           i_RdReq  =>          s_RdEn    ==========||   ||
--                                 /\                 \/   \/
--                                 ||          o_StatusWordCounter
--                                 ||                  ||
--                                 ||                  \/
--                                 ||========= o_StatusFull
--                                             o_StatusAlmostFull
--                                             o_StatusAlmostEmpty
--                                             o_StatusEmpty
--
--          i_WrData  =>      s_WrData (ram)      
--                           s_WrAddress (ram)
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.InferMem_pkg.all;

  entity InferFifo1c is
    generic (
    g_AsyncReset        : boolean   := False;
    g_SyncReset         : boolean   := False; 
    g_AddrSize          : positive  :=16;                              -- Address bus        
    g_DataSize          : positive  :=8 ;	                           -- Data bus
    g_AlmostFullLevel   : natural   := 2**16-1-2;	                   -- "almost_full" level
    g_AlmostEmptyLevel  : natural   := 2	                           -- "almost_empty" level
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
    o_StatusWordCounter : out std_logic_vector(g_AddrSize-1 downto 0)  -- Flag: number of word in the fifo
    );
  end InferFifo1c;

  architecture Behavior of InferFifo1c is
	
-------------------------------------------------------------------------------
--
-- Signals declaration
--
-------------------------------------------------------------------------------
    signal s_WrAddress      : std_logic_vector(g_AddrSize-1 downto 0); 
    signal s_WrEn           : std_logic;
    signal s_WrData         : std_logic_vector(g_DataSize-1 downto 0);

    signal s_RdAddress      : std_logic_vector(g_AddrSize-1 downto 0); 
    signal s_RdEn           : std_logic;       
    signal s_RdData         : std_logic_vector(g_DataSize-1 downto 0);  

    signal s_StatusFull     : std_logic;                           
    signal s_StatusEmpty    : std_logic;                                
       
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
		i_WrEn		    => s_WrEn,
		i_WrData		=> s_WrData,	        
		i_RdAddress		=> s_RdAddress,	
		i_RdEn		    => s_RdEn,	
		o_RdData		=> o_RdData
	);



-------------------------------------------------------------------------------
--
-- Process        : GuardStatus
-- Type           : Synchronous
-- Description    : Check the read / write operation by taken into account 
--                : StatusEmpty and StatusFull 
--
-------------------------------------------------------------------------------
--ASYNC_GUARD_GENERATE: if (g_AsyncReset = True) generate   
--GuardAccess : process(i_areset_n, i_clk)
--end generate ASYNC_GUARD_GENERATE;

--NOTASYNC_GUARD_GENERATE: if g_AsyncReset = False generate
--GuardAccess : process(i_clk)
--end generate NOTASYNC_GUARD_GENERATE;

GuardAccess : process(i_areset_n, i_clk)
        variable v_WrEn     : std_logic;
        variable v_RdEn     : std_logic;
        begin
            if i_areset_n = '0' and g_AsyncReset = True then
                s_WrAddress <= (others =>'0');
                s_WrEn      <= '0';
                s_WrData    <= (others =>'0');
                s_RdAddress <= (others =>'0');
                s_RdEn      <= '0';
                s_RdData    <= (others =>'0');
                v_RdEn      :='0';
                v_WrEn      :='0';

            elsif rising_edge(i_clk) then
--end generate ASYNC_GUARD_GENERATE;    -- tot test
--elsif g_AsyncReset = False generate   
--    GuardAccess : process(i_clk)
--        variable v_WrEn     : std_logic;
--        variable v_RdEn     : std_logic;
--        begin
--            if rising_edge(i_clk) then
--end generate ASYNC_GUARD_GENERATE;


-- SYNC_GUARD_GENERATE : if g_SyncReset = True generate
        if i_sreset = '1' and g_SyncReset = True then
            s_WrAddress <= (others =>'0');
            s_WrEn      <= '0';
            s_WrData    <= (others =>'0');
            s_RdAddress <= (others =>'0');
            s_RdEn      <= '0';
            s_RdData    <= (others =>'0');
            v_RdEn      :='0';
            v_WrEn      :='0';
        else
--end generate SYNC_GUARD_GENERATE;
            


            -- Management of WRITE access
            -- 1) when read access, no problem to write 2) when fifo not full            
            if (i_RdReq  ='1') or (s_StatusFull = '0') then
                v_WrEn := i_WrReq;
            else
                v_WrEn := '0';
            end if;

            s_WrEn <= v_WrEn;

            if v_WrEn = '1' then
                s_WrAddress <= std_logic_vector(unsigned(s_WrAddress) + 1);
            end if;
--            s_WrEn      <=  i_WrReq when ((i_RdReq  ='1') or (s_StatusFull = '0')) else
--                            '0';
--            s_WrAddress <=  std_logic_vector(unsigned(s_WrAddress) + 1) when (((i_RdReq  ='1') or (s_StatusFull = '0')) and i_WrReq = '1') else
--                            s_WrAddress;


            s_WrData <= i_WrData;


            -- Management of READ access
            -- 1) when write access no probelm to read (care about timing access) 2) when fifo not empty
            -- Note delete condition 1 because on the time to go through the fifo 
           if s_StatusEmpty='0' then
               v_RdEn := i_RdReq;
           else
               v_RdEn := '0';
           end if;
           
           s_RdEn <= v_RdEn;

           if v_RdEn = '1' then
               s_RdAddress <= std_logic_vector(unsigned(s_RdAddress) + 1);
           end if;
--            s_RdEn      <=  i_RdReq when s_StatusEmpty='0' else
--                            '0';
--            s_RdAddress <=  std_logic_vector(unsigned(s_RdAddress) + 1) when (s_StatusEmpty='0' and i_RdReq = '1') else
--                            s_RdAddress;

-- SYNC_GUARDEND_GENERATE : if g_SyncReset = True generate
            end if;
-- end generate SYNC_GUARDEND_GENERATE;
       end if;

    end process GuardAccess;
    


-------------------------------------------------------------------------------
--
-- Process	      : STATUS
-- Type           : Synchronous
-- Description    : Compute the number of word in the Fifo and manage the flags
--
-------------------------------------------------------------------------------  
-- ASYNC_STATUS_GENERATE: if g_AsyncReset = True generate 
-- Status : process(i_areset_n, i_clk)
-- end generate ASYNC_STATUS_GENERATE;
-- NOTASYNC_STATUS_GENERATE:if g_AsyncReset = False generate
-- Status : process(i_clk)
-- end generate NOTASYNC_STATUS_GENERATE;
Status : process(i_areset_n, i_clk)
    variable v_UseDw    : natural range 0 to 2**g_AddrSize;
    begin
        if i_areset_n = '0' and g_AsyncReset = True then
            v_UseDw                := 0;
            s_StatusEmpty          <= '1';
            s_StatusFull           <= '0';        
            o_StatusEmpty          <= '1';
            o_StatusFull           <= '0';
            o_StatusAlmostFull     <= '0';
            o_StatusAlmostEmpty    <= '1';
            o_StatusWordCounter    <= (others =>'0');
         
        elsif rising_edge(i_clk) then
    
--elsif g_AsyncReset = False generate 
--Status : process(i_areset_n, i_clk)
--    variable v_UseDw    : natural range 0 to 2**g_AddrSize;
--    begin
--        if rising_edge(i_clk) then
--
--end generate ASYNC_STATUS_GENERATE;

-- SYNC_STATUS_GENERATE : if g_SyncReset = True generate
            if i_sreset = '1' and g_SyncReset = True then
                v_UseDw                := 0;
                s_StatusEmpty          <= '1';
                s_StatusFull           <= '0';
                o_StatusEmpty          <= '1';
                o_StatusFull           <= '0';
                o_StatusAlmostFull     <= '0';
                o_StatusAlmostEmpty    <= '1';
                o_StatusWordCounter    <= (others =>'0');
            else
--end generate SYNC_STATUS_GENERATE;

                -- Mangement of the counter
                -- if read or write access ONLY
                if s_WrEn = '1' and s_RdEn = '0' then  
                    v_UseDw := v_UseDw + 1;
                elsif s_WrEn = '0' and s_RdEn = '1' then 
                    v_UseDw := v_UseDw - 1;
                else
                    v_UseDw := v_UseDw;
                end if;
    
                o_StatusWordCounter <= std_logic_vector(to_unsigned(v_UseDw,g_AddrSize));
                
    
                -- Management of Empty counter
                if v_UseDw = 0 then
                    s_StatusEmpty   <= '1';
                    o_StatusEmpty   <= '1';
                else
                    s_StatusEmpty   <= '0';
                    o_StatusEmpty   <= '0';
                end if;
    
    
                -- Management of Almost Empty counter
                if v_UseDw <= g_AlmostEmptyLevel then
                    o_StatusAlmostEmpty   <= '1';
                else
                    o_StatusAlmostEmpty   <= '0';
                end if;
    
                -- Management of Almost Full counter
                if v_UseDw >= g_AlmostFullLevel then
                    o_StatusAlmostFull   <= '1';
                else
                    o_StatusAlmostFull   <= '0';
                end if;
    
                -- Management of  Full counter
                if v_UseDw = 2**g_AddrSize then
                    s_StatusFull   <= '1';
                    o_StatusFull   <= '1';
                else
                    s_StatusFull   <= '0';
                    o_StatusFull   <= '0';
                end if;
            

--SYNC_STATUSEND_GENERATE : if g_SyncReset = True generate
            end if;
--end generate SYNC_STATUSEND_GENERATE;

        end if;
        -- WARNING : decalade de 1/ periode en mettant ici l'affectantion
        --o_StatusFull  <= s_StatusFull;                           
        --o_StatusEmpty <= s_StatusEmpty;
    end process Status;   



end Behavior;