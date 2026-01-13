unit Settings;

{$mode ObjFPC}{$H+}

interface

Uses
Classes, SysUtils, FPJson, JsonParser;

type
  TSettings = class
    private
      FDataFile: string;
      FWowDirectory: String;
      procedure LoadJSON;
    public
      constructor Create;
      procedure SaveJSON;
      procedure SetWoWDirectory(wowdirectory: String );
      function GetWoWDirectory: String;
    published
      property wowdirectory: String read FWoWDirectory write FWoWDirectory;
  end;

implementation

function GetAppName: String;
begin
  result := 'CopyWoWChar';
end;

constructor TSettings.Create;
begin
  inherited Create;
  onGetApplicationName := @GetAppName;
  CreateDir(GetAppConfigDir(false));
  FDataFile := GetAppConfigDir(false) + 'settings.json';
  LoadJSON;
end;

procedure TSettings.LoadJSON;
var
  JSONFile: TFileStream;
  JSONData: TJSONData;
  JSONObject: TJSONObject;
begin
  if not FileExists(FDataFile) then exit;

  JSONFile := TFileStream.Create(FDatafile, fmOpenRead Or fmShareDenyWrite);
  JSONData := GetJSON(JSONFile);
  JSONObject := TJSONObject(JSONData);

  if JSONObject.IndexOfName('wowdirectory') <> -1 then
    FWoWDirectory := JSONObject.Strings['wowdirectory']
  else
    FWoWDirectory := '';

  JSONFile.Free;
  JSONData.Free;
end;

procedure TSettings.SaveJSON;
var
  JSONObject: TJSONObject;
  JSONStr: string;
  F: TextFile;
begin
  JSONObject := TJSONObject.Create;
  JSONObject.add('wowdirectory', FWoWDirectory);

  JSONStr := JSONObject.FormatJSON;
  AssignFile(F, FDataFile);
  Rewrite(F);
  Write(F, JSONStr);
  CloseFile(F);

  JSONObject.Free;
end;

procedure TSettings.SetWoWDirectory(wowdirectory: String);
begin
  FWoWDirectory := wowdirectory;
end;

function TSettings.GetWoWDirectory: String;
begin
  result := FWoWDirectory;
end;

end.
