(* Written by Nikolenko Vitaly
      Copyright 2003             *)

program game;

{$PACKRECORDS 1}
{$PACKENUM 1}  


uses
  crt,g_tool,g_map,g_screen,g_input,g_enemy,zastavka;
type

   TSaveIndex = 1..9;
   THero = object

     name       : string[8];
     Param      : TParams;         (*Parameters*)
     WSkill     : TWSkills;   (*weapon skills*)
     Armor      : Array [itarmorhead..itarmorback] of TPtrQI;

     LHand,RHand: TPtrQI;
     Ring       : TPtrQI;
     Ammo       : TPtrQI;
     MHand      : TPtrQI;

     SightRange: byte;
     Exp: longint;
     lev: byte;
     posx,posy: byte;
     mapindex: byte;



     hp,maxhp: integer;
     mp,maxmp: integer;

     OV,DV,AV: shortint;

     vz: boolean;

     speed: word;
     energy: integer;

     PIBegin: TPtrQI;
     PMBegin,PMEndb: TPtrQM;


     function  getdoorc(x,y:byte):TDir;
     function  getdooro(x,y:byte):TDir;
     procedure DropItem(IPtr: TPtrQI);
     procedure PickItem(IPtr: TPtrQI);
     procedure DrawSidebar;
     procedure opendoor(ndir: Tdir);
     procedure closedoor(ndir: Tdir);
     procedure move(ndir: TDir);
     procedure ZOS;
     procedure Create;
     procedure attack(PMonster:TPtrQM);
     procedure defend(PMonster:TPtrQM);
     procedure drinkpotion(Pitem: TPtrQI);
     procedure death;
     procedure draw;
     procedure Updateparams;
     procedure load;
     procedure save;
   end;



var
  MPTmp     : TPtrQM;
  IPTmp     : TPtrQI;
  quit_b    : boolean;
  Hero    : THero;
  Maze    : TMaze;

  c       : byte;
  _k,_k1: byte;




procedure THero.drinkpotion(Pitem: TPtrQI);
begin
if pitem<>nil
then
  begin
  messagetoscreen(false,'You drink '+pitem^.data.name+', ');
  case Pitem^.data.potiontype of
    0: begin
       if hp+Pitem^.data.ppower>maxhp
       then
	 hp:=maxhp
       else
	 hp:=hp+Pitem^.data.ppower;
       messagetoscreen(false,'you feel better. ')
       end;
    1: begin
       if mp+Pitem^.data.ppower>maxmp
       then
         mp:=maxmp
       else
         mp:=mp+Pitem^.data.ppower;
       messagetoscreen(false,'you feel restored. ')
       end;
    end;
  if pitem^.quantity>1
  then
    dec(pitem^.quantity)
  else
    begin
    delitem(pibegin,pitem);
    dispose(pitem)
    end;
  end;
end;

procedure THero.DropItem(IPtr: TPtrQI);
var PTmp,ptmp1: TPtrQI;
    P0: TPtrQI;
    k: byte;
begin
if IPtr<>nil
then
  begin
  if iptr^.quantity>1
  then
    begin
    k:=askquant('Enter quantity',iptr^.quantity);
    if k=0
      then
        exit
      else
        if k<iptr^.quantity
        then
          begin
          new(p0);
	  p0^.data:=iptr^.data;
          p0^.quantity:=k;
	  iptr^.quantity:=iptr^.quantity-k;
          insertitem(maze.cell[posx,posy].items,p0);
          messagetoscreen(false,'You dropped '+inttostr(k)+' '+iptr^.data.name+'. ');
          exit
          end;
    end;

  delitem(pibegin,IPtr);
  insertitem(maze.cell[posx,posy].items,Iptr);
  messagetoscreen(false,'You dropped '+iptr^.data.name+'. ')
  end
end;

procedure THero.Updateparams;
var IType: TItemtype;

   procedure updateparam(par: TPtrQI);
   begin
   if par<>nil
   then
     case par^.data.itemtype of
       it1weapon,
       it2weapon,
       ittweapon,
       itrweapon: begin
                  ov:=ov+par^.data.wtohit;
                  dv:=dv+par^.data.wdef;
                  end;

       itShield,
       itarmorHead,
       itarmorBodyHi,
       itarmorBodyLo,
       itarmorLegs,
       itarmorArms,
       itarmorPalm,
       itarmorBelt,
       itarmorBack: begin
                    ov:=ov+par^.data.atohit;
                    dv:=dv+par^.data.adef;
                    av:=av+par^.data.arm;
                    end;
       end;
   end;
begin
sightrange:=50;
ov:=param[ref,0]+param[ref,1];
av:=0;
dv:=param[dex,0]+param[dex,1];
for itype:=ITarmorHead to itarmorback do
  updateparam(armor[itype]);
updateparam(LHand);
updateparam(RHand);
speed:=100+10*(param[mov,1]+param[mov,1]);
end;


procedure THero.PickItem(IPtr: TPtrQI);
var PTmp,ptmp1: TPtrQI;
    P0: TPtrQI;
    _s: string;
    k: word;
begin
if IPtr<>nil
then
  begin
  if iptr^.quantity>1
  then
    begin
    k:=askquant('Enter quantity',iptr^.quantity);
    if k=0
      then
        exit
      else
        if k<iptr^.quantity
        then
          begin
          new(p0);
          p0^.data:=iptr^.data;
	  p0^.quantity:=k;
	  iptr^.quantity:=iptr^.quantity-k;
          insertitem(pibegin,p0);
          messagetoscreen(false,'You picked up '+inttostr(k)+' '+iptr^.data.name+'. ');
          exit
          end;
    end;
  messagetoscreen(true,'You picked up '+iptr^.data.name+'. ');
  delitem(maze.cell[posx,posy].items,IPtr);
  insertitem(pibegin,Iptr)
  end;
(*TRANSLATE*)
end;

procedure THero.attack(PMonster:TPtrQM);
var aroll,droll:byte;
    x,y: byte;
    weapon: byte;
    _dm: byte;
    _ov: byte;
    _wskill: TWSKill;
    wdice: byte;
    pitem: TPtrQI;
begin
wdice:=$24;
_Wskill:=wsunarmed;
_dm:=0;
if rhand<>nil
then
  begin
  _wskill:=rhand^.data.wskill;
  Wdice:=rhand^.data.damdice;
  _dm:=rhand^.data.wdam;
  end;
