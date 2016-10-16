(* Written by Nikolenko Vitaly
      Copyright 2003             *)

program game;
uses
  crt,g_tool,g_map,g_screen,g_input,g_enemy;
type

   TSaveIndex = 1..9;
   THero = object

     name       : string[8];
     Param      : TParams;         (*Parameters*)
     Skill      : TSkills;         (*common skills*)
     WSkill     : TWSkills;   (*weapon skills*)
     Exp: longint;
     lev: byte;
     posx,posy: byte;
     mapindex: byte;

     hp,maxhp: integer;
     mp,maxmp: integer;

     OM,DM,AM: byte;
     vz: boolean;

     speed: word;
     energy: integer;

     PIBegin: TPtrQI;
     PMBegin,PMEndb: TPtrQM;


     wdice: byte;   (* REMOVE!! *)

     procedure opendoor(ndir: Tdir);
     procedure closedoor(ndir: Tdir);
     function  getdoorc(x,y:byte):TDir;
     function  getdooro(x,y:byte):TDir;
     procedure move(ndir: TDir);
     procedure ZOS;
     procedure Create;
     procedure attack(PMonster:TPtrQM);
     procedure defend(PMonster:TPtrQM);
     procedure death;
     procedure draw;
     procedure load(_index:tsaveindex);
     procedure save(_index:tsaveindex);
   end;



var
  PMTmp     : TPtrQM;
  quit_b    : boolean;
  defcol    : byte;
  Hero    : THero;
  HPoint  : TPoint;
  Maze    : TMaze;

  c       : byte;


Procedure delmonster(PMonster:TPtrQM);
var PTmp: TPtrQM;
begin
PTmp:=PMonster;
maze.cell[PTMp^.data.posx,PTMp^.data.posy].monster:=nil; (*deleting from maze cell*)
if PTmp^.prev<>nil
then
  begin
  PTmp^.prev^.next:=PTmp^.next;
  end
else
  begin
  Hero.PMbegin:=PTmp^.next;
  end;

if PTmp^.next<>nil
then
  begin
  PTmp^.next^.prev:=PTmp^.prev;
  end;
end;

procedure THero.attack(PMonster:TPtrQM);
var aroll,droll:byte;
    weapon: byte;
begin
messagetoscreen(false,'You attack '+PMonster^.data.name);

aroll:=getdice(3,6)+Hero.om;
droll:=getdice(3,6)+PMonster^.data.dm;

messagetoscreen(false,'A='+inttostr(aroll)+' D='+inttostr(droll)+'.');

if aroll>=droll
then
  begin
  weapon:=getdice(wdice shr 4,wdice mod 16);

  messagetoscreen(false,'You hit '+PMonster^.data.name);
  if PMonster^.data.AM<weapon
  then
    begin
    messagetoscreen(false,' for '+inttostr(weapon)+' HP.');
    PMonster^.data.HP:=PMonster^.data.HP-weapon;
    if PMonster^.data.HP<=0
    then
      begin
      messagetoscreen(false,' You kill '+PMonster^.data.name+'.');
      delmonster(PMonster);
      end
    else
      begin
      messagetoscreen(false,' It has '+inttostr(PMonster^.data.HP)+'/'+inttostr(PMonster^.data.MaxHP)+'.');
      end;
    end
  else
    messagetoscreen(false,' for no damage.');
  end
else
  messagetoscreen(false,'You missed '+PMonster^.data.name);


end;




procedure THero.defend(PMonster:TPtrQM);
var aroll,droll: byte;
    weapon: byte;
begin
messagetoscreen(false,PMonster^.data.name+' attacks you ');

droll:=getdice(3,6)+Hero.dm;
aroll:=getdice(3,6)+PMonster^.data.om;

messagetoscreen(false,'A='+inttostr(aroll)+' D='+inttostr(droll)+'.');

