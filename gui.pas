unit gui;

{$mode objfpc}{$H+}

interface

Uses
Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
ExtCtrls, ComCtrls, Settings, CharData;

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
  p, q: Integer;
begin
  for i := 0 to ListViewLeft.Items.Count - 1 do
  if ListViewLeft.Items[i].Selected then
  begin
    p := i;
    break;
  end;

  for i := 0 to ListViewRight.Items.Count - 1 do
  if ListViewRight.Items[i].Selected then
  begin
    q := i;
    break;
  end;

  ShowMessage(format('%s -> %s', [FWoWCharArray[p].name, FWoWCharArray[q].name]));
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
begin
  for C in FWoWCharArray do
  begin
    ItemLeft := ListViewLeft.Items.Add;
    ItemLeft.Caption := c.name;
    ItemLeft.SubItems.Add(c.account);
    ItemLeft.SubItems.Add(c.realm);

    ItemRight := ListViewRight.Items.Add;
    ItemRight.Caption := c.name;
    ItemRight.SubItems.Add(c.account);
    ItemRight.SubItems.Add(c.realm);
  end;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  SelectWoWDirectory
end;

end.
