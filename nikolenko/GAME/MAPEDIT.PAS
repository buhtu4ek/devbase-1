program mapedit;

{$PACKRECORDS 1}
{$PACKENUM 1}  


uses crt,g_input,g_map,g_tool,g_screen;
var map: tmaze;
    fil: TMazeFile;
    Rec: TMazeRec;
    ch: char;
    quit: boolean;
    x,y: byte;
    k,k1: byte;
    memcell: TCell;
    changed: boolean;


procedure stairs;
var ena: boolean;
    nx,ny: byte;
begin
x:=1;
y:=1;
clrscr;
writeln('               Stairs       ');
writeln('         UP             DOWN');
writeln('No    Map  Index      Map  Index');
(*      '==-------=======___-------=======*)
for k:=1 to 20 do
  begin
  write(k:2);
  write(map.stairsup[k].mapindex:6,map.stairsup[k].stairindex:6);
  writeln(map.stairsdown[k].mapindex:10,map.stairsdown[k].stairindex:6)
  end;
ena:=false;
mark(6,3);
mark(7,3);
mark(8,3);
repeat
case readkey of
  #0 : begin

       case x of
         1: nx:=5;
         2: nx:=11;
         3: nx:=21;
         4: nx:=27;
         end;

       for k:=1 to 3 do unmark(nx+k,y+2);

       case readkey of
         K_UP         : if y>1 then dec(y);
         K_DOWN       : if y<20 then inc(y);
         K_LEFT       : if x>1 then dec(x);
         K_RIGHT      : if x<4 then inc(x);
         end;
       end;
  #13: begin
       ny:=y+3;
       case x of
           1: begin
              gotoxy(6,ny);
              textbackground(green);
              write('   ');
              gotoxy(6,ny);
              readbyte(map.stairsup[y].mapindex);
              textbackground(black);
              gotoxy(6,ny);
              write(map.stairsup[y].mapindex:3)
              end;
           2: begin
              gotoxy(12,ny);
              textbackground(green);
              write('   ');
              gotoxy(12,ny);
              readbyte(map.stairsup[y].stairindex);
              textbackground(black);
              gotoxy(12,ny);
              write(map.stairsup[y].stairindex:3)
              end;
           3: begin
              gotoxy(22,ny);
              textbackground(green);
              write('   ');
              gotoxy(22,ny);
              readbyte(map.stairsdown[y].mapindex);
              textbackground(black);
              gotoxy(22,ny);
              write(map.stairsdown[y].mapindex:3)
              end;
           4: begin
              gotoxy(28,ny);
              textbackground(green);
              write('   ');
              gotoxy(28,ny);
              readbyte(map.stairsdown[y].stairindex);
              textbackground(black);
              gotoxy(28,ny);
              write(map.stairsdown[y].stairindex:3)
              end;
           end;

       end;

  'Q': ena:=true;

  end;

case x of
  1: nx:=5;
  2: nx:=11;
  3: nx:=21;
  4: nx:=27;
  end;
ny:=y+2;
for k:=1 to 3 do mark(nx+k,ny);

until ena;

end;

procedure move(dir:tdir);
var nx,ny: byte;
begin
nx:=getx(x,dir);
ny:=gety(y,dir);
if (nx>0)and(nx<81)and(ny>0)and(ny<21)
then
  begin
  x:=nx;
  y:=ny;
  {jumpxy;}
  end;
end;

procedure writecell(cell:tcell);
begin
with cell do
begin
write(' type=');
case value of
  ctwall:    begin
             write('Wall ');
             case (walltype shr 5) of
                0: write('straw');
                1: write('wood');
                2: write('brick');
                3: write('stone');
                4: write('dstone');
                5: write('granite');
                6: write('metal');
                7: write('unbrk.');
                end;
             write(' str=');
             write(walltype mod 32);
             end;

  ctground:  begin
             write('Ground ');
             case groundtype of
                gtwood:  write('wooden');
                gtstone: write('stone');
                gtgrass: write('grass');
                gtsand:  write('sand');
                GTIce:     write('ice');
                GTGranite: write('granite');
                GTBrick:   write('brick');
                GTMetal:   write('metal');
                end;

             end;

  ctdooro:   begin
             write('Opened door ');

             case ((doorotype shl 1)shr 6) of
                0: write('wooden ');
                1: write('wood+metal ');
                2: write('metal ');
                3: write('unbrk. ');
                end;

             if (doorotype shr 7)=1
             then
               write('locked ')
             else
               write('unlocked ');

             write('key=',doorctype mod 32);

             end;

  ctdoorc:   begin
             write('Closed door ');

             case ((doorctype shl 1)shr 6) of
                0: write('wooden ');
                1: write('wood+metal ');
                2: write('metal ');
                3: write('unbrk. ');
                end;

             if (doorctype shr 7)=1
             then
               write('locked ')
             else
               write('unlocked ');
             write('key=',doorctype mod 32);

             end;

  ctstairu:  begin
             write('Stairs up ');
             write('index=',stairindex);
             write('->',map.stairsup[stairindex].mapindex,':',map.stairsup[stairindex].stairindex)
             end;

  ctstaird:  begin
             write('Stairs down ');
             write('index=',stairindex);
             write('->',map.stairsdown[stairindex].mapindex,':',map.stairsdown[stairindex].stairindex)
             end;
  end;
write(' Light=',Light);
if visible
then
  write(' vis')
else
  write(' nvis');

if visiblenow
then
  write(' vnow')
else
  write(' nvnow');
end;

end;


procedure draw(var maze: TMaze);
begin
for k:=1 to 80 do
  for k1:=1 to 20 do
    maze.writemp(k,k1,false);

end;



procedure drawsidebar;
var s,t: string[10];
begin
textcolor(lightgray);
window(1,1,80,3);
clrscr;


window(1,24,80,25);
clrscr;

write('x=',x:2);
write(' CURRENT:');
writecell(map.cell[x,y]);
writeln;

write('y=',y:2);
write(' MEMORY: ');
writecell(memcell);
window(1,1,80,25);
gotoxy(60,1);
write('Map index=',map.index:3);


end;


procedure savemap;
var Rec: ^TMazeRec;
begin
new(Rec);
reset(fil);
seek(fil,map.index);
rec^.cell:=map.cell;
rec^.difficulty:=map.difficulty;

rec^.stairsup:=map.stairsup;
rec^.stairsdown:=map.stairsdown;

write(fil,rec^);
dispose(rec);
close(fil);
end;



procedure loadmap(_index: byte);
var Rec: ^TMazeRec;

begin
reset(fil);
seek(fil,_index);
new(rec);

read(fil,rec^);

map.stairsup:=rec^.stairsup;
map.stairsdown:=rec^.stairsdown;

map.cell:=rec^.cell;
map.index:=_index;
for k:=1 to 80 do
  for k1:=1 to 20 do
    with map do
    begin
    cell[k,k1].visible:=false;
    cell[k,k1].visiblenow:=false;
    cell[k,k1].items:=nil;
    cell[k,k1].monster:=nil;
    end;
close(fil);
dispose(Rec);
end;


procedure main_screen;
begin
window(1,1,80,25);
draw(map);
drawsidebar;
x:=1;
y:=1;
end;


(*=====MAIN=====*)
begin
cursoroff;
assign(fil,map_filename);
textcolor(lightgray);
textbackground(black);
changed:=false;
clrscr;
loadmap(0);
draw(map);
x:=1;
y:=1;
quit:=false;
with memcell do
  begin
  value:=ctground;
  groundtype:=gtstone;
  monster:=nil;
  items:=nil;
  end;

repeat
drawsidebar;
mark(x,y+2);
ch:=readkey;
unmark(x,y+2);
case ch of
      #0: begin
          ch:=readkey;
          case ch of
            K_UP         : move(dup);
            K_DOWN       : move(ddown);
            K_LEFT       : move(dleft);
            K_RIGHT      : move(dright);
            #120..#129   : begin
                           for k:=1 to 80 do
                             for k1:=1 to 20 do
                               if ch=#129
                               then
                                 map.cell[k,k1].light:=0
                               else
                                 map.cell[k,k1].light:=ord(ch)-119;
                           end;
            #83          : begin        (*Del*)
                           map.cell[x,y].value:=ctground;
                           map.cell[x,y].groundtype:=gtstone;
                           map.cell[x,y].Light:=0;
                           changed:=true
                           end;
            #82          : begin       (*Ins*)
                           map.cell[x,y]:=memcell;
                           map.writemp(x,y,false);

                           if x=80
                           then
                             begin
                             if y<20
                             then
                               begin
                               x:=1;
                               inc(y);
                               end
                             end
                           else
                             inc(x);
                           changed:=true
                           end;

            #31          : begin    (*Alt+S*)

                           stairs;

                           main_screen;
                           changed:=true
                           end;

            #71          : x:=1;   (*Home*)
            #79          : x:=80;  (*End*)
            #119         : begin   (*Ctrl+Home*)
                           x:=1;
                           y:=1
                           end;
            #117         : begin   (*Ctrl+End*)
                           x:=80;
                           y:=20
                           end;

            #73          : begin  (*pgUp*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemap;

                           k:=map.index;
                           if map.index>0
                           then
                             loadmap(k-1);
                           changed:=false;
                           draw(map)
                           end;

            #81          : begin  (*pgDn*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemap;
                           k:=map.index;
                           if map.index<mapcount
                           then
                             loadmap(k+1);
                           changed:=false;
                           draw(map)
                           end;

            #132         : begin  (*Ctrl+pgUp*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemap;
                           loadmap(0);
                           changed:=false;
                           draw(map)
                           end;

            #118         : begin  (*Ctrl+pgDn*)
                           if changed
                           then
                             if askyn('Save before continuing')
                             then
                               savemap;

                           loadmap(mapcount);
                           changed:=false;
                           draw(map)
                           end;
            end;
          end;
      'Q': begin
           if changed
           then
             if askyn('Save before continuing')
             then
             savemap;
           quit:=true;
           end;
      'G': begin
           gotoxy(1,1);
           write('Enter rooms q-ty=>');
           read(k);
           map.generate(k,4);
           draw(map);
           x:=1;y:=1;
           {jumpxy;}
           changed:=true
           end;

      'U': begin
           reset(fil);
           k:=0;
           while not eof(fil) do
             begin
             read(fil,rec);
             inc(k);
             end;
           while k<=Mapcount do
             begin
             write(fil,rec);
             inc(k)
             end;
           close(fil);
           gotoxy(1,1);
           write('File updated to ',MapCount,' elements. Press any key.');
           readkey
           end;
      'A': begin
           rewrite(fil);
           for k:=1 to 80 do
             for k1:=1 to 20 do


           rec.cell:=map.cell;
           rec.stairsup:=map.stairsup;
           rec.stairsdown:=map.stairsdown;
           rec.Difficulty:=1;
           for k:=0 to MapCount do
             write(fil,rec);
           close(fil);
           end;

      's': begin            (*--save--*)
           savemap;
           changed:=false;
           gotoxy(1,1);
           write('Saved in ',map.index,' file slot. Press any key.');
           readcommand;

           end;
      #19: begin            (*--save as--(Ctrl+S)*)
           gotoxy(1,1);
           write('Save in file slot number => ');
           readln(k);
           map.index:=k;
           savemap;
           changed:=false;
           write('Saved in ',map.index,' file slot. Press any key.');
           readcommand;
           end;

      'E': begin
           for k:=1 to scrw do
             for k1:=1 to scrh do
               begin
               map.cell[k,k1]:=memcell;
               with map.cell[k,k1] do
                 begin
                 visible:=false;
                 visiblenow:=false;
                 monster:=nil;
                 items:=nil
                 end;
               end;
           x:=1;
           y:=1;
           draw(map);
           changed:=true
           end;

      'w': begin
           map.cell[x,y].value:=ctwall;
           map.cell[x,y].walltype:=$87;
           changed:=true
           end;

 '0'..'9': begin
           map.cell[x,y].light:=ord(ch)-48;
           changed:=true
           end;
      'o': begin
           map.cell[x,y].value:=ctdooro;
           map.cell[x,y].doorotype:=$00;
           changed:=true
           end;

      'c': begin
           map.cell[x,y].value:=ctdoorc;
           map.cell[x,y].doorctype:=$00;
           changed:=true
           end;

      'g': begin
           map.cell[x,y].value:=ctground;
           map.cell[x,y].groundtype:=gtstone;
           changed:=true
           end;

      '>': begin
           map.cell[x,y].value:=ctstaird;
           map.cell[x,y].stairindex:=1;
           changed:=true
           end;

      '<': begin
           map.cell[x,y].value:=ctstairu;
           map.cell[x,y].stairindex:=1;
           changed:=true
           end;

      'p': begin
           map.cell[x,y]:=memcell;
           changed:=true
           end;
      'm': memcell:=map.cell[x,y];

      '+': begin
           with map.cell[x,y] do
           case value of
             ctstairu,
             ctstaird: begin
                       if stairindex=20
                       then
                         stairindex:=1
                       else
                         inc(stairindex);
                       end;
             ctwall:   begin
                       k:=walltype mod 32;
                       if k<31
                       then
                         inc(k)
                       else
                         k:=0;
                       walltype:=((walltype shr 5 ) shl 5)+k;
                       end;

             ctdooro:  begin
                       k:=doorotype mod 32;
                       if k<31
                       then
                         inc(k)
                       else
                         k:=0;
                       doorotype:=((doorotype shr 5)shl 5)+k;
                       end;

             ctdoorc:  begin
                       k:=doorctype mod 32;
                       if k<31
                       then
                         inc(k)
                       else
                         k:=0;
                       doorctype:=((doorctype shr 5)shl 5)+k;
                       end;

             end;
           changed:=true
           end;

      '-': begin
           with map.cell[x,y] do
           case value of
             ctstairu,
             ctstaird: begin
                       if stairindex=1
                       then
                         stairindex:=20
                       else
                         dec(stairindex);
                       end;
             ctwall:   begin
                       k:=walltype mod 32;
                       if k>0
                       then
                         dec(k)
                       else
                         k:=31;
                       walltype:=((walltype shr 5) shl 5)+k;
                       end;

             ctdooro:  begin
                       k:=doorotype mod 32;
                       if k>0
                       then
                         dec(k)
                       else
                         k:=31;
                       doorotype:=((doorotype shr 5)shl 5)+k;
                       end;

             ctdoorc:  begin
                       k:=doorctype mod 32;
                       if k>0
                       then
                         dec(k)
                       else
                         k:=31;
                       doorctype:=((doorctype shr 5)shl 5)+k;
                       end;

             end;
           changed:=true
           end;

      ' ': begin
           with map.cell[x,y] do
           case value of

             ctwall:   begin
                       k:=walltype shr 5;
                       inc(k);
                       walltype:=(walltype mod 32)+(k shl 5);
                       end;

             ctground: begin
                       if groundtype=gtsand
                       then
                          groundtype:=gtwood
                       else
                         inc(groundtype);

                       end;
             ctdooro:  begin
                       k:=(doorotype shl 1) shr 6;
                       k1:=doorotype shr 7;
                       inc(k);
                       doorotype:=(doorotype mod 32)+(k shl 5)+(k1 shl 7);
                       end;

             ctdoorc:  begin
                       k:=(doorctype shl 1) shr 6;
                       k1:=doorctype shr 7;
                       inc(k);
                       doorctype:=(doorctype mod 32)+(k shl 5)+(k1 shl 7);
                       end;

             end;
           changed:=true
           end;
      end;
map.writemp(x,y,false);
until quit;
textcolor(lightgray);
textbackground(black);

end.