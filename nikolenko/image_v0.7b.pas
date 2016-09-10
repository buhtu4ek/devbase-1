program image;

uses graph, wincrt;

var
	gm,gd: smallInt;
	i,j: integer;
	RainbowColors: array[1..6] of integer = (red,yellow,green,lightblue,blue,magenta);
	x, y: integer;


procedure Proc1(x, y: integer);
begin
	MoveTo(x,y);

	SetColor(white);
	LineRel(10,-10);
	LineRel(6,6);
	LineRel(6,-6);
	LineRel(10,10);
end;

procedure Proc2(x, y: integer);
var
	i: Integer;
begin
	for i := 1 to 6 do
	begin
		SetColor(RainbowColors[i]);
		setfillstyle(SolidFill, RainbowColors[i]);
		PieSlice(x,y,0,20,20-3*i);
	end;
end;

begin
	gm:=0;
	gd:=0;
	DetectGraph(Gm,Gd);
	InitGraph(gm,gd,'');

	setfillstyle(SolidFill, lightblue);
	bar(0,0, 800, 300);
	
	setfillstyle(SolidFill, lightgreen);
	bar(0,300, 800, 600);

	setfillstyle(SolidFill, yellow);
	SetColor(yellow);
	FillEllipse(50, 50, 20, 20);

	setfillstyle(SolidFill, brown);
	bar(590,200,610,400);

	SetColor(red);
	setfillstyle(SolidFill, red);
	PieSlice(400,300, 0, 180, 95);

	SetColor(yellow);
	setfillstyle(SolidFill, yellow);
	PieSlice(400,300, 0, 180, 90);

	j:= 360 div 5;
	for i := 0 to 5-1 do
	begin
		PieSlice(50,50, i*j, i*j + 20, 30 );
	end;

	SetColor(green);
	setfillstyle(SolidFill, green);
	PieSlice(400,300, 0, 180, 85);

	FillEllipse(600, 200, 40, 40);
	FillEllipse(600, 100, 40, 40);
	FillEllipse(580, 150, 40, 40);
	FillEllipse(620, 150, 40, 40);


	for i:= 1 to 5 do
	begin
	x:= 50 + i*40;
	y:=	550;
	line(x,y, x,y-30);	
	line(x,y, x-10,y-10);
	line(x,y, x+10,y-10);
	end;	

	SetColor(lightblue);
	setfillstyle(SolidFill, lightblue);
	PieSlice(400,300, 0, 180, 80);

	SetColor(blue);
	setfillstyle(SolidFill, blue);
	PieSlice(400,300, 0, 180, 75);

	FillEllipse(600, 500, 100,50);

	FillEllipse(90, 520, 10,10);
	FillEllipse(130, 520, 10,10);
	FillEllipse(170, 520, 10,10);
	FillEllipse(250, 520, 10,10);

	for i := 1 to 5 do
	begin
		Proc2(490 + i*30, 520-10*i);				
	end;

	SetColor(Magenta);
	setfillstyle(SolidFill, Magenta);
	PieSlice(400,300, 0, 180, 70);

	SetColor(lightblue);
	setfillstyle(SolidFill, lightblue);
	PieSlice(400,300, 0, 180, 65);

	for i := 1 to 5 do
	begin
		Proc1(200+50*i, 100-i*4);
	end;

	SetColor(red);
	setfillstyle(SolidFill, red);
	FillEllipse(600, 130, 5, 10);
	FillEllipse(578, 160, 5, 10);
	FillEllipse(614, 170, 5, 10);
	FillEllipse(595, 200, 5, 10);

	setfillstyle(SolidFill, magenta);
	SetColor(magenta);
	i:=0;
	while i <5  do
		i:=i+1;
		x:= 50 + i*40;
		y:=	550;
		FillEllipse(x, y-30, 7,7);		

	readkey();
	closeGraph();
end.