if aroll>=droll
then
  begin
  messagetoscreen(false,PMonster^.data.name+' hits you ');
  weapon:=getdice(PMonster^.data.wdice shr 4,PMonster^.data.wdice mod 16);
  if Hero.AM<weapon
  then
    begin
    messagetoscreen(false,'for '+inttostr(weapon)+' HP. ');
    hero.hp:=hero.hp-weapon;

    if hero.HP<=0
    then
      hero.death
    else
      begin
      messagetoscreen(false,' you have '+inttostr(hero.HP)+'/'+inttostr(hero.MaxHP)+'.');
      end;
    end
  else
    messagetoscreen(false,' for no damage.');
  end
else
  messagetoscreen(false,' '+PMonster^.data.name+' missed you.');


end;




procedure DrawSidebar;
begin
(*  Name       *)
  gotoxy(2,24);
  fprint('|4-|3'+hero.name+'|4-');
{(*  DODGE/AC   *)
  textcolor(green);gotoxy(1,25);
  write('“‚/Š:',plr.KD,'/',plr.KD);
(*  STR        *)
  textcolor(green);gotoxy(16,24);
  write('‘ˆ‹:',plr.param[str]);
(*  DEX        *)
  textcolor(green);gotoxy(23,24);
  write('‹Ž‚:',plr.param[dex]);
(*  TOU        *)
  textcolor(green);gotoxy(30,24);
  write('‘‹Ž:',plr.param[con]);
(*  MAG        *)
  textcolor(green);gotoxy(37,24);
  write('Œ€ƒ:',plr.param[mag]);
(*  CHA        *)
  textcolor(green);gotoxy(44,24);
  write('•€:',plr.param[pre]);}
(*  HEALTH     *)
  if (hero.hp <= 5)
    then textcolor(red+blink)
    else textcolor(lightblue);
  gotoxy(16,25);
  write('‡„Ž:',hero.Hp,'(',hero.maxhp,')');
(*  MANA       *)
  textcolor(lightblue);gotoxy(30,25);
  write('Œ€€:',hero.MP,'(',hero.maxmp,')');
(*  EXPERIENCE *)
  textcolor(lightblue);gotoxy(44,25);
  write('Ž›’:',hero.Lev,'/',hero.exp);
(*  SPEED *)
  textcolor(lightblue);gotoxy(60,25);
  write('‘ŠŽ:',Hero.Speed:3);
(*  Energy*)
  textcolor(yellow);gotoxy(60,24);
  write('Energy:',hero.energy:4);

end;



procedure THero.Create;
begin
  randomize;
  name:='Krueger';
  posx:= 5;
  posy:= 5;
  Param[STR]:=random(5)+2;
  Param[DEX]:=random(5)+2;
  Param[REF]:=random(5)+2;
  Param[WIL]:=random(5)+2;
  Param[INT]:=random(5)+2;
  Param[PRE]:=random(5)+2;
  Param[CON]:=random(5)+2;
  Param[MOV]:=random(5)+2;
  Param[TEX]:=random(5)+2;
  Param[BOD]:=random(5)+2;
  Param[MAG]:=random(5)+2;

  maxhp:=param[bod]*5+random(5);
  maxmp:=param[mag]*3+random(3);

  HP:=maxhp;
  MP:=maxmp;

  Exp:=0;
  Lev:=1;
  wdice:=$24;
  energy:=1000;
  Speed:=110;
  end;

Procedure Enter;
begin
textcolor(lightgray);
clrscr;
window(25,11,59,17);
clrscr;
writeLn('   Curs work');
writeLn('   Written by Nikolenko Vitaly');
writeln('                Copyright 2003');

reade;
clrscr;
writeLn('      Prepare');
writeLn('      to enter');
textcolor(red);
writeLn('     THE DUNGEON!!');
reade;
window(1,1,80,25);
clrscr;

end;

procedure THero.Death;
begin
messagetoscreen(true,'');
messagetoscreen(false,'You were defeated. Better luck next time. Good Bye');
reade;
ClrScr;
gotoxy(30,12);
Write('Rest in Peace...');
reade;
halt;
end;

(*-------Get direction of CLOSED DOOR on this POINT------*)
function THero.getdoorc(x,y:byte):TDir;
var n: byte;
    dir: tdir;
