--   ----------------------------------------------------------------------------------------------
--   File name     : InferMem_pkg.vhd     
--   Description   : Constant, procedure, function and component declaration   
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/05/2024 : 1.0   : Benjamin Disson  : Creation
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package InferMem_pkg is  

    component InferRam1c2p is
        generic(
            g_DataSize       :  integer := 8 ;        
            g_AddrSize       :  integer := 16 );     
        port(
            i_clk       : in std_logic;                                       
            i_WrData    : in std_logic_vector(g_DataSize-1 downto 0);  
            i_WrEn      : in std_logic;                                   
            i_WrAddress : in std_logic_vector(g_AddrSize-1 downto 0);     
            i_RdEn      : in std_logic;
            i_RdAddress : in std_logic_vector(g_AddrSize-1 downto 0);  
            o_RdData    : out std_logic_vector(g_DataSize-1 downto 0)
            );
        end component InferRam1c2p;


    component Wrapper_Ram1c2p is
        generic(
            g_DataSize      :  integer := 8 ;          
            g_AddrSize      :  integer := 16 );      
        port(           
            i_areset_n    : in std_logic  := '0';  -- Care, this standard pin is not in the infer Ram
            i_clk         : in std_logic;    
            i_WrAddress   : in std_logic_vector(g_AddrSize-1 downto 0); 
            i_WrEn        : in std_logic;                                                 
            i_WrData      : in std_logic_vector(g_DataSize-1 downto 0); 
            i_RdAddress   : in std_logic_vector(g_AddrSize-1 downto 0);                       
            i_RdEn        : in std_logic;
            o_RdData      : out std_logic_vector(g_DataSize-1 downto 0)                        
        );
    end component Wrapper_Ram1c2p;

--   ---------------------------------------------------------------------------------------------- 
--   ---------------------------------------------------------------------------------------------- 

    component InferFifo1c is
        generic (
            g_DataSize          : positive :=8 ;                               
            g_AddrSize          : positive :=16;                               
            g_AlmostFullLevel   : natural  := 2**16-1-2;                       
            g_AlmostEmptyLevel  : natural:= 2                                  
            );
        port ( 
            i_clk               : in  std_logic;                               
            i_areset_n          : in  std_logic;                               
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
    end component InferFifo1c;


    component Wrapper_Fifo1c is
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
    end component Wrapper_Fifo1c;
    
--   ---------------------------------------------------------------------------------------------- 
--   ---------------------------------------------------------------------------------------------- 
    
    component InferRam1c1p is
        generic(
            g_AddrSize      :  integer := 16;        
            g_DataSize      :  integer := 8 
            );     
        port(
            i_clk       : in std_logic;      
            i_WrAddress : in std_logic_vector(g_AddrSize-1 downto 0);                            
            i_WrEn      : in std_logic;                                
            i_WrData    : in std_logic_vector(g_DataSize-1 downto 0);
            o_RdData    : out std_logic_vector(g_DataSize-1 downto 0)
            );
    end component InferRam1c1p; 
    
    
    component Wrapper_Ram1c1p is
        generic(
            g_DataSize      :  integer := 8 ;          
            g_AddrSize      :  integer := 16 );      
        port(           
            i_areset_n    : in std_logic  := '0';  -- Care, this standard pin is not in the infer Ram
            i_clk         : in std_logic;    
            i_WrAddress   : in std_logic_vector(g_AddrSize-1 downto 0); 
            i_WrEn        : in std_logic;                                                 
            i_WrData      : in std_logic_vector(g_DataSize-1 downto 0);                        
            o_RdData      : out std_logic_vector(g_DataSize-1 downto 0)                        
        );
    end component Wrapper_Ram1c1p;    
    
    
--   ---------------------------------------------------------------------------------------------- 
--   ---------------------------------------------------------------------------------------------- 
    
    
    component InferFFRam1c1p is
        generic(
            g_AddrSize      :  integer := 16;        
            g_DataSize      :  integer := 8 
            );     
        port(
            i_clk       : in std_logic;      
            i_Address   : in std_logic_vector(g_AddrSize-1 downto 0);                            
            i_WrEn      : in std_logic;                                
            i_WrData    : in std_logic_vector(g_DataSize-1 downto 0); 
            o_RdData    : out std_logic_vector(g_DataSize-1 downto 0)
            );
    end component InferFFRam1c1p;    
    
    component InferFFRam1c2p is
        generic(
            g_AddrSize      :  integer := 16;        
            g_DataSize      :  integer := 8 
            );     
        port(
            i_clk       : in std_logic;      
            i_WrAddress : in std_logic_vector(g_AddrSize-1 downto 0);                            
            i_WrEn      : in std_logic;                                
            i_WrData    : in std_logic_vector(g_DataSize-1 downto 0);
            i_RdAddress : in std_logic_vector(g_AddrSize-1 downto 0);  
            o_RdData    : out std_logic_vector(g_DataSize-1 downto 0)
            );
    end component InferFFRam1c2p;
    
    component InferRom is
        generic(
            g_AddrSize  : positive := 8;													
            g_DataSize 	: positive := 16
            );												
        port(
            i_Address   : in std_logic_vector(g_AddrSize -1 downto 0 );				
            i_Clk       : in std_logic;									  	   								
            o_DataOut   : out std_logic_vector (g_DataSize -1 downto 0 ) 			
		); 
  end component InferRom;
    
    
    
end package InferMem_pkg;




package body InferMem_pkg is

end package body InferMem_pkg;
    
