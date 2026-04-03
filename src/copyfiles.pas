unit CopyFiles;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Zipper, CharData;
  { add flag -FuC:\lazarus\components\lazutils when testing }

type
  TFilePath = record
    Source, target: string
  end;

  TFilePathsArray = array of TFilePath;

function CollectFilePaths(const Source, target: TWoWChar): TFilePathsArray;
function CopyCharSettings(const Source, target: TWoWChar): boolean;
procedure MakeZipBackup(const WChar: TWoWChar);

implementation

{ * WantItem }

function WantItem(const Info: TRawByteSearchRec): boolean;
begin
  Result := (Info.Name <> '.') and (Info.Name <> '..') and
    (Info.Name <> 'cache.md5');
end;

{ * AddPath }

procedure AddPath(var A: TFilePathsArray; const Source, target: array of string);
var
  path: TFilePath;
begin
  path.Source := ConcatPaths(Source);
  path.target := ConcatPaths(target);
  SetLength(A, Length(A) + 1);
  A[High(A)] := path;
end;

{ * CollectFilePaths }

function CollectFilePaths(const Source, target: TWoWChar): TFilePathsArray;
var
  info1, info2: TRawByteSearchRec;
  OuterPath, InnerPath: string;
  A: TFilePathsArray = nil;
begin
  OuterPath := ConcatPaths(ConcatPaths([Source.path, '*']));

  if FindFirst(OuterPath, faDirectory, info1) = 0 then
    repeat
      begin
        if not WantItem(info1) then continue;

        // Directory
        if ((info1.Attr and faDirectory) = faDirectory) then
        begin
          InnerPath := ConcatPaths([Source.path, info1.Name, '*']);
          if FindFirst(InnerPath, faDirectory, info2) = 0 then
            repeat
              if WantItem(info2) then
                AddPath(A, [Source.path, info1.Name, info2.Name],
                  [target.path, info1.Name, info2.Name]);
            until FindNext(info2) <> 0;
          FindClose(info2);
        end

        // Non-directory
        else
          AddPath(A, [Source.path, info1.Name], [target.path, info1.Name]);
      end;

    until FindNext(info1) <> 0;
  FindClose(info1);
  Result := A;
end;

{ * CopyCharSettings }

function CopyCharSettings(const Source, target: TWoWChar): boolean;
var
  F: TFilePath;
  ok: boolean;
  flags: TCopyFileFlags;
begin
  MakeZipBackup(target);
  flags := [cffOverwriteFile, cffCreateDestDirectory];
  for F in CollectFilePaths(Source, target) do
  begin
    ok := FileUtil.CopyFile(F.Source, F.target, flags);
    if not ok then Exit(False);
  end;
  Result := True;
end;

{ * MakeZipBackup }

procedure MakeZipBackup(const WChar: TWoWChar);
var
  AZipper: TZipper;
  TheFileList: TStringList;
  directory, ZipPath, FileName: string;
begin
  directory := WChar.path;
  ZipPath := ConcatPaths([directory, 'settingsbackup.zip']);

  if FileExists(ZipPath) then
    DeleteFile(ZipPath);

  AZipper := TZipper.Create;
  AZipper.Filename := ZipPath;
  TheFileList := TStringList.Create;

  try
    FindAllFiles(TheFileList, directory);
    for FileName in TheFileList do
      AZipper.Entries.AddFileEntry(FileName, ExtractRelativePath(directory, FileName));
    AZipper.ZipAllFiles;
  finally
    TheFileList.Free;
    AZipper.Free;
  end;
end;

end.
