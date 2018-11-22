{------------------------------------
  功能说明：工厂管理
  创建日期：2010/04/20
  作者：WZW
  版权：WZW
-------------------------------------}
unit SysFactoryMgr;

interface

uses
  System.Types,
  SysUtils,
  Classes,
  FactoryIntf,
  SvcInfoIntf,
  uIntfObj,
  System.Generics.Collections;

type
  TSysFactoryList = class(TObject)
  private
    FList: TList;
    function GetItems(Index: integer): TFactory;
    function GetCount: Integer;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function Add(aFactory: TFactory): integer;
    function IndexOf(const IntfName: string): Integer;
    function GetFactory(const IntfName: string): TFactory;
    function FindFactory(const IntfName: string): TFactory;
    function Remove(aFactory: TFactory): Integer;
    property Items[Index: integer]: TFactory read GetItems; default;
    property Count: Integer read GetCount;
  end;

  TSysFactoryManager = class(TIntfObj, IEnumKey)
  private
    FSysFactoryList: TSysFactoryList;
    FIndexList: TDictionary<string, Pointer>;
    FKeyList: TStrings;
  protected
    {IEnumKey}
    procedure EnumKey(const IntfName: string);
  public
    procedure RegisterFactory(aIntfFactory: TFactory);
    procedure UnRegisterFactory(aFactory: TFactory); overload;
    function FindFactory(const IntfName: string): TFactory;
    property FactoryList: TSysFactoryList read FSysFactoryList;
    function Exists(const IntfName: string): Boolean;
    procedure ReleaseIntf;
    constructor Create;
    destructor Destroy; override;
  end;

  //注册接口异常类
  ERegistryIntfException = class(Exception);

function FactoryManager: TSysFactoryManager;

implementation

uses
  SysMsg;

var
  FFactoryManager: TSysFactoryManager;

function FactoryManager: TSysFactoryManager;
begin
  if FFactoryManager = nil then
    FFactoryManager := TSysFactoryManager.Create;

  Result := FFactoryManager;
end;

{ TSysFactoryList }

function TSysFactoryList.Add(aFactory: TFactory): integer;
begin
  Result := FList.Add(aFactory);
end;

constructor TSysFactoryList.Create;
begin
  inherited;
  FList := TList.Create;
end;

destructor TSysFactoryList.Destroy;
var
  i: Integer;
begin
  for i := Flist.Count - 1 downto 0 do
    TObject(FList[i]).Free;

  FList.Free;
  inherited Destroy;
end;

function TSysFactoryList.FindFactory(const IntfName: string): TFactory;
var
  idx: integer;
begin
  result := nil;
  idx := self.IndexOf(IntfName);
  if idx <> -1 then
    Result := TFactory(FList[idx]);
end;

function TSysFactoryList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSysFactoryList.GetFactory(const IntfName: string): TFactory;
begin
  Result := FindFactory(IntfName);
  if not Assigned(result) then
    raise Exception.CreateFmt(Err_IntfNotFound, [IntfName]);
end;

function TSysFactoryList.GetItems(Index: integer): TFactory;
begin
  Result := TFactory(FList[Index]);
end;

function TSysFactoryList.IndexOf(const IntfName: string): Integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to (FList.Count - 1) do
  begin
    if TFactory(FList[i]).Supports(IntfName) then
    begin
      result := i;
      Break;
    end;
  end;
end;

function TSysFactoryList.Remove(aFactory: TFactory): Integer;
begin
  Result := FList.Remove(aFactory);
end;
{ TSysFactoryManager }

constructor TSysFactoryManager.Create;
begin
  FSysFactoryList := TSysFactoryList.Create;
  FIndexList := TDictionary<string, Pointer>.Create;
  FKeyList := TStringList.Create;
end;

destructor TSysFactoryManager.Destroy;
begin
  FSysFactoryList.Free;
  FIndexList.Free;
  FKeyList.Free;
  inherited;
end;

function TSysFactoryManager.Exists(const IntfName: string): Boolean;
begin
  Result := FSysFactoryList.IndexOf(IntfName) <> -1;
end;

function TSysFactoryManager.FindFactory(const IntfName: string): TFactory;
var
  PFactory: Pointer;
begin
  Result := nil;
  if not FIndexList.TryGetValue(IntfName, PFactory) then
    PFactory := nil;
  if PFactory <> nil then
    Result := TFactory(PFactory)
  else
  begin
    if FKeyList.IndexOf(IntfName) = -1 then
    begin
      Result := FSysFactoryList.FindFactory(IntfName);
      if Result = nil then
        FKeyList.Add(IntfName)
      else
        FIndexList.Add(IntfName, Result);
    end;
  end;
end;

procedure TSysFactoryManager.RegisterFactory(aIntfFactory: TFactory);
var
  i: Integer;
  IntfName: string;
begin
  FSysFactoryList.Add(aIntfFactory);

  for i := FKeyList.Count - 1 downto 0 do
  begin
    IntfName := FKeyList[i];
    if aIntfFactory.Supports(IntfName) then
    begin
      FIndexList.Add(IntfName, Pointer(aIntfFactory));
      FKeyList.Delete(i);
    end;
  end;
end;

procedure TSysFactoryManager.ReleaseIntf;
var
  i: Integer;
begin
  for i := 0 to self.FSysFactoryList.Count - 1 do
    self.FSysFactoryList.Items[i].ReleaseIntf;
end;

procedure TSysFactoryManager.EnumKey(const IntfName: string);
begin
  self.FIndexList.Remove(IntfName);
end;

procedure TSysFactoryManager.UnRegisterFactory(aFactory: TFactory);
begin
  if Assigned(aFactory) then
  begin
    aFactory.EnumKeys(self);
    aFactory.ReleaseIntf;
    FSysFactoryList.Remove(aFactory);
  end;
end;

initialization
  FFactoryManager := nil;

finalization
  FFactoryManager.Free;

end.

