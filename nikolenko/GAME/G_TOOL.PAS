(* Written by Nikolenko Vitaly
      Copyright 2003             *)
unit g_Tool;

{$PACKRECORDS 1}
{$PACKENUM 1}  

INTERFACE

const
  K_SQ    = 'Q';

  K_UP_LEFT    = #71;
  K_UP_RIGHT   = #73;
  K_DOWN_LEFT  = #79;
  K_DOWN_RIGHT = #81;
  K_UP         = #72;
  K_DOWN       = #80;
  K_LEFT       = #75;
  K_RIGHT      = #77;



  ScrH    = 20;
  ScrW    = 80;

{=------Commands-------=}
  C_DOWN_LEFT  = 1;
  C_DOWN       = 2;
  C_DOWN_RIGHT = 3;
  C_LEFT       = 4;
  C_RIGHT      = 6;
  C_UP_LEFT    = 7;
  C_UP         = 8;
  C_UP_RIGHT   = 9;

  C_0          = 10;
  C_1          = 11;
  C_2          = 12;
  C_3          = 13;
  C_4          = 14;
  C_5          = 15;
  C_6          = 16;
  C_7          = 17;
  C_8          = 18;
  C_9          = 19;

  C_Inven      = 20;
  C_WInven     = 21;
  C_WSkill     = 22;

  C_Test1      = 100;
  C_Test2      = 101;

  C_Help       = 242;
  C_Drink      = 243;
  C_QPICK      = 244;
  C_PICK       = 245;
  C_DROP       = 246;
  C_ATTACK     = 247;
  C_ENTER      = 248;
  C_CANCEL     = 249;
  C_GO_UP      = 250;
  C_GO_DOWN    = 251;
  C_OPEN_DOOR  = 252;
  C_CLOSE_DOOR = 253;
  C_ZOS        = 254;
  C_QUIT       = 255;


  {MORDA : char = chr(2);}

type
  TDir = (DUp,DDown,DLeft,DRight,DUpLeft,DUpRight,DDownLeft,DDownRight,DHere,DNull);


procedure cursoroff;
procedure cursoron;
procedure charxy(ch_,cl_,bcl_,x,y: byte);
procedure mark(x,y:byte);
procedure unmark(x,y:byte);
function GetDice(dice: byte):byte;
function IntToStr(int: integer):string;
function getx(x:byte; dir:tdir):byte;
function gety(y:byte; dir:tdir):byte;
function CheckPtRange(x,y:byte):boolean;

IMPLEMENTATION

uses
  crt, windows;

function getx(x:byte; dir:tdir):byte;
begin
case dir of dup,ddown,dnull,dhere: getx:=x;
            dleft,dupleft,ddownleft: getx:=x-1;
            dright,ddownright,dupright: getx:=x+1;
            end;
end;

function gety(y:byte; dir:tdir):byte;
begin
case dir of dleft,dright,dhere,dnull: gety:=y;
            ddownleft,ddownright,ddown: gety:=y+1;
            dupleft,dupright,dup: gety:=y-1;
            end;
end;


function CheckPtRange(x,y:byte):boolean;
begin
CheckPtRange := ((x>0)and(y>0)and(x<=scrw)and(y<=scrh))
end;





(*=----------No cursor-----------=*)
procedure cursoroff;
var
  HConsole: LongWord;
  cursorInfo: CONSOLE_CURSOR_INFO;
begin
  HConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleCursorInfo(HConsole, cursorInfo);
  cursorInfo.bVisible := false;
  SetConsoleCursorInfo(HConsole, cursorInfo);
// asm
//     mov ah,1
//     mov ch,20h
//     mov cl,00h
//     mov bh,0
//     int 10h
// end;
end;

(*------yes cursor-------*)
procedure cursoron;
var
  HConsole: LongWord;
  cursorInfo: CONSOLE_CURSOR_INFO;
begin
  HConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleCursorInfo(HConsole, cursorInfo);
  cursorInfo.bVisible := true;
  SetConsoleCursorInfo(HConsole, cursorInfo);
// asm
//     mov ah,1
//     mov ch,00h
//     mov cl,01h
//     mov bh,0
//     int 10h
// end;
end;

function inttostr(int: integer):string;
var s: string[5];
begin
str(int,s);
inttostr:=s;
end;


(* throw dice xdy *)
function getdice(dice: byte):byte;
var n,n1: byte;
begin
n1:=0;
for n:=1 to (dice shr 4) do inc(n1,random(dice mod 16)+1);
getdice:=n1;
end;



function flength(txt: string):byte;
var
  n,ln: byte;
begin

  ln:=0;
  n:=1;
  while n<= length(txt) do
    begin
    if txt[n] = '|'
    then
      inc(n)
    else
      inc(ln);
    inc(n)
    end;
flength:=n
end;


procedure charxy(ch_,cl_,bcl_,x,y: byte);
var
  oldx,oldy: byte;
begin

//FillConsoleOutputCharacter
//FillConsoleOutputAttribute 

  oldx:=wherex();
  oldy:=wherey();
  textcolor(cl_);
  textbackground(bcl_);
  gotoxy(x+1,y+1);
  write(ch_);
  gotoxy(oldx,oldy);

{
asm
push ax
push es
push dx
push bx

mov ax,0B800h
mov es,ax
xor ax,ax

mov al,y

inc ax
inc ax

mov bl,160
mul bl

mov dx,ax

xor ax,ax
mov al,x
dec ax
shl ax,1

add ax,dx
mov bx,ax


mov dl,ch_
mov dh,cl_

mov al,bcl_
shl al,4
or  dh,al

mov [es:bx],dx

pop bx
pop dx
pop es
pop ax
end;
}
end;


procedure mark(x,y:byte);
label a,b;
begin
  {
asm
push ax
push es
push bx

mov ax,0B800h
mov es,ax
xor ax,ax

mov al,y

mov bl,160
mul bl

mov dx,ax

xor ax,ax
mov al,x
dec ax
shl ax,1

add ax,dx
inc ax
mov bx,ax

mov al,[es:bx]

mov ah,al
not ah

shl ah,5

jz  a
or  al,01110000b
jmp b
a:
and al,10000000b
or  al,01110000b
b:
mov [es:bx],al

pop bx
pop es
pop ax
end;
}
end;


procedure unmark(x,y:byte);
label a,b;
begin
  {
asm
push ax
push es
push bx

mov ax,0B800h
mov es,ax
xor ax,ax

mov al,y

mov bl,160
mul bl

mov dx,ax

xor ax,ax
mov al,x
dec ax
shl ax,1

add ax,dx
inc ax
mov bx,ax


mov al,[es:bx]
mov ah,al

shl ah,4
jz  a
and al,10001111b
jmp b
a:
and al,10000000b
or  al,00000111b
b:
mov [es:bx],al

pop bx
pop es
pop ax
end;
}
end;


END.