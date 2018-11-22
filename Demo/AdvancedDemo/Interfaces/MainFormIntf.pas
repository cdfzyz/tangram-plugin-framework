{------------------------------------
  功能说明：主窗体接口单元
  创建日期：2008/11/09
  作者：wzw
  版权：wzw
-------------------------------------}
unit MainFormIntf;
{$weakpackageunit on}
interface

uses Forms, Classes, Graphics;

type
  //单击(选择)快捷项
  IShortCutClick = interface
    ['{AEC846D1-8E5D-4EAE-993C-12616927C754}']
    //注册快捷菜单面板
    procedure RegPanel(FrameClass: TCustomFrameClass);
  end;
  //选择快捷菜单
  TShortCutClick = procedure(pIntf: IShortCutClick) of object;

  //主窗口实现的接口
  IMainForm = interface
    ['{C3DF922D-4AA5-4874-B0A3-72699DA671C8}']
    //创建普通菜单
    function CreateMenu(const Path: string; MenuClick: TNotifyEvent): TObject;
    //取消注册菜单
    procedure DeleteMenu(const Path: string);
    //创建工具栏
    function CreateToolButton(const aCaption: String; onClick: TNotifyEvent; Hint: String = ''): TObject;
    //注册快捷菜单
    procedure RegShortCut(const aCaption: string; onClick: TShortCutClick);
    //显示状态
    procedure ShowStatus(PnlIndex: Integer; const Msg: string);
    //退出程序
    procedure ExitApplication;
    //给ImageList添加图标
    function AddImage(Img: TGraphic): Integer;
  end;

  //系统窗体接口
  IFormMgr = interface
    ['{074BA876-C5DA-4689-BA11-48EB3CF22CF6}']
    function FindForm(const FormClassName: string): TForm;
    //FormClass:要创建的窗体类  SingleInstance:是否只创建一个实例
    function CreateForm(FormClass: TFormClass; SingleInstance: Boolean = True): TForm;
    procedure CloseForm(aForm: TForm);
  end;

implementation

end.
