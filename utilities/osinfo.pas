unit OSInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Registry, RegistryValue;

procedure GenerateOSInfoFile;

implementation

procedure GenerateOSInfoFile;

var
  f : file of TRegistryValue;
  r : array[0..6] of TRegistryValue;
  d : array[0..6] of String[50];
  v : array[0..6] of String[255];
  i : integer;

begin
  AssignFile(f, '00 - Operating system info.wrd');

  d[0] := 'Windows Edition';
  d[1] := 'Product ID';
  d[2] := 'Version';
  d[3] := 'Registered organization';
  d[4] := 'Registered owner';
  d[5] := 'Build Number';
  d[6] := 'System installation folder';

  v[0] := 'ProductName';
  v[1] := 'ProductID';
  v[2] := 'DisplayVersion';
  v[3] := 'RegisteredOrganization';
  v[4] := 'RegisteredOwner';
  v[5] := 'CurrentBuildNumber';
  v[6] := 'SystemRoot';

  Rewrite(f);

  for i := 0 to 6 do
  begin

    r[i].ARootKey:= HKEY_LOCAL_MACHINE;
    r[i].AKey:='SOFTWARE\Microsoft\Windows NT\CurrentVersion';
    r[i].Description:=d[i];
    r[i].AValue:=v[i];

    write(F,r[i]);

  end;

  CloseFile(f);

end;

end.

