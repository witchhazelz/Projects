program OSAKAIDE;

uses crt, sysutils, Dos;

const
  MAX_LINES = 1000;

type
  TLine = record
    Text: string;
    IsComment: boolean;
    IsString: boolean;
  end;

var
  fileName: string;
  fileContent: text;
  choice: char;
  lines: array[1..MAX_LINES] of TLine;
  lineCount: integer;
  i, j: integer;

procedure ShowMenu;
begin
  clrscr;
  writeln('OSAKAIDE');
  writeln('1. New File');
  writeln('2. Open File');
  writeln('3. Save File');
  writeln('4. Display Line Numbers');
  writeln('5. Search Text');
  writeln('6. Replace Text');
  writeln('7. Show File Statistics');
  writeln('8. Show File Size');
  writeln('9. Display File Info');
  writeln('ESC to Exit');
end;

procedure PrintWithSyntaxHighlighting;
var
  i: integer;
begin
  for i := 1 to lineCount do
  begin
    if lines[i].IsComment then
      TextColor(Cyan)
    else if lines[i].IsString then
      TextColor(Blue)
    else
      TextColor(White);

    writeln(lines[i].Text);
  end;
  TextColor(White);
end;

procedure ParseLines;
var
  inString: boolean;
  i: integer;
begin
  inString := False;
  for i := 1 to lineCount do
  begin
    lines[i].IsComment := False;
    lines[i].IsString := False;

    if (Pos('//', lines[i].Text) = 1) then
      lines[i].IsComment := True;

    if (Pos('"', lines[i].Text) > 0) then
      lines[i].IsString := True;
  end;
end;

procedure DisplayLoadingScreen;
begin
  clrscr;
  TextColor(Green);
  writeln('Loading...');
  writeln;
  writeln('⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣤⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⡿⢿⣿⣛⣟⣿⡿⢿⢿⣷⣦⡀⠀⠀⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⢰⣯⣷⣿⣿⣿⢟⠃⢿⣟⣿⣿⣾⣷⣽⣺⢆⠀⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⢸⣿⢿⣾⢧⣏⡴⠀⠈⢿⣘⣿⢿⣿⣿⣿⣿⡆⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⢹⣿⢠⡶⠒⢶⠀⠀⣠⠒⠒⠢⡀⢿⣿⣿⣿⡇⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⣿⣿⠸⣄⣠⡾⠀⠀⠻⣀⣀⡼⠁⢸⣿⣿⣿⣿⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⢰⣿⣿⠀⠀⠀⡔⠢⠤⠔⠒⢄⠀⠀⢸⣿⣿⣿⣿⡇⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⢸⣿⣿⣄⠀⠸⡀⠀⠀⠀⠀⢀⡇⠠⣸⣿⣿⣿⣿⡇⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⢸⣿⣿⣿⣷⣦⣮⣉⢉⠉⠩⠄⢴⣾⣿⣿⣿⣿⡇⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⢸⣿⣿⢻⣿⣟⢟⡁⠀⠀⠀⠀⢇⠻⣿⣿⣿⣿⣿⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⢸⠿⣿⡈⠋⠀⠀⡇⠀⠀⠀⢰⠃⢠⣿⡟⣿⣿⢻⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠸⡆⠛⠇⢀⡀⠀⡇⠀⠀⡞⠀⠀⣸⠟⡊⠁⠚⠌⠀⠀⠀⠀');
  writeln('⠀⠀⠀⠀⠀⠀⡍⠨⠊⣒⠴⠀⡇⡴⠋⡋⢐⠐⠅⡀⠐⢠⠕⠂⢂⠀⠀⠀');
  Delay(1000);
  clrscr;
end;

procedure NewFile;
begin
  DisplayLoadingScreen;
  fileName := '';
  lineCount := 0;
  writeln('New file created. Type your stuff below already. Press F1 to save or ESC to exit.');
end;

procedure OpenFile;
var
  lineText: string;
