--   ----------------------------------------------------------------------------------------------
--   File name     : AltMem221Mem_pkg.vhd     
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


package AltMem221Mem_pkg is  

    component AltMem221Ram1c2p is
        generic
        (
            g_AddrSize : integer;
            g_NbWords  : integer;
            g_DataSize : integer;
            g_Device   : string;
        );    
        port
        (
            clock       : IN STD_LOGIC;
            data        : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            rdaddress   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            rden        : IN STD_LOGIC;
            wraddress   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            wren        : IN STD_LOGIC;
            q           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    end component AltMem221Ram1c2p;

    component Wrapper_Ram1c2p is
        generic
        (
            g_DataSize    :  integer := 8 ;          
            g_AddrSize    :  integer := 16 
        );      
        port
        (           
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
    
    component AltMem221Ram1c1p 
        generic
        (
            g_AddrSize : integer;
            g_NbWords  : integer;
            g_DataSize : integer;
            g_Device   : string;
        );
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (g_AddrSize-1 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (g_DataSize-1 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		    : OUT STD_LOGIC_VECTOR (g_DataSize-1 DOWNTO 0)
        );
    END component AltMem221Ram1c1p; 

    component Wrapper_Ram1c1p is
        generic
            (
                g_DataSize        : integer := 8;      
                g_AddrSize        : integer := 8 
            );      
        port(
                i_areset_n    : in std_logic  := '0'; 
                i_clk         : in std_logic;    
                i_WrAddress   : in std_logic_vector(g_AddrSize-1 downto 0); 
                i_WrEn        : in std_logic;                                                 
                i_WrData      : in std_logic_vector(g_DataSize-1 downto 0); 
                o_RdData      : out std_logic_vector(g_DataSize-1 downto 0)
            );
    end component Wrapper_Ram1c1p;


    
 
--   ---------------------------------------------------------------------------------------------- 
--   ---------------------------------------------------------------------------------------------- 
  
    component AltMem221Fifo1c IS
        generic
        (
            g_AddrSize : integer := 8;
            g_DataSize : integer := 8;                           
            g_AlmostFullLevel   : natural  := 2**8-1-6;                    
            g_AlmostEmptyLevel  : natural:= 6;
            g_NbWords  : integer := 256;        
            g_Device   : string  := "Cyclone IV GX"    
        );
        PORT
        (
            aclr		    : IN STD_LOGIC ;
            clock		    : IN STD_LOGIC ;
            data		    : IN STD_LOGIC_VECTOR (g_DataSize-1 DOWNTO 0);
            rdreq		    : IN STD_LOGIC ;
            sclr		    : IN STD_LOGIC ;
            wrreq		    : IN STD_LOGIC ;
            almost_empty	: OUT STD_LOGIC ;
            almost_full		: OUT STD_LOGIC ;
            empty		    : OUT STD_LOGIC ;
            full		    : OUT STD_LOGIC ;
            q		        : OUT STD_LOGIC_VECTOR (g_DataSize-1 DOWNTO 0);
            usedw		    : OUT STD_LOGIC_VECTOR (g_AddrSize-1 DOWNTO 0)
        );
    END component AltMem221Fifo1c;

    component Wrapper_Fifo1c is
    generic 
    (
        g_AddrSize              : integer := 8;
        g_DataSize              : integer := 8;                           
        g_AlmostFullLevel       : natural  := 2**8-1-6;                    
        g_AlmostEmptyLevel      : natural:= 6;                             
    );
    port 
    ( 
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

    component AltMem221Fifo2c IS
        generic
        (
            g_AddrSize              : integer := 8;
            g_DataSize              : integer := 8;                           
            g_AlmostFullLevel       : natural  := 2**8-1-6;                    
            g_AlmostEmptyLevel      : natural:= 6;
            g_NbWords               : integer := 256;        
            g_Device                : string  := "Cyclone IV GX"    
        );
        PORT
        (
            aclr		: IN STD_LOGIC  := '0';
            data		: IN STD_LOGIC_VECTOR (g_DataSize-1 DOWNTO 0);
            rdclk		: IN STD_LOGIC ;
            rdreq		: IN STD_LOGIC ;
            wrclk		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            q		    : OUT STD_LOGIC_VECTOR (g_DataSize-1 DOWNTO 0);
            rdempty		: OUT STD_LOGIC ;
            rdfull		: OUT STD_LOGIC ;
            rdusedw		: OUT STD_LOGIC_VECTOR (g_AddrSize-1 DOWNTO 0);
            wrempty		: OUT STD_LOGIC ;
            wrfull		: OUT STD_LOGIC ;
            wrusedw		: OUT STD_LOGIC_VECTOR (g_AddrSize-1 DOWNTO 0)
        );
    END component AltMem221Fifo2c;
    
    
    component Wrapper_Fifo2c is
        generic 
        (
            g_AddrSize              : integer := 8;
            g_DataSize              : integer := 8;                           
            g_AlmostFullLevel       : natural  := 2**8-1-6;                    
            g_AlmostEmptyLevel      : natural:= 6;                             
        );
        port 
        ( 
            i_InClk             : in  std_logic;                   
            i_OutClk            : in  std_logic; 
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
    end component Wrapper_Fifo2c;
    

end package AltMem221Mem_pkg;




package body AltMem221Mem_pkg is

end package body AltMem221Mem_pkg;
    
