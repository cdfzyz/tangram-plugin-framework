﻿{------------------------------------
  功能说明：实现ISplashForm接口(闪屏窗体接口)
  创建日期：2008.12.07
  作者：WZW
  版权：WZW
-------------------------------------}
unit SplashFormObj;


interface

uses SysUtils, Messages, SplashFormIntf, SplashForm;

type
  TSplashFormObj = class(TInterfacedObject, ISplashForm)
  private
    FSplashForm: Tfrm_Splash;
  protected
    {ISplashForm}
    procedure Show;
    procedure loading(const msg: String);
    function GetWaitTime: Cardinal;
    procedure Hide;
  public
    constructor Create;
    destructor Destroy; override;
  end;
implementation

uses SysFactory;

{ TSplashFormObj }

constructor TSplashFormObj.Create;
begin
  FSplashForm := Tfrm_Splash.Create(nil);
end;

destructor TSplashFormObj.Destroy;
begin
  FSplashForm.Free;
  inherited;
end;

function TSplashFormObj.GetWaitTime: Cardinal;
begin
  Result := 0;
end;

procedure TSplashFormObj.Hide;
begin
  FSplashForm.Hide;
end;

procedure TSplashFormObj.Show;
begin
  FSplashForm.Show;
end;

procedure TSplashFormObj.loading(const msg: String);
begin
  FSplashForm.mm_Loading.Lines.Add('  ' + msg);
  //FSplashForm.mm_Loading.Perform(wm_vscroll,sb_linedown,0);
  FSplashForm.Refresh;
end;

function Create_SplashFormObj(param: Integer): TObject;
begin
  Result := TSplashFormObj.Create;
end;

initialization
  TIntfFactory.Create(ISplashForm, @Create_SplashFormObj);
finalization

end.
