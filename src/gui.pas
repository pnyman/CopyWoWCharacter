unit gui;

{$mode objfpc}{$H+}

interface

Uses
Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
ExtCtrls, ComCtrls, LCLType, Buttons, Settings, CharData, CopyFiles,
ReadMeForm;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    ListViewRight: TListView;
    ListViewLeft: TListView;
    MainMenu1: TMainMenu;
    MenuItemFile: TMenuItem;
    MenuItemQuit: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemReadme: TMenuItem;
    PanelBottom: TPanel;
    PanelRight: TPanel;
    PanelLeft: TPanel;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItemQuitClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemReadmeClick(Sender: TObject);
    procedure SelectWoWDirectory;
    procedure PopulateListBoxes;
    procedure WarningDialog(msg: String);
    procedure InfoDialog(msg: String);
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
  Width := 800;
  Height := 500;
  Position := poScreenCenter;

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
  FromSelected: Boolean = false;
  ToSelected: Boolean = false;
begin
  for i := 0 to ListViewLeft.Items.Count - 1 do
    if ListViewLeft.Items[i].Selected then
      begin
        WCharFrom := FWoWCharArray[i];
        FromSelected := true;
        break;
      end;

  for i := 0 to ListViewRight.Items.Count - 1 do
    if ListViewRight.Items[i].Selected then
      begin
        WCharTo := FWoWCharArray[i];
        ToSelected := true;
        break;
      end;

  if not FromSelected or not ToSelected then
    WarningDialog('Character selection misssing.')
  else
    if WCharFrom.path = WCharTo.path then
      WarningDialog('Cannot copy character to itself!')
  else
    ConfirmDialog(WCharFrom, WCharTo);
end;

procedure TForm1.WarningDialog(msg: String);
begin
  Application.MessageBox(PChar(msg), 'Error', MB_ICONERROR);
end;

procedure TForm1.InfoDialog(msg: String);
begin
  Application.MessageBox(PChar(msg), 'Info', MB_ICONINFORMATION);
end;

procedure TForm1.ConfirmDialog(WCharFrom, WCharTo: TWoWChar);
var
  Reply, BoxStyle: Integer;
  msg: String;
  OK: boolean;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  msg := format('Do you want to copy settings %sfrom: %s (%s) %sto: %s (%s)?',
         [sLineBreak, WCharFrom.name, WCharFrom.realm,
         sLineBreak, WCharTo.name, WCharTo.realm]);
  Reply := Application.MessageBox(PChar(msg), 'Confirmation', BoxStyle);

  if Reply = IDYES then
    OK := CopyFiles.CopyCharSettings(WCharFrom, WCharTo);

  if OK then
    InfoDialog('The settings were copied.')
  else
    WarningDialog('Operation aborted by user.');
end;

procedure TForm1.SelectWoWDirectory;
var
  directory: String;
  selection: Boolean;
begin
  selection := SelectDirectory('WoW directory', GetUserDir, directory);
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
  SelectWoWDirectory;
end;

procedure TForm1.MenuItemAboutClick(Sender: TObject);
begin
  ShowMessage('CopyWoWChar v0.1');
end;

procedure TForm1.MenuItemReadmeClick(Sender: TObject);
var
  F: TReadmeForm;
begin
  F := TReadmeForm.Create(Self);
  try
    F.ShowMarkdownFile('README.md');
    F.ShowModal;
  finally
    F.Free;
  end;
end;


procedure TForm1.MenuItemQuitClick(Sender: TObject);
begin
  Close;
end;


end.
