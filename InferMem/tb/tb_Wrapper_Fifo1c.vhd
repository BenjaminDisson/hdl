library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.all;


entity tb_Wrapper_Fifo1c is
end entity tb_Wrapper_Fifo1c;



architecture bench of tb_Wrapper_Fifo1c is
-------------------------------------------------------------------------------
-- Components declaration
-------------------------------------------------------------------------------
-- see InferMem_pkg

-------------------------------------------------------------------------------
-- Constant
-------------------------------------------------------------------------------
--    constant k_addr_size : integer := 5;
--    constant k_data_size : integer := 8;
--    constant k_target    : string  := "Stratix III";

constant CLK_PERIOD         : time := 10 ns;
constant LATENCY            : time := 105 ns;
constant C_AddrSize         : positive := 8;
constant C_DataSize         : positive := 16;
constant g_AlmostFullLevel  : positive := 2**8-1-3;
constant g_AlmostEmptyLevel : positive := 3;
-------------------------------------------------------------------------------
-- Signal declaration 
-------------------------------------------------------------------------------
    signal reset_n : std_logic;
    signal clk     : std_logic;
    signal enable  : std_logic;
    signal init    : std_logic;

    signal data_r        : std_logic_vector (k_data_size-1 downto 0);
    signal data_w        : std_logic_vector (k_data_size-1 downto 0);
    signal rden          : std_logic;
    signal wren          : std_logic;
    signal nb_used_words : std_logic_vector(g_addr_size-1 downto 0);
    
begin 

-- Instanciation
--******************
inst_Wrapper_Fifo1c : entity Wrapper_Fifo1c
    generic map (
    g_DataSize          => g_DataSize,                         
    g_AddrSize          => g_AddrSize,                         
    g_AlmostFullLevel   => g_AlmostFullLevel,                  
    g_AlmostEmptyLevel  => g_AlmostEmptyLevel                 
    )
    port map( 
    i_clk               => mi_clk,              
    i_areset_n          => mi_areset_n, 
    i_sclr              => mi_sclr,                    
    i_WrData            => mi_WrData,          
    i_WrReq             => mi_WrReq,            
    i_RdReq             => mi_RdReq,            
    o_RdData            => mo_RdData,           
    o_StatusFull        => mo_StatusFull,       
    o_StatusEmpty       => mo_StatusEmpty,      
    o_StatusAlmostFull  => mo_StatusAlmostFull, 
    o_StatusAlmostEmpty => mo_StatusAlmostEmpty,
    o_StatusWordCounter => mo_StatusWordCounter);


--    generic map (
--        g_addr_size => k_addr_size,
--        g_data_size => k_data_size,
--        g_target    => "Stratix III")
--    port map (
--        reset_n => reset_n,
--        clk     => clk,
--        enable  => enable,
--        init    => init,
--
--        rden          => rden,
--        data_r        => data_r,
--        wren          => wren,
--        data_w        => data_w,
--        nb_used_words => nb_used_words);


-- System clock
-------------------
ARESET_PROCESS : process
begin

  mi_areset_n <= '0'; wait for LATENCY;
  mi_areset_n <= '1'; wait;

end process ARESET_PROCESS;


SRESET_PROCESS : process
begin

  mi_sclr <= '0'; wait for LATENCY/2;
  mi_sclr <= '1'; wait for LATENCY;
  mi_sclr <= '0'; wait;

end process SRESET_PROCESS;


CLOCK_PROCESS : process
begin

  mi_clk <= '0'; wait for CLK_PERIOD;
  mi_clk <= '1'; wait for CLK_PERIOD;

end process CLOCK_PROCESS;

--    clk_proc : process
--    begin
--        clk <= '0';
--        wait for 5 ns;
--        clk <= '1';
--        wait for 5 ns;
--    end process clk_proc;
--
--    reset_n <= '0', '1' after 22 ns;
--
--    enable <= '0', '1' after 32 ns;
--
--    init <= '0';





    data_proc : process(clk, reset_n)
        variable v_cpt_add : integer range 0 to 2**k_addr_size-1;
    begin
        if(reset_n = '0') then
            data_w <= (others => '0');
            rden   <= '0';
            wren   <= '0';

            v_cpt_add := 0;
            
        elsif(rising_edge(clk)) then
            if(enable = '1') then
                if(init = '1') then
                    data_w <= (others => '0');
                    rden   <= '0';
                    wren   <= '0';

                    v_cpt_add := 0;
                    
                else

                    wren <= '0';
                    rden <= '0';

                    if(v_cpt_add /= 2**k_addr_size-1) then
                        data_w <= std_logic_vector(to_unsigned(v_cpt_add, data_w'length));
                        wren   <= '1';

                        rden <= wren;

                        v_cpt_add := v_cpt_add + 1;
                        
                    else
                        report "Fin de la simulation." severity failure;
                    end if;
                    
                end if;
            end if;
        end if;
    end process data_proc;




end architecture bench;
