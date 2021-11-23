create or replace noneditionable package PKG_TABLESCHAMPIONSHIPS is

  -- Author  : Felipe Carvalho Silva
  -- Created : 21/11/2021 23:43:35
  -- Purpose : Make the championship's tables.

  -- Public variable declarations
  nNumberMatches     number;
  nCountMatchesWeek  number;
  nMatchedPlayed     number;

  -- Public function and procedure declarations
procedure CREATE_CHAMPIONSHIP_MATCHES(pChamp in number, 
                                      pResult out varchar2);
function MATCH_PLAYED(pChamp     in number,
                      pLeg       in Number,
                      pTeamHome  in Number,
                      pTeamAway  in Number) return number;
                      
end PKG_TABLESCHAMPIONSHIPS;
/
create or replace noneditionable package body PKG_TABLESCHAMPIONSHIPS is

procedure CREATE_CHAMPIONSHIP_MATCHES(pChamp in number, pResult out varchar2) is
  i               number;
  nMakeTable      number; 
  nNumberOfLegs   number;  
  CURSOR c(pChamp NUMBER) is
    SELECT *
      FROM (select a.HOME, a.id_home, b.AWAY, b.id_away
              from (select T.name AS home, t.id as id_home
                      from teams T, teams_championship TC
                     where TC.TEAM_ID = T.ID
                       AND TC.CHAMPIONSHIP_ID = pChamp
                     order by name) a,
                   (select T.name AS AWAY, t.id as id_away
                      from teams T, teams_championship TC
                     where TC.TEAM_ID = T.ID
                       AND TC.CHAMPIONSHIP_ID = pChamp
                       order by t.name desc) b
             where a.home <> b.away) P
     WHERE NOT EXISTS (SELECT 1
              FROM MATCHES Z
             WHERE Z.CHAMPIONSHIP_ID = 1
               AND ((Z.HOMETEAM_ID = P.id_HOME
               AND Z.AWAYTEAM_ID = P.ID_AWAY) or 
               (Z.HOMETEAM_ID = P.id_away
               AND Z.AWAYTEAM_ID = P.ID_home)))
     order by P.id_away, P.ID_home;
  rsC    c%rowtype;
  
begin

  nCountMatchesWeek := 0;      
  /*The query above will be return:
    - leg's number of matches 
    - number of legs
    - check result of the function PKG_UTILS.CheckNumberOfTeams. 
      If result wll be 0, the table won't make. 
   */
   select s.numberMatches,
          s.numberLegs,
          (select PKG_UTILS.CheckNumberOfTeams(s.teams) FROM DUAL)
     into nNumberMatches, nNumberOfLegs, nMakeTable     
     from (select count(1) / 2 as numberMatches,
                  count(1) - 1 as numberLegs,
                  count(1) as teams
             from teams_championship tc
            where tc.CHAMPIONSHIP_ID = pChamp) s;

  

  if nMakeTable = 1 then
      for i in 1..nNumberOfLegs loop 
          open c(pChamp);
          loop
            fetch c
              into rsC;
            exit when c%notfound;
            select match_played(pChamp, i, rsc.id_home, rsc.id_away)
              into nMatchedPlayed
              from dual;
            if nMatchedPlayed = 0 then
              insert into matches
                (championship_id,
                 leg,
                 hometeam_id,
                 awayteam_id,
                 goals_hometeam,
                 goals_awayteam)
              values
                (pChamp, 
                  i, 
                  rsc.id_home, 
                  rsc.id_away, 
                  0, 
                  0);
                commit;
                nCountMatchesWeek := nCountMatchesWeek+1;
              dbms_output.put_line(rsC.Home || ' X ' || rsC.Away);
            end if;
            exit when nCountMatchesWeek = nNumberMatches;           
         
          end loop;
          close c;
      end loop;  
      pResult := 'Matches created.';
  else    
      pResult := 'Matches didn''t create. Please verify championship teams.';
  end if;
  
end CREATE_CHAMPIONSHIP_MATCHES;


function MATCH_PLAYED(pChamp     in number,
                      pLeg       in Number,
                      pTeamHome  in Number,
                      pTeamAway  in Number) return number is
  nTeamsPlayed   number;

begin
   --Check if both teams played in this match week.              
    select count(1)
      into nTeamsPlayed
      from matches m
     where m.championship_id = pChamp
       and m.leg = pLeg
       and (m.hometeam_id = pTeamHome or m.awayteam_id = pTeamHome or
           m.hometeam_id = pTeamAway or m.awayteam_id = pTeamAway);

  if nTeamsPlayed > 0 then
      return 1;
  else
    --Check if both teams played in this championship, with home inverter.
    -- Case both teams didn't play, this game will be added in the matchweek.

      select count(1)  
        into nTeamsPlayed           
        from matches m
       where m.championship_id = pChamp
         and (m.awayteam_id = pTeamHome)
         and (m.hometeam_id = pTeamAway);

    if nTeamsPlayed = 0 then 
       return 0;
    else
        --Check if both teams played in this championship, without home inverter.
        select count(1)
          into nTeamsPlayed 
          from matches m
         where m.championship_id = pChamp
           and m.hometeam_id = pTeamHome
           and m.awayteam_id = pTeamAway;
        if nTeamsPlayed = 0 then    
           return 0;
        else   
           return 1;   
        end if;   
    end if;   
   
  end if;               

end MATCH_PLAYED;

end PKG_TABLESCHAMPIONSHIPS;
/
