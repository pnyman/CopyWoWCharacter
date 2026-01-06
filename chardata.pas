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

procedure FindWoWCharacters(server: String);
function GetWowChars: TWoWCharArray;
procedure PrintWoWCharacters;

implementation

var
  wowchars: TWoWCharArray;

function IsValidDir(test: Boolean; name: String): Boolean;
var
  A, B, C, D: Boolean;
begin
  A := name = '.';
  B := name = '..';
  C := name = 'SavedVariables';
  D := name = 'Turtle WoW'; { ad hoc }
  result := test And Not (A Or B Or C Or D);
end;

procedure AddWoWCharacter(server, account, realm, name: String);
var
  wowchar: TWoWChar;
begin
  wowchar.server := ExtractFileName(server);
  wowchar.account := ExtractFileName(account);
  wowchar.realm := ExtractFileName(realm);
  wowchar.name := ExtractFileName(name);
  wowchar.path := name;
  SetLength(wowchars, Length(wowchars) + 1);
  wowchars[High(wowchars)] := wowchar;
end;

procedure FindWoWCharacters(server: String);
var
  WTF: String;
  info: TRawByteSearchRec;
  account: TAccount;
  accounts: TAccountArray;
  realm: TRealm;
  realms: TRealmArray;
begin
  WTF := ConcatPaths([server, '/WTF/Account/']);
  SetLength(realms, 0);
  SetLength(accounts, 0);

  // Accounts
  if FindFirst(ConcatPaths([WTF, '*']), faAnyFile, info) = 0 then
    begin
      Repeat
        With info do
          begin
            if IsValidDir(((attr and faDirectory) = faDirectory), name) then
              begin
                account.path := ConcatPaths([WTF, name]);
                account.name := name;
                SetLength(accounts, Length(accounts) + 1);
                accounts[High(accounts)] := account;
              end;
          end;
      Until FindNext(info) <> 0;
      FindClose(info);
    end;

  // Realms
  for account in accounts do
    if FindFirst(ConcatPaths([account.path, '*']), faAnyFile, info) = 0 then
      begin
        Repeat
          With info do
            begin
              if IsValidDir(((attr and faDirectory) = faDirectory), name) then
                begin
                  realm.account := account;
                  realm.path := ConcatPaths([account.path, name]);
                  realm.name := name;
                  SetLength(realms, Length(realms) + 1);
                  realms[High(realms)] := realm;
                end;
            end;
        Until FindNext(info) <> 0;
        FindClose(info);
      end;

  // Characters
  for realm in realms do
    if FindFirst(ConcatPaths([realm.path, '*']), faAnyFile, info) = 0 then
      begin
        Repeat
          With info do
            begin
              if IsValidDir(((attr and faDirectory) = faDirectory), name) then
                begin
                  AddWoWCharacter(server, realm.account.name, realm.name, ConcatPaths([realm.path,
                                  name]));
                end;
            end;
        Until FindNext(info) <> 0;
        FindClose(info);
      end;
end;

function GetWowChars: TWoWCharArray;
begin
  result := wowchars;
end;

procedure PrintWoWCharacters;
var
  data: String;
  c: TWoWChar;
begin
  for c in wowchars do
    begin
      data := format('%s %s %s %s %s', [c.server, c.account, c.realm, c.name, c.path]);
      WriteLn(data);
    end;
end;

end.
