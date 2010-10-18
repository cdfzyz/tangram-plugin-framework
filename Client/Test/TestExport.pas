unit TestExport;


interface

uses RegIntf,SysUtils,RegPluginIntf;

procedure InstallPackage(Reg: IRegistry); // ��װ��
procedure UnInstallPackage(Reg: IRegistry); // ж�ذ�
procedure RegisterPlugIn(Reg: IRegPlugin); // ע����

exports
  InstallPackage,
  UnInstallPackage,
  RegisterPlugIn;

implementation

uses Forms,_sys,Windows;

const InstallKey='SYSTEM\LOADPACKAGE\USER';
      ValueKey='Package=%s;load=True';

procedure InstallPackage(Reg:IRegistry);
var ModuleFullName,ModuleName,Value:String;
begin
  if Reg.OpenKey(InstallKey,True) then
  begin
    //s:=inttostr(HInstance);
    //MessageBox(GetActiveWindow,pchar(s),'ok',0);
    //exit;
    ModuleFullName:=SysUtils.GetModuleName(HInstance);
    ModuleName:=ExtractFileName(ModuleFullName);
    Value:=Format(ValueKey,[ModuleFullName]);
    Reg.WriteString(ModuleName,Value);
    Reg.SaveData;
  end;
end;

procedure UnInstallPackage(Reg:IRegistry);
var ModuleName:String;
begin
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

procedure RegisterPlugIn(Reg: IRegPlugin); // ע����
begin
  //sys.Dialogs.ShowMessageFmt('��ʼ���� Flags=%d',[Flags]);
end;

initialization

finalization

end.
