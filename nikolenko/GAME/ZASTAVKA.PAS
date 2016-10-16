unit zastavka;

{$PACKRECORDS 1}
{$PACKENUM 1}  

interface
procedure zast;
implementation
  uses crt;
  procedure zast;
    type TVid=record
           sym:char;
           attr:byte
         end;
    var 
        //Vid:array[1..25,1..80] of TVid absolute $0B800:$0000;
        i,j,k,color:byte;

    const
        symbol='*';
    begin
      clrscr;
      TextColor(white);
      gotoxy(32,10);
      writeln('KursWork');
      gotoxy(24,12);
      writeln('written by Nikolenko Vitaly');
      gotoxy(28,13);
      writeln('student of the "KPI"');
      gotoxy(32,14);
      writeln('group KV-23');
      color:=LightCyan;
      {
      for k:=24 to 50 do
        begin
          vid[17,k].sym:=symbol;
          vid[8,k].sym:=symbol;
          vid[17,k].attr:=color;
          vid[8,k].attr:=color;
        end;
        for i:=0 to 3 do
          begin
            vid[9+i,23-i].sym:=symbol;
            vid[9+i,51+i].sym:=symbol;
            vid[16-i,23-i].sym:=symbol;
            vid[16-i,51+i].sym:=symbol;

            vid[9+i,23-i].attr:=color;
            vid[9+i,51+i].attr:=color;
            vid[16-i,23-i].attr:=color;
            vid[16-i,51+i].attr:=color
          end;

      color:=Cyan;
      for k:=23 to 51 do
        begin
          vid[18,k].sym:=symbol;
          vid[7,k].sym:=symbol;
          vid[18,k].attr:=color;
          vid[7,k].attr:=color;
        end;
        for i:=0 to 4 do
          begin
            vid[8+i,22-i].sym:=symbol;
            vid[8+i,52+i].sym:=symbol;
            vid[17-i,22-i].sym:=symbol;
            vid[17-i,52+i].sym:=symbol;

            vid[8+i,22-i].attr:=color;
            vid[8+i,52+i].attr:=color;
            vid[17-i,22-i].attr:=color;
            vid[17-i,52+i].attr:=color
          end;

       color:=LightBlue;
      for k:=22 to 52 do
        begin
          vid[19,k].sym:=symbol;
          vid[6,k].sym:=symbol;
          vid[19,k].attr:=color;
          vid[6,k].attr:=color;
        end;
        for i:=0 to 5 do
          begin
            vid[7+i,21-i].sym:=symbol;
            vid[7+i,53+i].sym:=symbol;
            vid[18-i,21-i].sym:=symbol;
            vid[18-i,53+i].sym:=symbol;

            vid[7+i,21-i].attr:=color;
            vid[7+i,53+i].attr:=color;
            vid[18-i,21-i].attr:=color;
            vid[18-i,53+i].attr:=color
          end;

       color:=blue;
      for k:=21 to 53 do
        begin
          vid[20,k].sym:=symbol;
          vid[5,k].sym:=symbol;
          vid[20,k].attr:=color;
          vid[5,k].attr:=color;
        end;
        for i:=0 to 6 do
          begin
            vid[6+i,20-i].sym:=symbol;
            vid[6+i,54+i].sym:=symbol;
            vid[19-i,20-i].sym:=symbol;
            vid[19-i,54+i].sym:=symbol;

            vid[6+i,20-i].attr:=color;
            vid[6+i,54+i].attr:=color;
            vid[19-i,20-i].attr:=color;
            vid[19-i,54+i].attr:=color
          end;
        }
     end;
  end.