begin
  DisplayLoadingScreen;
  clrscr;
  writeln('Enter file name to open:');
  readln(fileName);
  Assign(fileContent, fileName);
  {$I-}
  Reset(fileContent);
  if IOResult = 0 then
  begin
    lineCount := 0;
    while not Eof(fileContent) do
    begin
      Inc(lineCount);
      Readln(fileContent, lineText);
      if lineCount <= MAX_LINES then
        lines[lineCount].Text := lineText
      else
        writeln('File exceeds maximum line count');
    end;
    Close(fileContent);
    ParseLines;
    clrscr;
    writeln('File content:');
    PrintWithSyntaxHighlighting;
    writeln;
    writeln('Press F1 to save or ESC to exit.');
  end
  else
    writeln('Error opening file...what did you do.....');
end;

procedure SaveFile;
begin
  DisplayLoadingScreen;
  clrscr;
  if fileName = '' then
  begin
    writeln('Enter file name to save:');
    readln(fileName);
  end;
  Assign(fileContent, fileName);
  Rewrite(fileContent);
  for i := 1 to lineCount do
    Writeln(fileContent, lines[i].Text);
  Close(fileContent);
  writeln('File saved as *drumroll please* ', fileName);
end;

procedure DisplayLineNumbers;
begin
  clrscr;
  writeln('Line numbers:');
  for i := 1 to lineCount do
    writeln(i:4, ' ', lines[i].Text);
end;

procedure SearchText;
var
  searchTerm: string;
  found: boolean;
  i: integer;
begin
  clrscr;
  writeln('Enter text to search:');
  readln(searchTerm);
  found := False;
  for i := 1 to lineCount do
  begin
    if Pos(searchTerm, lines[i].Text) > 0 then
    begin
      writeln('Found on line ', i);
      found := True;
    end;
  end;
  if not found then
    writeln('404 not found.');
end;

procedure ReplaceText;
var
  searchTerm, replaceTerm: string;
  i: integer;
begin
  clrscr;
  writeln('Enter text to search:');
  readln(searchTerm);
  writeln('Enter new text:');
  readln(replaceTerm);
  for i := 1 to lineCount do
    lines[i].Text := StringReplace(lines[i].Text, searchTerm, replaceTerm, [rfReplaceAll]);
  writeln('Text replaced.');
end;

procedure ShowFileStatistics;
var
  totalChars, totalWords, totalLines: integer;
  line: string;
begin
  clrscr;
  totalChars := 0;
  totalWords := 0;
  totalLines := lineCount;
  
  for i := 1 to lineCount do
  begin
    line := lines[i].Text;
    Inc(totalChars, Length(line));
    totalWords := totalWords + WordCount(line);
  end;
  
  writeln('File Statistics:');
  writeln('Total Lines: ', totalLines);
  writeln('Total Words: ', totalWords);
  writeln('Total Characters: ', totalChars);
end;

procedure ShowFileSize;
var
  fileSize: LongInt;
begin
  clrscr;
  Assign(fileContent, fileName);
  {$I-}
  Reset(fileContent);
  if IOResult = 0 then
  begin
    fileSize := FileSize(fileContent);
    Close(fileContent);
    writeln('File Size: ', fileSize, ' bytes');
  end
  else
    writeln('Error opening file.');
end;

procedure DisplayFileInfo;
begin
  clrscr;
  writeln('File Information:');
  writeln('File Name: ', fileName);
  ShowFileSize;
  ShowFileStatistics;
end;

begin
  clrscr;
  ShowMenu;
  choice := ReadKey;

  case choice of
    '1': NewFile;
    '2': OpenFile;
    '3': SaveFile;
    '4': DisplayLineNumbers;
    '5': SearchText;
    '6': ReplaceText;
    '7': ShowFileStatistics;
    '8': ShowFileSize;
    '9': DisplayFileInfo;
    else
      writeln('Wrooonggggg choice.');
  end;

  repeat
    choice := ReadKey;
    case choice of
      #27: begin  // ESC key
        clrscr;
        writeln('Exiting...*cue elevator music*');
        halt;
      end;
      #0: begin
        choice := ReadKey;
        if choice = #59 then  // F1 key
          SaveFile;
      end;
    end;
  until False;
end.

