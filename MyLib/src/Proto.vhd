
    Generic
    (
        G_ASYNCRESET : boolean := "True";                                       
        G_SYNCRESET  : boolean := "False                                      
    );
    i_sys_clk          : in  std_logic;                                 
    i_arst_n           : in  std_logic;                     
	i_srst_n           : in  std_logic;                   
	

TOTO : process(i_sys_clk,i_arst_n)
	begin

ASYNC_GENERATE: if G_ASYNCRESET = "True" generate	
	process(i_sys_clk,i_arst_n)
	begin
	if i_arst_n='0' then
		MEM_OUT <= (others => '0');
	elsif rising_edge(i_sys_clk) then
	
elsif G_ASYNCRESET = "false" generate	
	process(i_sys_clk)
	begin
	if rising_edge(i_sys_clk) then
end generate ASYNC_GENERATE;			


SYNC_GENERATE : if G_SYNCRESET = "true" generate
		if i_srst_n = '0' then
			MEM_OUT <= (others => '0');
		else
end generate SYNC_GENERATE;
			
			MEM_OUT <= MEM(to_integer(ADDR_R));

SYNC_GENERATE : if G_SYNCRESET = "true" generate
		end if;
end generate SYNC_GENERATE;

		end if; -- end of clock
end process TOTO;	

