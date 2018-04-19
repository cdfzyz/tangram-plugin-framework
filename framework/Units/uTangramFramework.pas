{------------------------------------
  ����˵������ܼ��ص�Ԫ��ֻ��Ҫ�������򹤳��ļ��ñ���Ԫ�滻Forms��Ԫ���ɼ��ؿ�ܣ�
            �����Ķ�����Ҫ�ٸ���
  �������ڣ�2010/10/18
  ���ߣ�wei
  ��Ȩ��wei
-------------------------------------}
unit uTangramFramework;

interface

uses
  SysUtils,
  Classes,
  Vcl.Forms,
  Windows,
  SysModuleMgr;

type
  TTangramApp = class
  private
    FModuleMgr: TModuleMgr;
    FLoadModuleFromRegistry: Boolean;
    function  GetFormApp: TApplication;
    function  GetTitle: string;
    procedure SetTitle(const Value: string);
    function  ReadHintHidePause: Integer;
    procedure WriteHintHidePause(const Value: Integer);
    function  GetMainFormOnTaskbar: Boolean;
    procedure SetMainFormOnTaskbar(const Value: Boolean);
  public
    property Title: string read GetTitle write SetTitle;
    property HintHidePause: Integer read ReadHintHidePause write
      WriteHintHidePause;
    procedure Initialize;
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure Run;
    property FormApp: TApplication read GetFormApp;
    property MainFormOnTaskbar: Boolean read GetMainFormOnTaskbar write
      SetMainFormOnTaskbar;
    constructor Create;
    destructor Destroy; override;
    property LoadModuleFromRegistry: Boolean read FLoadModuleFromRegistry write
      FLoadModuleFromRegistry;
  end;

var
  Application: TTangramApp;

implementation

{$i tangram.inc}

{ TTangramApp }

constructor TTangramApp.Create;
begin
  FLoadModuleFromRegistry := True;
  FModuleMgr := TModuleMgr.Create;
end;

procedure TTangramApp.CreateForm(InstanceClass: TComponentClass; var Reference);
begin
  Vcl.Forms.Application.CreateForm(InstanceClass, Reference);
end;

destructor TTangramApp.Destroy;
begin
  FModuleMgr.Free;
  inherited;
end;

function TTangramApp.GetFormApp: TApplication;
begin
  Result := Vcl.Forms.Application;
end;

function TTangramApp.GetMainFormOnTaskbar: Boolean;
begin
  {$IFDEF D2007UP}
  Result := Vcl.Forms.Application.MainFormOnTaskbar;
  {$ENDIF}
end;

function TTangramApp.GetTitle: string;
begin
  Result := Vcl.Forms.Application.Title;
end;

procedure TTangramApp.Initialize;
begin
  Vcl.Forms.Application.Initialize;
end;

function TTangramApp.ReadHintHidePause: Integer;
begin
  Result := Vcl.Forms.Application.HintHidePause;
end;

procedure TTangramApp.Run;
begin
  if FLoadModuleFromRegistry then
  begin
    FModuleMgr.LoadModules;
    FModuleMgr.Init;
  end;
  Vcl.Forms.Application.Run;
  FModuleMgr.final;
end;

procedure TTangramApp.SetMainFormOnTaskbar(const Value: Boolean);
begin
  {$IFDEF D2007UP}
  Vcl.Forms.Application.MainFormOnTaskbar := Value;
  {$ENDIF}
end;

procedure TTangramApp.SetTitle(const Value: string);
begin
  Vcl.Forms.Application.Title := Value;
end;

procedure TTangramApp.WriteHintHidePause(const Value: Integer);
begin
  Vcl.Forms.Application.HintHidePause := Value;
end;

initialization
  Application := TTangramApp.Create;

finalization
  Application.Free;

end.