begin
n:=0;

for dir:=dup to ddownright do
  if maze.cell[getx(x,dir),gety(y,dir)].value=ctdoorc (*if there is a closed door at Dir of POINT...*)
  then
    begin
    getdoorc:=dir;                  (*... then result is DIR*)
    inc(n);
    end;

if n<>1 then   (*if there is no doors or more than one around...*)
   getdoorc:=dNULL; (*...then result is NULL*)
end;



(*-------Get direction of OPENED DOOR on this POINT-------*)
function THero.getdooro(x,y:byte):TDir;
var n: byte;
    dir:tdir;
    x1,y1:byte;
begin
n:=0;

for dir:=dup to ddownright do
  begin
  x1:=getx(x,dir);
  y1:=gety(y,dir);
  if maze.cell[x1,y1].value=ctdooro (*if there is an opened door at Dir of POINT...*)
  then
    begin
    getdooro:=dir;                  (*... then result is DIR*)
    inc(n);
    end;
  end;

if n<>1 then   (*if there is no doors or more than one around...*)
   getdooro:=dNULL; (*...then result is NULL*)

end;



(*------------Door closing-----------*)
procedure THero.closedoor(ndir: Tdir);
var x,y: byte;
begin
x:=getx(posx,ndir); (*get variables for      *)
y:=gety(posy,ndir); (*more comfortable acting*)

if maze.cell[x,y].value=ctdooro
then (*if there is an opened door higher than POINT...*)
  maze.cell[x,y].value:=ctdoorc (*...then close it*)
else
  messagetoscreen(false,'|7There is no opened door.');  (*...else put error message to screen*)

hero.energy:=hero.energy-1000;
end;






(*------------Door opening-----------*)
procedure THero.opendoor(ndir: Tdir);
var x,y: byte;
begin
x:=getx(posx,ndir); (*get variables for      *)
y:=gety(posy,ndir); (*more comfortable acting*)

if maze.cell[x,y].value=ctdoorc
then                            (*if there is a closed door at POINT...*)
  maze.cell[x,y].value:=ctdooro (*...then open it*)
else
  messagetoscreen(false,'|7There is no closed door.');(*...else put error message to screen*)

hero.energy:=hero.energy-1000;
end;



function Sight(xb,yb,xe,ye:byte):byte;
var x,y,dx,dy: real;
    see,a:byte;
begin
x:=xe-xb;
y:=ye-yb;
if (abs(x)>abs(y))
then
  begin
  dx:=x/abs(x);
  dy:=y/abs(x)
  end
else
  begin
  dx:=x/abs(y);
  dy:=y/abs(y)
  end;

see:=0;
x:=xb; y:=yb;

while (x<>xe) and (y<>ye) and (see<240) do
  begin
  if not maze.cst(round(x),round(y))
  then
    see:=255;
  case maze.cell[round(x),round(y)].light of
    1   : a:=8;
    2,3 : a:=5;
    4..6: a:=4; (*dungeon*)
    7..8: a:=3;
    9   : a:=2; (*daylight*)
    0   : a:=0;
    end;

  see:=see+a;
  x:=x+dx;
  y:=y+dy
  end;
sight:=see
end;



(*------------Line of sight (straight)------------*)
procedure LOSS(x,y:byte;(*POINT*)dir:Tdir;level: byte);
var a: byte;
begin
if not CheckPtRange(x,y) then exit;

case maze.cell[x,y].light of 1   : a:=8; (*dark dungeon*)
                             2,3 : a:=5;
                             4..6: a:=4; (*dungeon*)
                             7..8: a:=3;
                             9:    a:=2; (*daylight*)
                             0:    a:=0; (*absolute darkness*)
                             end;

