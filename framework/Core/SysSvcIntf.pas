﻿unit SysSvcIntf;

interface

uses NotifyServiceIntf, ModuleLoaderIntf, ObjRefIntf;

type
  ISysService = interface
    ['{782CE8B0-66C0-4211-9A78-C54E19DBC5B3}']
    function Notify: INotifyService;
    function ModuleLoader: IModuleLoader;
    function GetObjRef(const IID: TGUID; out ObjRef: IObjRef): Boolean;
  end;
implementation

end.
