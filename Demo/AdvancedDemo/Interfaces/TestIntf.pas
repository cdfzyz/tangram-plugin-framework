unit TestIntf;
{$weakpackageunit on}
interface
type
  ITest = interface
    ['{CF7A7BB0-8540-4565-BDD8-52C52922B1D9}']
    procedure Test;
  end;
  ITestDLL = interface
    ['{E0B8EE32-940B-4544-8D1E-3DD81C8A9127}']
    procedure test;
  end;
implementation

end.