if level>16 then exit;(*break condition*)
if a=0 then exit;    (*you can`t see in absolute darkness*)


maze.cell[x,y].visiblenow:=true;     (*check this POINT as visible right now*)
maze.cell[x,y].visible:=true;        (*check this POINT as visible at all*)

if maze.CST(x,y) then (*if can see through this POINT then...*)
begin
LOSS(getx(x,dir),gety(y,dir),dir,level+a);   (* ...see further straight*)

case dir of
   dup   : begin

          if maze.cst(x-1,y) or not maze.cst(x-1,y-1)
          (*...if can see throught LEFT POINT, or next is wall...*)
             then LOSS(x-1,y-1,dir,level+round(a*1.5)); (*...see further straight-left*)


          if maze.cst(x+1,y) or not maze.cst(x+1,y-1)
          (*...if can see throught RIGHT POINT, or next is wall...*)
             then LOSS(x+1,y-1,dir,level+round(a*1.5)); (*...see further straight-right*)
          end;
   (*by analogy*)
   ddown : begin
          if maze.cst(x-1,y) or not maze.cst(x-1,y+1) then LOSS(x-1,y+1,dir,level+round(a*1.5));
          if maze.cst(x+1,y) or not maze.cst(x+1,y+1) then LOSS(x+1,y+1,dir,level+round(a*1.5));
          end;
   dleft : begin
          if maze.cst(x,y-1) or not maze.cst(x-1,y-1) then LOSS(x-1,y-1,dir,level+round(a*1.5));
          if maze.cst(x,y+1) or not maze.cst(x-1,y+1) then LOSS(x-1,y+1,dir,level+round(a*1.5));
          end;
   dright: begin
          if maze.cst(x,y-1) or not maze.cst(x+1,y-1) then LOSS(x+1,y-1,dir,level+round(a*1.5));
          if maze.cst(x,y+1) or not maze.cst(x+1,y+1) then LOSS(x+1,y+1,dir,level+round(a*1.5));
          end;
   end;
end;
end;




(*-------------Line of sight (diagonal)-------------*)

procedure LOSD(x,y:byte;(*POINT*) ndir:tdir; level:byte);
var a: byte;
begin

if not CheckPtRange(x,y) then exit;
case maze.cell[x,y].light of 1   : a:=8;
                             2,3 : a:=5;
                             4..6: a:=4; (*dungeon*)
                             7..8: a:=3;
                             9   : a:=2; (*daylight*)
                             0   : a:=0; (*absolute darkness*)
                             end;

if level>10 then exit;(*break condition*)
if a=0 then exit;    (*you can`t see in absolute darkness*)


maze.cell[x,y].visibleNOW:=true;(*check this POINT as visible right now*)
maze.cell[x,y].visible:=true;   (*check this POINT as visible at all*)


if maze.cst(x,y)  (*if can see through this*)
then
  losd(getx(x,ndir),gety(y,ndir),ndir,level+a);  (*POINT then see further*)
end;


procedure Thero.draw;
begin
charxy(2,2,defcol,posx,posy);
end;


procedure test1;
var n,n1: byte;
begin
for n:=1 to 80 do
  for n1:=1 to 20 do
    if maze.cell[n,n1].visible
      then maze.writemp(n,n1);
end;


(*----------Zone of sight-------------*)
procedure THero.ZOS;
var n,n1: shortint;
    x,y,k: byte;
begin
x:=posx;
y:=posy;

{if maze.cell[x,y].light=0
then
  maze.cell[x,y].visible:=false
else
  begin
  maze.cell[x,y].visible:=true;    (*mark start point as VISIBLE at all if is illuminated*)
  maze.cell[x,y].visiblenow:=true; (*mark start point as VISIBLE right now*)
  end;


LOSD(x+1,y-1,dupright,1);
LOSD(x+1,y+1,ddownright,1);
LOSD(x-1,y+1,ddownleft,1);
LOSD(x-1,y-1,dupleft,1);

LOSS(x,y-1,dup,1);
LOSS(x,y+1,ddown,1);
LOSS(x-1,y,dleft,1);
LOSS(x+1,y,dright,1);}

(*-----------Draw, clear ZOS-------*)
for n:=x-11 to x+11 do
  for n1:=y-11 to y+11 do
    if CheckPtRange(n,n1)
    then
      if sight(x,y,n,n1)<11
      then
        begin
        maze.cell[n,n1].visible:=true;
        maze.cell[n,n1].visiblenow:=true;
        end;

