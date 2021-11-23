create or replace noneditionable package PKG_UTILS is

  -- Author  : Felipe Carvalho Silva
  -- Created : 21/11/2021 
  -- Purpose : Useful functions and procs
  

FUNCTION CheckNumberOfTeams(pNumber in number) RETURN number;
end PKG_UTILS;
/
create or replace noneditionable package body PKG_UTILS is

FUNCTION CheckNumberOfTeams(pNumber in number) RETURN number is
  /*
    Check if league teams' number has 2, 4, 8, 16, 32 teams, and so on (always multiplying by 2).
    If it has an odd number of teams, for example, the season table won't be created.
   
   For example: if the Brazilian Championship has 16 teams, this championship will be created, and will be 15 legs (only one round)

   Function return:  
   0 = false
   1 = true
   */
  i      number;
  nAux   number;
begin
  if MOD(pNumber,2) > 0 then
      return 0;
  else  
      nAux := pNumber;   
      for i in reverse 2 .. pNumber  loop 
        if MOD(i,2) = 0 then
          nAux := nAux/2;
          dbms_output.put_line(nAux);
          exit when nAux = 2;
        end if;
      end loop;  
  end if;  
  
  if nAux = 2 then  
    return 1;
  else
    return 0;
  end if;    
end CheckNumberOfTeams;    
end PKG_UTILS;
/
