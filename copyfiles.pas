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


procedure AddPath(var A: TFilePathsArray; path: TFilePath);
begin
  SetLength(A, Length(A) + 1);
  A[High(A)] := path;
end;


function CollectFilePaths(Const source, target: TWoWChar): TFilePathsArray;
var
  OuterInfo, InnerInfo: TRawByteSearchRec;
  OuterPath, InnerPath: String;
  path: TFilePath;
  A: TFilePathsArray = nil;
begin
  OuterPath := ConcatPaths(ConcatPaths([source.path, '*']));

  if FindFirst(OuterPath, faDirectory, OuterInfo) = 0 then
    Repeat
      With OuterInfo do
        begin
          if not WantItem(OuterInfo) then continue;

          // Directory
          if ((OuterInfo.Attr and faDirectory) = faDirectory) then
            begin
              InnerPath := ConcatPaths([source.path, OuterInfo.name, '*']);
              if FindFirst(InnerPath, faDirectory, InnerInfo) = 0 then
                Repeat
                  With InnerInfo do
                    if WantItem(InnerInfo) then
                      begin
                        path.source := ConcatPaths([source.path, OuterInfo.name, InnerInfo.name]);
                        path.target := ConcatPaths([target.path, OuterInfo.name, InnerInfo.name]);
                        AddPath(A, path);
                      end;
                Until FindNext(InnerInfo) <> 0;
              FindClose(InnerInfo);
            end

          else
            // Non-directory
            begin
              path.source := ConcatPaths([source.path, OuterInfo.name]);
              path.target := ConcatPaths([target.path, OuterInfo.name]);
              AddPath(A, path);
            end;
        end;

    Until FindNext(OuterInfo) <> 0;
  FindClose(OuterInfo);
  result := A;
end;


function CopySettings(Const source, target: TWoWChar): Boolean;
var
  F: TFilePath;
  ok: Boolean;
begin
  for F in CollectFilePaths(source, target) do
    begin
      ok := FileUtil.CopyFile(F.source, F.target, [cffOverwriteFile, cffCreateDestDirectory]);
      if not ok then Exit(false);
    end;
  result := true;
end;

end.
