unit uIntf;
{$weakpackageunit on}

interface

uses Vcl.Forms, Vcl.Graphics;

type
  //������ʵ�ֵĽӿ�
  IIntf1 = interface
    ['{11BD3D1F-D178-4F84-A939-5C9D25CAD73F}']
    procedure SetMainFormCaption(const str: String);
    procedure SetMainFormColor(aColor: TColor);
  end;
  //DLLģ����ʵ�ֵĽӿ�
  IIntf2 = interface
    ['{91B01582-4C31-4874-ABB3-90E811929CA0}']
    procedure ShowDLlForm;
  end;
  //BPLģ����ʵ�ֵĽӿ�
  IIntf3 = interface
    ['{BE99F519-6CB0-427A-A849-E7E12D377442}']
    procedure ShowBPLform;
  end;
implementation

end.
