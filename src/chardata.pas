unit CharData;

{$mode ObjFPC}{$H+}

interface

Uses Classes, SysUtils;

type
  TAccount = Record
    name, path: String;
  end;

  TRealm = Record
    account: TAccount;
    name, path: String;
  end;

  TWoWChar = Record
    server, account, realm, name, path: String;
  end;

  TRealmArray = Array of TRealm;
  TAccountArray = Array of TAccount;
  TWoWCharArray = Array of TWoWChar;

function FindWoWCharacters(Const server: String): TWoWCharArray;
procedure PrintWoWCharacters(Const A: TWoWCharArray);

implementation

{ * IsValidDir }

function IsValidDir(Const Info: TRawByteSearchRec): Boolean;
begin
  Result := ((Info.Attr And faDirectory) <> 0) And
            (Info.Name <> '.') And
            (Info.Name <> '..') And
            (Info.Name <> 'SavedVariables') And
            (Info.Name <> 'Turtle WoW');
end;

{ * AddWoWCharacter }

procedure AddWoWCharacter(Var A: TWoWCharArray;
                          Const server, account, realm, name: String);
var
  C: TWoWChar;
begin
  C.server := ExtractFileName(server);
  C.account := ExtractFileName(account);
  C.realm := ExtractFileName(realm);
  C.name := ExtractFileName(name);
  C.path := name;
  SetLength(A, Length(A) + 1);
  A[High(A)] := C;
end;

{ * FindWoWCharacters }

function FindWoWCharacters(Const server: String): TWoWCharArray;
var
  WTF: String;
  info: TRawByteSearchRec;
  account: TAccount;
  accounts: TAccountArray;
  realm: TRealm;
  realms: TRealmArray;
begin
  WTF := ConcatPaths([server, 'WTF', 'Account']);
  SetLength(realms, 0);
  SetLength(accounts, 0);
  SetLength(result, 0);

  // Accounts
  if FindFirst(ConcatPaths([WTF, '*']), faDirectory, info) = 0 then
  Repeat
    if IsValidDir(info) then
    begin
      account.path := ConcatPaths([WTF, info.name]);
      account.name := info.name;
      SetLength(accounts, Length(accounts) + 1);
      accounts[High(accounts)] := account;
    end;
  Until FindNext(info) <> 0;
  FindClose(info);

  // Realms
  for account in accounts do
  if FindFirst(ConcatPaths([account.path, '*']), faDirectory, info) = 0 then
  Repeat
    if IsValidDir(info) then
    begin
      realm.account := account;
      realm.path := ConcatPaths([account.path, info.name]);
      realm.name := info.name;
      SetLength(realms, Length(realms) + 1);
      realms[High(realms)] := realm;
    end;
  Until FindNext(info) <> 0;
  FindClose(info);

  // Characters
  for realm in realms do
  if FindFirst(ConcatPaths([realm.path, '*']), faDirectory, info) = 0 then
  Repeat
    if IsValidDir(info) then
      AddWoWCharacter(result,
                      server, realm.account.name, realm.name,
                      ConcatPaths([realm.path, info.name]));
  Until FindNext(info) <> 0;
  FindClose(info);
end;

{ * PrintWoWCharacters }

procedure PrintWoWCharacters(Const A: TWoWCharArray);
var
  data: String;
  c: TWoWChar;
  i: Integer;
begin
  i := 0;
  for c in A do
  begin
    data := format('%2d %-12s %s %s %s %s', [i, c.name, c.server, c.account, c.realm, c.path]);
    WriteLn(data);
    inc(i);
  end;
end;

end.
