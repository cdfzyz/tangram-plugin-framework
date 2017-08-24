unit uDBPlugin;

interface

uses SysUtils, Classes, uTangramModule, SysModule, RegIntf;

type
  TDBPlugin = class(TModule)
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
  InstallKey = 'SYSTEM\LOADMODULE\DBSUPPORT';
  ValueKey   = 'Module=%s;load=True';

{ TDBPlugin }

constructor TDBPlugin.Create;
begin
  inherited;

end;

destructor TDBPlugin.Destroy;
begin

  inherited;
end;

procedure TDBPlugin.final;
begin
  inherited;

end;

procedure TDBPlugin.Init;
begin
  inherited;

end;

procedure TDBPlugin.Notify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  inherited;

end;

class procedure TDBPlugin.RegisterModule(Reg: IRegistry);
var ModuleFullName, ModuleName, Value: String;
begin
  //ע��ģ��
  if Reg.OpenKey(InstallKey, True) then
  begin
    ModuleFullName := SysUtils.GetModuleName(HInstance);
    ModuleName := ExtractFileName(ModuleFullName);
    Value := Format(ValueKey, [ModuleFullName]);
    Reg.WriteString(ModuleName, Value);
    Reg.SaveData;
  end;
end;

class procedure TDBPlugin.UnRegisterModule(Reg: IRegistry);
var ModuleName: String;
begin
  //ȡ��ע��ģ��
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName := ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

initialization
  RegisterModuleClass(TDBPlugin);
finalization

end.
