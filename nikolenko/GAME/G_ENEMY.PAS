(* Written by Nikolenko Vitaly
      Copyright 2003             *)
unit g_enemy;

{$PACKRECORDS 1}
{$PACKENUM 1}  

INTERFACE
uses g_tool;


type

  TInvenScreen = (iswand,isInven,IsPick,IsDrop,IsWear,IsUse,isDrink);

  TWSkill = (     wsUnarmed,
                  wsSword,
                  wsDagger,
                  wsSpear,
                  wsAxe,
                  wsMaces,
                  wsShoot,
                  wsBow,
                  wsThrown,
                  wsShield,
                  wsOnehand,
                  wsTwohand);

{  TSkill =(Archery,
           Athletics,
           Dodge,
           Healing,
           );}

  TParam =
          (STR,DEX,MAG,
           MOV,INT,CON,
           WIL,REF);


           (* 0 - current; 1 - temp*)
  TParams = array[TParam,0..1]of byte;

{  TSkills = array[TSkill]of byte;}

          (* 0 - current; 1 - inc*)
  TWSkills = array[TWSkill,0..1]of byte;

  TArmorType = (atBodyHi,
                atBodyLo,
                atHead,
                atArm,
                atPalm,
                atFinger,
                atLeg,
                atBack,
                atBelt
               );


  TItemtype = (itnone,
               itfood,
               itmoney,
               (*weapons*)
               it1weapon,
               it2weapon,
               ittweapon,
               itrweapon,
               itshield,
               (*armor*)
               itarmorHead,
               itarmorBodyHi,
               itarmorBodyLo,
               itarmorLegs,
               itarmorArms,
               itarmorPalm,
               itarmorBelt,
               itarmorBack,
               itRing,
               itammo,
               itwand,
               itpotion,
               ittool,
               itjunk);


  TItem = record
    index:byte;
    price: word;
    name: string[30];
    weight: word;
    hits,maxhits: word;
    case itemtype:Titemtype of
      itmoney:  (cost: longint);

      it1weapon,
      it2weapon,
      ittweapon,
      itrweapon: (wskill: twskill;
                 wtohit,wdam,wdef: shortint;
                 damdice: byte);
      itshield,
      itarmorHead,
      itarmorBodyHi,
      itarmorBodyLo,
      itarmorLegs,
      itarmorArms,
      itarmorPalm,
      itarmorBelt,
      itarmorBack:  (armortype: TArmorType;
                   atohit,arm,adef: shortint);

      itammo:   (ammotype: Twskill);

      itWand:   (charges:byte;magictype: byte);
      itpotion: (potiontype:byte;ppower:word);
      itring:   (param: TParam;modif:shortint);
      itfood:   (nutrients: word;
                 Rotting: byte;
                 poison: byte)
      end;

  TPtrQI = ^TQitem;

  TQitem = record
    data: TItem;
    quantity: word;
    next: TPtrQI
    end;

  TItemRec = record
     mapindex: byte;
     Item: TItem;
     quantity: word;
     posx,posy: byte;
     end;

  TItemFile = file of TItemRec;

  TMonster = object
    index: byte;                             (*monster index in FILE*)
    Name: string[30];                        (*monster NAME*)
    Symbol : byte;                           (*symbol, used for monster*)
    SColor :byte;                            (*color, used for symbol*)
    Speed: word;

    HP,MaxHP: integer;                       (*current/max hits*)

    Posx: byte;                              (*Coordinates on map*)
    Posy: byte;

    Wdice: byte;

    DV,AV: shortint;                         (*defence/armor modifiers*)
    OV,DM: shortint;                         (*offence/damage modifiers*)

    level: byte;
    item1,item2,item3: byte;                (*items that monster may carry*)
    procedure Draw(ViewZos: boolean);
    procedure Create(_index,mlevel:byte);
  end;

  TPtrQM = ^TQMonster;

  TMonsterRec = record
       index: byte;
       Name: string[30];                       (*monster NAME*)
       Symbol : byte;                           (*symbol, used for monster*)
       SColor :byte;                            (*color, used for symbol*)
       Speed: word;
       MaxHP: integer;                       (*current/max hits*)
       Wdice: byte;
       DV,AV: shortint;                         (*defence/armor modifiers*)
       OV,DM: shortint;                         (*offence/damage modifiers*)
       item1,item2,item3: byte;
       end;

  TMonsterSaveRec = record
       index: byte;
       posx,posy: byte;
       mapindex: byte;
       HP: integer;
       lev: byte;
       end;

  TQMonster = record
       data: tmonster;
       next,
       prev: TPtrQM;
       end;


