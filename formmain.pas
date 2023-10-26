unit formmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  FileUtil, SysInfo, Windows, ShellAPI;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnGenerate: TButton;
    btnSave: TButton;
    btnClose: TButton;
    btnHelp: TButton;
    Report: TMemo;
    SaveDialog1: TSaveDialog;
    procedure btnCloseClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

var
  DefaultDirectory: String;

{ TfrmMain }

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  /// Save the report
  if SaveDialog1.Execute then
     Report.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Check parameters
  if (ParamCount = 1) then
     begin
       if (DirectoryExists(ParamStr(1))) then
          DefaultDirectory := ParamStr(1)
       else
          DefaultDirectory := ExtractFilePath(ParamStr(0)) + 'data';
     end
  else
    DefaultDirectory := ExtractFilePath(ParamStr(0)) + 'data';
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnGenerateClick(Sender: TObject);
var
  DataFiles : TStringList;
  i : integer;
  Section, CurrentFile : String;
begin
  // Clean Report Area
  Report.Clear;

  // Checks if data directory exists
  if (DirectoryExists(DefaultDirectory)) then
  begin
     // Starts a new report

     Screen.Cursor := crHourGlass;

     Report.Lines.BeginUpdate;
     Report.Lines.Add('WinRPT System Report');
     Report.Lines.Add('Date of report creation: ' + DateToStr(Date) + ' - ' +
                       TimeToStr(Time));
     Report.Lines.Add('Generating report from ' + DefaultDirectory + ' folder.');
     Report.Lines.Add('');

     // Loads report information by files
     DataFiles := FindAllFiles(DefaultDirectory, '*.wrd', false);
     try
       //ShowMessage(Format('Found %d files', [DataFiles.Count]));
       for i := 0 to (DataFiles.Count - 1) do
         begin
            CurrentFile := DataFiles[i];
            Section := ExtractFileNameOnly(CurrentFile);
            Report.Lines.Add(Section);
            Report.Lines.Add(DashedLine(Section, True));
            Report.Lines.Add('');
            GetRegistryInfo(Report, CurrentFile);
            Report.Lines.Add('');
         end;
    finally
      DataFiles.Free;
    end;

     Report.Lines.Add('');

     Report.Lines.Add('End of report.');
     Report.Lines.EndUpdate;

     Screen.Cursor := crDefault;
  end
  else
     ShowMessage('Fatal: Directory ' + DefaultDirectory + ' does not exists.');
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  // Shows HTML help file
  ShellExecute(Self.Handle, 'open', PChar('help\index.html'), nil, nil,
SW_SHOWNORMAL);
end;

end.

