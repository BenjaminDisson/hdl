library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.all;

entity tb_Wrapper_Fifo1c is
end entity tb_Wrapper_Fifo1c;


-- Options
-- Questa: Toggle leaf name for wave
-- questa: vsim -voptargs="+acc" -t ps pour avoir tous les signaux et empêcher l'optimisation

architecture bench of tb_Wrapper_Fifo1c is
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
constant C_AlmostFullLevel  : positive := (2**8)-1-3;
constant C_AlmostEmptyLevel : positive := 3;
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
signal mo_StatusWordCounter : std_logic_vector(C_AddrSize-1 downto 0);

signal s_CtrlCounter            : natural range 0 to 2**C_AddrSize;--std_logic_vector(C_AddrSize-1 downto 0);
signal s_CtrlCounter_tmp        : natural range 0 to 2**C_AddrSize;--std_logic_vector(C_AddrSize-1 downto 0);
signal s_CtrlCounter_tmp_tmp    : natural range 0 to 2**C_AddrSize;--std_logic_vector(C_AddrSize-1 downto 0);
signal s_StatusEmpty_tmp        : std_logic;
signal s_StatusFull_tmp         : std_logic;
signal s_StatusAlmostEmpty_tmp  : std_logic;
signal s_StatusAlmostFull_tmp   : std_logic;

-------------------------------------------------------------------------------
-- Functions declaration 
-------------------------------------------------------------------------------
function StdLogicToInteger(MyStdLogic: std_logic) return integer is
begin
    if MyStdLogic = '1' then 
        return 1; 
    else 
        return 0;
    end if;
end;

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
    g_SyncReset         =>  False,     
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
  mi_sreset <= '1'; wait for LATENCY;
  mi_sreset <= '0'; wait;

end process SRESET_PROCESS;


CLOCK_PROCESS : process
begin

  mi_clk <= '0'; wait for CLK_PERIOD;
  mi_clk <= '1'; wait for CLK_PERIOD;

end process CLOCK_PROCESS;


-- Reference for the flag
-------------------------
StatusWordCounter_PROCESS : process
begin

    wait until rising_edge(mi_clk);
    if mi_WrReq = '1' then
        if mi_RdReq ='0' then
            if s_CtrlCounter < 2**C_AddrSize then
                s_CtrlCounter <= s_CtrlCounter+1;
            end if;
        end if;
    else
        if mi_RdReq ='1' then
            if s_CtrlCounter > 0 then
                s_CtrlCounter <= s_CtrlCounter-1;
            end if;
        end if;
    end if;
   s_CtrlCounter_tmp        <= s_CtrlCounter;
   s_CtrlCounter_tmp_tmp    <= s_CtrlCounter_tmp;

    if s_CtrlCounter = 0 then
        s_StatusEmpty_tmp <= '1';
    else
        s_StatusEmpty_tmp <= '0';
    end if;

    if s_CtrlCounter = 2**C_AddrSize then
        s_StatusFull_tmp <= '1';
    else
        s_StatusFull_tmp <= '0';
    end if;


    if s_CtrlCounter <= C_AlmostEmptyLevel then
        s_StatusAlmostEmpty_tmp <= '1';
    else
        s_StatusAlmostEmpty_tmp <= '0';
    end if;

    if s_CtrlCounter >= C_AlmostFullLevel then
        s_StatusAlmostFull_tmp <= '1';
    else
        s_StatusAlmostFull_tmp <= '0';
    end if;

