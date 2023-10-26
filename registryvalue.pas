Unit RegistryValue;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Registry;

type
  TRegistryValue = Record
    Description : String[255];
    ARootKey : HKEY;
    AKey : String[255];
    AValue : String[255];
  end;

implementation
 
end.
