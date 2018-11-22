{------------------------------------
  功能说明：实现权限控制服务接口
  创建日期：2010/05/11
  作者：wzw
  版权：wzw
-------------------------------------}
unit ImpAuthoritySvrIntf;

interface

uses
  sysUtils,
  Classes,
  SysFactory,
  SvcInfoIntf,
  AuthoritySvrIntf,
  Contnrs,
  DB,
  DBClient;

type
  TItem = class
  public
    Key: string;
    Path: string;
    ItemName: string;
    Default: Boolean;
  end;

  TAuthoritySvr = class(TInterfacedObject, IAuthoritySvr, IAuthorityRegistrar,
    ISvcInfo)
  private
    FList: TObjectList;
    Cds_RegAuthority: TClientDataSet;
    function GetKeys: string;
  protected
  {ISvcInfo}
    function GetModuleName: string;
    function GetTitle: string;
    function GetVersion: string;
    function GetComments: string;
  {IAuthoritySvr}
    procedure RegAuthority(aIntf: IAuthorityCtrl);
    procedure AuthorityCtrl(aIntf: IAuthorityCtrl);
    procedure UpdateAuthority;
  {IAuthorityRegistrar}
    procedure RegAuthorityItem(const Key, Path, aItemName: string; Default:
      Boolean = False);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  SysSvc,
  DBIntf,
  ProgressFormIntf,
  NotifyServiceIntf,
  uConst,
  DialogIntf,
  SysInfoIntf;

function Create_AuthoritySvr(param: Integer): TObject;
begin
  Result := TAuthoritySvr.Create;
end;

{ TTAuthoritySvr }

function TAuthoritySvr.GetComments: string;
begin
  Result := '权限管理相关';
end;

function TAuthoritySvr.GetModuleName: string;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TAuthoritySvr.GetTitle: string;
begin
  Result := '权限服务接口(IAuthoritySvr)';
end;

function TAuthoritySvr.GetVersion: string;
begin
  Result := '20100511.001';
end;

procedure TAuthoritySvr.AuthorityCtrl(aIntf: IAuthorityCtrl);
const
  Sql = 'select * from [RoleAuthority] where RoleID=%d and aKey in (%s)';
var
  i: Integer;
  Item: TItem;
  aEnable: Boolean;
  DBAccess: IDBAccess;
  cds: TClientDataSet;
  RoleID: Integer;
  IsAdmin: Boolean;
  SysInfo: ISysInfo;
begin
  FList.Clear;
  aIntf.RegAuthority(self);
  if FList.Count > 0 then
  begin
    if SysService.QueryInterface(IDBAccess, DBAccess) = S_OK then
    begin
      cds := TClientDataSet.Create(nil);
      try
        SysInfo := SysService as ISysInfo;
        RoleID := SysInfo.LoginUserInfo^.RoleID;
        IsAdmin := SysInfo.LoginUserInfo^.IsAdmin;
        if not IsAdmin then
          DBAccess.QuerySQL(cds, Format(Sql, [RoleID, self.GetKeys]));
        for i := 0 to FList.Count - 1 do
        begin
          Item := TItem(FList[i]);
          if IsAdmin then
            aIntf.HandleAuthority(Item.Key, True)
          else
          begin
            if cds.Locate('aKey', Item.Key, []) then
              aEnable := cds.FieldByName('aEnable').AsBoolean
            else
              aEnable := Item.Default;
            aIntf.HandleAuthority(Item.Key, aEnable);
          end;
        end;
      finally
        cds.Free;
      end;
    end;
  end;
end;

procedure TAuthoritySvr.RegAuthority(aIntf: IAuthorityCtrl);
var
  DBAccess: IDBAccess;
  i: Integer;
  Item: TItem;
begin
  FList.Clear;
  aIntf.RegAuthority(self);
  if FList.Count > 0 then
  begin
    if SysService.QueryInterface(IDBAccess, DBAccess) = S_OK then
    begin
      DBAccess.BeginTrans;
      for i := 0 to FList.Count - 1 do
      begin
        Item := TItem(FList[i]);
        DBAccess.QuerySQL(Cds_RegAuthority, 'select * from [AuthorityItem] where aKey = '''+ Item.Key +'''');
        if Cds_RegAuthority.RecordCount = 0 then
          Cds_RegAuthority.Append
        else
          Cds_RegAuthority.Edit;
        Cds_RegAuthority.FieldByName('aKey').AsString := Item.Key;
        Cds_RegAuthority.FieldByName('aItemName').AsString := Item.ItemName;
        Cds_RegAuthority.FieldByName('aPath').AsString := Item.Path;
        Cds_RegAuthority.FieldByName('aDefault').AsBoolean := Item.Default;
        Cds_RegAuthority.Post;
        DBAccess.ApplyUpdate('[AuthorityItem]', Cds_RegAuthority);
      end;
      DBAccess.CommitTrans;
    end;
  end;
end;

procedure TAuthoritySvr.RegAuthorityItem(const Key, Path, aItemName: string;
  Default: Boolean);
var
  Item: TItem;
begin
  Item := TItem.Create;
  Item.Key := Key;
  Item.Path := Path;
  Item.ItemName := aItemName;
  Item.Default := Default;
  FList.Add(Item);
end;

constructor TAuthoritySvr.Create;
begin
  FList := TObjectList.Create(True);
  Cds_RegAuthority := TClientDataSet.Create(nil);
end;

destructor TAuthoritySvr.Destroy;
begin
  FList.Free;
  Cds_RegAuthority.Free;
  inherited;
end;

function TAuthoritySvr.GetKeys: string;
var
  s: string;
  i: integer;
  Item: TItem;
begin
  s := '';
  for i := 0 to FList.Count - 1 do
  begin
    Item := TItem(FList[i]);
    if s = '' then
      s := '''' + Item.Key + ''''
    else
      s := s + ',''' + Item.Key + '''';
  end;
  Result := s;
end;

procedure TAuthoritySvr.UpdateAuthority;
const
  Sql = 'Select * from %s where 1<>1';
  Sql_Clear = 'Delete from %s';
  TableName = '[AuthorityItem]';
var
  Intf: IProgressForm;
  DBAccess: IDBAccess;
  Dialog: IDialog;
  NotifyIntf: INotifyService;
begin
  Dialog := SysService as IDialog;
  if SysService.QueryInterface(IDBAccess, DBAccess) = S_OK then
  begin
    Intf := SysService as IProgressForm;
    Intf.ShowMsg('正在更新系统权限，请稍等......');
    try
      NotifyIntf := SysService as INotifyService;
      DBAccess.QuerySQL(Cds_RegAuthority, Format(Sql, [TableName]));
      NotifyIntf.SendNotify(Flags_RegAuthority, nil, 0);
      DBAccess.BeginTrans;
      try
        DBAccess.ExecuteSQL(Format(Sql_Clear, [TableName]));

        DBAccess.ApplyUpdate(TableName, Cds_RegAuthority);
        DBAccess.CommitTrans;
        Intf.Hide;
        Dialog.ShowInfo('权限更新完成！');
        Cds_RegAuthority.EmptyDataSet;
      except
        on E: Exception do
        begin
          DBAccess.RollbackTrans;
          Dialog.ShowError(E);
        end;
      end;
    finally
      Intf.Hide;
    end;
  end
  else
    Dialog.ShowError('未找到IDBAccess接口，不能更新权限！');
end;

initialization
  TSingletonFactory.Create(IAuthoritySvr, @Create_AuthoritySvr);

finalization

end.

