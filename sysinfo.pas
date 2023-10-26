unit SysInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, StrUtils, StdCtrls, Dialogs, Windows,
  RegistryValue, Registry;

// Report functions
function ExtractFileNameOnly(Filenametouse:String) : String;
function DashedLine(s: String; d: Boolean = False) : String;
procedure GetRegistryInfo(MyMemo: TMemo; KFile: String);

implementation

type
  TStringArray = array of string;

// Created by Bing Chat ;) - splits a string separated by Delimiter
function SplitString(S: string; Delimiter: Char): TStringArray;
  var
    i: Integer;
    Substring: string;
  begin
    SetLength(Result, 0);
    repeat
      i := Pos(Delimiter, S);
      if i > 0 then
      begin
        Substring := Copy(S, 1, i - 1);
        Delete(S, 1, i);
      end
      else
        Substring := S;
      if Substring <> '' then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := Substring;
      end;
    until i = 0;
end;

//Checks if last char is an *, what means that we want list all subkeys or values
function HasWildcard(Path: String) : Boolean;
begin
  HasWildcard := (Path[Length(Path)] = '*');
end;

//Removes last char
function RemoveLastChar(s: string): string;
begin
  RemoveLastChar := Copy(s, 1, Length(s) - 1);
end;

//Lists all subkeys from a key
function ListSubkeys(const RootKey: HKEY; const KeyPath: widestring) : TStringArray;
var
  Key: HKEY;
  Index: DWORD;
  SubkeyName: widestring;
  SubkeyNameLength: DWORD;
begin
  SetLength(Result, 0);
  if RegOpenKeyEx(RootKey, PChar(KeyPath), 0, KEY_READ, Key) = ERROR_SUCCESS then
  begin
    try
      Index := 0;
      repeat
        SubkeyNameLength := MAX_PATH;
        SetLength(SubkeyName, SubkeyNameLength);
        if RegEnumKeyEx(Key, Index, PChar(SubkeyName), SubkeyNameLength, nil, nil, nil, nil) = ERROR_SUCCESS then
        begin
          SetLength(SubkeyName, SubkeyNameLength);
          Result[Length(Result) - 1] := SubkeyName;
          //Writeln(SubkeyName);
          Inc(Index);
        end
        else
          Break;
      until False;
    finally
      RegCloseKey(Key);
    end;
  end;
end;

//https://forum.lazarus.freepascal.org/index.php?topic=44218.0#
function ExtractFileNameOnly(Filenametouse:String) : String;
begin
   ExtractFileNameOnly := ExtractFilename(copy(Filenametouse,1,rpos(ExtractFileExt(Filenametouse),Filenametouse)-1));
end;

// https://forum.lazarus.freepascal.org/index.php?topic=32131.0
{
function RegistryReadString(const ARootKey: HKEY; AKeyName,
                            AStringValue: WideString): WideString;
var
  lpKey: HKEY;
  lpSize: DWORD;
  lptype: DWORD;
  lpWs: WideString;
begin
  Result := '';
  lpKey := 0;
  if RegOpenKeyExW(ARootKey, PWideChar(AKeyName), 0, KEY_READ, lpKey) = ERROR_SUCCESS then
  begin
    lpType := 0;
    lpSize := 0;
    if RegQueryValueExW(lpKey, PWideChar(AStringValue), nil, @lpType, nil, @lpSize) = ERROR_SUCCESS then
    begin
      if lpType in [REG_SZ, REG_EXPAND_SZ] then
      begin
        SetLength(lpWs, lpSize);
        if RegQueryValueExW(lpKey, PWideChar(AStringValue), nil, @lpType, PByte(lpWs), @lpSize) = ERROR_SUCCESS then
        begin
          SetLength(lpWs, StrLen(PWideChar(lpWs)));
          Result := lpWs;
        end;
      end;
      RegCloseKey(lpKey);
    end;
  end;
end;
}

// Reads a Registry value.
function RegistryReadValues(const ARootKey: HKEY; AKeyName, AStringValue:
    WideString; AllValues: Boolean): WideString;
var
  lpKey: HKEY;
  lpSize: DWORD;
  lpType: DWORD;
  lpWs: WideString;
  idx: Integer;
  enumValueName: array[0..255] of WideChar;
  enumValueNameLen, enumValueType, enumValueSize: DWORD;
