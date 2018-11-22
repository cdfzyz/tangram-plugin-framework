unit uTestObj;

interface

uses sysUtils, Classes, Dialogs, SysFactory, uTestIntf;

type
  TTestObj = class(TInterfacedObject, ITest)
  private
  protected
  {ITest}
    procedure test;
  public
  end;

implementation

function Create_TestObj(param: Integer): TObject;
begin
  Result := TTestObj.Create;
end;


{ TTestObj }

procedure TTestObj.test;
begin
  showmessage('你好！');
end;

var Factory: TObject;
initialization
  Factory := TIntfFactory.Create(ITest, @Create_TestObj);
finalization
  Factory.Free;//动态卸载模块记得释放工厂类
end.