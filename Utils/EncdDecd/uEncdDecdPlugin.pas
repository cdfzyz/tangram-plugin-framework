﻿unit uEncdDecdPlugin;

interface

uses SysUtils, uTangramModule, SysModule, RegIntf;

type
  TEncdDecdPlugin = class(TModule)
  private
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Notify(Flags: Integer; Intf: IInterface; Param: Integer); override;

    class procedure RegisterModule(Reg: IRegistry); override;
    class procedure UnRegisterModule(Reg: IRegistry); override;
  end;
implementation

const
  InstallKey = 'SYSTEM\LOADMODULE\UTILS';//这里要改成相应的KEY
{ TEncdDecdPlugin }

constructor TEncdDecdPlugin.Create;
begin
  inherited;

end;

destructor TEncdDecdPlugin.Destroy;
begin

  inherited;
end;

procedure TEncdDecdPlugin.final;
begin
  inherited;

end;

procedure TEncdDecdPlugin.Init;
begin
  inherited;

end;

procedure TEncdDecdPlugin.Notify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  inherited;

end;

class procedure TEncdDecdPlugin.RegisterModule(Reg: IRegistry);
begin
  //注册包
  DefaultRegisterModule(Reg, InstallKey);
end;

class procedure TEncdDecdPlugin.UnRegisterModule(Reg: IRegistry);
begin
  //取消注册包
  DefaultUnRegisterModule(Reg, InstallKey);
end;

initialization
  RegisterModuleClass(TEncdDecdPlugin);
finalization
end.
