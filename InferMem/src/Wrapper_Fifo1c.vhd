--   ----------------------------------------------------------------------------------------------
--   File name     : Wrapper_Fifo1c.vhd     
--   Description   : Wrapper made to standardize all kind of composant that   
--                 : can be instanciated or inferred     
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson  : Creation
--
--
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.InferMem_pkg.all;

entity Wrapper_Fifo1c is
    generic (
    g_DataSize          : positive :=8 ;                            
    g_AddrSize          : positive :=16;                            
    g_AlmostFullLevel   : natural  := 2**16-1-2;                    
    g_AlmostEmptyLevel  : natural:= 2                               
    );
    port ( 
    i_clk               : in  std_logic;                   
    i_areset_n          : in  std_logic;                   
    i_sclr              : in  std_logic;                   

    i_WrData            : in  std_logic_vector(g_DataSize-1 downto 0); 
    i_WrReq             : in  std_logic;                     
    i_RdReq             : in  std_logic;                  
    o_RdData            : out std_logic_vector(g_DataSize-1 downto 0); 
    
    o_StatusFull        : out std_logic;                  
    o_StatusEmpty       : out std_logic;                  
    o_StatusAlmostFull  : out std_logic;                  
    o_StatusAlmostEmpty : out std_logic;                  
    o_StatusWordCounter : out std_logic_vector(g_AddrSize-1 downto 0)  
    );
end Wrapper_Fifo1c;

architecture Behavior of Wrapper_Fifo1c is
begin

  inst_InterFifo1c : InterFifo1c
    generic map (
    g_DataSize          => g_DataSize,                         
    g_AddrSize          => g_AddrSize,                         
    g_AlmostFullLevel   => g_AlmostFullLevel,                  
    g_AlmostEmptyLevel  => g_AlmostEmptyLevel                 
    )
    port map( 
    i_clk               => i_clk,              
    i_areset_n          => i_areset_n,                     
    i_WrData            => i_WrData,          
    i_WrReq             => i_WrReq,            
    i_RdReq             => i_RdReq,            
    o_RdData            => o_RdData,           
    o_StatusFull        => o_StatusFull,       
    o_StatusEmpty       => o_StatusEmpty,      
    o_StatusAlmostFull  => o_StatusAlmostFull, 
    o_StatusAlmostEmpty => o_StatusAlmostEmpty,
    o_StatusWordCounter => o_StatusWordCounter              
    );


end Behavior;