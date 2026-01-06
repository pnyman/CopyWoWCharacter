unit CopyFiles;

{$mode ObjFPC}{$H+}

interface

Uses
Classes, SysUtils, CharData;

type
  TFilePath = Record
    source, target: String
  end;

  TFilePathsArray = Array of TFilePath;

implementation

procedure AddFilePath(Const ToPath: String;
                      Const outer, inner: TRawByteSearchRec;
                      Var A: TFilePathsArray);
var
  path: TFilePath;
begin
  path.source := inner.name;
  path.target := ConcatPaths([ToPath, outer.name, inner.name]);
  SetLength(A, Length(A) + 1);
  A[High(A)] := path;
end;


function WantItem(Const Info: TRawByteSearchRec): Boolean;
begin
  Result := (Info.Name <> '.') And
            (Info.Name <> '..') And
            (Info.Name <> 'cache.md5');
end;


{ Not done, doesn't actually copy any files yet! }
procedure CopySettingsFiles(source, target: TWoWChar);
var
  FromPath, ToPath: String;
  OuterInfo, InnerInfo: TRawByteSearchRec;
  OuterPath, InnerPath: String;
  A: TFilePathsArray = nil;
begin
  FromPath := source.path;
  ToPath := target.path;
  OuterPath := ConcatPaths(ConcatPaths([FromPath, '*']));

  if FindFirst(OuterPath, faDirectory, OuterInfo) = 0 then
    Repeat
      With OuterInfo do
        begin
          // Directory
          if ((OuterInfo.Attr and faDirectory) = faDirectory) and WantItem(OuterInfo) then
            begin
              InnerPath := ConcatPaths([FromPath, OuterInfo.name, '*']);
              if FindFirst(InnerPath, faDirectory, InnerInfo) = 0 then
                Repeat
                  With InnerInfo do
                    if WantItem(InnerInfo) then
                      AddFilePath(ToPath, OuterInfo, InnerInfo, A);
                Until FindNext(InnerInfo) <> 0;
            end
          else
            // Non-directory
            if WantItem(OuterInfo) then
              AddFilePath(ToPath, OuterInfo, InnerInfo, A);
        end;
    Until FindNext(OuterInfo) <> 0;
  FindClose(OuterInfo);
end;

end.