const
  {SkillName: Array[tskill]of string[10] = ('Archery',
                                           'Athletics',
                                           'Dodge',
                                           'Healing'
                                           );}

  WeapOV: array[0..10] of byte = (0,1,2,3,5,7,10,13,17,21,26);
  WeapDV: array[0..10] of byte = (0,0,1,1,2,3,5,7,10,12,16);
  WeapDM: array[0..10] of byte = (0,0,0,1,1,2,3,4,6,10,15);

  ShieldOV: array[0..10] of byte = (0,0,0,0,1,1,2,2,3,4,5);
  ShieldDV: array[0..10] of byte = (0,1,2,3,5,7,10,13,17,21,26);
  ShieldAV: array[0..10] of byte = (0,1,1,2,2,3,3,4,5,7,10);


  WSKillName: array[wsunarmed..wsshield] of string[15] =(
					      'Unarmed combat',
					      'Swords',
					      'Daggers',
					      'Spears',
					      'Axes',
					      'Maces',
					      'Shooting',
					      'Bows',
					      'Throwing',
					      'Shields');


  WeapXP: array[1..10] of word =(50,150,250,450,750,1250,2100,3350,5500,8900);
  LevXP:  array[1..10] of word = (1,2,3,5,7,11,17,26,42,67);

  ItemsSaveFile = 'items.sav';
  ItemsFile     = 'items.dat';
MonsterDataFile = 'monster.dat';
MonsterSaveFile = 'monster.sav';
  ItemCount     = 100;
MonsterCount    = 100;

function FullName(Item:Titem):string;

procedure delmonster(var PBegin:TPtrQM;PMonster: TPtrQM);
procedure addmonster(var PBegin:TPtrQM;PMonster: TPtrQM);

procedure DelItem(var Pbegin: TPtrQI;PItem: TPtrQI);
procedure InsertItem(var Pbegin,PItem: TPtrQI);
procedure LoadItem(var Item: Titem;_index:byte);

procedure SaveQItems(Pbegin: TPtrQI);
procedure LoadQItems(var Pbegin: TPtrQI);



IMPLEMENTATION
uses crt;

procedure LoadItem(var Item: Titem;_index:byte);
var fil: file of TItem;
begin
assign(fil,ItemsFile);
reset(fil);
seek(fil,_index);
read(fil,Item);
close(fil)
end;

procedure DelItem(var Pbegin: TPtrQI;PItem: TPtrQI);
var p0,ptmp: TPtrQI;
begin
new(p0);
p0^.next:=pbegin;
ptmp:=p0;
while ptmp^.next<>PItem do
  ptmp:=ptmp^.next;
ptmp^.next:=ptmp^.next^.next;
pbegin:=p0^.next;
dispose(p0);
end;

procedure InsertItem(var Pbegin,PItem: TPtrQI);
var p0: TPtrQI;
    ptmp1,ptmp2 : TPtrQI;
begin
new(p0);
p0^.next:=pbegin;
p0^.data.itemtype:=itnone;
ptmp1:=p0;
ptmp2:=pbegin;
while (ptmp2<>nil) and (PItem^.data.itemtype>=ptmp2^.data.itemtype) do
  begin
  if ptmp2^.data.itemtype=pitem^.data.itemtype
  then
    begin
    while (ptmp2<>nil)
      and (PItem^.data.index>=ptmp2^.data.index)
      and (ptmp2^.data.itemtype=pitem^.data.itemtype) do
      begin
      if (ptmp2^.data.index=pitem^.data.index) and
         (ptmp2^.data.hits=pitem^.data.hits)
      then
        begin
        ptmp2^.quantity:=ptmp2^.quantity+pitem^.quantity;
        dispose(pitem);
        exit
        end;
      ptmp1:=ptmp2;
      ptmp2:=ptmp2^.next;
      end;
    break
    end;
  ptmp1:=ptmp2;
  ptmp2:=ptmp2^.next;
  end;
ptmp1^.next:=pitem;
pitem^.next:=ptmp2;
pbegin:=p0^.next;
dispose(p0);
end;

function FullName(Item:Titem):string;
var s: string;
    k: byte;
    ch: char;
