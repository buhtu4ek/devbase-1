program MonsEdit;

{$PACKRECORDS 1}
{$PACKENUM 1}  

uses crt,g_input,g_enemy,g_tool,g_screen;

var fil: file of TMonsterRec;
    Rec: TMonsterRec;
    MemRec: TMonsterRec;
    ch: char;
    quit: boolean;
    x,y: byte;
    maxy: byte;
    k,k1: byte;
    changed: boolean;
    memItem: TItem;
    s: string;
    wr: word;
    i: integer;


procedure loadmon(var _item:TMonsterRec;_index: byte);
begin
reset(fil);
seek(fil,_index);
read(fil,_item);
close(fil)
end;

procedure savemon(var _item:TMonsterRec);
begin
reset(fil);
seek(fil,_item.index);
write(fil,_item);
close(fil)
end;



procedure drawItem;
label _a,_b,_c;
var _s: string;
    _Item: TItem;

begin
with rec do
begin
clrscr;
gotoxy(1,4);
fprint('_14Name');
fprint('                   |7'+name);
writeln;
fprint('_14Symbol');
fprint('                 |7'+chr(symbol));
s:=name+' ';
writeln;
fprint('_14Color');
fprint('                  |7'+inttostr(Scolor));
charxy(symbol,scolor,0,45,1);
writeln;
fprint('_14Maxhits');
fprint('                |7'+inttostr(maxhp));
writeln;
fprint('_14Speed');
fprint('                  |7'+inttostr(speed));
writeln;
fprint('_14Dice');
fprint('                   |7'+inttostr(Wdice));
case (wdice mod 16) of
    1: k:=1;
    2: k:=2;
    3: k:=3;
    4: k:=4;
  5,6: k:=6;
  7,8: k:=8;
 9,10: k:=10;
11,12: k:=12;
  else k:=20;
  end;
fprint('                    '+inttostr(wdice shr 4)+'d'+inttostr(k));
writeln;
fprint('_14DV');
fprint('                     |7'+inttostr(dv));
writeln;
fprint('_14OV');
fprint('                     |7'+inttostr(ov));
writeln;
fprint('_14AV');
fprint('                     |7'+inttostr(av));
writeln;
fprint('_14DM');
fprint('                     |7'+inttostr(dm));
writeln;
fprint('_14Item1');
fprint('                  |7'+inttostr(Item1));

loaditem(_Item,item1);
fprint('                    '+fullname(_Item));
writeln;

fprint('_14Item2');
fprint('                  |7'+inttostr(Item2));
loaditem(_Item,item2);
fprint('                    '+fullname(_Item));
writeln;

fprint('_14Item3');
fprint('                  |7'+inttostr(Item3));
loaditem(_Item,item3);
fprint('                    '+fullname(_Item));
writeln;
maxy:=13;

end;

gotoxy(2,20);
textcolor(lightgray);
end;



procedure markitem(_index: byte);
var k: byte;
begin
for k:=1 to 20 do
  mark(23+k,_index+2);
end;

procedure unmarkitem(_index: byte);
var k: byte;
begin
for k:=1 to 20 do
  unmark(23+k,_index+2);
end;



(*=====MAIN=====*)
begin
cursoroff;
assign(fil,monsterdatafile);
                            textcolor(lightgray);
textbackground(black);
changed:=false;
clrscr;

