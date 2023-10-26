program gendata;

{$mode ObjFPC}{$H+}

uses
  Classes, SysUtils, OSInfo, Started;

begin

  GenerateOSInfoFile;
  GenerateStarted;

end.

