program itemedit;

{$PACKRECORDS 1}
{$PACKENUM 1}  


uses crt,g_input,g_enemy,g_tool,g_screen;
var fil: file of Titem;
    Rec: TItem;
    MemRec: TItem;
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


procedure loaditem(var _item:TItem;_index: byte);
begin
reset(fil);
seek(fil,_index);
read(fil,_item);
close(fil)
end;

procedure saveitem(var _item:TItem);
begin
reset(fil);
seek(fil,_item.index);
write(fil,_item);
close(fil)
end;



procedure drawItem;
label _a,_b,_c;
var _s: string;
  procedure writeWSkill(_skill: TWSkill);
  begin
                case _skill of
                   wsSword   :fprint('  |7Sword ');
                   wsDagger  :fprint('  |7Dagger');
                   wsBow     :fprint('  |7Bow   ');
                   wsSpear   :fprint('  |7Spear ');
                   wsAxe     :fprint('  |7Axe   ');
                   wsUnarmed :fprint('  |7Unarmed ');
                   wsMaces   :fprint('  |7Mace ');
                   wsShoot   :fprint('  |7Shooting ');
                   wsThrown  :fprint('  |7Thrown ');
                   end;
  end;
begin
with rec do
begin
s:='';
clrscr;
gotoxy(1,4);
fprint('_14Price');
fprint('                  |7'+inttostr(price));
writeln;
fprint('_14Name');
fprint('                   |7'+name);
s:=name+' ';
writeln;
fprint('_14Weight');
fprint('                 |7'+inttostr(weight));
writeln;
fprint('_14Maxhits');
fprint('                |7'+inttostr(maxhits));
writeln;
fprint('_14Type                   ');
maxy:=5;
case itemtype of
      itmoney:   begin
                 fprint('|7Money');
                 maxy:=5;
                 end;

      it1weapon: begin
                 fprint('|71-hand weapon');
                 goto _a

                 end;
      it2weapon: begin
                 fprint('|72-hand weapon');

                 goto _a
                 end;
      ittweapon: begin
                 fprint('|7Throwing weapon');

                 goto _a
                 end;
      itrweapon: begin
                 fprint('|7Ranged weapon');
                 maxy:=4;
                 _a:
                 writeln;
                 fprint('_14Weapon Skill         ');
                 writeWSkill(rec.wskill);
                 writeln;

                 if rec.wtohit>=0
                 then
                   s:=s+'+';
                 s:=s+inttostr(rec.wtohit);

                 s:=s+', defence ';
                 if rec.wdef>=0
                 then
                   s:=s+'+';
                 s:=s+inttostr(rec.wdef);

                 s:=s+' '+inttostr(rec.damdice shr 4)+'d';
                 case (rec.damdice mod 16) of
                    1:k:=1;
                    2:k:=2;
                    3:k:=3;
                    4:k:=4;
                  5,6:k:=6;

                  7,8:k:=8;

                 9,10:k:=10;
                11,12:k:=12;
                  else k:=20;
                  end;
                  s:=s+inttostr(k);
                 if rec.wdam>=0
                 then
                   s:=s+'+';
                 s:=s+inttostr(rec.wdam);

                 fprint('_14+Offence');
                 fprint('               |7'+inttostr(rec.wtohit));
                 writeln;
                 fprint('_14+Defence');
                 fprint('               |7'+inttostr(rec.wdef));
                 writeln;
                 fprint('_14+Damage');
                 fprint('                |7'+inttostr(rec.wdam));
                 writeln;
                 fprint('_14Dice');
                 fprint('                   |7'+inttostr(rec.damdice));
                 maxy:=10;
                 end;

      itShield:      begin
                     fprint('|7Shield');
                     maxy:=8;
                     goto _c
                     end;
      itarmorHead   :begin
                     fprint('|7Helmet');
                     rec.armortype:=athead;
                     goto _b
                     end;
      itarmorBodyHi :begin
                     fprint('|7Body heavy armor');
                     rec.armortype:=atbodyhi;
                     goto _b
                     end;
      itarmorBodyLo :begin
                     fprint('|7Body light armor');
                     rec.armortype:=atbodylo;
                     goto _b
                     end;
      itarmorLegs   :begin
                     fprint('|7Legs');
                     rec.armortype:=atleg;
                     goto _b
                     end;
      itarmorArms   :begin
                     fprint('|7Arms');
                     rec.armortype:=atarm;
                     goto _b
                     end;
      itarmorPalm   :begin
                     fprint('|7Palms');
                     rec.armortype:=atPalm;
                     goto _b
                     end;
      itarmorBelt   :begin
                     fprint('|7Belt');
                     rec.armortype:=atbelt;
                     goto _b
                     end;
      itarmorBack:   begin
                     fprint('|7Cloak');
                     rec.armortype:=atback;
                     _b:


                     maxy:=8;
                     _c:
                 s:=s+'to hit ';
                 if rec.atohit>=0
                 then
                   s:=s+'+';
                 s:=s+inttostr(rec.wtohit);

                 s:=s+', defence ';
                 if rec.wdef>=0
                 then
                   s:=s+'+';
                 s:=s+inttostr(rec.wdef);


                 s:=s+', armor ';
                 if rec.arm>=0
                 then
                   s:=s+'+';
                 s:=s+inttostr(rec.arm);

                     writeln;
                     fprint('_14+Offence');
                     fprint('               |7'+inttostr(rec.atohit));
                     writeln;
                     fprint('_14+Defence');
                     fprint('               |7'+inttostr(rec.adef));
                     writeln;
                     fprint('_14Armor');
                     fprint('                  |7'+inttostr(rec.arm));
                     writeln;

                     end;

      itammo:        begin
                     fprint('|7Ammo');
                     writeln;
                     fprint('_14Ammotype             ');
                     writeWSkill(rec.ammotype);
                     writeln;
                     maxy:=6
                     end;


      itfood:        begin
                     fprint('|7Food');
                     writeln;
                     fprint('_14Nutrients');
                     fprint('              |7'+inttostr(rec.nutrients));
                     writeln;
                     fprint('_14Poison');
                     fprint('                 |7'+inttostr(rec.poison));
                     writeln;
                     maxy:=7
                     end;
      itpotion:      begin
                     fprint('|7Potion');
                     writeln;
                     fprint('_14Type');
                     fprint('                   |7'+inttostr(rec.potiontype));
                     writeln;
                     fprint('_14Power');
                     fprint('                  |7'+inttostr(rec.ppower));
                     writeln;
                     maxy:=7
                     end;

      itwand:        begin
                     fprint('|7Wand');
                     writeln;
                     fprint('_14Magic');
                     fprint('                  |7'+inttostr(rec.magictype));
                     writeln;
                     fprint('_14Charges');
                     fprint('                |7'+inttostr(rec.charges));
                     writeln;
                     maxy:=7
                     end;
      itring:        begin
                     fprint('|7Ring');
                     writeln;
                     fprint('_14Param.                 ');
                     case rec.param of
                       STR: fprint('|7Strength');
                       DEX: fprint('|7Dexterity');
                       MAG: fprint('|7Magic');
                       MOV: fprint('|7Move');
                       INT: fprint('|7Intell.');
                       CON: fprint('|7Const.');
                       WIL: fprint('|7Willpower');
                       REF: fprint('|7Reflex');
                       end;

                     writeln;
                     fprint('_14Modif.');
                     fprint('                 |7'+inttostr(rec.modif));
                     writeln;
                     maxy:=7
                     end;


      itjunk:        fprint('|7Junk');
      ittool:        fprint('|7Tool');

      end;
