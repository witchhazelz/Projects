program CellularAutomata;

uses
  Crt;  { unit for color handling in turbo pascal }

const
  SizeX = 40;
  SizeY = 20;
  Generations = 20;
  InitialAlive = 5;

type
  Grid = array[1..SizeX, 1..SizeY] of boolean;

var
  currentGen, nextGen: Grid;
  x, y, dx, dy: integer;

procedure Initialize;
begin
  ClrScr; 
  for x := 1 to SizeX do
    for y := 1 to SizeY do
      currentGen[x, y] := false;
  Randomize;
  for x := 1 to InitialAlive do
    currentGen[Random(SizeX) + 1, Random(SizeY) + 1] := true;
end;

procedure PrintGrid;
begin
  for y := 1 to SizeY do
  begin
    for x := 1 to SizeX do
    begin
      if currentGen[x, y] then
      begin
        TextColor(Green);  { set color for alive cells }
        write('*');
      end
      else
      begin
        TextColor(Blue);  { set color for dead cells }
        write(' ');
      end;
    end;
    writeln;
  end;
  TextColor(White);  { reset text color }
end;

function CountNeighbors(x, y: integer): integer;
var
  nx, ny: integer;
begin
  CountNeighbors := 0;
  for dx := -1 to 1 do
    for dy := -1 to 1 do
      if (dx <> 0) or (dy <> 0) then
      begin
        nx := x + dx;
        ny := y + dy;
        if (nx >= 1) and (nx <= SizeX) and (ny >= 1) and (ny <= SizeY) then
          if currentGen[nx, ny] then
            Inc(CountNeighbors);
      end;
end;

procedure NextGeneration;
begin
  for x := 1 to SizeX do
    for y := 1 to SizeY do
    begin
      case CountNeighbors(x, y) of
        2: nextGen[x, y] := currentGen[x, y];
        3: nextGen[x, y] := true;
      else
        nextGen[x, y] := false;
      end;
    end;
end;

procedure InteractiveMode;
var
  command: string;
begin
  Initialize;
  repeat
    PrintGrid;
    writeln('Enter command (NEXT, RANDOM, QUIT):');
    readln(command);
    case command of
      'NEXT': NextGeneration;
      'RANDOM': Initialize;
      'QUIT': writeln('Exiting...');
    else
      writeln('Unknown command. Use NEXT, RANDOM, or QUIT.');
    end;
  until command = 'QUIT';
end;

begin
  InteractiveMode;
end.
