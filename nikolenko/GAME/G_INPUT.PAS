(* Written by Nikolenko Vitaly
      Copyright 2003             *)
unit g_input;

{$PACKRECORDS 1}
{$PACKENUM 1}  

INTERFACE
uses g_tool;

function ReadCommand: byte;
function AskYN(str:string): boolean;
function AskDir(str:string): Tdir;
function AskQuant(str: string;max: word): word;

procedure reade;
Procedure readbyte(var num: byte);
Procedure readint(var num: integer;qnum: byte);
Procedure readstr(var str: string;qnum: byte);

IMPLEMENTATION
uses crt,g_screen;




procedure reade;
var c: char;
begin
repeat
  c:=readkey;
until c=#13;
end;



function Extended: byte;
var ch:char;
begin
  ch:=readkey;
  case ch of
    #67          : Extended:=C_Test1;  (*F9*)
    #68          : Extended:=C_Test2;  (*F10*)
    K_UP         : Extended:=C_UP;
    K_DOWN       : Extended:=C_DOWN;
    K_LEFT       : Extended:=C_LEFT;
    K_RIGHT      : Extended:=C_RIGHT;
    K_UP_LEFT    : Extended:=C_UP_LEFT;
    K_UP_RIGHT   : Extended:=C_UP_RIGHT;
    K_DOWN_LEFT  : Extended:=C_DOWN_LEFT;
    K_DOWN_RIGHT : Extended:=C_DOWN_RIGHT;
    else Extended:=0;
  end;
end;

function ReadCommand: byte;
begin
  case readkey of
     #0: ReadCommand:=Extended;
    'Q': ReadCommand:=C_QUIT;
    'H': ReadCommand:=C_ZOS;
    'h': ReadCommand:=C_Help;
    'o': ReadCommand:=C_OPEN_DOOR;
    'c': ReadCommand:=C_CLOSE_DOOR;
    '<': ReadCommand:=C_GO_UP;
    '>': ReadCommand:=C_GO_DOWN;
#27,'z': ReadCommand:=C_CANCEL;
    'a': ReadCommand:=C_ATTACK;
    '0': ReadCommand:=C_0;
    '1': ReadCommand:=C_1;
    '2': ReadCommand:=C_2;
    '3': ReadCommand:=C_3;
    '4': ReadCommand:=C_4;
    '5': ReadCommand:=C_5;
    '6': ReadCommand:=C_6;
    '7': ReadCommand:=C_7;
    '8': ReadCommand:=C_8;
    '9': ReadCommand:=C_9;
    'i': ReadCommand:=C_inven;
    'I': ReadCommand:=C_WInven;
    #13: ReadCommand:=C_ENTER;
    'W': ReadCommand:=C_WSkill;
    'd': ReadCommand:=C_DROP;
    'p': ReadCommand:=C_PICK;
    ',': ReadCommand:=C_QPICK;
    'D': ReadCommand:=C_Drink;
    else ReadCommand:=0;
  end ;

end;

Procedure readstr(var str: string;qnum: byte);
var k: integer;
    ch: char;
    n: integer;
begin
str:='';
k:=0;
repeat
  ch:=readkey;
  case ch  of
    #0:readkey;
    #8:if k>0
       then
         begin
         write(#8);
         write(' ');
         write(#8);
         dec(k);
         dec(str[0])
         end;
    #13:;
    else
      if k<qnum then
        begin
        write(ch);
        str:=str+ch;
        inc(k);
        end
    end
until ch=#13;

end;

function AskQuant(str: string;max: word): word;
var k: integer;
    ch: char;
    n: integer;
    s: string[5];
    var num: word;
begin
messagetoscreen(true,str+'(Max='+inttostr(max)+'): ');
gotoxy(length(str)+12,1);
s:='';
k:=0;
repeat
  ch:=readkey;
  case ch  of
    #0: reADKEY;
   #27: num:=0;
    '0'..'9':if k<4
             then
               begin
               write(ch);
               inc(k);
               s:=s+ch
               end;


    #8:if k>0
       then
         begin
         write(#8);
         write(' ');
         write(#8);
         dec(k);
         dec(s[0])
         end;
    #13:if s=''
        then
          num:=max
        else
          begin
          val(s,n,k);
          if k<>0
          then
            num:=0
          else
            if n>max
            then
              num:=max
            else
              num:=n;
          end;
    end;
until (ch=#13) or (ch=#27);
askquant:=num

end;

Procedure readint(var num: integer;qnum: byte);
var k: integer;
    ch: char;
    n: integer;
    s: string[5];
begin
s:='';
k:=0;
repeat
  ch:=readkey;
  case ch  of
    #0: reADKEY;
    '0'..'9':if k<qnum
             then
               begin
               write(ch);
               inc(k);
               s:=s+ch
               end;


    #8:if k>0
       then
         begin
         write(#8);
         write(' ');
         write(#8);
         dec(k);
         dec(s[0])
         end;
    #13:if s=''
        then
          num:=0
        else
          begin
          val(s,n,k);
          if k<>0
          then
            num:=0
          else
            num:=n;
          end;
    end;
until ch=#13;

end;

Procedure readbyte(var num: byte);
var k: integer;
    ch: char;
    n: integer;
    s: string[3];
begin
s:='';
k:=0;
repeat
  ch:=readkey;
  case ch  of
    #0: reADKEY;
    '0'..'9':if k<3
             then
               begin
               write(ch);
               inc(k);
               s:=s+ch
               end;


    #8:if k>0
       then
         begin
         write(#8);
         write(' ');
         write(#8);
         dec(k);
         dec(s[0])
         end;
    #13:if s=''
        then
          num:=0
        else
          begin
          val(s,n,k);
          if n>255
          then
            num:=0
          else
            num:=n
          end;
    end;
until ch=#13;

end;


function AskYN(str:string): boolean;
var c:char;
begin
  Messagetoscreen(true,'|7'+str+'?|8(y/n) ');
  repeat c:=readkey;c:=upcase(c) until (c='Y') or (c='N');
  if c = 'Y' then askyn:=true
  else
     begin
     messagetoscreen(true,'');
     askyn:=false;
     end
end;


function Askdir(str:string): Tdir;
var n:byte;
begin
  Messagetoscreen(true,'|7'+str+'?|8 14789632 |7- direction (z - abort)');
  repeat n:=readcommand until
                        (n=C_UP)
                     or (n=C_down)
                     or (n=C_left)
                     or (n=C_right)
                     or (n=C_up_right)
                     or (n=C_down_right)
                     or (n=C_up_left)
                     or (n=C_down_left)
                     or (n=C_enter)
                     or (n=C_cancel);
  messagetoscreen(true,'');
  if (n=C_cancel) or (n=c_enter) then begin
              askdir:=dnull;
              end
  else
  case n of        C_UP   :askdir:=dup;
                   C_DOWN :askdir:=ddown;
                   C_LEFT :askdir:=dleft;
                   C_RIGHT:askdir:=dright;
                   c_up_right: askdir:=dupright;
                   c_up_left : askdir:=dupleft;
                   c_down_right : askdir:=ddownright;
                   c_down_left  : askdir:=ddownleft;

                   end;
end;

END.