end process StatusWordCounter_PROCESS;



    WR_DATA_PROCESS : process
        variable ValCpt : natural range 0 to 2**C_AddrSize;
    begin
        -- Initialise input
        mi_WrData   <= (others => '0');          
        mi_WrReq    <='0';           
        mi_RdReq   <='0';    
        ValCpt    := 0;
    
        wait for LATENCY*2;

        for i in 0 to 5 loop
            wait until rising_edge(mi_clk);
        end loop;

        assert false report "Beginning " severity note;

        while (ValCpt /= 2**C_AddrSize) loop 
            ValCpt := ValCpt + 1;
            mi_WrData <= std_logic_vector(to_unsigned(ValCpt, mi_WrData'length));
            mi_WrReq   <= '1';
            mi_RdReq   <= '0';


            if ValCpt < 10 then -- for Empty
                assert false report "CONTROLE val="  & integer'image((ValCpt)) & " mo_StatusWordCounter=" & integer'image(to_integer(unsigned(mo_StatusWordCounter)))  & " s_CtrlCounter_tmp=" & integer'image((s_CtrlCounter_tmp)) & " s_CtrlCounter_tmp_tmp=" & integer'image((s_CtrlCounter_tmp_tmp)) severity note;
            end if;
            if ValCpt > 253 then -- for Full
                assert false report "CONTROLE val="  & integer'image((ValCpt)) & " mo_StatusWordCounter=" & integer'image(to_integer(unsigned(mo_StatusWordCounter)))  & " s_CtrlCounter_tmp=" & integer'image((s_CtrlCounter_tmp)) & " s_CtrlCounter_tmp_tmp=" & integer'image((s_CtrlCounter_tmp_tmp)) severity note;
            end if;


            if mo_StatusWordCounter /= std_logic_vector(to_unsigned(s_CtrlCounter_tmp,mo_StatusWordCounter'length)) then
                assert false report "Error Wmo_StatusWordCounterW val="  & integer'image((ValCpt)) & " mo_StatusWordCounter=" & integer'image(to_integer(unsigned(mo_StatusWordCounter)))  & " s_CtrlCounter_tmp=" & integer'image((s_CtrlCounter_tmp)) severity note;
            end if;

            if mo_StatusFull = '0' and s_StatusFull_tmp ='1'then
                assert false report "WError mo_StatusFull_1 " severity note;
            end if;
            if mo_StatusFull = '1' and s_StatusFull_tmp ='0'then
                assert false report "WError mo_StatusFull_2 " severity note;
            end if;
            if mo_StatusFull = '1' and s_StatusFull_tmp ='1' then
                assert false report "Wmo_StatusEmpty ok " severity note;
            end if;


            if mo_StatusEmpty = '0' and s_StatusEmpty_tmp = '1' then --mo_StatusEmpty ='0'then
                assert false report "WError mo_StatusEmpty_1  mo_StatusEmpty=" & integer'image(StdLogicToInteger(mo_StatusEmpty)) & " StatusEmpty_tmp= " & integer'image(StdLogicToInteger(s_StatusEmpty_tmp)) severity note;
            end if;
            if mo_StatusEmpty = '1' and s_StatusEmpty_tmp = '0' then --mo_StatusEmpty ='1'then
                assert false report "WError mo_StatusEmpty_2 - ValCpt="& integer'image((ValCpt)) & " StatusEmpty_tmp=" & integer'image(StdLogicToInteger(s_StatusEmpty_tmp)) severity note;
            end if;
            if mo_StatusEmpty = '1' and mo_StatusEmpty ='1'then
                assert false report "Wmo_StatusEmpty ok" severity note;
            end if;

     
            if mo_StatusAlmostFull ='0' and s_StatusAlmostFull_tmp='1' then
                assert false report "WError mo_StatusAlmostFull_1 - mo_StatusAlmostFull="& integer'image(StdLogicToInteger(mo_StatusAlmostFull)) &" s_StatusAlmostFull_tmp="& integer'image(StdLogicToInteger(s_StatusAlmostFull_tmp)) & " mo_StatusWordCounter=" & integer'image(to_integer(unsigned(mo_StatusWordCounter))) & " tmp_tmp=" & integer'image((s_CtrlCounter_tmp_tmp)) severity note;
            end if;
            if mo_StatusAlmostFull ='1' and s_StatusAlmostFull_tmp='0' then
                assert false report "WError mo_StatusAlmostFull_2 - mo_StatusAlmostFull="& integer'image(StdLogicToInteger(mo_StatusAlmostFull)) &" s_StatusAlmostFull_tmp="& integer'image(StdLogicToInteger(s_StatusAlmostFull_tmp))  & " mo_StatusWordCounter=" & integer'image(to_integer(unsigned(mo_StatusWordCounter))) & " tmp_tmp=" & integer'image((s_CtrlCounter_tmp_tmp)) severity note;
            end if;
            if mo_StatusAlmostFull ='1' and s_StatusAlmostFull_tmp='1'  then
                assert false report "Wmo_StatusAlmostFull ok" severity note;
            end if;   

            if mo_StatusAlmostEmpty ='0' and s_StatusAlmostEmpty_tmp = '1' then
                assert false report "WError mo_StatusAlmostEmpty_1 - mo_StatusAlmostEmpty="& integer'image(StdLogicToInteger(mo_StatusAlmostEmpty)) &" s_StatusAlmostFull_tmp="& integer'image(StdLogicToInteger(s_StatusAlmostEmpty_tmp)) & " mo_StatusWordCounter=" & integer'image(to_integer(unsigned(mo_StatusWordCounter))) & " tmp_tmp=" & integer'image((s_CtrlCounter_tmp_tmp)) severity note;
            end if;
            if mo_StatusAlmostEmpty ='1' and s_StatusAlmostEmpty_tmp = '0' then
                assert false report "WError mo_StatusAlmostEmpty_2" severity note;
            end if;
            if mo_StatusAlmostEmpty ='1' and s_StatusAlmostEmpty_tmp = '1' then
                assert false report "Wmo_StatusAlmostEmpty ok" severity note;
            end if;             

            wait until rising_edge(mi_clk);

            
        end loop;

        mi_WrReq   <= '0';
        ValCpt    := 0;


        while (ValCpt /= 2**C_AddrSize) loop
            mi_RdReq   <= '1';
            ValCpt := ValCpt + 1;
            if mo_RdData /= std_logic_vector(to_unsigned(ValCpt, mo_RdData'length)) then
                assert false report "Error mo_RdData " severity note;
            end if;


            if mo_StatusWordCounter /= std_logic_vector(to_unsigned(ValCpt,mo_StatusWordCounter'length)) then
                assert false report "Error mo_StatusWordCounter2 " & integer'image((ValCpt)) severity note;
            end if;

            if ValCpt = 2**C_AddrSize-1 and mo_StatusFull ='0'then
                assert false report "Error mo_StatusFull_1 " severity note;
            end if;
            if ValCpt /= 2**C_AddrSize-1 and mo_StatusFull ='1'then
                assert false report "Error mo_StatusFull_2 " severity note;
            end if;
            if ValCpt = 2**C_AddrSize-1 and mo_StatusFull ='1' then
                assert false report "mo_StatusFull ok " severity note;
            end if;


            if ValCpt = 0 and mo_StatusEmpty ='0'then
                assert false report "Error mo_StatusEmpty_1" severity note;
            end if;
            if ValCpt /= 0 and mo_StatusEmpty ='1'then
                assert false report "Error mo_StatusEmpty_2" severity note;
            end if;
            if ValCpt = 0 and mo_StatusEmpty ='1'then
                assert false report "mo_StatusEmpty ok" severity note;
            end if;

     
            if ValCpt = C_AlmostFullLevel and mo_StatusAlmostFull ='0'then
                assert false report "Error mo_StatusAlmostFull_1" severity note;
            end if;
            if ValCpt /= C_AlmostFullLevel and mo_StatusAlmostFull ='1'then
                assert false report "Error mo_StatusAlmostFull_2" severity note;
            end if;
            if ValCpt = C_AlmostFullLevel and mo_StatusAlmostFull ='1'then
                assert false report "mo_StatusAlmostFull ok" severity note;
            end if;   

            if ValCpt = C_AlmostEmptyLevel and mo_StatusAlmostEmpty ='0'then
                assert false report "Error mo_StatusAlmostEmpty_1" severity note;
            end if;
            if ValCpt /= C_AlmostEmptyLevel and mo_StatusAlmostEmpty ='1'then
                assert false report "Error mo_StatusAlmostEmpty_2" severity note;
            end if;
            if ValCpt = C_AlmostEmptyLevel and mo_StatusAlmostEmpty ='1'then
                assert false report "mo_StatusAlmostEmpty ok" severity note;
            end if;

            wait until rising_edge(mi_clk);
          end loop;
        mi_WrReq   <= '0';
        ValCpt    := 0;
        mi_RdReq   <= '1';

        wait until rising_edge(mi_clk);

    -- FINISH COVERAGE        

    end process WR_DATA_PROCESS;

end architecture bench;
