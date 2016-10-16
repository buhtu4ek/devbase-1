program prog1;

uses
	wincrt, graph, sysutils;

const
	cellwidth = 80;
	cellheight = 40;
var
	gm,gd : integer;

	i: integer;
begin

	DetectGraph(gd,gm);
	InitGraph(gd,gm, '');

	SetTextStyle(1, HorizDir, 1);
	SetColor(white);

	for i := 0 to 255 do
	begin
		setfillstyle(solidfill, i);

		outtextxy(
			cellwidth * (i mod 16)+10,
			cellheight * (i div 16)+ 18,
			inttostr(i)
			);

		bar (
			cellwidth * (i mod 16) + cellwidth div 2,
			cellheight * (i div 16) + 5,
			cellwidth * (i mod 16) + cellwidth-18,
			cellheight * (i div 16) + cellheight - 5
			);		
	end;


	readkey;
	CloseGraph();
end.