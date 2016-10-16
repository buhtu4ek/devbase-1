(* Written by Nikolenko Vitaly
      Copyright 2003             *)
unit g_map;

{$PACKRECORDS 1}
{$PACKENUM 1}  

interface
uses g_tool,g_enemy;

const
    Map_filename = 'map.dat';
    Map_savefile = 'map.sav';
    MapCount = 42;

type
    TGroundType = (GTwood,GTstone,GTgrass,GTgranite,GTBrick,GTmetal,GTIce,GTsand);

    TCellType = (CTwindow,CTwall,CTground,CTdooro,CTdoorc,CTstaird,CTstairu);   (*Kind of cell*)

    TCell = record
      Visible: boolean;         (*had I seen this cell before?*)
      VisibleNOW: boolean;      (*am I seeing it right now*)
      Light: byte;              (*level of illumination (0 - dark, 1 - lighter)*)
      Monster: TPtrQM;       (*monster on this cell*)
      Items: TPtrQI;
      case Value: TCellType of  (*what`s in cell*)
	CTwall: (WallType :byte);              (*Wall  3 bits - type, 5 bits - strength
						 000 - straw 10
						 001 - wood  6
						 010 - brick 12
						 011 - stone
						 100 - Dstone
						 101 - granite
						 110 - metal
						 111 - unbreakable *)

	CTground: (GroundType: TGroundType);  (*Floor  *)

	CTdoorc: (DoorCType:Byte);   (*Closed Door   1 bit - locked 2 bits - type, 5 bits - keynumber*)

	CTDooro: (DoorOType:Byte);   (*Opened Door   1 bit - 0      2 bits - type, 5 bits - keynumber
								    00 - wood
								    01 - wood+metal
								    10 - metal
								    11 - unbreakable *)
	ctstaird,ctstairu: (StairIndex: byte);

      end;

     TACell = array[1..scrw,1..scrh] of tcell;

     TSTairs = record
	       MapIndex,
	       StairIndex :byte;
	       end;

     TASTairs = array[1..20] of TSTairs;

     TMaze = object
     public
       cell: TACell;
       StairsUp,
       StairsDown : TAStairs;
       index: byte;
       difficulty: byte;

       procedure Draw;
       procedure Generate(rcount,tunlen:byte);
       procedure WriteMP(x,y:byte;ViewZos: boolean);
       function  CMT(x,y:byte): boolean;
       function  CST(x,y:byte): boolean;
       procedure load(_index: byte);
       procedure save;
       procedure GenMonsters(var PBegin: TPtrQM);
       procedure loadQMonsters(var Pbegin: TPtrQM);
       procedure SaveQMonsters(var Pbegin: TPtrQM);
     private
       procedure GenRooms(rcount: byte);
       procedure GenTunnels(rcount,tunlen: byte);
       procedure PutDoor(x,y:byte);
       procedure Tunnel(x,y:byte;ndir:tdir;prior:string);
       function  CheckPT(x,y:byte;ndir:tdir): byte;
       procedure SaveItems;
       procedure LoadItems;


     end;

    TMazeRec = record
      cell: TACell;
      difficulty: byte;
      StairsUp,
      StairsDown : TAStairs;
      end;

    TMazeFile = file of TMazeRec;




implementation
uses
  crt;

type
     rm = record                 (*single room*)
        top,left,width,height: byte;
        end;

{const RCount=4;   (*rooms count*)
      TunLen=3;   (*minimal tunnel length*)}


var room: array[1..10] of rm; (*all rooms*)
    endg: boolean;
    k,k1: byte;
    cpx,cpy:byte;


procedure TMaze.SaveQMonsters(var Pbegin: TPtrQM);
var f,g: File of TMonsterSaveRec;
    trec,
    srec: TMonsterSaveRec;

    ena: boolean;
    ptmp1,ptmp: TPtrQM;
begin
assign(f,monstersavefile);
assign(g,'~'+monstersavefile);
reset(f);
rewrite(g);
ena:=true;
while not eof(f) and ena do
  begin
  read(f,srec);
  if srec.mapindex<>index
  then
    write(g,srec)
  else
    ena:=false;
  end;

ptmp:=Pbegin;
while ptmp<>nil do
  begin
  with ptmp^.data do
    begin
    srec.index:=index;
    srec.hp:=hp;
    srec.posx:=posx;
    srec.posy:=posy;
    srec.lev:=level;
    end;
  srec.mapindex:=index;
  write(g,srec);
  ptmp1:=ptmp;
  ptmp:=ptmp^.next;
  dispose(ptmp1)
  end;

while not eof(f) do
  begin
  read(f,srec);
  if srec.mapindex<>index
  then
    write(g,srec)
  end;
pbegin:=nil;
close(f);
close(g);
erase(f);
rename(g,monstersavefile)

end;


procedure TMaze.loadQMonsters(var Pbegin: TPtrQM);
var ena: boolean;
    fil: file of TMonsterSaveRec;
   SRec: TMonsterSaveRec;
     PM: TPtrQM;
begin
assign(fil,monsterSaveFile);
reset(fil);
ena:= false;
while (not eof(fil)) do
  begin
  read(fil,SRec);
  if srec.mapindex=index
  then
    begin
    ena:=true;
    new(PM);
    with pm^.data do
      begin
      create(srec.index,srec.lev);
      posx:=srec.posx;
      posy:=srec.posy;
      hp:=srec.hp;
      cell[posx,posy].monster:=pm;
      end;
    ADDmonster(pbegin,pm);
    end
  else
    if ena
    then
      break
  end;
pm:=nil;
close(fil)
end;

procedure TMaze.LoadItems;
var PTmp: TPtrQI;
    f: TItemFile;
    tmp: TItemRec;
    k,k1: byte;
begin
if index=0 then exit;
assign(f,ItemsSaveFile);
reset(f);
while not eof(f) do
  begin
  read(f,tmp);
  if tmp.mapindex=index
  then
    begin
    new(ptmp);
    ptmp^.data:=tmp.item;
    ptmp^.quantity:=tmp.quantity;
    insertitem(cell[tmp.posx,tmp.posy].items,ptmp);
    end;
  end;
close(f);
end;


procedure TMaze.SaveItems;
var ptmp1,PTmp: TPtrQI;
    f,g: TItemFile;
    tmp: TItemRec;
    k,k1: byte;
    ena: boolean;

begin
if index=0 then exit;
assign(f,ItemsSaveFile);
assign(g,'~'+ItemsSaveFile);
reset(f);
rewrite(g);
ena:=true;
while not eof(f) and ena do
  begin
  read(f,tmp);
  if (tmp.mapindex<>index)
  then
    write(g,tmp)
  else
    ena:=false;
  end;

for k:=1 to 80 do
  for k1:=1 to 20 do
        begin
        ptmp:=cell[k,k1].items;
        while ptmp<>nil do
          begin
          tmp.item:=ptmp^.data;
          tmp.quantity:=ptmp^.quantity;
          tmp.posx:=k;
          tmp.posy:=k1;
          tmp.mapindex:=index;
          write(g,tmp);
          ptmp1:=ptmp;
          ptmp:=ptmp^.next;
          dispose(ptmp1);
          end;
        end;

while not eof(f) do
      begin
      read(f,tmp);
      if tmp.mapindex<>index
      then
        write(g,tmp);
      end;

close(g);
close(f);
erase(f);
rename(g,ItemsSaveFile);

end;



function  TMaze.CMT(x,y:byte): boolean;
begin
case cell[x,y].value of
     CTdooro,
     CTground,
     CTstaird,
     CTstairu : CMT:=true;
     CTdoorc,
     CTwindow,
     CTwall  : cmt:=false;
     else  cmt:=false;
     end;
end;




(*just put door in POINT*)
procedure TMaze.PutDoor(x,y:byte);
begin
with cell[x,y] do
case random(6) of
     0,2: begin
          value:=CTdoorc;
          doorctype:=0
          end;
     1:   begin
          value:=CTground;
          groundtype:=gtstone;
          end;
     else begin
          value:=CTdooro;
          doorotype:=0
          end;

     end;
end;






(*-----Write POINT to screen--------*)
procedure TMaze.WriteMP(x,y:byte;ViewZos: boolean);
var bcol,col,byt: byte;
    ena: boolean;
    ITmp: TItem;
begin
ena:=viewzos;
if index=0
then
  begin

bcol:=black;
with cell[x,y] do
case value of
     CTground: begin  (*draw floor*)
               byt:=46;   (*  '.' *)
               case groundtype of
                 GTwood:  col:=brown;
                 GTstone: col:=lightgray;
                 GTIce:     begin
                            byt:=61;   (*'='*)
                            col:=lightcyan
                            end;
                 GTGranite: col:=magenta;
                 GTBrick:   col:=lightred;

                 GTMetal:   begin
                            byt:=5;
                            col:=green;
                            end;
                 GTgrass:   begin
                            byt:=34;   (*'"'*)
                            col:=lightgreen;
                            end;
                 GTsand:    col:=yellow;
                 end;




               end;

     CTwall :  begin  (*draw wall*)
               case (walltype shr 5) of
                 0: col:=lightgreen;
                 1: col:= 6;
                 2: col:=12;
                 3: col:= 8;
                 4: col:= 8;
                 5: col:= 5;
                 6: col:= 3;
                 7: col:=15;
                 end;

               byt:=94 (*'^' - Mountains*)
               end;

     CTdooro,
     CTdoorc,
     CTstairu: begin
               col:=darkgray;
               byt:=42;  (*'*'*)
               end;

     CTstaird: begin
               col:=lightgray;
               byt:=111 (* 'o' - village*);
               end;
     end;
  end
else
  begin
with cell[x,y] do
begin
if Items<>nil
then
  with items^.data do
    begin
    case itemtype of
      it1weapon,
      it2weapon,
      ittweapon,
      itrweapon: begin
                byt:=40;   (*'('*)
                col:=red;
                end;
      itmoney : begin
                byt:=36;   (*'$'*)
                col:=yellow
                end;
      itjunk  : begin
                byt:=64;   (*'@'*)
                col:=blue
                end;
      itshield: begin
                byt:=15;   (*''*)
                col:=lightred
                end;
      itarmorHead,
      itarmorBodyHi,
      itarmorBodyLo,
      itarmorLegs,
      itarmorArms,
      itarmorPalm,
      itarmorBelt,
      itarmorBack:
                begin
                byt:=91;   (*'['*)
                col:=lightgreen
                end;
      itammo  : begin
                byt:=42;   (*'*'*)
                col:=darkgray
                end;
      itpotion: begin
                byt:=11; (*''*);
                case potiontype of
                  0: col:=red;
                  1: col:=blue;
                  2: col:=blue;
                  3: col:=yellow;
                  end;

                end;
      itring  : begin
                byt:=9; (*'o'*)
                col:=5
                end;
      itwand  : begin
                byt:=92; (*'\'*)
                col:=white
                end;

      itfood  : begin
                byt:=37; (*'%'*)
                col:=green
                end;
      end;

    end
else
  case value of
     CTground: begin  (*draw floor*)

               case groundtype of
                 GTwood:  col:=brown;
                 GTstone: begin
                          if ena
                          then
                            col:=black
                          else
                            col:=lightgray;
                          end;

                 GTIce:     col:=lightcyan;
                 GTGranite: col:=magenta;
                 GTBrick:   col:=lightred;
                 GTMetal:   col:=cyan;
                 GTgrass:   col:=green;
                 GTsand:    col:=yellow;
                 end;



               byt:=46;   (*  '.' *)
               end;
     CTwall :  begin  (*draw wall*)
               case (walltype shr 5) of
                 0: col:=lightgreen;
                 1: col:= 6;
                 2: col:=12;
                 3: col:= 8;
                 4: col:= 8;
                 5: col:= 5;
                 6: col:= 3;
                 7: col:=15;
                 end;
               {col:=darkgray;}
               byt:=178
               end;

     CTdooro:  begin  (*draw opened door*)
               case ((doorotype shl 1) shr 6) of
                 0: col:=6;
                 1: col:=6;
                 2: col:=3;
                 3: col:=15;
                 end;
               byt:=47  (*  '/' *)
               end;

     CTdoorc:  begin
               case ((doorctype shl 1) shr 6) of
                 0: col:=6;
                 1: col:=6;
                 2: col:=3;
                 3: col:=15;
                 end;

               (*if there are walls left and right of POINT then draw horizontal closed door*)
               if (cell[x-1,y].value=CTwall) and (cell[x+1,y].value=CTWall)
               then
                 byt:=45  (* '-' *)

               else

                 (*if there are walls higher and lower of POINT then draw vertical closed door*)
                 if (cell[x,y+1].value=ctWALL) and (cell[x,y-1].value=ctWALL)
                 then
                   byt:=124 (* '|' *)
                 else
                   byt:=43 (* '+' *);
               end;

     CTstairu: begin  (*draw stairs up*)
               if ena
               then
                 col:=black
               else
                 col:=lightgray;
               byt:=60 (* '<' *);
               end;

     CTstaird: begin  (*draw stairs down*)
               if ena
               then
                 col:=black
               else
                 col:=lightgray;
               byt:=62 (* '>' *);
               end;
  end;


if ena then bcol:=7 else bcol:=0;
end;
end;
charxy(byt,col,bcol,x,y);

textbackground(black);
end;



(*draw maze*)
procedure TMaze.Draw;
var n,n1:byte;
begin
for n:=1 to ScrW do
  for n1:=1 to ScrH do
    if cell[n,n1].visible
    then
      WriteMP(n,n1,false)
    else
      charxy(0,0,0,n,n1);
end;


function TMaze.CST(x,y:byte): boolean;
begin
case cell[x,y].value of
     CTdooro,
     CTground,
     CTstaird,
     CTstairu : CST:=true;
     CTdoorc,
     CTwindow,
     CTwall  : cst:=false;
     else  cst:=false;
     end;
end;


  (*check how POINT is suitable for tunnel*)
function TMaze.CheckPT(x,y:byte;ndir:Tdir): byte;
var res: byte;

begin

res:=2;      (*fully suitable for tunnel*)

if (x=1) or (x=80) or (y=1) or (y=20)
then
  res:=0     (*not suitable - point is on border*)
else
  if ((cell[x,y+1].value<>ctWALL) and (ndir<> dDOWN)) or
     ((cell[x,y-1].value<>ctWALL) and (ndir<>   dUP)) or
     ((cell[x-1,y].value<>ctWALL) and (ndir<> dLEFT)) or
     ((cell[x+1,y].value<>ctWALL) and (ndir<>dRIGHT))
  then
    res:=1   (*suitable for door (end of tunnel) - tunnel runs into room or other tunnel*)
  else
    case ndir of ddown  : if (cell[x+1,y-1].value<>ctWALL) or (cell[x-1,y-1].value<>ctWALL) then res:=0;
                 dup    : if (cell[x+1,y+1].value<>ctWALL) or (cell[x-1,y+1].value<>ctWALL) then res:=0;
                 dright : if (cell[x-1,y-1].value<>ctWALL) or (cell[x-1,y+1].value<>ctWALL) then res:=0;
                 dleft  : if (cell[x+1,y-1].value<>ctWALL) or (cell[x+1,y+1].value<>ctWALL) then res:=0;
                 end;
             (*not suitable - tunnel runs between rooms*)


checkpt:=res;
end;






  (*------Recursive tunnel generator------*)
procedure TMaze.Tunnel(x,y:byte;ndir:tdir;prior:string);
var n: byte;
    indir: tdir;
    cx,cy,bx,by: byte;
    bad: boolean;

begin
bad:=false;
bx:=x;
by:=y;
cpx:=x;
cpy:=y;

case ndir of dUP    : indir:=dDOWN;
             dDOWN  : indir:=dUP;
             dLEFT  : indir:=dRIGHT;
             dRIGHT : indir:=dLEFT;
             end;

for n:=1 to 4 do
    if not endg then

    case checkpt(cpx,cpy,indir) of

    0: bad:=true;

    1: begin
       putdoor(cpx,cpy);
       endg:=true;
       end;

    2: begin
       if cell[cpx,cpy].value<>ctDOORO
       then
         begin
         cell[cpx,cpy].value:=ctground;
         cell[cpx,cpy].groundtype:=gtstone;
         end;
       if n<>4 then
       case ndir of
          dleft:  dec(cpx);
          dright: inc(cpx);
          dup:    DEC(cpy);
          ddown:  inc(cpy);
          end;
       end;
    end;


if not endg then
begin

cx:=cpx;
cy:=cpy;
if not bad then
   for n:=1 to 4 do
    case prior[n] of
    'l':if indir<>dLEFT  then tunnel(cx-1,cy,dLEFT,'ldru');
    'u':if indir<>dUP    then tunnel(cx,cy-1,dUP,'uldr');
    'r':if indir<>dRIGHT then tunnel(cx+1,cy,dRIGHT,'ruld');
    'd':if indir<>dDOWN  then tunnel(cx,cy+1,dDOWN,'drul');
    end;
cpx:=cx;
cpy:=cy;

if not endg then
     while (cpx<>bx) or (cpy<>by) do
     begin
         cell[cpx,cpy].value:=ctWALL;

         case indir of
           dleft:  dec(cpx);
           dright: inc(cpx);
           dup:    DEC(cpy);
           ddown:  inc(cpy);
         end;
         cell[cpx,cpy].value:=ctWAll;

     end;
end;
end;



  (*--------Generating tunnels---------*)
procedure TMaze.GenTunnels(rcount,tunlen: byte);
var n,n1,n2: byte;
    a: byte;
    b:tdir;
    xr,yr: byte;
    ena: boolean;
    prior: string[4];
begin
for n2:=1 to (rcount+2)*2 do
 repeat
  repeat
  ena:=true;
  n1:=random(rcount)+1;
  a:=random(4)+1;
  case a of

  1:    begin
         xr:=room[n1].left+random(room[n1].width)+1;
         yr:=room[n1].top-1;
         prior:='uldr';
         b:=dUP;
         if checkpt(xr,yr,ddown)<>2 then ena:=false;
         end;
  2:  begin
         xr:=room[n1].left-1;
         yr:=room[n1].top+random(room[n1].height)+1;
         prior:='ldru';
         b:=dleft;
         if checkpt(xr,yr,dright)<>2 then ena:=false;
         end;
  3: begin
         xr:=room[n1].left+room[n1].width+1;
         yr:=room[n1].top+random(room[n1].height)+1;
         prior:='ruld';
         b:=dright;
         if checkpt(xr,yr,dleft)<>2 then ena:=false;
         end;
  4:  begin
         xr:=room[n1].left+random(room[n1].width)+1;
         yr:=room[n1].top+room[n1].height+1;
         prior:='drul';
         b:=dDown;
         if checkpt(xr,yr,dup)<>2 then ena:=false;
         end;
  end;
  until ena;
 cpx:=xr;
 cpy:=yr;
 endg:=false;
 putdoor(xr,yr);
 tunnel(xr,yr,b,prior);
 until endg;
end;

(*------generating random ROOMS------*)
procedure TMaze.GenRooms(rcount: byte);
var ena:boolean;
    x,y,xr,yr: byte;
    n,n1,n2: byte;
begin
for n2:=1 to rcount do
    begin
    repeat
    ena:=true;
    xr:=random(5)+6;
    yr:=random(5)+3;
    x:=random(scrw-xr-2)+2;
    y:=random(scrh-yr-2)+2;
    for n:=x-1 to xr+x+1 do for n1:=y-1 to y+yr+1 do
      if not (cell[n,n1].value=ctwall) then ena:=false;
    until ena;

    room[n2].width:=xr;
    room[n2].height:=yr;
    room[n2].top:=y;
    room[n2].left:=x;

    for n:=x to x+xr do for n1:= y to y+yr do
      begin
      cell[n,n1].value:=ctground;
      cell[n,n1].groundtype:=gtstone;
      end
    end
end;

procedure TMaze.Generate(rcount,tunlen:byte);
var r: word;
    ptmp: TPtrQM;
begin
randomize;
for k:=1 to scrw do for k1:=1 to scrh do
  begin
  cell[k,k1].value:=ctwall;
  cell[k,k1].Walltype:=140;       (*making MAZE solid*)
  cell[k,k1].visible:=false;      (*making MAZE unseen*)
  cell[k,k1].visiblenow:=false;   (*making MAZE unseen*)
  cell[k,k1].light:=5;            (*making MAZE illuminated*)
  cell[k,k1].items:=nil;          (*no items at maze*)
  cell[k,k1].monster:=nil;        (*no monsters at maze*)
  end;
genrooms(rcount);
(*-----declaring "ENTER" and "EXIT" Stairs----*)
stairsup[1].stairindex:=1;
stairsup[1].mapindex:=index-1;

stairsdown[1].stairindex:=1;
stairsdown[1].mapindex:=index+1;


stairsdown[1].stairindex:=1;
(*----Placing "ENTER" ('>') and "EXIT" ('<') points
             in room center--*)
with cell[ room[1].left+(room[1].width div 2) ,room[1].top+(room[1].height div 2)] do
  begin
  value:=ctStairu;
  stairindex:=1
  end;
with cell[ room[2].left+(room[2].width div 2) ,room[2].top+(room[2].height div 2)] do
  begin
  value:=ctStaird;
  stairindex:=1
  end;

gentunnels(rcount,tunlen);
for k:=1 to scrw do
  for k1:=1 to scrh do
    with cell[k,k1] do
      if value=ctwall
      then
        walltype:=$87;
end;

procedure tmaze.genmonsters(var PBegin: TPtrQM);
var k,k1: byte;
    r: word;
    ptmp:TPtrQM;
begin
r:=10*difficulty;
k:=1;
k1:=1;
while r>0 do
  begin
  inc(k);
  if k>80
  then
    begin
    inc(k1);
    k:=1;
    end;

  if k1>20
  then
    k1:=1;
  if (cell[k,k1].value=ctground) and (cell[k,k1].monster=nil) and (random(60)<1)
  then
    begin
    new(ptmp);
    ptmp^.data.create(random(10),difficulty);
    ptmp^.data.posx:=k;
    ptmp^.data.posy:=k1;
    addmonster(pbegin,ptmp);
    cell[k,k1].monster:=ptmp;
    dec(r)
    end;
  end;
end;

procedure TMaze.save;
var F: TMazeFile;
    Rec: ^TMazeRec;
begin
new(Rec);
assign(f,map_savefile);
reset(f);
seek(f,index);
rec^.cell:=cell;
rec^.difficulty:=difficulty;
rec^.stairsup:=stairsup;
rec^.stairsdown:=stairsdown;
write(f,rec^);
saveitems;
dispose(rec);
close(f)
end;

procedure Tmaze.load(_index: byte);
var F: TMazeFile;
    Rec: ^TMazeRec;
begin
assign(f,map_savefile);
reset(f);
seek(f,_index);
new(rec);
read(f,rec^);
stairsup:=rec^.stairsup;
stairsdown:=rec^.stairsdown;
cell:=rec^.cell;
index:=_index;
for k:=1 to 80 do
  for k1:=1 to 20 do
    begin
    cell[k,k1].visiblenow:=false;
    cell[k,k1].items:=nil;
    cell[k,k1].monster:=nil;
    end;
loaditems;
dispose(Rec);
close(f);
end;

end.