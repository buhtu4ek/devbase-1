uses crt;
var c: char;
begin
clrscr;
repeat
c:=readkey;
writeln(c,'   -    ',ord(c));
until c='Q';
end.
