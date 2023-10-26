unit Started;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Registry, RegistryValue;

procedure GenerateStarted;

implementation

procedure GenerateStarted;

var
  f : file of TRegistryValue;
  r : TRegistryValue;

begin
  AssignFile(f, '02 - Programs started automatically.wrd');

  Rewrite(f);
  
  r.ARootKey:= HKEY_LOCAL_MACHINE;
  r.AKey:='SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
  r.Description := 'Machine';
  r.AValue:='*';

  write(F,r);

  r.ARootKey:= HKEY_LOCAL_MACHINE;
  r.AKey:='SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';
  r.Description := 'Machine (next boot only)';
  r.AValue:='*';

  write(F,r);

  r.ARootKey:= HKEY_CURRENT_USER;
  r.AKey:='SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
  r.Description := 'Current user';
  r.AValue:='*';

  write(F,r);

  r.ARootKey:= HKEY_CURRENT_USER;
  r.AKey:='SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';
  r.Description := 'Current user (next login only)';
  r.AValue:='*';

  write(F,r);

  CloseFile(f);

end;

end.