energy:=energy-1000+wskill[_wskill,0]*60;
_dm:=_dm+weapDM[wskill[_wskill,0]]+param[str,0]+param[str,1];
_ov:=weapOV[wskill[_wskill,0]]+param[ref,0]+param[ref,1];
messagetoscreen(false,'You attack '+PMonster^.data.name+', ');
aroll:=getdice($36)+Hero.OV+_ov;
droll:=getdice($36)+PMonster^.data.dv;
if aroll>=droll
then
  begin
  (* hit monster *)
  inc(wskill[_wskill,1]);         (*improve skill*)
  if (wskill[_wskill,1]>weapxp[wskill[_wskill,0]+1])and(wskill[_wskill,0]<10)
  then
    (*level-up*)
    begin
    inc(wskill[_wskill,0]);
    wskill[_wskill,1]:=0;
    messagetoscreen(false,'you advanced to level |9'+inttostr(wskill[_wskill,0])+'|7 in|9 '+wskillname[_wskill]+'|7More...');
    readcommand
    end;
  weapon:=getdice(wdice)+_dm;
  messagetoscreen(false,'you hit '+PMonster^.data.name);
  if PMonster^.data.AV<weapon
  then
    begin
    messagetoscreen(false,' for '+inttostr(weapon)+' HP. ');
    PMonster^.data.HP:=PMonster^.data.HP-weapon;
    if PMonster^.data.HP<=0
    then
      begin
      (* Monster's death *)
      x:=pmonster^.data.posx;
      y:=pmonster^.data.posy;
      messagetoscreen(false,'You kill '+PMonster^.data.name+'. ');
      maze.cell[x,y].monster:=nil;
      if random(50)<25
      then
	begin
	New(PItem);
	loaditem(Pitem^.data,pmonster^.data.item1);
	Pitem^.quantity:=1;
	Pitem^.next:=nil;
	insertitem(maze.cell[x,y].items,pitem)
	end;
      if random(50)<13
      then
	begin
	New(PItem);
	loaditem(Pitem^.data,pmonster^.data.item2);
	Pitem^.quantity:=1;
	Pitem^.next:=nil;
	insertitem(maze.cell[x,y].items,pitem)
	end;
      if random(50)<6
      then
	begin
	New(PItem);
	loaditem(Pitem^.data,pmonster^.data.item3);
	Pitem^.quantity:=1;
	Pitem^.next:=nil;
	insertitem(maze.cell[x,y].items,pitem)
	end;
      delmonster(Hero.PMBegin,PMonster)
      end
    end
  else
    messagetoscreen(false,' for no damage.');
  end
else
  (*miss monster*)
  messagetoscreen(false,'You missed '+PMonster^.data.name);
end;

procedure THero.defend(PMonster:TPtrQM);
var aroll,droll: byte;
    weapon: byte;
    _dv   : byte;
    _wskill: twskill;
begin
(*TRANSLATE*)
_wskill:=wsunarmed;
if rhand<>nil
then
  begin
  _wskill:=rhand^.data.wskill;
  end;
_dv:=weapdv[wskill[_wskill,0]];
messagetoscreen(false,PMonster^.data.name+' attacks you. ');
droll:=getdice($36)+Hero.DV+_dv;
aroll:=getdice($36)+PMonster^.data.oV;
if aroll>=droll
then
  begin
  messagetoscreen(false,PMonster^.data.name+' hits you ');
  weapon:=getdice(PMonster^.data.wdice);
  if Hero.AV<weapon
  then
    begin
    messagetoscreen(false,'for '+inttostr(weapon)+' HP. ');
    hero.hp:=hero.hp-weapon;
    if hero.HP<=0
    then
      hero.death
    end
  else
    messagetoscreen(false,' for no damage.');
  end
else
  begin
  (* monster missed*)
  inc(wskill[wsshield,1]);
  if (wskill[wsshield,0]>weapXP[wskill[wsshield,1]+1]) and(wskill[wsshield,0]<10)
    then
    begin
    (*Level-up*)
    inc(wskill[wsshield,0]);
    wskill[wsshield,1]:=0;
    messagetoscreen(false,'You advanced to level|9 '+inttostr(wskill[wsshield,0])+'|7 in|9 "Shields"|7.More... ');
    readcommand;
    end;
  messagetoscreen(false,' '+PMonster^.data.name+' missed you.');
  end;
end;

procedure THero.DrawSidebar;
var dhp,dmp,_hp,_mp: real;
    k: byte;
begin
window(1,24,80,25);
(*  Name       *)
gotoxy(1,1);
fprint('|4-|3'+hero.name+'|4- ');
write('Level_ ',lev:2);
(*  DV,AV *)
gotoxy(37,1);
fprint('DV/AV ['+inttostr(dv)+','+inttostr(av)+']');
(* hits, mana*)
dhp:=maxhp/15;
dmp:=maxmp/15;
_hp:=0;
_mp:=0;
for k:=1 to 15 do
  begin
  if _hp>hp
  then
    charxy(176,4,0,64+k,21)  (**)
  else
    charxy(177,4,0,64+k,21);
  if _mp>mp
  then
    charxy(176,1,0,64+k,22)
  else
    charxy(177,1,0,64+k,22);
  _hp:=_hp+dhp;
  _mp:=_mp+dmp;
  end;
gotoxy(52,1);
textcolor(lightgray);
write('Hits:');
textcolor(red);
write(hp:4,'/',maxhp:3);
gotoxy(52,2);
textcolor(lightgray);
write('Mana:');
textcolor(blue);
write(mp:4,'/',maxmp:3);
window(1,1,80,25);
end;

procedure THero.Create;
var itype: titemtype;
    ws:    TWSkill;
    _item: TPtrQI;
begin
  randomize;
  name:='Hero';
  posx:= 9;
  posy:= 2;
  Param[STR,0]:=random(5)+2;
  Param[DEX,0]:=random(5)+2;
  Param[REF,0]:=random(5)+2;
  Param[WIL,0]:=random(5)+2;
  Param[INT,0]:=random(5)+2;
  Param[CON,0]:=random(5)+2;
  Param[MOV,0]:=random(5)+2;
  Param[MAG,0]:=random(5)+2;
  Param[STR,1]:=0;
  Param[DEX,1]:=0;
  Param[REF,1]:=0;
  Param[WIL,1]:=0;
  Param[INT,1]:=0;
  Param[CON,1]:=0;
  Param[MOV,1]:=0;
  Param[MAG,1]:=0;
  for ws:=wsunarmed to wstwohand do
    begin
    WSkill[ws,0]:=0;
    WSkill[ws,1]:=0;
    end;
  maxhp:=param[con,0]*5+random(5);
  maxmp:=param[mag,0]*3+random(3);
  HP:=maxhp;
  MP:=maxmp;
  Exp:=0;
  Lev:=1;
  energy:=1000;
  Speed:=110;
  SightRange:=10;
  posx:=9;
  posy:=2;
  mapindex:=0;
  for itype:=itarmorhead to itarmorback do
    armor[itype]:=nil;
  pibegin:=nil;
  pmbegin:=nil;
  rhand:=nil;
  lhand:=nil;
  ring:=nil;
  ammo:=nil;
  new(_item);
  loaditem(_item^.data,0);
  rhand:=_item;
  end;

Procedure Enter;
begin
textcolor(lightgray);
clrscr;
window(25,11,59,17);
clrscr;
clrscr;
writeLn('      Prepare');
writeLn('      to enter');
textcolor(red);
writeLn('     THE DUNGEON!!');
reade;
window(1,1,80,25);
clrscr;
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
(*TRANSLATE*)
hero.energy:=hero.energy-1000;
end;






(*------------Door opening-----------*)
procedure THero.opendoor(ndir: Tdir);
var x,y: byte;
begin
x:=getx(posx,ndir); (*get variables for      *)
y:=gety(posy,ndir); (*more comfortable acting*)
(*TRANSLATE*)
if maze.cell[x,y].value=ctdoorc
then                            (*if there is a closed door at POINT...*)
  maze.cell[x,y].value:=ctdooro (*...then open it*)
else
  messagetoscreen(false,'|7There is no closed door.');(*...else put error message to screen*)

hero.energy:=hero.energy-1000;
end;



function Sight(xb,yb,xe,ye:byte):word;
var see,x,y,dx,dy: real;
    a:byte;
begin
x:=xe-xb;
y:=ye-yb;
if (y=0) and (x=0)
then
  begin
  if maze.cell[xe,ye].light=0
  then
    sight:=250
  else
    sight:=0;
  exit
  end;


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


repeat
  if not maze.cst(round(x),round(y))
  then
    see:=301
  else
    begin
    case maze.cell[round(x),round(y)].light of
      0:see:=see+60;
      1:see:=see+40;
      2:see:=see+25;
      3:see:=see+20;
      4:see:=see+16;
      5:see:=see+12;
      6:see:=see+10;
      7:see:=see+8;
      8:see:=see+6;
      9:see:=see+5;
      end;
    x:=x+dx;
    y:=y+dy
    end
until ((abs(x-xe)<1) and (abs(y-ye)<1)) or (see>=300);
see:=see*sqrt(sqr(dx)+sqr(dy));
sight:=round(see)
end;



(*============================SCREENS===============*)
(*============================SCREENS===============*)
(*============================SCREENS===============*)
(*============================SCREENS===============*)
procedure WSkillScreen;
var k: byte;
   _wskill: TWskill;
begin
clrscr;
fprint(
  '|6-------------------------------WEAPON SKILLS-----------------------------------');
gotoxy(5,24);
  fprint('|6Esc |7- Exit');
gotoxy(21,5);
fprint('|9 Level    OV      DV    Damage');
gotoxy(1,6);
k:=6;
for _wskill:=wsunarmed to wsthrown do
  begin
  gotoxy(1,k);
  fprint('|9'+WSkillName[_wskill]+'|7');
  gotoxy(20,k);
  fprint(':   '+inttostr(Hero.WSkill[_wskill,0])+'|7');
  gotoxy(28,k);
  fprint(':  +'+inttostr(weapOV[hero.WSkill[_wskill,0]]));
  gotoxy(36,k);
  fprint(':  +'+inttostr(weapDV[hero.WSkill[_wskill,0]]));
  gotoxy(44,k);
  fprint(':  +'+inttostr(weapDM[hero.WSkill[_wskill,0]])+'  :');
  inc(k);
  end;
k:=readcommand;
maze.draw;
messagetoscreen(true,'');
end;


function InvenScreen(_PBegin: TPtrQI;filter: Titemtype;screentype: TInvenScreen):TPtrQI;
const InvH = 14;
var ch: char;
    PTmp: TPtrQI;
    totw: longint;
    k,y: byte;
    kabeg,kaend: byte;
    kbeg,kcur,quant: byte;
    maxy: byte;
    _item: array[0..InvH+1] of byte;
    s: string[50];
    nostr: string[40];

  procedure redraw;
  var k,k1: byte;
      itype: TItemType;
  begin
  itype:=itnone;
  window(1,3,80,20);
  clrscr;
  window(1,1,80,25);
  for k:=0 to invh+1 do
    _item[k]:=0;
  k:=0;
  k1:=0;
  quant:=0;
  ptmp:=_pbegin;
  while (PTmp<>nil) and (k<Invh) do
  begin
  inc(k1);
  if (k1>=kbeg) and (k1<kaend)
  then
    begin
    if itype<>ptmp^.data.itemtype
    then
      begin
      gotoxy(3,k+6);
      inc(k);
      _item[k]:=0;
      itype:=ptmp^.data.itemtype;
      case itype of
        itjunk        : fprint('_12Misc');
	itShield      : fprint('_12Shields');
	it1weapon     : fprint('_12One-hand weapons');
        it2weapon     : fprint('_12Two-hand weapons');
        ittweapon     : fprint('_12Throwing weapons');
        itrweapon     : fprint('_12Ranged weapons');
        itarmorHead   : fprint('_12Helmets');
        itarmorBodyHi : fprint('_12Body heavy armor');
        itarmorBodyLo : fprint('_12Body light armor');
        itarmorLegs   : fprint('_12Boots/Leggings');
        itarmorArms   : fprint('_12Armings');
        itarmorPalm   : fprint('_12Gloves');
        itarmorBelt   : fprint('_12Belts');
        itarmorBack   : fprint('_12Cloaks');
	itmoney       : fprint('_12Money');
        itammo        : fprint('_12Ammo');
        itfood        : fprint('_12Food');
        itwand        : fprint('_12Wands');
        itpotion      : fprint('_12Potions');
        itring        : fprint('_12Rings');
        end;
      end;
      gotoxy(8,k+6);
      s:=Fullname(ptmp^.data);
    if ptmp^.quantity>1
    then
      s:=s+', '+inttostr(ptmp^.quantity)+' it.';
    fprint('|7'+s);

    gotoxy(72,k+6);
    if ptmp^.quantity>1
    then
      write(ptmp^.quantity*ptmp^.data.weight:6,' kg')
    else
      write(ptmp^.data.weight:6,' kg');
    inc(k);
    inc(quant);                                           (*quantity of items*)
    _item[k]:=length(s)
    end;
  ptmp:=ptmp^.next;
  end;
  maxy:=k;
  gotoxy(5,4);
  write('Total weight ',totw);
  if kbeg>kabeg
  then
    begin
    textcolor(yellow);
    gotoxy(8,5);
    write(#30+#30+#30+#30+#30+#30+#30+#30+#30+#30+#30);
    end
  else
    begin
    textcolor(7);
    gotoxy(8,5);
    write('-----------')
    end;

  if kbeg+quant+1<kaend
  then
    begin
    textcolor(yellow);
    gotoxy(8,21);
    write(#31+#31+#31+#31+#31+#31+#31+#31+#31+#31+#31)
    end
  else
    begin
    textcolor(7);
    gotoxy(8,21);
    write('-----------')
    end;
  end;


  procedure markitem;
  var k: byte;
  begin
  for k:=1 to _item[y] do
    mark(7+k,y+4);
  end;

  procedure unmarkitem;
  var k: byte;
  begin
  for k:=1 to _item[y] do
    unmark(7+k,y+4);
  end;


begin
clrscr;
Invenscreen:=nil;

case screentype of
  isinven: begin
           s:='------Inventory-------';
           nostr:='You are carrying notning';
           end;

  isdrop:  begin
           s:='-Choose item to drop--';
           nostr:='You are carrying notning';
           end;
  ispick:  begin
	   s:='Choose item to pick up';
           nostr:='Nothing here';
           end;
 isdrink:  begin
           s:='Choose potion to drink';
           nostr:='You have no potions to drink';
           end;
  iswear:  begin
           s:='Choose item to wear';
           nostr:='You have nothing to wear';
           end;
  isuse:   begin
           s:='Choose item to use';
           nostr:='You have notning to use';
           end;
  iswand:  begin
           s:='Choose wand to zap';
           nostr:='You have no wands';
           end;
  end;
fprint(
'|6----------------------------'+s+'------------------------------');
gotoxy(5,24);
fprint('|6'+#24#25+' |7- move cursor |6PgUp,PgDn - |7Scroll |6Enter |7- Select |6Esc |7- Exit');
k:=0;
quant:=0;
kbeg:=0;
kcur:=0;
kabeg:=0;
kaend:=0;
PTMP:=_PBegin;
totw:=0;
while (PTmp<>nil) do
  with ptmp^.data do
    begin
    inc(k);
    if (filter=itnone)or
       (filter=itemtype)or
       (((itemtype=it2weapon)or(itemtype=itrweapon)or(itemtype=ittweapon))and(filter=it1weapon))
    then
      begin
      if kabeg=0
      then
        kabeg:=k;

      totw:=totw+ptmp^.quantity*ptmp^.data.weight;
      end
    else
      if kabeg>0
      then
        begin
        kaend:=k;
        break
        end;

    ptmp:=ptmp^.next
    end;


if (kaend=0) and (kabeg>0)
then
  kaend:=k+1;

kcur:=kabeg;
kbeg:=kabeg;
redraw;

if quant=0
then
  begin
  kbeg:=0;
  gotoxy(3,6);
  fprint('|7'+nostr);
  end
else
  begin
  y:=2;
  markitem;
  end;
repeat
  k:=readcommand;
  case k of
  c_up_right:    begin
                 if (kbeg-quant)<kabeg
                 then
                   kbeg:=kabeg
                 else
                   kbeg:=kbeg-quant;

                 redraw;
                 kcur:=kbeg;
                 y:=2;
                 markitem
                 end;
  c_down_right:  begin
                 if (kbeg+quant)<kaend
                 then
                   kbeg:=kbeg+quant;
                 redraw;
                 kcur:=kbeg+quant-1;
                 y:=maxy;
                 markitem
		 end;
    c_up:    begin
	     if y>2
             then
               begin
               unmarkitem;
	       dec(kcur);
               if _item[y-1]=0
               then
		 dec(y);
               dec(y);

	       markitem
               end
             else
               if kcur>kabeg
               then
                 begin
                 dec(kcur);
                 dec(kbeg);
                 redraw;
                 y:=2;
                 markitem
                 end;
	     end;
    c_down:  begin
             if (y<maxy)
             then
               begin
               unmarkitem;
               inc(kcur);
               if _item[y+1]=0
               then
                 inc(y);

               inc(y);
               markitem
               end
             else
               if kcur+1<kaend
               then
                 begin
                 unmarkitem;
                 inc(kbeg);
                 redraw;
		 kcur:=kbeg+quant-1;
                 y:=maxy;
		 markitem
                 end;
             end;
    c_enter: begin
	     if quant>0
             then
               begin
	       ptmp:=_pbegin;
               for _k:=2 to kcur do
		 ptmp:=ptmp^.next;
	       Invenscreen:=ptmp;
               end
             end;
    end
until (k=c_cancel)or(k=c_enter);
clrscr;
messagetoscreen(false,'');
maze.draw
end;

procedure WearScreen(Screentype: TInvenScreen);
label a;
var k: byte;
    kcur: byte;
    _item: array[8..18] of byte;
    ptmp: ^TPtrQI;
    ptmp1: TPtrQI;
    itype: TItemType;
    s: string;

  procedure markitem;             (*Cursor*)
  var k: byte;
  begin
  for k:=1 to _item[kcur] do
    mark(15+k,kcur-1);
  end;

  procedure unmarkitem;           (*Cursor*)
  var k: byte;
  begin
  for k:=1 to _item[kcur] do
    unmark(15+k,kcur-1);
  end;

  procedure redraw;
  var k: byte;
  begin
  clrscr;
  fprint(
  '|6---------------------------------Equiptment------------------------------------');
  gotoxy(5,24);
  fprint('|6'+#24#25+' |7- move cursor |6Enter |7- Select |6Esc |7- Exit');
  for k:=8 to 18 do
  _item[k]:=2;
  gotoxy(2,8);
  fprint('|9Head');
  gotoxy(14,8);
 if hero.armor[itarmorhead]<>nil
  then
    begin
    s:=fullname(hero.armor[itarmorhead]^.data);
    fprint(':|7 '+s);
    _item[8]:=length(s)
    end
  else
    fprint(':|7 --');

  gotoxy(2,9);
  fprint('|9Cloak');
  gotoxy(14,9);
  if hero.armor[itarmorback]<>nil
  then
    begin
    s:=fullname(hero.armor[itarmorhead]^.data);
    fprint(':|7 '+s);
    _item[9]:=length(s)
    end
  else
    fprint(':|7 --');

gotoxy(2,10);
fprint('|9Heavy armor');
gotoxy(14,10);
if hero.armor[itarmorbodyHi]<>nil
then
  begin
  s:=fullname(hero.armor[itarmorbodyhi]^.data);
  fprint(':|7 '+s);
  _item[10]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,11);
fprint('|9Light armor');
gotoxy(14,11);
if hero.armor[itarmorbodyLo]<>nil
then
  begin
  s:=fullname(hero.armor[itarmorbodylo]^.data);
  fprint(':|7 '+s);
  _item[11]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,12);
fprint('|9Right hand');
gotoxy(14,12);
if hero.Rhand<>nil
then
  begin
  s:=fullname(hero.RHand^.data);
  fprint(':|7 '+s);
  _item[12]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,13);
fprint('|9Left hand');
gotoxy(14,13);
if hero.Lhand<>nil
then
  begin
  s:=fullname(hero.Lhand^.data);
  fprint(':|7 '+s);
  _item[13]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,14);
fprint('|9Arms');
gotoxy(14,14);
if hero.armor[itarmorarms]<>nil
then
  begin
  s:=fullname(hero.armor[itarmorarms]^.data);
  fprint(':|7 '+s);
  _item[14]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,15);
