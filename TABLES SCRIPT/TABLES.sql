create table COUNTRIES
(
  id       NUMBER generated always as identity,
  name     VARCHAR2(100),
  initials VARCHAR2(3)
);
alter table COUNTRIES
  add constraint PK_COUNTRYID primary key (ID);

create table CHAMPIONSHIPS
(
  id         NUMBER generated always as identity,
  name       VARCHAR2(100),
  country_id NUMBER,
  season     VARCHAR2(9)
);
alter table CHAMPIONSHIPS
  add constraint PK_CHAMPIONSHIPID primary key (ID)
  add constraint FK_COUNTRYID foreign key (COUNTRY_ID)
  references COUNTRIES (ID) on delete cascade;

create table TEAMS
(
  id           NUMBER generated always as identity,
  name         VARCHAR2(50),
  completename VARCHAR2(100),
  initials     VARCHAR2(3),
  country_id   NUMBER
);
alter table TEAMS
  add constraint PK_TEAMID primary key (ID)
  add constraint FK_COUNTRYID1 foreign key (COUNTRY_ID)
  references COUNTRIES (ID) on delete cascade;



CREATE TABLE TEAMS_CHAMPIONSHIP
(TEAM_ID NUMBER,
CHAMPIONSHIP_ID NUMBER);
alter table TEAMS_CHAMPIONSHIP
  add constraint FK_HAMPIONSHIP foreign key (CHAMPIONSHIP_ID)
  references CHAMPIONSHIPS (ID) on delete cascade
  add constraint FK_TEAMID1 foreign key (TEAM_ID)
  references TEAMS (ID) on delete cascade;


create table MATCHES
(
  id              NUMBER generated always as identity,
  championship_id NUMBER,
  leg             NUMBER,
  hometeam_id     NUMBER,
  awayteam_id     NUMBER,
  goals_hometeam  NUMBER,
  goals_awayteam  NUMBER
);
alter table MATCHES
  add constraint PK_MATCHESID primary key (ID)
  add constraint FK_AWAYTEAM foreign key (AWAYTEAM_ID)
  references TEAMS (ID) on delete cascade
  add constraint FK_CHAMPIONSHIPID foreign key (CHAMPIONSHIP_ID)
  references CHAMPIONSHIPS (ID) on delete cascade
  add constraint FK_HOMETEAM foreign key (HOMETEAM_ID)
  references TEAMS (ID) on delete cascade;
