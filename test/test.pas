Program test;
{$mode objfpc}{$H+}{$J-}{$R+}

uses SysUtils, CharData, Settings, CopyFiles;

var
  MySettings: Settings.TSettings;
  A: CharData.TWoWCharArray;
  C: TWoWChar;
  F: CopyFiles.TFilePathsArray;
  R: CopyFiles.TFilePath;
  data: String;

begin
  WriteLn('Letar...');
  MySettings := Settings.TSettings.Create;
  A := CharData.FindWoWCharacters(MySettings.GetWoWDirectory);

  { C := A[2]; }
  { data := format('%s %s %s %s %s', [c.server, c.account, c.realm, c.name, c.path]); }
  { WriteLn(data); }
  {  }
  { F := CopyFiles.CollectFilePaths(A[3], A[2]); }
  { WriteLn(Length(F)); }
  { for R in F do }
  {   begin }
  {     WriteLn(R.source + ' -> ' + R.target); }
  {   end; }
  {  }
  { CharData.PrintWoWCharacters(A); }

  CopyFiles.MakeZipBacup(A[3]);

end.
