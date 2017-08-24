{------------------------------------
  功能说明：系统通知服务
  创建日期：2011/07/16
  作者：wzw
  版权：wzw
-------------------------------------}
unit SysNotifyService;

interface

uses SysUtils, Classes, uIntfObj, NotifyServiceIntf, SvcInfoIntf;

type
  TNotifyObj = class(TObject)
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer); virtual; abstract;
  end;
  ////////////////////////////////////////////
  TIntfNotify = class(TNotifyObj)
  private
    FNotifyIntf: INotify;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer); override;
    constructor Create(Notify: INotify);
    destructor Destroy; override;
  end;
  ////////////////////////////////////////////
  TIntfNotifyEx = class(TIntfNotify)
  private
    FFlags: Integer;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer); override;
    constructor Create(Flags: Integer; Notify: INotify);
  end;
  ////////////////////////////////////////////
  TEventNotify = class(TNotifyObj)
  private
    FNotifyEvent: TSysNotifyEvent;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer); override;
    constructor Create(NotifyEvent: TSysNotifyEvent);
  end;
  ////////////////////////////////////////////
  TEventNotifyEx = class(TEventNotify)
  private
    FFlags: Integer;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer); override;
    constructor Create(Flags: Integer; NotifyEvent: TSysNotifyEvent);
  end;
  ///////////////////////////////////////////


  TNotifyService = class(TIntfObj, INotifyService, ISvcInfo)
  private
    FList: TStrings;
    Factory: TObject;
    procedure RegNotify(ID: Integer; NotifyObj: TNotifyObj);
    procedure UnRegNotify(ID: Integer);
    procedure WriteErrFmt(const err: String; const Args: array of const);
  protected
  {INotifyService}
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);

    procedure RegisterNotify(Notify: INotify);
    procedure UnRegisterNotify(Notify: INotify);

    procedure RegisterNotifyEx(Flags: Integer; Notify: INotify);
    procedure UnRegisterNotifyEx(Notify: INotify);

    procedure RegisterNotifyEvent(NotifyEvent: TSysNotifyEvent);
    procedure UnRegisterNotifyEvent(NotifyEvent: TSysNotifyEvent);

    procedure RegisterNotifyEventEx(Flags: Integer; NotifyEvent: TSysNotifyEvent);
    procedure UnRegisterNotifyEventEx(NotifyEvent: TSysNotifyEvent);
    {ISvcInfo}
    function GetModuleName: String;
    function GetTitle: String;
    function GetVersion: String;
    function GetComments: String;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses SysSvc, LogIntf, SysMsg, SysFactory;

{ TNotifyService }

function TNotifyService.GetComments: String;
begin
  Result := '注册、发送通知，用于模块之间通讯。';
end;

function TNotifyService.GetModuleName: String;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TNotifyService.GetTitle: String;
begin
  Result := '系统通知服务接口(INotifyService)';
end;

function TNotifyService.GetVersion: String;
begin
  Result := '20110716.001';
end;

constructor TNotifyService.Create;
begin
  FList := TStringList.Create;

  Factory := TObjFactory.Create(INotifyService, self);
end;

destructor TNotifyService.Destroy;
var i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    FList.Objects[i].Free;

  FList.Free;
  Factory.Free;
  inherited;
end;

procedure TNotifyService.RegNotify(ID: Integer; NotifyObj: TNotifyObj);
begin
  FList.AddObject(IntToStr(ID), NotifyObj);
end;

procedure TNotifyService.UnRegNotify(ID: Integer);
var idx: Integer;
begin
  idx := FList.IndexOf(IntToStr(ID));
  if idx <> -1 then
  begin
    FList.Objects[idx].Free;
    FList.Delete(idx);
  end;
end;

procedure TNotifyService.WriteErrFmt(const err: String;
  const Args: array of const);
var
  Log: ILog;
begin
  if SysService.QueryInterface(ILog, Log) = S_OK then
    Log.WriteLogFmt(err, Args);
end;

procedure TNotifyService.RegisterNotify(Notify: INotify);
begin
  self.RegNotify(Integer(Pointer(Notify)), TIntfNotify.Create(Notify));
end;

procedure TNotifyService.RegisterNotifyEvent(NotifyEvent: TSysNotifyEvent);
begin
  self.RegNotify(Integer(@NotifyEvent), TEventNotify.Create(NotifyEvent));
end;

procedure TNotifyService.RegisterNotifyEventEx(Flags: Integer;
  NotifyEvent: TSysNotifyEvent);
begin
  self.RegNotify(Integer(@NotifyEvent), TEventNotifyEx.Create(Flags, NotifyEvent));
end;

procedure TNotifyService.RegisterNotifyEx(Flags: Integer; Notify: INotify);
begin
  self.RegNotify(Integer(Pointer(Notify)), TIntfNotifyEx.Create(Flags, Notify));
end;

procedure TNotifyService.SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);
var i: Integer;
  NotifyObj: TNotifyObj;
begin
  for i := 0 to FList.Count - 1 do
  begin
    NotifyObj := TNotifyObj(FList.Objects[i]);
    try
      NotifyObj.SendNotify(Flags, Intf, Param);
    except
      on E: Exception do
        WriteErrFmt(Err_ModuleNotify, [E.Message]);
    end;
  end;
end;

procedure TNotifyService.UnRegisterNotify(Notify: INotify);
begin
  self.UnRegNotify(Integer(Pointer(Notify)));
end;

procedure TNotifyService.UnRegisterNotifyEx(Notify: INotify);
begin
  self.UnRegisterNotify(Notify);
end;

procedure TNotifyService.UnRegisterNotifyEvent(NotifyEvent: TSysNotifyEvent);
begin
  self.UnRegNotify(Integer(@NotifyEvent));
end;

procedure TNotifyService.UnRegisterNotifyEventEx(NotifyEvent: TSysNotifyEvent);
begin
  self.UnRegisterNotifyEvent(NotifyEvent);
end;

{ TIntfNotify }

constructor TIntfNotify.Create(Notify: INotify);
begin
  self.FNotifyIntf := Notify;
end;

destructor TIntfNotify.Destroy;
begin
  FNotifyIntf := nil;
  inherited;
end;

procedure TIntfNotify.SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  if FNotifyIntf <> nil then
    FNotifyIntf.Notify(Flags, Intf, Param);
end;

{ TIntfNotifyEx }

constructor TIntfNotifyEx.Create(Flags: Integer; Notify: INotify);
begin
  self.FFlags := Flags;
  inherited Create(Notify);
end;

procedure TIntfNotifyEx.SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  if Flags = self.FFlags then
    inherited;
end;

{ TEventNotify }

constructor TEventNotify.Create(NotifyEvent: TSysNotifyEvent);
begin
  self.FNotifyEvent := NotifyEvent;
end;

procedure TEventNotify.SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  if Assigned(FNotifyEvent) then
    FNotifyEvent(Flags, Intf, Param);
end;

{ TEventNotifyEx }

constructor TEventNotifyEx.Create(Flags: Integer; NotifyEvent: TSysNotifyEvent);
begin
  self.FFlags := Flags;
  inherited Create(NotifyEvent);
end;

procedure TEventNotifyEx.SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);
begin
  if self.FFlags = Flags then
    inherited;
end;

initialization

finalization

end.
