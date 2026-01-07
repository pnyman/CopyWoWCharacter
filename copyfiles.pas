unit CopyFiles;

{$mode ObjFPC}{$H+}

interface

Uses
Classes, SysUtils, FileUtil, CharData;
{ add flag -FuC:\lazarus\components\lazutils when testing }

type
  TFilePath = Record
    source, target: String
  end;

  TFilePathsArray = Array of TFilePath;

function CollectFilePaths(Const source, target: TWoWChar): TFilePathsArray;
function CopySettings(Const source, target: TWoWChar): Boolean;

implementation

function WantItem(Const Info: TRawByteSearchRec): Boolean;
begin
  Result := (Info.Name <> '.') And
            (Info.Name <> '..') And
            (Info.Name <> 'cache.md5');
end;

procedure AddPath(Var A: TFilePathsArray; Const source, target: Array Of String);
var
  path: TFilePath;
begin
  path.source := ConcatPaths(source);
  path.target := ConcatPaths(target);
  SetLength(A, Length(A) + 1);
  A[High(A)] := path;
end;

function CollectFilePaths(Const source, target: TWoWChar): TFilePathsArray;
var
  info1, info2: TRawByteSearchRec;
  OuterPath, InnerPath: String;
  A: TFilePathsArray = nil;
begin
  OuterPath := ConcatPaths(ConcatPaths([source.path, '*']));

  if FindFirst(OuterPath, faDirectory, info1) = 0 then
    Repeat
      begin
        if not WantItem(info1) then continue;

        // Directory
        if ((info1.Attr and faDirectory) = faDirectory) then
          begin
            InnerPath := ConcatPaths([source.path, info1.name, '*']);
            if FindFirst(InnerPath, faDirectory, info2) = 0 then
              Repeat
                if WantItem(info2) then
                  AddPath(A,
                          [source.path, info1.name, info2.name],
                          [target.path, info1.name, info2.name]);
              Until FindNext(info2) <> 0;
            FindClose(info2);
          end

        else
          // Non-directory
          begin
            AddPath(A, [source.path, info1.name], [target.path, info1.name]);
          end;
      end;

    Until FindNext(info1) <> 0;
  FindClose(info1);
  result := A;
end;

function CopySettings(Const source, target: TWoWChar): Boolean;
var
  F: TFilePath;
  ok: Boolean;
  flags: TCopyFileFlags;
begin
  flags := [cffOverwriteFile, cffCreateDestDirectory];
  for F in CollectFilePaths(source, target) do
    begin
      ok := FileUtil.CopyFile(F.source, F.target, flags);
      if not ok then Exit(false);
    end;
  result := true;
end;

end.