for n:=x-11 to x+11 do
  for n1:=y-11 to y+11 do
    if CheckPtRange(n,n1)
    then
      begin
        if maze.cell[n,n1].visible      (*if point is visible at all*)
        then
          begin
          maze.writemp(n,n1);
           {}      (*if point is visible right now*)
          if maze.cell[n,n1].visiblenow then
            begin
            if maze.cell[n,n1].monster<>nil
            then
              begin
              maze.cell[n,n1].monster^.data.draw(defcol)
              end
            else
              if (n=hero.posx) and (n1=posy)
              then
                Hero.draw;                     (*draw player*)

            maze.cell[n,n1].visiblenow:=false (*clear ZOS*)
            end
          end

        else
          charxy(0,0,0,n,n1)                (* if cell is not visible at all - clear*)
      end;
end;


procedure THero.Save(_index:tsaveindex);
var fil: file;
begin
assign(fil,'hero.sav');
rewrite(fil,1);
with hero do
  begin
  blockwrite(fil,name,sizeof(name));
  blockwrite(fil,param,sizeof(param));
  blockwrite(fil,skill,sizeof(skill));
  blockwrite(fil,wskill,sizeof(wskill));

  blockwrite(fil,exp,4);
  blockwrite(fil,lev,1);
  blockwrite(fil,posx,1);
  blockwrite(fil,posy,1);
  blockwrite(fil,mapindex,1);

  blockwrite(fil,hp,2);
  blockwrite(fil,maxhp,2);
  blockwrite(fil,mp,2);
  blockwrite(fil,maxmp,2);

  blockwrite(fil,OM,1);
  blockwrite(fil,DM,1);
  blockwrite(fil,AM,1);

  blockwrite(fil,speed,2);
  blockwrite(fil,energy,2);

  end;
close(fil);
end;


procedure THero.Load(_index:tsaveindex);
var fil: file;
begin
assign(fil,'hero.sav');
rewrite(fil,1);
with hero do
  begin
  blockread(fil,name,sizeof(name));
  blockread(fil,param,sizeof(param));
  blockread(fil,skill,sizeof(skill));
  blockread(fil,wskill,sizeof(wskill));

  blockread(fil,exp,4);
  blockread(fil,lev,1);
  blockread(fil,posx,1);
  blockread(fil,posy,1);
  blockread(fil,mapindex,1);

  blockread(fil,hp,2);
  blockread(fil,maxhp,2);
  blockread(fil,mp,2);
  blockread(fil,maxmp,2);

  blockread(fil,OM,1);
  blockread(fil,DM,1);
  blockread(fil,AM,1);

  blockread(fil,speed,2);
  blockread(fil,energy,2);

  end;
close(fil);
end;



(*Player`s MOVEMENT*)
procedure THero.move(ndir: Tdir);
var n,n1: shortint;
    x,y,k: byte;
begin

if ndir=dnull
then
  exit;

if ndir=dhere
then
  begin
  Energy:=energy-1000;
  exit
  end;

messagetoscreen(true,'');

x:=getx(posx,ndir);
y:=gety(posy,ndir);

if (x>0)and(x<=80)and(y>0)and(y<=20) then
begin

case maze.cell[x,y].value of
     ctstairu,
     ctstaird,
     ctground,
     ctdooro: begin

            if maze.cell[x,y].monster=nil then
              begin
              posx:=x;
              posy:=y;
              Energy:=energy-round(100000/speed);
              end
            else
              begin

              (*===========MONSTER FIGHT==========*)
              attack(maze.cell[x,y].monster);
              Energy:=energy-round(100000/speed);   (*CHANGE w/skill*)

              end;
            end;

     ctwall : begin
              messagetoscreen(false,'|4‚¨ ©¤¥â¥ ã áâi­ã.|7 ');
              Energy:=energy-1000;
              end;

     ctdoorc: begin
            if askyn('|4„¢¥ài § ç¨­¥­i|7. ‚i¤ç¨­¨â¨ ¤¢¥ài') then (*...ask if you don`t want to open this door,*)
                 begin
                 hero.opendoor(ndir);   (*...if yes then open door*)
                 energy:=energy-1000;
                 messagetoscreen(true,'');
                 end
            end

     end

