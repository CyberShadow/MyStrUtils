unit MyStrUtils;

interface

uses
  Types;

function Right(S: String; Count: Integer): String;
function EndsWith(S, Tail: String): Boolean;
function ChompLeft(S, Left: String): String;
function Strip(S: String): String;

procedure DeleteArrayItem(var X: TStringDynArray; const Index: Integer);
procedure AddString(var A: TStringDynArray; S: String);
function Split(S: String; Delim: Char): TStringDynArray;
function SplitLines(S: String): TStringDynArray;
function Join(Strings: TStringDynArray; Delim: String): String;
function StringMatch(Strings: TStringDynArray; S: String): Boolean;
function SubstringMatch(Substrings: TStringDynArray; S: String): Boolean;
function FindAndDelete(Strings: TStringDynArray; S: String): Boolean;
function Concatenate(A, B: TStringDynArray): TStringDynArray;
procedure AppendStrings(var A: TStringDynArray; B: TStringDynArray);
function OneString(S: String): TStringDynArray;
function MakeStrings(const S: array of String): TStringDynArray;
function ReplacePrefixedStrings(Strings: TStringDynArray; Prefix: String; NewStrings: TStringDynArray): TStringDynArray;

function GetFile(FN: String): String;
procedure PutFile(FN, Data: String);

implementation

{uses
  SysUtils;}

// ***************************************************************

function Right(S: String; Count: Integer): String;
begin
  if Length(S)<=Count then
    Result := S
  else
    Result := Copy(S, Length(S)-Count+1, Count);
end;

function EndsWith(S, Tail: String): Boolean;
begin
  Result := Copy(S, Length(S)-Length(Tail)+1, Length(Tail))=Tail;
end;

function ChompLeft(S, Left: String): String;
begin
  while Copy(S, 1, Length(Left))=Left do
    Delete(S, 1, Length(Left));
  Result := S;
end;

function Strip(S: String): String;
begin
  while (Length(S)>0) and (S[1] in [#13, #10, #9, ' ']) do
    Delete(S, 1, 1);
  while (Length(S)>0) and (S[Length(S)] in [#13, #10, #9, ' ']) do
    SetLength(S, Length(S)-1);
  Result := S;
end;

// ***************************************************************

procedure DeleteArrayItem(var X: TStringDynArray; const Index: Integer);
var
  I: Integer;
begin
  for I := Index to High(X)-1 do
    X[I] := X[I+1];
  SetLength(X, Length(X)-1);
end;

procedure AddString(var A: TStringDynArray; S: String);
begin
  SetLength(A, Length(A)+1);
  A[High(A)] := S;
end;

function Split(S: String; Delim: Char): TStringDynArray;
begin
  Result := nil;
  if S='' then Exit;
  S := S + Delim;
  while S<>'' do
  begin
    SetLength(Result, Length(Result)+1);
    Result[High(Result)] := Copy(S, 1, Pos(Delim, S)-1);
    Delete(S, 1, Pos(Delim, S));
  end;
end;

function SplitLines(S: String): TStringDynArray;
var
  I: Integer;
begin
  Result := Split(S, #10);
  for I:=0 to High(Result) do
  begin
    while Copy(Result[I], 1, 1)=#13 do
      Delete(Result[I], 1, 1);
    while Copy(Result[I], Length(Result[I]), 1)=#13 do
      Delete(Result[I], Length(Result[I]), 1);
  end;
end;

function Join(Strings: TStringDynArray; Delim: String): String;
var
  I: Integer;
begin
  Result := '';
  if Length(Strings)=0 then
    Exit;
  Result := Strings[0];
  for I := 1 to High(Strings) do
    Result := Result + Delim + Strings[I];
end;

function StringMatch(Strings: TStringDynArray; S: String): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I:=0 to High(Strings) do
    if Strings[I]=S then
      Exit;
  Result := False;
end;

function SubstringMatch(Substrings: TStringDynArray; S: String): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I:=0 to High(Substrings) do
    if Length(Substrings[I])>0 then
      if Pos(Substrings[I], S)>0 then
        Exit;
  Result := False;
end;

function FindAndDelete(Strings: TStringDynArray; S: String): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I:=0 to High(Strings) do
    if Strings[I]=S then
    begin
      DeleteArrayItem(Strings, I);
      Exit;
    end;
  Result := False;
end;

function Concatenate(A, B: TStringDynArray): TStringDynArray;
var
  I: Integer;
begin
  SetLength(Result, Length(A) + Length(B));
  for I:=0 to High(A) do
    Result[I] := A[I];
  for I:=0 to High(B) do
    Result[Length(A) + I] := B[I];
end;

procedure AppendStrings(var A: TStringDynArray; B: TStringDynArray);
var
  I: Integer;
begin
  SetLength(A, Length(A) + Length(B));
  for I:=0 to High(B) do
    A[Length(A) - Length(B) + I] := B[I];
end;

function OneString(S: String): TStringDynArray;
begin
  Result := MakeStrings(S);
end;

function MakeStrings(const S: array of String): TStringDynArray;
var
  I: Integer;
begin
  SetLength(Result, Length(S));
  for I:=0 to High(S) do
    Result[I] := S[I];
end;

function ReplacePrefixedStrings(Strings: TStringDynArray; Prefix: String; NewStrings: TStringDynArray): TStringDynArray;
var
  I, OldRepStart, OldRepEnd: Integer;
begin
  I := 0;
  while I < Length(Strings) do
  begin
    if Copy(Strings[I], 1, Length(Prefix))=Prefix then
      Break;
    Inc(I);
  end;
  //if I=Length(Strings) then
  //  raise Exception.Create('Can''t find old representation: ' + Prefix);
  OldRepStart := I;
  while I < Length(Strings) do
  begin
    if Copy(Strings[I], 1, Length(Prefix))<>Prefix then
      Break;
    Inc(I);
  end;
  OldRepEnd := I;
  SetLength(Result, OldRepStart + (Length(Strings)-OldRepEnd) + Length(NewStrings));
  for I:=0 to OldRepStart-1 do
    Result[I] := Strings[I];
  for I:=0 to High(NewStrings) do
    Result[OldRepStart+I] := NewStrings[I];
  for I:=0 to Length(Strings)-OldRepEnd-1 do
    Result[OldRepStart+Length(NewStrings)+I] := Strings[OldRepEnd+I];
end;

// ***************************************************************

function GetFile(FN: String): String;
var
  F: File;
  OldFileMode: Integer;
begin
  OldFileMode := FileMode; FileMode := {fmOpenRead}0;
  Assign(F, FN);
  Reset(F, 1);
  FileMode := OldFileMode;
  SetLength(Result, FileSize(F));
  if FileSize(F)>0 then
    BlockRead(F, Result[1], FileSize(F));
  CloseFile(F);
end;

procedure PutFile(FN, Data: String);
var
  F: File;
begin
  Assign(F, FN);
  ReWrite(F, 1);
  BlockWrite(F, Data[1], Length(Data));
  CloseFile(F);
end;

end.
