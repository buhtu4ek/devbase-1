uses crt;
var i,j:byte;
begin
textbackground(0);
clrscr;
for i:=0 to 7 do
  begin
  textbackground(i);
  for j:=0 to 15 do
    begin
    textcolor(j);
    write(j:4)
    end;
  writeln;
  end;
readkey
end.