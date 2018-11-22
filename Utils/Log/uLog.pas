{------------------------------------
  功能说明：实现ILog接口
  创建日期：2008/11/21
  作者：wzw
  版权：wzw
-------------------------------------}
unit uLog;

interface

uses
  SysUtils,
  DateUtils,
  LogIntf,
  SvcInfoIntf;

type
  TLogObj = class(TInterfacedObject, ILog, ISvcInfo)
  private
    procedure WriteToFile(const Msg: string);
  protected
    {ILog}
    procedure WriteLog(const Str: string);
    procedure WriteLogFmt(const Str: string; const Args: array of const);
    function GetLogFileName: string;
    {ISvcInfo}
    function GetModuleName: string;
    function GetTitle: string;
    function GetVersion: string;
    function GetComments: string;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  SysSvc,
  SysFactory;

{ TLogObj }

function TLogObj.GetLogFileName: string;
var
  Logpath: string;
begin
  Logpath := ExtractFilePath(ParamStr(0)) + 'Logs\';
  if not DirectoryExists(Logpath) then
    ForceDirectories(Logpath);

  Result := Logpath + FormatDateTime('YYYY-MM-DD', Now) + '.log';
end;

constructor TLogObj.Create;
begin

end;

destructor TLogObj.Destroy;
begin

  inherited;
end;

function TLogObj.GetComments: string;
begin
  Result := '封装日志相关操作';
end;

function TLogObj.GetModuleName: string;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TLogObj.GetTitle: string;
begin
  Result := '日志接口(ILog)';
end;

function TLogObj.GetVersion: string;
begin
  Result := '20110417.002';
end;

procedure TLogObj.WriteLog(const Str: string);
begin
  WriteToFile(Str);
end;

procedure TLogObj.WriteLogFmt(const Str: string; const Args: array of const);
begin
  WriteToFile(Format(Str, Args));
end;

procedure TLogObj.WriteToFile(const Msg: string);
var
  FileName: string;
  FileHandle: TextFile;
begin
  FileName := GetLogFileName;
  AssignFile(FileHandle, FileName);
  try
    if FileExists(FileName) then
      Append(FileHandle)//Reset(FileHandle)
    else
      Rewrite(FileHandle);

    Writeln(FileHandle, FormatDateTime('[HH:MM:SS]', Now) + '  ' + Msg);
  finally
    CloseFile(FileHandle);
  end;
end;

function Create_LogObj(param: Integer): TObject;
begin
  Result := TLogObj.Create;
end;

initialization
  TIntfFactory.Create(ILog, @Create_LogObj);

finalization

end.

