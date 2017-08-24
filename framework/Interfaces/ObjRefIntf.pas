//2011.09.05 by wei
unit ObjRefIntf;
{$weakpackageunit on}
interface

type
  IObjRef = interface
    ['{43B273B9-F06C-45DC-96A5-4A8B7239E020}']
    function Obj: TObject;
    function ObjIsNil: Boolean;
  end;

implementation

end.