y:=1;
quit:=false;
loadmon(rec,0);
drawItem;
markitem(1);
repeat
gotoxy(50,2);
fprint('|7Index=_14'+inttostr(rec.index));
ch:=readkey;
case ch of
      #0: begin
          ch:=readkey;
          case ch of

            K_UP         : begin
                           unmarkitem(y);
                           if Y>1
                           then
                             dec(y);
                           markitem(y);
                           end;
            K_DOWN       : begin
                           unmarkitem(y);
                           if Y<MaxY
                           then
                             inc(y);
                           markitem(y);

                           end;

            K_Left       : begin
                           {case y of
                             5: begin
                                if rec.itemtype=itFood
                                then
                                  rec.itemtype:=itjunk
                                else
                                  dec(rec.itemtype)

                                end;
                             6:case rec.itemtype of
                                 it1weapon,
                                 it2weapon,
                                 ittweapon,
                                 itrweapon: begin
                                            if rec.wskill=wssword
                                            then
                                              rec.wskill:=wsbow
                                            else
                                              dec(rec.wskill)
                                            end;

                                 itammo:    begin
                                            if rec.ammotype>wsshoot
                                            then
                                              dec(rec.ammotype)
                                            else
                                              rec.ammotype:=wsthrown
                                            end;
                                 end;

                             end;
                           drawitem;
                           markitem(y);
                           changed:=true}
                           end;

            K_Right      : begin
                           {case y of
                             5:begin
                               if rec.itemtype=itjunk
                               then
                                 rec.itemtype:=itfood
                               else
                                 inc(rec.itemtype)
                               end;

                             6:case rec.itemtype of
                                 it1weapon,
                                 it2weapon,
                                 ittweapon,
                                 itrweapon: begin
                                            if rec.wskill=wsbow
                                            then
                                              rec.wskill:=wssword
                                            else
                                              inc(rec.wskill)

                                            end;
                                 itammo:    begin
                                            if rec.ammotype<wsthrown
                                            then
                                              inc(rec.ammotype)

                                            else
                                              rec.ammotype:=wsshoot
                                            end;
                                 end;
                             end;
                           drawitem;
                           markitem(y);
                           changed:=true}
                           end;

            #73          : begin        (*PgUp*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemon(rec);

                           k:=rec.index;
                           if rec.index>0
                           then
                             loadmon(rec,k-1);
                           drawItem;
                           y:=1;
                           markitem(1);
                           changed:=false
                           end;

            #81          : begin       (*PgDn*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemon(rec);
                           k:=rec.index;
                           if rec.index<Itemcount
                           then
                             loadmon(rec,k+1);
                           drawItem;
                           y:=1;
                           markitem(1);
                           changed:=false
                           end;

            #132         : begin  (*Ctrl+pgUp*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemon(rec);
                           loadmon(rec,0);
                           changed:=false;
                           drawitem;
                           y:=1;
                           markitem(1);
                           end;

            #118         : begin  (*Ctrl+pgDn*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemon(rec);

                           loadmon(rec,itemcount);
                           changed:=false;
                           drawitem;
                           y:=1;
                           markitem(1)
                           end;
            #31          : begin    (*Alt+S*)
                           changed:=true
                           end;
            END;
          END;

      's': begin            (*--save--*)
           savemon(rec);
           messagetoscreen(true,'Saved in '+inttostr(rec.index)+' file slot. Press any key.');
           readcommand;
           messagetoscreen(true,'');
           changed:=false;
           end;

      'Q': begin
           if changed
           then
             if askyn('Save before continuing')
             then
             savemon(rec);
           quit:=true;
           end;
      'm': memrec:=rec;

      'p': begin
           memrec.index:=rec.index;
           rec:=memrec;
           changed:=true;
           drawitem;
           markitem(y)
           end;

      'A': begin
           rewrite(fil);
           with rec do
             begin
             maxhp:=10;
             Symbol:=77;
             Scolor:=red;
             speed:=90;
             wdice:=$16;
             ov:=0;
             av:=0;
             dv:=0;
             dm:=0;
             item1:=0;
             item2:=0;
             item3:=0;

             for k:=0 to MonsterCount do
               begin
               index:=k;
               name:='MonsterNo'+inttostr(k);
               write(fil,Rec);
               end;
             end;
           close(fil);
           messagetoscreen(true,'Done filling file');
           end;


      '-': with rec do
           begin
           case y of
             3: begin
                dec(scolor);
                scolor:=scolor mod 16
                end;
             4: dec(maxhp);
             5: dec(speed);
             6: dec(wdice);
             7: dec(dv);
             8: dec(ov);
             9: dec(av);
            10: dec(dm);
            11: if item1>0 then dec(item1);
            12: if item2>0 then dec(item2);
            13: if item3>0 then dec(item3);
            end;
           changed:=true;
           drawitem;
           markitem(y)
           end;

      '+': with rec do
           begin
           case y of
             3: begin
                inc(scolor);
                scolor:=scolor mod 16
                end;
             4: inc(maxhp);
             5: inc(speed);
             6: inc(wdice);
             7: inc(dv);
             8: inc(ov);
             9: inc(av);
            10: inc(dm);
            11: if item1< itemcount then inc(item1);
            12: if item2< itemcount then inc(item2);
            13: if item3< itemcount then inc(item3);
            end;
           changed:=true;
           drawitem;
           markitem(y)
           end;

      #13: begin            (*Enter*)
           gotoxy(24,y+3);
           textbackground(green);
           textcolor(black);
           write('                    ');
           gotoxy(24,y+3);
           changed:=true;
           case y of
             1: begin
                readstr(s,16);
                rec.name:=s;
                end;
             2: begin
                readstr(s,1);
                rec.symbol:=ord(s[1]);
                end;
             3: begin
                readbyte(k);
                rec.scolor:=k;
                end;
             4: begin
                readint(i,4);
                rec.maxhp:=i;
                end;
             5: begin
                readint(i,2);
                rec.speed:=i;
                end;
             6: begin
                readbyte(k);
                rec.wdice:=k;
                end;
             7: begin
                readbyte(k);
                rec.dv:=k;
                end;
             8: begin
                readbyte(k);
                rec.ov:=k;
                end;
             9: begin
                readbyte(k);
                rec.av:=k;
                end;
            10: begin
                readbyte(k);
                rec.dm:=k;
                end;
            11: begin
                readbyte(k);
                rec.item1:=k;
                end;
            12: begin
                readbyte(k);
                rec.item2:=k;
                end;
            13: begin
                readbyte(k);
                rec.item3:=k;
                end;
            end;
           textbackground(black);
           drawitem;
           markitem(y);
           end;
      end

until quit;
textcolor(lightgray);
textbackground(black);

end.