end;
gotoxy(2,20);
_s:=fullname(rec);
write(_s);
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
assign(fil,itemsfile);
textcolor(lightgray);
textbackground(black);
changed:=false;
clrscr;

x:=1;
y:=1;
quit:=false;
loaditem(rec,0);
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
                           case y of
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
                           changed:=true
                           end;

            K_Right      : begin
                           case y of
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
                           changed:=true
                           end;

            #73          : begin        (*PgUp*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               saveitem(rec);

                           k:=rec.index;
                           if rec.index>0
                           then
                             loaditem(rec,k-1);
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
                               saveitem(rec);
                           k:=rec.index;
                           if rec.index<Itemcount
                           then
                             loaditem(rec,k+1);
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
                               saveitem(rec);
                           loaditem(rec,0);
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
                               saveitem(rec);

                           loaditem(rec,itemcount);
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
           saveitem(rec);

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
             saveitem(rec);
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
      'U': begin
           write('File updated to ',' elements. Press any key.');
           readkey
           end;
      'A': begin
           rewrite(fil);
           with rec do
             begin
             name:='Item';
             weight:=10;
             hits:=5;
             maxhits:=5;
             itemtype:=itjunk;
             for k:=0 to ItemCount do
               begin
               index:=k;
               name:='ItemNo'+inttostr(k);
               write(fil,Rec);
               end;
             end;
           close(fil);
           messagetoscreen(true,'Done filling file');
           end;

      '-': with rec do
           begin
           case y of
             1: dec(price);
             3: dec(weight);
             4: dec(maxhits);
             6: case rec.itemtype of
                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     dec(atohit);

                  itring:       if param=str
                                then
                                  param:=ref
                                else
                                  DEC(param);
                  itwand:       dec(magictype);
                  itpotion:     dec(potiontype);
                  itfood:       dec(nutrients);
                  end;


             7: case itemtype of
                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     dec(adef);

                  it1weapon,
                  it2weapon,
                  ittweapon,
                  itrweapon:    dec(wtohit);

                  itring:       DEC(modif);
                  itwand:       dec(charges);
                  itpotion:     dec(ppower);

                  itfood:       dec(poison);
                  end;

             8: case itemtype of
                  it1weapon,
                  it2weapon,
                  ittweapon,
                  itrweapon:    dec(wdef);

                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     dec(arm);


                  end;
             9: dec(wdam);
            10: dec(damdice);
             end;
           changed:=true;
           drawitem;
           markitem(y)
           end;
      '+': with rec do
           begin
           case y of
             3: inc(weight);
             4: inc(maxhits);
             6: case rec.itemtype of
                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     inc(atohit);
                  itring:       if param=ref
                                then
                                  param:=str
                                else
                                  inc(param);
                  itwand:       inc(magictype);
                  itpotion:     inc(potiontype);
                  itfood:       inc(nutrients);
                  end;


             7: case itemtype of
                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     inc(adef);

                  it1weapon,
                  it2weapon,
                  ittweapon,
                  itrweapon:    inc(wtohit);

                  itfood:       inc(poison);
                  itring:       inc(modif);
                  itwand:       inc(charges);
                  itpotion:     inc(ppower);
                  end;

             8: case itemtype of
                  it1weapon,
                  it2weapon,
                  ittweapon,
                  itrweapon:    inc(wdef);

                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     inc(arm);


                  end;
             9: inc(wdam);
            10: inc(damdice);
             end;
           changed:=true;
           drawitem;
           markitem(y)
           end;

      #13: begin            (*Enter*)
           case y of
             1: begin
                gotoxy(24,4);
                textbackground(green);
                textcolor(black);
                write('                    ');
                gotoxy(24,4);
                readint(i,30);
                rec.price:=i;
                changed:=true;
                end;
             2: begin
                gotoxy(24,5);
                textbackground(green);
                textcolor(black);
                write('                    ');
                gotoxy(24,5);
                readstr(s,30);
                rec.name:=s;
                changed:=true;
                end;
             3: begin
                gotoxy(24,6);
                textbackground(green);
                textcolor(black);
                write('                    ');
                gotoxy(24,6);
                readint(i,4);
                rec.weight:=i;
                changed:=true;
                end;
             4: begin
                gotoxy(24,7);
                textbackground(green);
                textcolor(black);
                write('                    ');
                gotoxy(24,7);
                readint(i,4);
                rec.maxhits:=i;
                changed:=true;
                end;

             6:case rec.itemtype of
                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     begin
                                gotoxy(24,9);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,9);
                                readbyte(k);
                                rec.atohit:=k-50;
                                end;
                  itfood:       begin
                                gotoxy(24,9);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,9);
                                readint(i,5);
                                rec.nutrients:=i;
                                end;
                  end;

             7: case rec.itemtype of
                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     begin
                                gotoxy(24,10);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,10);
                                readbyte(k);
                                rec.adef:=k-50;
                                end;
                  it1weapon,
                  it2weapon,
                  ittweapon,
                  itrweapon:    begin
                                gotoxy(24,10);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,10);
                                readbyte(k);
                                rec.wtohit:=k-50;
                                end;

                  itfood:       begin
                                gotoxy(24,10);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,10);
                                readbyte(k);
                                rec.poison:=k-50;
                                end;
                  end;

             8: case rec.itemtype of
                  it1weapon,
                  it2weapon,
                  ittweapon,
                  itrweapon:    begin
                                gotoxy(24,11);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,11);
                                readbyte(k);
                                rec.wdef:=k-50;
                                end;

                  itarmorHead,
                  itarmorBodyHi,
                  itarmorBodyLo,
                  itarmorLegs,
                  itarmorArms,
                  itarmorPalm,
                  itarmorBelt,
                  itarmorBack,
                  itshield:     begin
                                gotoxy(24,11);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,11);
                                readbyte(k);
                                rec.arm:=k-50;
                                end;


                  end;
             9:                 begin
                                gotoxy(24,12);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,12);
                                readbyte(k);
                                rec.wdam:=k-50;
                                end;

             10:                begin
                                gotoxy(24,13);
                                textbackground(green);
                                textcolor(black);
                                write('                    ');
                                gotoxy(24,13);
                                readbyte(k);
                                rec.damdice:=k;
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