end
end;




procedure MonsterMove(PMonster: TPtrQM);
var dir,mdir: tdir;
     s,s1: word;
    mx,my: byte;
    x,y: byte;
begin
with PMonster^.data do
  begin

  if (abs(posx-Hero.posx)<=1) and (abs(posy-Hero.posy)<=1)  (*if Monster is near - attack*)
    then hero.defend(PMonster)
  else
    begin

    mdir:=dhere;
    mx:=posx;
    my:=posy;

    if (sight(posx,posy,hero.posx,hero.posy)<10) or                  (* if Monster sees Hero *)
       ((abs(posx-Hero.posx)<=3) and (abs(posy-Hero.posy)<=3))  (* or hears Hero - run into*)

    then                                                        (* then Hunt hero*)
      begin
      s:=sqr(hero.posx-posx)+sqr(hero.posy-posy);
      for dir:=dup to ddownright do
        begin
        x:=getx(posx,dir);
        y:=gety(posy,dir);
        if maze.cmt(x,y) and (maze.cell[x,y].monster=nil)  (* if Cell is free*)
        then
          begin
          s1:=sqr(hero.posx-x)+sqr(hero.posy-y);           (* find the best way - closest way*)
          if s1<s
          then
            begin
            mx:=x;
            my:=y;
            mdir:=dir;
            s:=s1
            end
          end
        end
      end

    else                                    (* else move randomly *)
      begin
      s:=0;
      for dir:=dup to ddownright do
        begin
        x:=getx(posx,dir);
        y:=gety(posy,dir);
        if maze.cmt(x,y) and (maze.cell[x,y].monster=nil)  (* if Cell is free*)
        then
          begin
          s1:=random(8)+2;                    (* find the random way*)
          if s1>s then
            begin
            mx:=x;
            my:=y;
            mdir:=dir;
            s:=s1
            end
          end
        end
      end;

    maze.cell[mx,my].monster:=PMonster;             (* the Move itself *)
    maze.cell[posx,posy].monster:=nil;
    posx:=mx;
    posy:=my
    end
  end

end;


procedure MakeDungeon(Enter: boolean);
begin
  maze.Generate(5,3);(*generating new maze *)
  if enter then maze.GetEnterPoint(Hpoint) (*if descending then put hero in enter point*)
           else maze.GetExitPoint(Hpoint); (*if ascending then put hero in exit point*)


  hero.posx:=Hpoint.x;
  hero.posy:=Hpoint.y;

(*=-----------Screen-------------=*)
  textcolor(lightgray);
  textbackground(black);
end;


procedure helpwindow;
begin
textcolor(lightgray);
Clrscr;
gotoxy(2,10);
writeln('Help window');
writeln('Press Shift+Q to quit');
repeat

until readkey='Q';
end;

procedure drawmenu;
begin
textcolor(lightgray);
Clrscr;
gotoxy(2,10);
writeln('Choose action:');
writeln('[N]ew game');
writeln('[L]oad game');
writeln('[H]elp');
writeln('[Q]uit');
end;



Procedure Menu;
var ena: boolean;
begin
drawmenu;
repeat
  ena:=false;
  case readkey of
    'n':begin
        hero.Create;
        hero.save(1);
        ena:=true
        end;
    'l':begin
        ena:=true
        end;
    'h':begin

        helpwindow;
        drawmenu;
        end;
    'q':halt;
    end;
until ena;
clrscr
end;


(*PROGRAM*)
BEGIN
(*=---------Initialization--------=*)
cursoroff;
randomize;


(*=--------Greetings screens------=*)
enter;
menu;




drawsidebar;
defcol:=0;



maze.load(2);





(*==========MONSTER========*)

