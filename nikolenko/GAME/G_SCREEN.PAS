(* Written by Nikolenko Vitaly
      Copyright 2003             *)
unit g_screen;

{$PACKRECORDS 1}
{$PACKENUM 1}  

INTERFACE
uses g_enemy,g_input;

procedure fPrint(txt: string);
procedure MessageToScreen(clearWindow: boolean;text: string);


IMPLEMENTATION
uses crt;

procedure fPrint(txt: string);
var
  l,n,c: byte;
  c1:integer;
begin
  textcolor(lightgray);
  l:=length(txt);
  n:=1;
  while n <= l do
  begin
    if txt[n] = '|'
    then
      begin
      val(txt[n+1],c,c1);
      textcolor(c);
      inc(n);
      end
    else
      if txt[n] = '_'
      then
        begin
        val(txt[n+1]+txt[n+2],c,c1);
        textcolor(c);
        inc(n);
        inc(n);
        end
      else
        write(txt[n]);
    inc(n);
  end;
end;

procedure MessageToScreen(clearWindow: boolean;text: string);
const winlen: word=0;
var l,n,c: byte;
    c1: integer;

begin
  window(1,1,80,3);
  textcolor(lightgray);
  textbackground(black);
  if clearwindow
  then
    begin
    clrscr;
    gotoxy(1,1);
    winlen:=0
    end
  else
    gotoxy(1+(winlen mod 80),1+(winlen div 80));

  n:=1;
  l:=length(text);
  while n<=l do
    begin

    if text[n] = '|'
    then
      begin
      val(text[n+1],c,c1);
      textcolor(c);
      inc(n)
      end
    else
      begin
      write(text[n]);
      inc(winlen)
      end;
    inc(n);
    if winlen>228
    then
      begin
      write('(More...)');
      readcommand;
      clrscr;
      winlen:=0
      end
    end;
  window(1,1,80,25);
end;


END.