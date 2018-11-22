{------------------------------------
  功能说明：系统通知相关接口
  创建日期：2011/07/16
  作者：wzw
  版权：wzw
-------------------------------------}
unit NotifyServiceIntf;
{$weakpackageunit on}
interface

type
  INotify = interface
    ['{9D0B21A1-CCA0-422F-B11B-4650B506A573}']
    procedure Notify(Flags: Integer; Intf: IInterface; Param: Integer);
  end;

  TSysNotifyEvent = procedure(Flags: Integer; Intf: IInterface; Param: Integer) of object;

  INotifyService = interface
    ['{F347E481-F6C3-48DA-BDD5-9452C69FCE30}']
    procedure SendNotify(Flags: Integer; Intf: IInterface; Param: Integer);

    procedure RegisterNotify(Notify: INotify);
    procedure UnRegisterNotify(Notify: INotify);

    procedure RegisterNotifyEx(Flags: Integer; Notify: INotify);
    procedure UnRegisterNotifyEx(Notify: INotify);

    procedure RegisterNotifyEvent(NotifyEvent: TSysNotifyEvent);
    procedure UnRegisterNotifyEvent(NotifyEvent: TSysNotifyEvent);

    procedure RegisterNotifyEventEx(Flags: Integer; NotifyEvent: TSysNotifyEvent);
    procedure UnRegisterNotifyEventEx(NotifyEvent: TSysNotifyEvent);
  end;

implementation

end.
