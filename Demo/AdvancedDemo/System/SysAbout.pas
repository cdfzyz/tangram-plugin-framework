unit SysAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, uBaseForm;

type
  TFrm_About = class(TBaseForm)
    btn_close: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private
    { Private declarations }
  public
    class procedure Execute;
  end;

var
  Frm_About: TFrm_About;

implementation

{$R *.dfm}

{ TFrm_About }

class procedure TFrm_About.Execute;
begin
  Frm_About := TFrm_About.Create(nil);
  Frm_About.Label1.Caption := 'Bpl 框架2.0';
  Frm_About.Label2.Caption := '作者：wei';
  Frm_About.Label3.Caption := '博客：http://hi.baidu.com/0xcea4';
  Frm_About.ShowModal;
  Frm_About.Free;
end;

end.
