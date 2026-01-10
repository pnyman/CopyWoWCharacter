unit gui;

{$mode objfpc}{$H+}

interface

Uses
Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
ExtCtrls, ComCtrls, LCLType, Settings, CharData;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TButton;
    ButtonCancel: TButton;
    Label2: TLabel;
    Label3: TLabel;
    ListViewRight: TListView;
    ListViewLeft: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    PanelBottom: TPanel;
    PanelRight: TPanel;
    PanelLeft: TPanel;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure SelectWoWDirectory;
    procedure PopulateListBoxes;
    procedure WarningDialog;
    procedure ConfirmDialog(WCharFrom, WCharTo: TWoWChar);
    private
      FSettings: Settings.TSettings;
      FWoWDirectory: String;
      FWoWCharArray: TWowCharArray;
    public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormShow(Sender : TObject);
begin
  FSettings := Settings.TSettings.Create;
  FWoWDirectory := FSettings.GetWoWDirectory;
  if FWoWDirectory = '' then SelectWoWDirectory;
  FWoWCharArray := FindWoWCharacters(FSettings.GetWoWDirectory);
  PopulateListBoxes;
end;

procedure TForm1.FormResize(Sender: TObject);
var
  gap: Integer;
begin
  gap := 8;
  PanelRight.Width := (ClientWidth Div 2) - gap;
  PanelLeft.Width := (ClientWidth Div 2) - gap;
end;

procedure TForm1.ButtonOKClick(Sender: TObject);
var
  i: Integer;
  WCharFrom, WCharTo: TWoWChar;
begin
  for i := 0 to ListViewLeft.Items.Count - 1 do
  if ListViewLeft.Items[i].Selected then
  begin
    WCharFrom := FWoWCharArray[i];
    break;
  end;

  for i := 0 to ListViewRight.Items.Count - 1 do
  if ListViewRight.Items[i].Selected then
  begin
    WCharTo := FWoWCharArray[i];
    break;
  end;

  if WCharFrom.path = WCharTo.path then
  WarningDialog
  else
  ConfirmDialog(WCharFrom, WCharTo);
end;

procedure TForm1.WarningDialog;
begin
  Application.MessageBox('Cannot copy a char to itself!', 'Error', MB_ICONERROR);
end;

procedure TForm1.ConfirmDialog(WCharFrom, WCharTo: TWoWChar);
var
  Reply, BoxStyle: Integer;
  msg: String;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  msg := format('Do you want to copy%s%s (%s) to %s (%s)?',
                [sLineBreak, WCharFrom.name, WCharFrom.realm,
                 WCharTo.name, WCharTo.realm]);
  Reply := Application.MessageBox(PChar(msg), 'Confirmation', BoxStyle);
end;

procedure TForm1.SelectWoWDirectory;
var
  directory: String;
  selection: Boolean;
begin
  selection := SelectDirectory('Wow directory', GetUserDir, directory);
  if selection then
  begin
    FWoWDirectory := directory;
    FSettings.SetWoWDirectory(FWoWDirectory);
    FSettings.SaveJSON;
  end;
end;

procedure TForm1.PopulateListBoxes;
var
  C: TWoWChar;
  ItemLeft, ItemRight: TListItem;
  account: String;
begin
  for C in FWoWCharArray do
  begin
    account := LowerCase(c.account);
    account[1] := UpCase(account[1]);

    ItemLeft := ListViewLeft.Items.Add;
    ItemLeft.Caption := c.name;
    ItemLeft.SubItems.Add(account);
    ItemLeft.SubItems.Add(c.realm);

    ItemRight := ListViewRight.Items.Add;
    ItemRight.Caption := c.name;
    ItemRight.SubItems.Add(account);
    ItemRight.SubItems.Add(c.realm);
  end;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  SelectWoWDirectory
end;

end.