fprint('|9Ring');
gotoxy(14,15);
if hero.ring<>nil
then
  begin
  s:=fullname(hero.ring^.data);
  fprint(':|7 '+s);
  _item[15]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,16);
fprint('|9Palms');
gotoxy(14,16);
if hero.armor[itarmorpalm]<>nil
then
  begin
  s:=fullname(hero.armor[itarmorpalm]^.data);
  fprint(':|7 '+s);
  _item[16]:=length(s)
  end
else
  fprint(':|7 --');

gotoxy(2,17);
fprint('|9Belt');
gotoxy(14,17);
if hero.armor[itarmorbelt]<>nil
then
  begin
  s:=fullname(hero.armor[itarmorbelt]^.data);
  fprint(':|7 '+s);
  _item[17]:=length(s)
  end
else
  fprint(':|7 --');

  gotoxy(2,18);
  fprint('|9Legs');
  gotoxy(14,18);
 if hero.armor[itarmorlegs]<>nil
  then
    begin
    s:=fullname(hero.armor[itarmorlegs]^.data);
    fprint(':|7 '+s);
    _item[18]:=length(s)
    end
  else
    fprint(':|7 --');
    markitem;
  end;



begin
kcur:=8;
redraw;
repeat
  k:=readcommand;
  case k of
    c_up:    if kcur>8
             then
               begin
               unmarkitem;
               dec(kcur);
               markitem
               end;
    c_down:  if kcur<18
             then
               begin
               unmarkitem;
               inc(kcur);
               markitem
               end;

    c_enter: begin
             new(ptmp);
             ptmp:=nil;
	     case kcur of
                8: begin
                   itype:=itarmorhead;
                   ptmp:=@hero.armor[itype];
                   end;
                9: begin
		   itype:=itarmorBack;
                   ptmp:=@hero.armor[itype];
                   end;
               10: begin
                   itype:=itarmorBodyHi;
                   ptmp:=@hero.armor[itype];
                   end;
               11: begin
                   itype:=itarmorbodylo;
                   ptmp:=@hero.armor[itype];
                   end;
               12: begin
		   itype:=it1weapon;
                   ptmp:=@hero.RHand;
                   end;
               13: begin
                   itype:=itshield;
                   ptmp:=@hero.LHand;
                   end;
               14: begin
                   itype:=itarmorarms;
                   ptmp:=@hero.armor[itype];
                   end;
               15: begin
                   itype:=itring;
                   ptmp:=@hero.ring;
                   end;
               16: begin
                   itype:=itarmorpalm;
                   ptmp:=@hero.armor[itype];
                   end;
               17: begin
                   itype:=itarmorbelt;
                   ptmp:=@hero.armor[itype];
                   end;
	       18: begin
                   itype:=itarmorlegs;
                   ptmp:=@hero.armor[itype];
                   end;
	       end;

             if ptmp^<>nil
             then
               begin
               insertitem(hero.pibegin,ptmp^);
	       ptmp^:=nil
               end
             else
               begin
               ptmp1:=invenscreen(hero.pibegin,itype,iswear);
               if ptmp1<>nil
               then
                 begin
                 if ((ptmp1^.data.itemtype=it2weapon)and(ptmp1^.data.itemtype=itrweapon))
                    and (hero.lhand<>nil)
                 then
                   begin end
		 else
                   if ptmp1^.quantity>1
                   then
                     begin
                     dec(ptmp1^.quantity);
                     new(ptmp^);
                     ptmp^^.next:=nil;
                     ptmp^^.quantity:=1;
                     ptmp^^.data:=ptmp1^.DATA;
                     end
                   else
                     begin
                     ptmp^:=ptmp1;

                     delitem(hero.pibegin,ptmp1);
                     ptmp1^.next:=nil
                     end;
                 end;
               end;
             redraw;
             end;
    end
