program image;

uses graph, wincrt;

const
	NumberOfSunRays = 5;
	SunRadius = 20;
	SunRayRadius = 30;

	TreeRadius = 40;
	TreeHeight = 200;

	NumberOfFlowers = 5;
	NumberOfSeaGulls = 6;
	NumberOfFish = 4;

var
	gm,gd: smallInt;
	i: integer;
	RainbowColors: array[1..6] of integer = (red,yellow,green,lightblue,blue,red+blue);

procedure DrawBackGround();
begin
	// Sky
	setfillstyle(SolidFill, lightblue);
	bar(0,0, 800, 300);
	
	// Land
	setfillstyle(SolidFill, lightgreen);
	bar(0,300, 800, 600);
end;

procedure DrawSun(x, y: integer; SunColor: integer);
var
	i: Integer;	
	RayAngle: integer;
begin	
	setfillstyle(SolidFill, SunColor);
	SetColor(SunColor);
	
	// Sun rays
	RayAngle:= 360 div NumberOfSunRays;
	for i := 0 to NumberOfSunRays-1 do
	begin
		PieSlice(x,y, i*RayAngle, i*RayAngle + 20, SunRayRadius );
	end;

	// Sun body
	FillEllipse(x, y, SunRadius, SunRadius);
end;

procedure DrawTree(x, y: integer);
var
	YLeaves: Integer;
begin
	//Trunk
	setfillstyle(SolidFill, brown);
	bar(x-10,y-TreeHeight,x+10,y);

	// Leaves
	setfillstyle(SolidFill, green);
	SetColor(green);
	YLeaves := y - TreeHeight;

	FillEllipse(x, YLeaves, TreeRadius, TreeRadius);
	FillEllipse(x, YLeaves-100, TreeRadius, TreeRadius);
	FillEllipse(x-20, YLeaves-50, TreeRadius, TreeRadius);
	FillEllipse(x+20, YLeaves-50, TreeRadius, TreeRadius);

	// Fruits
	setfillstyle(SolidFill, red);
	SetColor(red);
	FillEllipse(x, YLeaves - 70, 5, 10);
	FillEllipse(x-22, YLeaves - 40, 5, 10);
	FillEllipse(x+14, YLeaves - 30, 5, 10);
	FillEllipse(x-5, YLeaves, 5, 10);
end;

procedure DrawFlower(x, y: integer);
begin

	// leaves
	SetColor(green);	
	line(x,y, x,y-30);	
	line(x,y, x-10,y-10);
	line(x,y, x+10,y-10);

	// Flower
	setfillstyle(SolidFill, blue);
	SetColor(blue);
	FillEllipse(x, y-30, 10,10);

	setfillstyle(SolidFill, magenta);
	SetColor(magenta);
	FillEllipse(x, y-30, 7,7);
end;

procedure DrawPond(x, y: integer);
begin
	setfillstyle(SolidFill, blue);
	SetColor(blue);
	FillEllipse(x, y, 100,50);
end;

procedure DrawRainbow(x, y: integer; BkColor: integer);
var
	i: Integer;
begin

	for i:= 1 to 6 do
	begin
		SetColor(RainbowColors[i]);
		setfillstyle(SolidFill, RainbowColors[i]);
		PieSlice(x,y, 0, 180, 100-5*i);
	end;

	SetColor(BkColor);
	setfillstyle(SolidFill, BkColor);
	PieSlice(x,y, 0, 180, 100-5*7);
end;

procedure DrawSeaGull(x, y: integer);
begin

	MoveTo(x,y);

	SetColor(white);
	LineRel(10,-10);
	LineRel(6,6);
	LineRel(6,-6);
	LineRel(10,10);
end;

procedure DrawFish(x, y: integer);
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

	DrawBackGround();

	DrawSun(40,40, yellow);

	DrawSun(150,60, red);

	DrawTree(600,400);

	DrawPond(600, 500);
	for i := 1 to NumberOfFish do
	begin
		DrawFish(490 + i*30, 520-10*i);				
	end;

	DrawRainbow(400,300, lightblue);

	for i := 1 to NumberOfFlowers do
	begin
		DrawFlower(50 + i*40, 550);				
	end;

	for i := 1 to NumberOfSeaGulls do
	begin
		DrawSeaGull(200+50*i, 100-i*4);
	end;

	readkey();
	closeGraph();
end.