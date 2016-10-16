uses crt;
var c: char;
    n: byte;
begin
clrscr;
n:=0;
repeat
c:=readkey;
writeln(n,'  -  ','''',chr(n),'''');
inc(n);
until c='Q';
end.