until (k=c_cancel);
clrscr;
messagetoscreen(false,'');
maze.draw;
end;


procedure helpwindow;
begin
textcolor(lightgray);
Clrscr;
fprint('|6------------------------------------HELP----------------------------------------');
gotoxy(1,2);
fprint('|2'+#2+'|7 - Hero');
gotoxy(1,3);
fprint('|4s|7,|2T|7,|8w,_14O|7,|1f|7... - Monsters');
gotoxy(1,4);
fprint('|4(|7,_10[|7,|4'+#11',_14$|7,|1@|7... - Items');
writeln;
fprint('|8'+#178+#178+#178+'           |7 ...');
writeln;
fprint('|8'+#178+#178+#178+' |7 - walls   ... - ground');
writeln;
writeln;
gotoxy(31,5);
fprint('|8'+#178+'|6-'+'|8'+#178+'|7 - Closed door');
gotoxy(31,6);
fprint('|8'+#178+'|6/'+'|8'+#178+'|7 - Opened door');
gotoxy(51,5);
fprint('|7< - Stairs up');
gotoxy(51,6);
fprint('|7> - Stairs down');
writeln;
writeln;
fprint('|6Arrows|7 - Move/attack monster');
writeln;
fprint('|6>|7 - Go downstairs');
writeln;
fprint('|6<|7 - Go upstairs');
writeln;
fprint('|6O|7 - Open door');
writeln;
fprint('|6C|7 - Close door');
writeln;
fprint('|6I|7 - Inventory');
writeln;
fprint('|6P|7 - Pick item');
writeln;
fprint('|6D|7 - Drop item');
writeln;
fprint('|6,|7 - Quick pick item');
writeln;
fprint('|6H|7 - This screen');
writeln;
fprint('|6Shift+H|7 - Switch "Zone of sight"');
writeln;
fprint('|6Shift+I|7 - Personal inventory');
writeln;
fprint('|6Shift+W|7 - Weapon skills');
writeln;
fprint('|6Shift+D|7 - Drink potion');
writeln;
fprint('|6Shift+Q|7 - Quit');
gotoxy(5,24);
fprint('|6Esc|7 - exit');
repeat
until readkey=#27;
clrscr;
end;


procedure Thero.draw;
begin
if vz
then
  charxy(2,2,7,posx,posy)
else
  charxy(2,2,0,posx,posy)
end;


procedure test1; (*F9*)
begin
;
end;


procedure test2;  (*F10*)
var PTMP: TPtrQM;
begin
new(ptmp);
ptmp^.data.create(1,1);
ptmp^.next:=nil;
ptmp^.prev:=nil;
with hero do
  begin
  ptmp^.data.posx:=posx+1;
  ptmp^.data.posy:=posy+1;
  maze.cell[posx+1,posy+1].monster:=ptmp;
  addmonster(hero.pmbegin,ptmp);
  end;

end;


(*----------Zone of sight-------------*)
procedure THero.ZOS;
var n,n1: shortint;
    x,y,k: byte;
begin
x:=posx;
y:=posy;

for n:=x-11 to x+11 do
  for n1:=y-11 to y+11 do
    if CheckPtRange(n,n1)
    then
      if Sight(x,y,n,n1)<50{SightRange}                            (*if visible right now*)
      then
        begin
        if maze.cell[n,n1].monster<>nil
            then
	      begin
              maze.cell[n,n1].monster^.data.draw(vz)    (*draw monster if visible*)
              end
            else
              begin
              maze.cell[n,n1].visible:=true;            (*Mark as visible and draw Cell*)
              maze.writemp(n,n1,vz)
              end;
        end
      else
        begin
        if maze.cell[n,n1].visible
	then
          maze.writemp(n,n1,false)         (*was visible - rewrite*)
        else
          charxy(0,0,0,n,n1);              (*Not visible - fill black*)
        end;

draw;  (*draw hero*)
end;


procedure THero.Save;
var fil: file;
   empty,
     rec: TItemRec;
   itype: TItemType;
begin
rec.mapindex:=mapindex;
rec.posx:=posx;
rec.posy:=posy;
rec.quantity:=1;
empty.mapindex:=mapindex;
empty.posx:=posx;
empty.posy:=posy;
empty.quantity:=1;
empty.item.name:='None';
empty.item.price:=1;
empty.item.index:=1;
empty.item.hits:=1;
empty.item.maxhits:=1;
empty.item.itemtype:=itnone;
assign(fil,'hero.sav');
rewrite(fil,1);
with hero do
  begin
  blockwrite(fil,name,sizeof(name));
  blockwrite(fil,param,sizeof(param));
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

  blockwrite(fil,OV,1);
  blockwrite(fil,DV,1);
  blockwrite(fil,AV,1);

  blockwrite(fil,energy,2);
  for itype:=itarmorhead to itarmorback do
    begin
    if armor[itype]=nil
    then
      rec:=empty
    else
      rec.item:=armor[itype]^.data;
    blockwrite(fil,rec,sizeof(rec));
    end;

  if rhand=nil
  then
    rec:=empty
  else
    rec.item:=rhand^.data;
  blockwrite(fil,rec,sizeof(rec));

  if lhand=nil
  then
    rec:=empty
  else
    rec.item:=lhand^.data;
  blockwrite(fil,rec,sizeof(rec));

  if ring=nil
  then
    rec:=empty
  else
    rec.item:=ring^.data;
  blockwrite(fil,rec,sizeof(rec));

  if ammo=nil
  then
    rec:=empty
  else
    begin
    rec.item:=ammo^.data;
    rec.quantity:=ammo^.quantity;
    end;
  blockwrite(fil,rec,sizeof(rec));
  end;
close(fil);
saveQitems(pibegin);
end;


procedure THero.Load;
var fil: file;
 empty,rec: TItemRec;
  itype: TItemType;

begin
assign(fil,'hero.sav');
reset(fil,1);
with hero do
  begin
  blockread(fil,name,sizeof(name));
  blockread(fil,param,sizeof(param));
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

  blockread(fil,OV,1);
  blockread(fil,DV,1);
  blockread(fil,AV,1);

  blockread(fil,energy,2);

  for itype:=itarmorhead to itarmorback do
    begin
    blockread(fil,rec,sizeof(rec));

    if rec.item.itemtype=itnone
    then
      armor[itype]:=nil
    else
      begin
      new(armor[itype]);
      armor[itype]^.data:=rec.item;
      armor[itype]^.quantity:=1;
      armor[itype]^.next:=nil;
      end;
    end;

  blockread(fil,rec,sizeof(rec));
  if rec.item.itemtype=itnone
  then
    rhand:=nil
  else
    begin
    new(rhand);
    rhand^.data:=rec.item;
    rhand^.quantity:=1;
    rhand^.next:=nil;
    end;

  blockread(fil,rec,sizeof(rec));
  if rec.item.itemtype=itnone
  then
    lhand:=nil
  else
    begin
    new(lhand);
    lhand^.data:=rec.item;
    lhand^.quantity:=1;
    lhand^.next:=nil;
    end;

  blockread(fil,rec,sizeof(rec));
  if rec.item.itemtype=itnone
  then
    ring:=nil
  else
    begin
    new(ring);
    ring^.data:=rec.item;
    ring^.quantity:=1;
    ring^.next:=nil;
    end;

  blockread(fil,rec,sizeof(rec));
  if rec.item.itemtype=itnone
  then
    ammo:=nil
  else
    begin
    new(ammo);
    ammo^.data:=rec.item;
    ammo^.quantity:=rec.quantity;
    ammo^.next:=nil;
    end;

  end;
close(fil);
loadQitems(pibegin);
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

x:=getx(posx,ndir);
y:=gety(posy,ndir);

if CheckPtRange(x,y) then
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
	      maze.cell[x,y].visible:=true;
	      if maze.index=0
	      then
		messagetoscreen(false,'|7You can''t climb mountains. ')
	      else
		messagetoscreen(false,'|4You run into wall|7. ');
	      Energy:=energy-1000;
	      end;

     ctdoorc: begin
	      maze.cell[x,y].visible:=true;
	      if askyn('|4Doors are closed|7. Open door') then (*...ask if you don`t want to open this door,*)
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
    if (sight(posx,posy,hero.posx,hero.posy)<50) or                  (* if Monster sees Hero *)
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




procedure drawmenu(cont: boolean);
begin
textcolor(lightgray);
Clrscr;
gotoxy(2,10);
fprint('|4Choose action:|7');
writeln;
if cont
then
  fprint('[|3C|7]ontinue game')
else
  fprint('[|8C|7]ontinue game');
writeln;
fprint('[|3N|7]ew game');
writeln;
fprint('[|3H|7]elp');
writeln;
fprint('[|3Q|7]uit');
end;



Procedure Menu;
var ena: boolean;
    rec: ^TMazeRec;
    f,g: TMazeFile;
    cont: boolean;
begin
hero.load;
if hero.name=''
  then cont:=false
  else cont:=true;
drawmenu(cont);
repeat
  ena:=false;
  case readkey of
'C','c':if cont
        then
          begin
          clrscr;
	  ena:=true;
          hero.load;
          maze.load(hero.mapindex);
          maze.draw;
	  end;
'N','n':begin
        clrscr;
        ena:=true;
        hero.Create;
        hero.save;
        new(rec);
        assign(f,map_filename);
        assign(g,map_savefile);
        reset(f);
        rewrite(g);
        while not eof(f) do
          begin
          read(f,rec^);
          write(g,rec^);
          end;
        close(f);
        close(g);
        assign(f,monstersavefile);
        rewrite(f);
	close(f);
        assign(f,Itemssavefile);
        rewrite(f);
        close(f);
        maze.load(0);
        dispose(rec);
        enter;
        end;
'H','h':begin
        helpwindow;
        drawmenu(cont);
        end;
'Q','q':halt;
    end;
until ena;
end;


procedure THero.Death;
begin
hero.drawsidebar;
Hero.name:='';
hero.save;
messagetoscreen(true,'');
messagetoscreen(false,'You were defeated. Better luck next time. Good Bye');
reade;
ClrScr;
gotoxy(30,12);
Write('Rest in Peace...');
readcommand;
halt
end;


procedure ascend(_index:byte);
var k,k1: byte;
    st_index: byte;
    ena: boolean;
    mp_index: byte;
begin
mp_index:=maze.index;
st_index:=maze.stairsup[_index].stairindex;
if maze.stairsup[_index].mapindex<>maze.index             (*if stairs lead to other map*)
then
  begin
  ena:=false;
  maze.save;                                              (* save this map*)
  maze.saveQMonsters(hero.pmbegin);
  hero.mapindex:=maze.stairsup[_index].mapindex;
  maze.load(maze.stairsup[_index].mapindex);              (* load other map*)
  maze.loadQMonsters(hero.pmbegin);
  if maze.cell[1,1].value=ctdooro
  then
    begin
    maze.generate(random(4)+4,3);
    maze.stairsdown[1].mapindex:=mp_index;
    maze.stairsdown[1].stairindex:=_index;
    maze.stairsup[1].mapindex:=maze.index-1;
    maze.stairsup[1].stairindex:=1;
    maze.difficulty:=3;
    maze.GenMonsters(hero.pmbegin);
    end;
  maze.draw;                                              (* draw visible part*)
  end
else
  ena:= true;
for k:=1 to 80 do
    for k1:=1 to 20 do
      if (maze.cell[k,k1].value=ctstaird) and (maze.cell[k,k1].stairindex=st_index)
        then
          begin
          if ena
          then
            maze.writemp(hero.posx,hero.posy,false);
          hero.posx:=k;
	  hero.posy:=k1;
          messagetoscreen(true,'You ascend. ');                     (* put message *)
          (*TRANSLATE*)
          break;
          end;
end;

procedure descend(_index:byte);
var k,k1: byte;
    mp_index,
    st_index: byte;
    ena: boolean;
begin
mp_index:=maze.index;
st_index:=maze.stairsdown[_index].stairindex;
// writeln('_index=',_index);
// writeln('MAZE_INDEX=',maze.index);
// writeln('mapindex=',maze.stairsdown[_index].mapindex,'ST=',st_index);
// writeln(maze.stairsdown[_index].mapindex<>maze.index);readkey;
if (maze.stairsdown[_index].mapindex<>maze.index)            (*if stairs lead to other map*)
then
  begin
  writeln('Other MAP');readkey;
  ena:=false;
  maze.save;
  maze.SaveQMonsters(hero.pmbegin);
  hero.mapindex:=maze.stairsdown[_index].mapindex;
  //writeln('Loading map N ', maze.stairsdown[_index].mapindex);readkey;
  maze.load(maze.stairsdown[_index].mapindex);              (* load other map*)
  //writeln('maze.cell[1,1].value =', maze.cell[1,1].value);readkey;
  if maze.cell[1,1].value=ctdooro
  then
    begin
    maze.generate(random(4)+4,3);
    maze.stairsup[1].mapindex:=mp_index;
    maze.stairsup[1].stairindex:=_index;
    maze.stairsdown[1].mapindex:=maze.index+1;
    maze.stairsdown[1].stairindex:=1;
    maze.difficulty:=3;
    maze.GenMonsters(hero.pmbegin);
    end
  else
    maze.LoadQMonsters(hero.pmbegin);
  maze.draw;                                              (* draw visible part*)
  end
else
  ena:=true;
for k:=1 to 80 do
    for k1:=1 to 20 do
      if (maze.cell[k,k1].value=ctstairu) and (maze.cell[k,k1].stairindex=st_index)
        then
          begin
          if ena
          then
	    maze.writemp(hero.posx,hero.posy,false);
          hero.posx:=k;
          hero.posy:=k1;
          messagetoscreen(true,'You descend. ');                     (* put message *)
          exit;
          end;
end;


(*=========MAIN PROGRAM=========*)
BEGIN
(*=---------Initialization--------=*)
textbackground(black);
cursoroff;
randomize;

Zast;
reade;
(*=--------Greetings screens------=*)
menu;

hero.updateparams;
hero.drawsidebar;

iptmp:=nil;
hero.ZOS;
quit_b:=false;
(*=--------Main loop----------=*)
repeat
    c:=ReadCommand;
    messagetoscreen(true,''); (*clearing buffer*)
    (*-----------Beginning of TURN-----------*)
    case c of
      C_TEST1:
	       Test1;
      C_TEST2:
	       Test2;

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
      C_WInven: wearscreen(isinven);
      C_Inven : invenscreen(hero.pibegin,itnone,isinven);
      C_WSkill: WSkillScreen;
      C_QUIT: if askyn('Want to quit')
	      then
		begin
		quit_b:=true;
                maze.save;
                hero.save;
                end;
      C_DROP : if maze.index=0
               then
                 messagetoscreen(false,'can''t drop in wilderness. ')
               else
                 hero.dropitem(invenscreen(hero.pibegin,itnone,isdrop));
      c_qpick: if maze.cell[hero.posx,hero.posy].items<>nil
               then
                 begin
                 messagetoscreen(false,'You picked '+maze.cell[hero.posx,hero.posy].items^.data.name);
                 hero.pickitem(maze.cell[hero.posx,hero.posy].items);
                 end
               else
                 messagetoscreen(false,'No items');
      C_Pick : hero.pickitem(invenscreen(maze.cell[hero.posx,hero.posy].items,itnone,ispick));
      c_help: begin
              helpwindow;
              maze.draw;
              messagetoscreen(false,'');
              end;

      C_ZOS: begin
             (*flip Viewing Zone of sight mode*)
             hero.vz:=not hero.vz;
             hero.zos;
	     end;
      C_Drink: hero.drinkpotion(invenscreen(hero.pibegin,itpotion,isdrink));
      C_OPEN_DOOR:
             begin
             if (hero.getdoorc(hero.posx,hero.posy)=dNULL)
             (*if there isn`t a closed door around hero*)
              then hero.opendoor(askdir('Where do yo want to open door'))     (*TRANSLATE*)
             (*...then ask direction*)
             else hero.opendoor(hero.getdoorc(hero.posx,hero.posy));
             (*...else open door at direction*)
             end;
      C_CLOSE_DOOR:
	     begin
             if (hero.getdooro(hero.posx,hero.posy)=dNULL)
             (*if there isn`t an opened door around hero*)
             then hero.closedoor(askdir('Where do yo want to close door'))   (*TRANSLATE*)
             (*...then ask direction*)
             else hero.closedoor(hero.getdooro(hero.posx,hero.posy));
             (*...else close door at direction*)
             end;
      C_GO_UP:
             begin
             with maze.cell[hero.posx,hero.posy] do
	     if value=ctstairu
             then
               begin
               ascend(stairindex);
               end
             else messagetoscreen(true,'There is no ascention');
             end;
      C_GO_DOWN:
             begin
             with maze.cell[hero.posx,hero.posy] do
             if value=ctstaird
             then
               descend(stairindex)
             else messagetoscreen(true,'There is no descention'); (*TRANSLATE*)
             end;
      end;

    hero.zos;        (*calculate Zone of Sight*);

    if hero.energy<=0
    then
      begin
      (*_______________End of Turn____________________*)
      if (random(40)<hero.param[con,0])and(hero.hp<hero.maxhp)  (* Healing *)
      then
        inc(hero.hp);
      if (random(40)<hero.param[mag,0])and(hero.mp<hero.maxmp)  (* Mana restore *)
      then
        inc(hero.mp);
      while hero.energy<=0 do
        begin
        hero.energy:=hero.energy+1000;
        (*============MONSTERS MOVES HERE============*)
        MPTmp:=Hero.PMBegin;
        while MPTmp<>nil do
          begin
          MonsterMove(MPTmp);
          MPTmp:=MPTmp^.next;
          end;
        end;
      end;
    (*---------Location Messages---------*)
    with maze.cell[hero.posx,hero.posy] do
    begin
    case value of
	      ctstairu  : messagetoscreen(false,'There is a stairway leading up. ');
	      ctstaird  : messagetoscreen(false,'There is a stairway leading down. ');
	      end;

    if maze.index=0
    then
      case value of
	      ctground: case groundtype of
			gtgrass: messagetoscreen(false,'Grassland. ');
			gtbrick: messagetoscreen(false,'Scorched earth. ');
			gtstone: messagetoscreen(false,'Bridge. ');
			gtice:   messagetoscreen(false,'Frozen water. ');
			gtsand:  messagetoscreen(false,'Desert. ');
			gtwood:  messagetoscreen(false,'Road. ');
      gtmetal: messagetoscreen(false,'Forest. ');
			end;
	      ctstaird  : messagetoscreen(false,'There is a dungeon entrance. ');
	      end;

    if items<>nil
    then
      if items^.next<>nil
      then
        messagetoscreen(false,'Several items is lying here. ')
      else
	with items^ do
          begin
          if quantity>1
          then
            messagetoscreen(false,data.name+'x'+inttostr(quantity)+' is lying here')
          else
            messagetoscreen(false,items^.data.name+' is lying here. ');
          end;
    end;
    hero.UpdateParams;
    hero.drawsidebar;
    hero.zos;        (*calculate Zone of Sight*);
    until quit_b;
   (*_____________________________________________*)
END.