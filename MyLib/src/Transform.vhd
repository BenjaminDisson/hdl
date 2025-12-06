


-------------------------------------------------------------------------------
function gray2bcd (var  : unsigned) return unsigned is
  variable len : integerr := var'length;
  variable result : unsigned (var'length-1 downto 0);
  begin
  result (len-1) := ver(len-1);
  for i in len-2 downto 0 loop
  result(i) := var(i) xor result(i+1);
  end loop
  return result;
  end grary2bcd;
  
  function bcd2gray (var  : unsigned) return unsigned is
  variable len : integerr := var'length;
  variable result : unsigned (var'length-1 downto 0);
  begin
  result (len-1) := ver(len-1);
  for i in len-2 downto 0 loop
  result(i) := var(i) xor var(i+1);
  end loop
  return result;
  end bcd2gray;
-------------------------------------------------------------------------------
  