begin
  Result := '';
  lpKey := 0;

  if RegOpenKeyExW(ARootKey, PWideChar(AKeyName), 0, KEY_READ, lpKey) = ERROR_SUCCESS then
  begin
    if AllValues then
    begin
      Result := #13#10;
      idx := 0;
      enumValueNameLen := SizeOf(enumValueName) div SizeOf(WideChar);
      enumValueSize := lpSize;

      while RegEnumValueW(lpKey, idx, @enumValueName, enumValueNameLen,
        nil, @enumValueType, nil, @enumValueSize) = ERROR_SUCCESS do
      begin
        SetLength(lpWs, enumValueSize);

        if RegQueryValueExW(lpKey, enumValueName, nil, @lpType, PByte(lpWs), @enumValueSize) = ERROR_SUCCESS then
        begin
          if (lpType in [REG_SZ, REG_EXPAND_SZ]) and
            (Copy(enumValueName, 1, Length(AStringValue)) = AStringValue) then
          begin
            SetLength(lpWs, StrLen(PWideChar(lpWs)));
            Result := Result + lpWs + #13#10;
          end;
        end;

        Inc(idx);
        enumValueSize := lpSize;
      end;
    end
    else
    begin
      lpType := 0;
      lpSize := 0;

      if RegQueryValueExW(lpKey, PWideChar(AStringValue), nil, @lpType, nil, @lpSize) = ERROR_SUCCESS then
      begin
        if lpType in [REG_SZ, REG_EXPAND_SZ] then
        begin
          SetLength(lpWs, lpSize);

          if RegQueryValueExW(lpKey, PWideChar(AStringValue), nil, @lpType, PByte(lpWs), @lpSize) = ERROR_SUCCESS then
          begin
            SetLength(lpWs, StrLen(PWideChar(lpWs)));
            Result := lpWs;
          end;
        end;
      end;
    end;

    RegCloseKey(lpKey);
  end;
end;

// Writes a dashed line
function DashedLine(s: String; d: Boolean = False) : String;
var
  i, l : integer;
  temp : String;
  c : char;
begin
  l := Length(s);
  temp := '';
  if d then
    c := '='
  else
    c := '-';
  for i := 0 to l - 1 do
    temp := temp + c;
  DashedLine := temp;
end;

// Writes Registry information on given TMemo
procedure GetRegistryInfo(MyMemo: TMemo; KFile: String);
var
  RVFile: File of TRegistryValue;
  RV: TRegistryValue;
  Subkey, TheValue : String;
  DArray, VArray, Subkeys: TStringArray;
  i, j : integer;
 begin
   try
     AssignFile(RVFile, KFile);
     Reset(RVFile);
   except
     ShowMessage('Error opening file ' + KFile);
   end;

   while not eof(RVFile)      // as long as data can still be read
    do begin
      read(RVFile, RV); // read a record from file

      // Remove last char from value if it has one.
      if HasWildcard(RV.AValue) then
        TheValue := RemoveLastChar(RV.AValue)
      else
        TheValue := RV.AValue;

      { In case we have multiple keys (e.g.: keys with same name in many
        different folders, using as such as processors or installed programs
        info, we're providing a way to put more than one information into a
        record field, as such as wildcards. }
      if HasWildcard(RV.AKey) then
        begin
          Subkey := RemoveLastChar(RV.AKey);
          DArray := SplitString(RV.Description, ',');
          VArray := SplitString(RV.AValue, ',');
          // Both arrays must have the same length!
           if (Length(DArray) <> Length(VArray)) then
              MyMemo.Lines.Add('Error: description and values mismatch!')
           else
              begin
                // List subkeys into an array and pass each item to function
                Subkeys := ListSubkeys(RV.ARootKey, Subkey);
                for i := 0 to (Length(Subkeys) - 1) do
                  MyMemo.Lines.Add(Subkeys[i]);
                  MyMemo.Lines.Add(DashedLine(Subkeys[i]));
                  // Now, let's use each splitted part to show our information.
                  for j := 0 to (Length(DArray) - 1) do
                    MyMemo.Lines.Add(DArray[j] + ': ' +
                      RegistryReadValues(RV.ARootKey,
                      WideString(Subkeys[i]),
                      WideString(TheValue),
                      HasWildcard(RV.AValue)));
              end;
        end
      else
        begin
           MyMemo.Lines.Add(RV.Description + ': ' +
                     RegistryReadValues(RV.ARootKey,
                     WideString(RV.AKey),
                     WideString(TheValue),
                     HasWildcard(RV.AValue)));
        end;
    end;

   CloseFile(RVFile);
 end;

end.

