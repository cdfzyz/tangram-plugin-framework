{------------------------------------
  ����˵����ϵͳ��־�ӿ�
  �������ڣ�2008/11/20
  ���ߣ�wzw
  ��Ȩ��wzw
-------------------------------------}
unit LogIntf;
{$weakpackageunit on}

interface

uses
  SysUtils;

type
  ILog = interface
    ['{472FD4AD-F589-4D4D-9051-A20D37B7E236}']
    procedure WriteLog(const Str: string);
    procedure WriteLogFmt(const Str: string; const Args: array of const);
    function GetLogFileName: string;
  end;

implementation

end.

