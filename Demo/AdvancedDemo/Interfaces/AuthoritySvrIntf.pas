{------------------------------------
  ����˵����Ȩ�޿��Ʒ���ӿ�
  �������ڣ�2010/05/11
  ���ߣ�wzw
  ��Ȩ��wzw
-------------------------------------}
unit AuthoritySvrIntf;
{$weakpackageunit on}
interface

type
  IAuthorityRegistrar = interface
    ['{F2A8A69F-70C2-4086-B167-18C1C1761E54}']
    procedure RegAuthorityItem(const Key, Path, aItemName: string; Default: Boolean = False);
  end;

  IAuthorityCtrl = interface
    ['{44BB7145-9CF1-4C51-A567-25415801921D}']
    procedure RegAuthority(aIntf: IAuthorityRegistrar);
    procedure HandleAuthority(const Key: String; aEnable: Boolean);
  end;

  IAuthoritySvr = interface
    ['{45936D0D-4DA3-40B3-98D1-FB32A7E3C3FF}']
    procedure RegAuthority(aIntf: IAuthorityCtrl);
    procedure AuthorityCtrl(aIntf: IAuthorityCtrl);
    procedure UpdateAuthority;
  end;

implementation

end.
