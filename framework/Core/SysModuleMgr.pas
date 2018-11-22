{ ------------------------------------
  功能说明：模块管理
  创建日期：2010/05/11
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit SysModuleMgr;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Contnrs,
  RegIntf,
  SplashFormIntf,
  ModuleInfoIntf,
  SvcInfoIntf,
  SysModule,
  ModuleLoaderIntf,
  StrUtils,
  uIntfObj,
  ModuleInstallerIntf,
  SysNotifyService,
  NotifyServiceIntf,
  Forms;

type
  TGetModuleClassPro = function: TModuleClass;

  TModuleType = (mtUnknow, mtBPL, mtDLL);

  TTangramModule = class(TObject)
  private
    FLoadBatch: string;
    FModuleHandle: HMODULE;
    FModuleFileName: string;
    FModuleObj: TModule;
    FModuleCls: TModuleClass;
    FValidModule: Boolean;
    function GetModuleType: TModuleType;
    function LoadModule: THandle;
    procedure UnLoadModule;
    function GetModuleName: string;
  protected
  public
    constructor Create(const mFile: string; LoadBatch: string = '';
      CreateModuleObjInstance: Boolean = True);
    destructor Destroy; override;
    property ModuleFileName: string read FModuleFileName;
    property ModuleType: TModuleType read GetModuleType;
    property ModuleName: string read GetModuleName;
    procedure ModuleNotify(Flags: Integer; Intf: IInterface; Param: Cardinal);
    procedure ModuleInit(const LoadBatch: string);
    procedure ModuleFinal;
    procedure Install;
    procedure UnInstall;
    property IsValidModule: Boolean read FValidModule;
  end;

  TModuleMgr = class(TIntfObj, IModuleInfo, IModuleLoader, IModuleInstaller,
    ISvcInfoEx)
  private
    SplashForm: ISplashForm;
    Tick: Cardinal;
    FModuleList: TObjectList;
    FLoadBatch: string;
    FNotifyService: TNotifyService;
    procedure WriteErrFmt(const err: string; const Args: array of const);
    function FormatPath(const s: string): string;
    procedure GetModuleList(RegIntf: IRegistry; ModuleList: TStrings; const Key:
      string);
    function FindModule(const ModuleFile: string): TTangramModule;
  protected
    {IModuleLoader}
    procedure LoadBegin;
    procedure LoadModuleFromFile(const ModuleFile: string);
    procedure LoadModulesFromDir(const Dir: string = '');
    procedure LoadFinish;
    procedure UnLoadModule(const ModuleFile: string);
    function ModuleLoaded(const ModuleFile: string): Boolean;
    { IModuleInfo }
    procedure GetModuleInfo(ModuleInfoGetter: IModuleInfoGetter);
    { ISvcInfoEx }
    procedure GetSvcInfo(Intf: ISvcInfoGetter);
    {IModuleInstaller}
    procedure InstallModule(const ModuleFile: string);
    procedure UninstallModule(const ModuleFile: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadModules;
    procedure Init;
    procedure final;
  end;

implementation

uses
  SysSvc,
  LogIntf,
  LoginIntf,
  StdVcl,
  AxCtrls,
  SysFactoryMgr,
  SysFactory,
  SysFactoryEx,
  IniFiles,
  RegObj,
  uSvcInfoObj,
  SysMsg;

{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}

const
  Value_Module = 'Module';
  Value_Load = 'LOAD';
  SplashFormWaitTime = 1500;
  key_LoadModule = 'SYSTEM\LOADMODULE';

function CreateRegObj(Param: Integer): TObject;
var
  RegFile, IniFile, AppPath: string;
  Ini: TIniFile;
begin
  AppPath := ExtractFilePath(ParamStr(0));
  IniFile := AppPath + 'Root.ini';
  Ini := TIniFile.Create(IniFile);
  try
    RegFile := AppPath + Ini.ReadString('Default', 'Reg', 'Tangram.xml');
    Result := TRegObj.Create(RegFile);
  finally
    Ini.Free;
  end;
end;

function Create_SvcInfoObj(Param: Integer): TObject;
begin
  Result := TSvcInfoObj.Create;
end;

{ TTangramModule }

constructor TTangramModule.Create(const mFile: string; LoadBatch: string = '';
  CreateModuleObjInstance: Boolean = True);
var
  GetModuleClassPro: TGetModuleClassPro;
begin
  FValidModule := False;
  FModuleObj := nil;
  FModuleCls := nil;
  FLoadBatch := LoadBatch;
  FModuleFileName := mFile;
  FModuleHandle := self.LoadModule;
  @GetModuleClassPro := GetProcAddress(FModuleHandle, 'GetModuleClass');
  if Assigned(GetModuleClassPro) then
  begin
    FModuleCls := GetModuleClassPro;
    FValidModule := FModuleCls <> nil;
    if (FModuleCls <> nil) and (CreateModuleObjInstance) then
      FModuleObj := FModuleCls.Create;
  end;
end;

destructor TTangramModule.Destroy;
begin
  if Assigned(FModuleObj) then
    FModuleObj.Free;

  self.UnLoadModule;
  inherited;
end;

function TTangramModule.GetModuleName: string;
begin
  Result := ExtractFileName(FModuleFileName);
end;

function TTangramModule.GetModuleType: TModuleType;
var
  ext: string;
begin
  ext := ExtractFileExt(self.FModuleFileName);
  if SameText(ext, '.bpl') then
    Result := mtBPL
  else
    Result := mtDLL;
end;

function TTangramModule.LoadModule: THandle;
begin
  Result := 0;
  case GetModuleType of
    mtBPL:
      Result := SysUtils.LoadPackage(self.FModuleFileName);
    mtDLL:
      Result := Windows.LoadLibrary(Pchar(self.FModuleFileName));
  end;
end;

procedure TTangramModule.ModuleFinal;
begin
  if FModuleObj <> nil then
    FModuleObj.final;
end;

procedure TTangramModule.ModuleInit(const LoadBatch: string);
begin
  if FModuleObj <> nil then
  begin
    if self.FLoadBatch = LoadBatch then
      FModuleObj.Init;
  end;
end;

procedure TTangramModule.Install;
var
  Reg: IRegistry;
begin
  if FModuleCls <> nil then
  begin
    Reg := SysService as IRegistry;
    FModuleCls.RegisterModule(Reg);
  end;
end;

procedure TTangramModule.ModuleNotify(Flags: Integer; Intf: IInterface; Param:
  Cardinal);
begin
  if FModuleObj <> nil then
    FModuleObj.Notify(Flags, Intf, Param);
end;

procedure TTangramModule.UnInstall;
var
  Reg: IRegistry;
begin
  if FModuleCls <> nil then
  begin
    Reg := SysService as IRegistry;
    FModuleCls.UnRegisterModule(Reg);
  end;
end;

procedure TTangramModule.UnLoadModule;
begin
  case GetModuleType of
    mtBPL:
      SysUtils.UnloadPackage(self.FModuleHandle);
    mtDLL:
      Windows.FreeLibrary(self.FModuleHandle);
  end;
end;

{ TModuleMgr }

procedure TModuleMgr.GetSvcInfo(Intf: ISvcInfoGetter);
var
  SvrInfo: TSvcInfoRec;
begin
  SvrInfo.ModuleName := ExtractFileName(SysUtils.GetModuleName(HInstance));
  SvrInfo.GUID := GUIDToString(IModuleInfo);
  SvrInfo.Title := '模块信息接口(IModuleInfo)';
  SvrInfo.Version := '20100512.001';
  SvrInfo.Comments := '用于获取当前系统加载包的信息及初始化包。';
  Intf.SvcInfo(SvrInfo);

  SvrInfo.GUID := GUIDToString(IModuleLoader);
  SvrInfo.Title := '模块加载接口(IModuleLoader)';
  SvrInfo.Version := '20110225.001';
  SvrInfo.Comments :=
    '用户可以用此接口自主加载模块，不用框架默认的从注册表加载方式';
  Intf.SvcInfo(SvrInfo);

  SvrInfo.GUID := GUIDToString(IModuleInstaller);
  SvrInfo.Title := '模块安装接口(IModuleInstaller)';
  SvrInfo.Version := '20110420.001';
  SvrInfo.Comments := '用于安装和卸载模块';
  Intf.SvcInfo(SvrInfo);
end;

constructor TModuleMgr.Create;
begin
  FLoadBatch := '';
  FModuleList := TObjectList.Create(True);
  FNotifyService := TNotifyService.Create;

  TSingletonFactory.Create(IRegistry, @CreateRegObj);
  TObjFactoryEx.Create([IModuleInfo, IModuleLoader, IModuleInstaller], self);
  TIntfFactory.Create(ISvcInfoEx, @Create_SvcInfoObj);
end;

destructor TModuleMgr.Destroy;
begin
  FNotifyService.Free;
  FModuleList.Free;
  inherited;
end;

function TModuleMgr.FindModule(const ModuleFile: string): TTangramModule;
var
  i: Integer;
  Module: TTangramModule;
begin
  Result := nil;
  for i := 0 to FModuleList.Count - 1 do
  begin
    Module := TTangramModule(FModuleList[i]);
    if SameText(Module.ModuleFileName, ModuleFile) then
    begin
      Result := Module;
      Break;
    end;
  end;
end;

function TModuleMgr.FormatPath(const s: string): string;
const
  Var_AppPath = '($APP_PATH)';
begin
  Result := StringReplace(s, Var_AppPath, ExtractFilePath(Paramstr(0)), [rfReplaceAll,
    rfIgnoreCase]);
end;

procedure TModuleMgr.GetModuleList(RegIntf: IRegistry; ModuleList: TStrings;
  const Key: string);
var
  SubKeyList, ValueList, aList: TStrings;
  i: Integer;
  valueStr: string;
  valueName, vStr, ModuleFile, Load: WideString;
begin
  SubKeyList := TStringList.Create;
  ValueList := TStringList.Create;
  aList := TStringList.Create;
  try
    RegIntf.OpenKey(Key, False);
    // 处理值
    RegIntf.GetValueNames(ValueList);
    for i := 0 to ValueList.Count - 1 do
    begin
      aList.Clear;
      valueName := ValueList[i];
      if RegIntf.ReadString(valueName, vStr) then
      begin
        valueStr := AnsiUpperCase(vStr);
        ExtractStrings([';'], [], pchar(valueStr), aList);
        ModuleFile := FormatPath(aList.Values[Value_Module]);
        Load := aList.Values[Value_Load];
        if (ModuleFile <> '') and (CompareText(Load, 'TRUE') = 0) then
          ModuleList.Add(ModuleFile);
      end;
    end;
    // 向下查找
    RegIntf.GetKeyNames(SubKeyList);
    for i := 0 to SubKeyList.Count - 1 do
      GetModuleList(RegIntf, ModuleList, Key + '\' + SubKeyList[i]); // 递归
  finally
    SubKeyList.Free;
    ValueList.Free;
    aList.Free;
  end;
end;

function TModuleMgr.ModuleLoaded(const ModuleFile: string): Boolean;
begin
  Result := FindModule(ModuleFile) <> nil;
end;

procedure TModuleMgr.GetModuleInfo(ModuleInfoGetter: IModuleInfoGetter);
var
  i: Integer;
  Module: TTangramModule;
  MInfo: TModuleInfo;
begin
  if ModuleInfoGetter = nil then
    exit;
  for i := 0 to FModuleList.Count - 1 do
  begin
    Module := TTangramModule(FModuleList[i]);
    MInfo.PackageName := Module.ModuleFileName;
    MInfo.Description := GetPackageDescription(pchar(MInfo.PackageName));
    ModuleInfoGetter.ModuleInfo(MInfo);
  end;
end;

procedure TModuleMgr.Init;
var
  CurTick, UseTime, WaitTime: Cardinal;
  LoginIntf: ILogin;
  Module: TTangramModule;
  i: Integer;
begin
  Module := nil;
  for i := 0 to FModuleList.Count - 1 do
  begin
    try
      Module := TTangramModule(FModuleList.Items[i]);

      if Assigned(SplashForm) then
        SplashForm.loading(Format(Msg_InitingModule, [Module.ModuleName]));

      Module.ModuleInit(self.FLoadBatch);
    except
      on E: Exception do
      begin
        WriteErrFmt(Err_InitModule, [Module.ModuleName, E.Message]);
      end;
    end;
  end;
  // 隐藏Splash窗体
  if Assigned(SplashForm) then
  begin
    CurTick := GetTickCount;
    UseTime := CurTick - Tick;
    WaitTime := SplashForm.GetWaitTime;
    if WaitTime = 0 then
      WaitTime := SplashFormWaitTime;
    if UseTime < WaitTime then
    begin
      SplashForm.loading(Msg_WaitingLogin);
      sleep(WaitTime - UseTime);
    end;

    SplashForm.Hide;
    //FactoryManager.FindFactory(ISplashForm).Free;
    SplashForm := nil;
  end;
  // 检查登录
  if SysService.QueryInterface(ILogin, LoginIntf) = S_OK then
  begin
    if not LoginIntf.Login then
    begin
      Application.ShowMainForm := False;
      Application.Terminate;
    end;
  end;
end;

procedure TModuleMgr.LoadModules;
var
  aList: TStrings;
  i: Integer;
  RegIntf: IRegistry;
  ModuleFile: string;
begin
  aList := TStringList.Create;
  try
    SplashForm := nil;
    RegIntf := SysService as IRegistry;
    GetModuleList(RegIntf, aList, key_LoadModule);
    for i := 0 to aList.Count - 1 do
    begin
      ModuleFile := aList[i];

      if Assigned(SplashForm) then
        SplashForm.loading(Format(Msg_LoadingModule, [ExtractFileName(ModuleFile)]));
          // 加载包
      if FileExists(ModuleFile) then
        LoadModuleFromFile(ModuleFile)
      else
        WriteErrFmt(Err_ModuleNotExists, [ModuleFile]);

      // 显示Falsh窗体
      if SplashForm = nil then
      begin
        if SysService.QueryInterface(ISplashForm, SplashForm) = S_OK then
        begin
          Tick := GetTickCount;
          SplashForm.Show;
        end;
      end;
    end;
  finally
    aList.Free;
  end;
end;

procedure TModuleMgr.LoadBegin;
var
  BatchID: TGUID;
begin
  if CreateGUID(BatchID) = S_OK then
    self.FLoadBatch := GUIDToString(BatchID);
end;

procedure TModuleMgr.LoadFinish;
begin
  self.Init;
end;

procedure TModuleMgr.LoadModulesFromDir(const Dir: string);
var
  DR: TSearchRec;
  ZR: Integer;
  TmpPath, FileExt, FullFileName: string;
begin
  if Dir = '' then
    TmpPath := ExtractFilePath(ParamStr(0))
  else
  begin
    if RightStr(Dir, 1) = '\' then
      TmpPath := Dir
    else
      TmpPath := Dir + '\';
  end;
  ZR := SysUtils.FindFirst(TmpPath + '*.*', FaAnyfile, DR);
  try
    while ZR = 0 do
    begin
      if ((DR.Attr and FaDirectory <> FaDirectory) and (DR.Attr and FaVolumeID
        <> FaVolumeID)) and (DR.Name <> '.') and (DR.Name <> '..') then
      begin
        FullFileName := TmpPath + DR.Name;
        FileExt := ExtractFileExt(FullFileName);

        if SameText(FileExt, '.dll') or SameText(FileExt, '.bpl') then
          self.LoadModuleFromFile(FullFileName);
      end;
      ZR := SysUtils.FindNext(DR);
    end; //end while
  finally
    SysUtils.FindClose(DR);
  end;
end;

procedure TModuleMgr.LoadModuleFromFile(const ModuleFile: string);
var
  Module: TTangramModule;
begin
  try
    Module := TTangramModule.Create(ModuleFile, self.FLoadBatch);
    if Module.IsValidModule then
      FModuleList.Add(Module)
    else
      Module.Free;
  except
    on E: Exception do
    begin
      WriteErrFmt(Err_LoadModule, [ExtractFileName(ModuleFile), E.Message]);
    end;
  end;
end;

procedure TModuleMgr.UnLoadModule(const moduleFile: string);
var
  Module: TTangramModule;
begin
  Module := self.FindModule(moduleFile);
  if Module <> nil then
    FModuleList.Remove(Module);
end;

procedure TModuleMgr.final;
var
  i: Integer;
  Module: TTangramModule;
begin
  for i := 0 to FModuleList.Count - 1 do
  begin
    Module := TTangramModule(FModuleList.Items[i]);
    try
      Module.ModuleFinal;
    except
      on E: Exception do
        self.WriteErrFmt(Err_finalModule, [Module.ModuleName, E.Message]);
    end;
  end;

  FactoryManager.ReleaseIntf;
end;

procedure TModuleMgr.WriteErrFmt(const err: string; const Args: array of const);
var
  Log: ILog;
begin
  if SysService.QueryInterface(ILog, Log) = S_OK then
    Log.WriteLogFmt(err, Args);
end;

procedure TModuleMgr.InstallModule(const ModuleFile: string);
var
  Module: TTangramModule;
begin
  Module := self.FindModule(ModuleFile);
  if Module = nil then
  begin
    Module := TTangramModule.Create(ModuleFile, '', False);
    if Module.IsValidModule then
      FModuleList.Add(Module)
    else
    begin
      Module.Free;
      exit;
    end;
  end;
  Module.Install;
end;

procedure TModuleMgr.UninstallModule(const ModuleFile: string);
var
  Module: TTangramModule;
begin
  Module := self.FindModule(ModuleFile);
  if Module = nil then
  begin
    Module := TTangramModule.Create(ModuleFile, '', False);
    if Module.IsValidModule then
      FModuleList.Add(Module)
    else
    begin
      Module.Free;
      exit;
    end;
  end;
  Module.UnInstall;
end;

initialization

finalization

end.