{new(PMTmp);
PMTmp^.next:=nil;
PMTmp^.prev:=nil;
Hero.PMBegin:=PMTmp;
with PMTmp^.data do
  begin
  create(1,1);
  posx:=hero.posx+1;
  posy:=hero.posy+1;
  maze.cell[posx,posy].monster:=PMTmp;
  wdice:=$13;
  end;}

hero.ZOS;
quit_b:=false;

(*=--------Main loop----------=*)
repeat
    c:=ReadCommand;
    messagetoscreen(true,''); (*clearing buffer*)

    (*-----------Beginning of TURN-----------*)


    case c of
      C_TEST: Test1;

      c_cancel          : Hero.Move(dNULL);

      C_UP        , C_8 : Hero.Move(dUP);
      C_DOWN      , C_2 : Hero.Move(dDOWN);
      C_LEFT      , C_4 : Hero.Move(dLEFT);
      C_RIGHT     , C_6 : Hero.Move(dRIGHT);
      C_UP_LEFT   , C_7 : Hero.Move(dUPLEFT);
      C_UP_RIGHT  , C_9 : Hero.Move(dUPRIGHT);
      C_DOWN_LEFT , C_1 : Hero.Move(dDOWNLEFT);
      C_DOWN_RIGHT, C_3 : Hero.Move(dDOWNRIGHT);
                    C_5 : Hero.Move(dHere);

      C_QUIT: if askyn('Want to quit')
              then
                begin
                quit_b:=true;
                hero.save(1);
                end;

      C_ZOS: begin
             maze.ViewZOS:=not maze.ViewZOS; (*flip Viewing Zone of sight mode*)
             hero.vz:=not hero.vz;
             if hero.vz then defcol:=7 else defcol:=0;
             hero.zos;
             end;
      C_OPEN_DOOR:
             begin
             if (hero.getdoorc(hero.posx,hero.posy)=dNULL)
             (*if there isn`t a closed door around hero*)

             then hero.opendoor(askdir('Where do yo want to open door'))
             (*...then ask direction*)

             else hero.opendoor(hero.getdoorc(hero.posx,hero.posy));
             (*...else open door at direction*)
             end;

      C_CLOSE_DOOR:
             begin
             if (hero.getdooro(hero.posx,hero.posy)=dNULL)
             (*if there isn`t an opened door around hero*)

             then hero.closedoor(askdir('Where do yo want to open door'))
             (*...then ask direction*)


             else hero.closedoor(hero.getdooro(hero.posx,hero.posy));
             (*...else close door at direction*)
             end;


      C_GO_UP:              (*REMAKE!!!*)
             begin
             maze.GetEnterPoint(HPoint);
             if (hpoint.x=hero.posx) and (hpoint.y=hero.posy) then

              begin
              MakeDungeon(false);
              {messa'You ascend';}

              end

             else messagetoscreen(true,'There is no ascention');
             end;


      C_GO_DOWN:
             begin

             maze.GetExitPoint(HPoint);

             if (hpoint.x=hero.posx) and (hpoint.y=hero.posy) then
              begin
              MakeDungeon(true);
              {message:=message+'You descend';}

              end
             else messagetoscreen(true,'There is no descention');

             end;



      end;



    if hero.energy<=0
    then
      begin

      (*_______________End of Turn____________________*)
      hero.energy:=hero.energy+1000;

      (*============MONSTERS MOVES HERE============*)
      PMTmp:=Hero.PMBegin;
      while PMTmp<>nil do
        begin
        MonsterMove(PMTmp);
        PMTmp:=PMTmp^.next;
        end;


      end;




    hero.zos;        (*calculate Zone of Sight*);
    drawsidebar;
    case maze.cell[hero.posx,hero.posy].value of
              ctdooro   : messagetoscreen(false,'opened door here, man! ');
              ctstairu  : messagetoscreen(false,'There is a stairway leading up. ');
              ctstaird  : messagetoscreen(false,'There is a stairway leading down. ');
              end;


    until quit_b;

   (*_____________________________________________*)

END.