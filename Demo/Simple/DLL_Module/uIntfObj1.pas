﻿unit uIntfObj1;

interface

uses sysUtils, Classes, SysFactory, SvcInfoIntf, uIntf;

type
  TIntfObj1 = class(TInterfacedObject, IIntf2, ISvcInfo)
  private
  protected
  {ISvcInfo}
    function GetModuleName: String;
    function GetTitle: String;
    function GetVersion: String;
    function GetComments: String;
  {IIntf2}
    procedure ShowDLlForm;
  public
  end;

implementation

uses uFrmDLL;

function Create_IntfObj1(param: Integer): TObject;
begin
  Result := TIntfObj1.Create;
end;

{ TIntfObj1 }

function TIntfObj1.GetComments: String;
begin
  Result := '测试接口';
end;

function TIntfObj1.GetModuleName: String;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TIntfObj1.GetTitle: String;
begin
  Result := 'DLL模块实现的接口(IIntf2)';
end;

function TIntfObj1.GetVersion: String;
begin
  Result := '20110218.001';
end;

procedure TIntfObj1.ShowDLlForm;
begin
  frmDLL := TfrmDLL.Create(nil);
  try
    frmDLL.ShowModal;
  finally
    frmDLL.Free;
  end;
end;

initialization
  TIntfFactory.Create(IIntf2, @Create_IntfObj1);
finalization

end.