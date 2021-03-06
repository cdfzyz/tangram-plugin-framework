﻿unit TestPlugin;

interface

uses
  SysUtils,
  Classes,
  Graphics,
  MainFormIntf,
  MenuRegIntf,
  uTangramModule,
  SysModule,
  RegIntf;

type
  TTestPlugin = class(TModule)
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
  InstallKey = 'SYSTEM\LOADMODULE\USER';
  ValueKey = 'Module=%s;load=True';
{ TTestPlugin }

constructor TTestPlugin.Create;
begin
  inherited;

end;

destructor TTestPlugin.Destroy;
begin

  inherited;
end;

procedure TTestPlugin.final;
begin
  inherited;

end;

procedure TTestPlugin.Init;
begin
  inherited;

end;

procedure TTestPlugin.Notify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  inherited;

end;

class procedure TTestPlugin.RegisterModule(Reg: IRegistry);
var
  ModuleFullName, ModuleName, Value: string;
begin
  if Reg.OpenKey(InstallKey, True) then
  begin
    ModuleFullName := SysUtils.GetModuleName(HInstance);
    ModuleName := ExtractFileName(ModuleFullName);
    Value := Format(ValueKey, [ModuleFullName]);
    Reg.WriteString(ModuleName, Value);
    Reg.SaveData;
  end;
end;

class procedure TTestPlugin.UnRegisterModule(Reg: IRegistry);
var
  ModuleName: string;
begin
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName := ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

initialization
  RegisterModuleClass(TTestPlugin);

finalization

end.

