unit ReadmeForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, IpHtml,
  MarkdownProcessor, MarkdownUtils;

type

  { TReadMeForm }

  TReadMeForm = class(TForm)
    IpHtmlPanel1: TIpHtmlPanel;
  private

  public
    procedure ShowMarkdownFile(const AFileName: string);
  end;

var
  Form: TReadMeForm;

implementation

{$R *.lfm}

procedure TReadmeForm.ShowMarkdownFile(const AFileName: string);
var
  MD: TStringList;
  HTML: string;
  Processor: TMarkdownProcessor;
  Doc: TIpHtml;
  fs: TStringStream;
begin
  MD := TStringList.Create;
  Processor := TMarkdownProcessor.CreateDialect(mdDaringFireball);
  Doc := TIpHtml.Create;
  try
    MD.LoadFromFile(AFileName);
    HTML := Processor.Process(MD.Text);
    fs := TStringStream.Create(HTML);
    Doc.LoadFromStream(fs);
    IpHtmlPanel1.SetHtml(Doc);
  finally
    MD.Free;
    Processor.Free;
    fs.Free;
  end;
end;


end.