begin
s:=item.name+' ';
with item do
case itemtype of
  itarmorHead,
  itarmorBodyHi,
  itarmorBodyLo,
  itarmorLegs,
  itarmorArms,
  itarmorPalm,
  itarmorBelt,
  itarmorBack,
  itshield:     s:=s+'('+inttostr(atohit)+','+'0) ['+
                   inttostr(adef)+','+inttostr(arm)+']';
  it1weapon,
  it2weapon,
  ittweapon,
  itrweapon:    begin
                case (damdice mod 16) of
                  1:     k:=1;
                  2:     k:=2;
                  3:     k:=3;
                  4:     k:=4;
                  5,6:   k:=6;
                  7,8:   k:=8;
                  9,10:  k:=10;
                  11,12: k:=12;
                  else   k:=20;
                  end;
                if wdam>=0
                then
                  ch:='+';
                s:=s+'('+inttostr(wtohit)+','+inttostr(damdice shr 4)+'d'+
                inttostr(k)+ch+inttostr(wdam)+') ['+inttostr(wdef)+',0]';
                end;
  itpotion:     begin
                case potiontype of
                  0: s:=s+' (Hits) ';
                  1: s:=s+' (Mana) ';
                  2: s:=s+' (Invis.) ';
                  3: s:=s+' (Berserk) ';
                  4: s:=s+' (Magic 4) ';
                  else s:=s+', not magic ';
                  end;
                s:=s+'power'+inttostr(ppower);
                end;
  itring:       begin
                case param of
                  STR: s:=s+'(strength ';
                  DEX: s:=s+'(dexterity ';
                  MAG: s:=s+'(magic ';
                  MOV: s:=s+'(move ';
                  INT: s:=s+'(int. ';
                  CON: s:=s+'(const. ';
                  WIL: s:=s+'(willpower ';
                  REF: s:=s+'(reflex ';
                  else s:=s+',Not magic ';
                  end;
                if modif>=0
                then
                  s:=s+'+';
                s:=s+inttostr(modif)+')';
                end;
  itwand:       begin
                case magictype of
                  0: s:=s+'(Magic 0) ';
                  1: s:=s+'(Magic 1) ';
                  2: s:=s+'(Magic 2) ';
                  3: s:=s+'(Magic 3) ';
                  4: s:=s+'(Magic 4) ';
                  else s:=s+',Not magic ';
                  end;
                s:=s+'('+inttostr(charges);
                s:=s+' charges)';
                end;
  end;
fullname:=s;
end;

procedure addmonster(var PBegin:TPtrQM;PMonster: TPtrQM);
begin
PMonster^.next:=PBegin;
PMonster^.prev:=nil;
if pbegin<>nil
then
  PBegin^.prev:=Pmonster;
PBegin:=Pmonster;
end;

procedure delmonster(var PBegin:TPtrQM;PMonster: TPtrQM);
begin
if pmonster^.prev<>nil
then
  begin
  PMonster^.prev^.next:=PMonster^.next;
  end
else
  pbegin:=pmonster^.next;

if pmonster^.next<>nil
then
  PMonster^.next^.prev:=PMonster^.prev;
dispose(PMonster);
end;

procedure TMonster.Create(_index,mlevel:byte);
var fil: file of TMonsterRec;
    tmp: TMonsterRec;
begin
assign(fil,monsterdatafile);
reset(fil);
seek(fil,_index);
read(fil,tmp);
close(fil);
index:=_index;
Name:=tmp.name;
Symbol :=tmp.symbol;
SColor :=tmp.scolor;
Speed:=tmp.speed;
MaxHP:=tmp.maxhp;
HP:= maxhp;
Wdice:=tmp.wdice;
OV:=tmp.ov+mlevel;
DV:=tmp.dv+(mlevel shr 1);
AV:=tmp.dv+(mlevel div 3);
DM:=tmp.dv+(mlevel shr 2);
level:=mlevel;
item1:=tmp.item1;
item2:=tmp.item1;
item3:=tmp.item1
end;

procedure LoadQItems(var Pbegin: TPtrQI);
var PTmp: TPtrQI;
    f: TItemFile;
    tmp: TItemRec;
    k,k1: byte;
begin
assign(f,ItemsSaveFile);
reset(f);
while not eof(f) do
  begin
  read(f,tmp);
  if tmp.mapindex=0
  then
    begin
    new(ptmp);
    ptmp^.data:=tmp.item;
    ptmp^.quantity:=tmp.quantity;
    insertitem(pbegin,ptmp);
    end;
  end;
close(f);
end;

procedure SaveQItems(Pbegin: TPtrQI);
var PTmp: TPtrQI;
    f,g: TItemFile;
    tmp: TItemRec;
    k,k1: byte;
    ena: boolean;
begin
assign(f,ItemsSaveFile);
assign(g,'~'+ItemsSaveFile);
reset(f);
rewrite(g);
ena:=true;
ptmp:=pbegin;
while ptmp<>nil do
  begin
  tmp.item:=ptmp^.data;
  tmp.mapindex:=0;
  tmp.quantity:=ptmp^.quantity;
  write(g,tmp);
  ptmp:=ptmp^.next
  end;
while not eof(f) do
  begin
  read(f,tmp);
  if (tmp.mapindex<>0)
  then
    write(g,tmp)
  end;
close(g);
close(f);
erase(f);
rename(g,ItemsSaveFile);
end;

procedure TMonster.draw(ViewZos: boolean);
begin
if ViewZos
then
  charxy(symbol,Scolor,7,posx,posy)
else
  charxy(symbol,Scolor,0,posx,posy)
end;

END.