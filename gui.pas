unit gui;

{$mode objfpc}{$H+}

interface

Uses
Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
ExtCtrls, Settings;

type

  { TForm1 }

  TForm1 = class(TForm)
      Button1: TButton;
      Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure FormShow(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure SelectWoWDirectory;
    private
      FSettings: Settings.TSettings;
      FWoWDirectory: String;
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
  if FWoWDirectory = '' then
    SelectWoWDirectory;
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

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  SelectWoWDirectory
end;

procedure TForm1.Panel2Click(Sender: TObject);
begin

end;

procedure TForm1.Panel3Click(Sender: TObject);
begin

end;

end.
