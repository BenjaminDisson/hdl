--   ----------------------------------------------------------------------------------------------
--   File name     : InferAxiStrFifo1c.vhd     
--   Description   : Single clock fifo  
--                 : Fifo1c with Axi-stream interfaces
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson  : Creation
--
--      ___________________________
--     |                           |
--     |          _________        |
--     |  Axi    |        | Axi    |
--   --   Stream | Fifo1c | Stream  --
--     |  Slave  |________| Master |
--     |                           |
--     |___________________________|
--      

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.InferMem_pkg.all;

  entity InferInferAxiStrFifo1c is
    generic (
    g_DataSize          : positive :=8 ;	                           -- Data bus
    g_AddrSize          : positive :=16; 	                           -- Address bus
    g_AlmostFullLevel   : natural  := 2**16-1-2;	                   -- "almost_full" level
    g_AlmostEmptyLevel  : natural:= 2;	                               -- "almost_empty" level
    g_TidSize           : natural:= 2;
    g_TdestSize         : natural:= 2;
    g_Tuserize          : natural:= 2
    );
    port ( 
    i_clk               : in  std_logic;  							   -- Single clock
	i_areset_n          : in  std_logic;  						       -- Asynchrous Reset
    --i_sclr                : in  std_logic; 						 	  -- Synchronous Reset
    i_StrS_TVALID            : in  std_logic;
    o_StrS_TREADY            : out std_logic;
    i_StrS_TDATA             : in  std_logic_vector(g_DataSize-1 downto 0);
    i_StrS_TSTRB             : in  std_logic_vector(g_DataSize/4-1 downto 0);
    i_StrS_TKEEP             : in  std_logic_vector(g_DataSize/8-1 downto 0);
    i_StrS_TLAST             : in  std_logic;
    i_StrS_TID               : in  std_logic_vector(g_TidSize-1 downto 0);
    i_StrS_TDEST             : in  std_logic_vector(g_TdestSize-1 downto 0);
    i_StrS_TUSER             : in  std_logic_vector(g_Tuserize-1 downto 0);

    o_StrM_TVALID            : out  std_logic;
    i_StrM_TREADY            : in std_logic;
    o_StrM_TDATA             : out  std_logic_vector(g_DataSize-1 downto 0);
    o_StrM_TSTRB             : out  std_logic_vector(g_DataSize/4-1 downto 0);
    o_StrM_TKEEP             : out  std_logic_vector(g_DataSize/8-1 downto 0);
    o_StrM_TLAST             : out  std_logic;
    o_StrM_TID               : out  std_logic_vector(g_TidSize-1 downto 0);
    o_StrM_TDEST             : out  std_logic_vector(g_TdestSize-1 downto 0);
    o_StrM_TUSER             : out  std_logic_vector(g_Tuserize-1 downto 0);

    o_StrStatusFull          : out std_logic;                               -- Flag: fifo is full
    o_StrStatusEmpty         : out std_logic;                               -- Flag: fifo is empty
    o_StrStatusAlmostFull    : out std_logic;                               -- Flag: fifo nearly full
    o_StrStatusAlmostEmpty   : out std_logic;                               -- Flag: fifo nearly empty
    o_StrStatusWordCounter   : out std_logic_vector(g_AddrSize-1 downto 0)  -- Flag: number of word in the fifo
    );
  end InferInferAxiStrFifo1c;

  architecture Behavior of InferInferAxiStrFifo1c is
	
-------------------------------------------------------------------------------
--
-- Signals declaration
--
-------------------------------------------------------------------------------
    signal s_StrStatusFull  : std_logic;
    signal s_StrStatusEmpty : std_logic;


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
inst_InferFifo1c : InferFifo1c
    generic map
        (
        g_DataSize          => g_DataSize,
        g_AddrSize          => g_AddrSize,
        g_AlmostFullLevel   => g_AlmostFullLevel,
        g_AlmostEmptyLevel  => g_AlmostEmptyLevel
        )
    port map
    ( 
    i_clk               => i_clk,
    i_areset_n          => open,
    --i_sclr         : in  std_logic;                            
    i_WrData            => i_StrS_TDATA,
    i_WrReq             => i_StrS_TVALID & (not(s_StrStatusFull)),
    i_RdReq             => i_StrM_TREADY & (not(s_StrStatusEmpty))
    o_RdData            => o_StrM_TDATA
    o_StatusFull        => s_StrStatusFull,
    o_StatusEmpty       => s_StrStatusEmpty,
    o_StatusAlmostFull  => o_StrStatusAlmostFull,
    o_StatusAlmostEmpty => o_StrStatusAlmostEmpty,
    o_StatusWordCounter => o_StrStatusWordCounter
    );

    o_StrS_TREADY <= not(s_StrStatusFull);


    o_StrM_TVALID <= not(s_StrStatusEmpty);
    o_StrM_TSTRB  <= (others =>'1');
    o_StrM_TKEEP  <= (others =>'1');
    o_StrM_TLAST  <= '0';
    o_StrM_TID    <= i_StrM_TID;   
    o_StrM_TDEST  <= i_StrM_TDEST; 
    o_StrM_TUSER  <= i_StrM_TUSER; 
 



end Behavior;