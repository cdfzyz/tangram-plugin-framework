{------------------------------------
  ����˵����ϵͳ��Ϣ�ӿ�
  �������ڣ�2008/11/12
  ���ߣ�wzw
  ��Ȩ��wzw
-------------------------------------}
unit SysInfoIntf;
{$weakpackageunit on}
interface
type
  PLoginUserInfo = ^TLoginUserInfo;
  TLoginUserInfo = record
    UserID: Integer;
    UserName: String;
    RoleID: Integer;
    IsAdmin: Boolean;
  end;

  ISysInfo = interface
    ['{E06C3E07-6865-405C-9EC6-6384BB4CB5DD}']
    function RegistryFile: string;//ע����ļ�
    function AppPath: string;//����Ŀ¼
    function ErrPath: string;//������־Ŀ¼

    function LoginUserInfo: PLoginUserInfo;
  end;
implementation

end.
