﻿{ ------------------------------------
  功能说明：TModule祖先类
  创建日期：2010/07/16
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit SysModule;

interface

uses
  uIntfObj,
  RegIntf,
  NotifyServiceIntf;

type
  TModuleClass = class of TModule;

  TModule = class(TIntfObj, INotify)
  private
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Init; virtual;
    procedure final; virtual;
    procedure Notify(Flags: Integer; Intf: IInterface; Param: Integer); virtual;
    class procedure RegisterModule(Reg: IRegistry); virtual;
    class procedure UnRegisterModule(Reg: IRegistry); virtual;
  end;

implementation

uses
  SysSvc;

{ TModule }

constructor TModule.Create;
begin
  (SysService as INotifyService).RegisterNotify(Self);
end;

destructor TModule.Destroy;
var
  NotifyService: INotifyService;
begin
  if SysService.QueryInterface(INotifyService, NotifyService) = S_OK then
    NotifyService.UnRegisterNotify(Self);
  inherited;
end;

procedure TModule.Init;
begin

end;

procedure TModule.final;
begin

end;

procedure TModule.Notify(Flags: Integer; Intf: IInterface; Param: Integer);
begin

end;

class procedure TModule.RegisterModule(Reg: IRegistry);
begin

end;

class procedure TModule.UnRegisterModule(Reg: IRegistry);
begin

end;

end.

