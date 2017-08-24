{------------------------------------
  功能说明：数据库操作接口
  创建日期：2010/04/26
  作者：wzw
  版权：wzw
-------------------------------------}
unit DBIntf;
{$weakpackageunit on}
interface

uses Classes, DB, DBClient;

type
  IDBConnection = interface
    ['{C2AF5DCA-985A-4915-B2CB-4F3FDD321BA5}']
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    property Connected: Boolean read GetConnected write SetConnected;
    procedure ConnConfig;
    function GetDBConnection: TObject;
  end;

  IDBAccess = interface
    ['{FC3B34E7-55E3-492E-B029-31646DC7522C}']
    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollbackTrans;

    procedure QuerySQL(Cds: TClientDataSet; const SQLStr: String);

    procedure ExecuteSQL(const SQLStr: String);
    procedure ApplyUpdate(const TableName: String; Cds: TClientDataSet);

    //function ExecProcedure(const ProName:String;Param:Array of Variant):Boolean;
  end;

  IDataRecord = interface
    ['{7738C1DF-DE2D-46A6-BA4C-AF1F69DBE856}']
    procedure LoadFromDataSet(DataSet: TDataSet);
    procedure SaveToDataSet(const KeyFields: String; DataSet: TDataSet; FieldsMapping: string = '');
    procedure CloneFrom(DataRecord: IDataRecord);

    function GetFieldValue(const FieldName: String): Variant;
    procedure SetFieldValue(const FieldName: String; Value: Variant);
    property FieldValues[const FieldName: string]: Variant read GetFieldValue write SetFieldValue;

    function FieldValueAsString(const FieldName: String): String;
    function FieldValueAsBoolean(const FieldName: String): Boolean;
    function FieldValueAsCurrency(const FieldName: String): Currency;
    function FieldValueAsDateTime(const FieldName: String): TDateTime;
    function FieldValueAsFloat(const FieldName: String): Double;
    function FieldValueAsInteger(const FieldName: String): Integer;

    function GetFieldCount: Integer;
    function GetFieldName(const Index: Integer): String;
  end;

  IListFiller = interface
    ['{ED67EA0E-3385-4EBA-8094-44E26B81077F}']
    procedure FillList(DataSet: TDataSet; const FieldName: String; aList: TStrings); overload;
    procedure FillList(const TableName, FieldName: string; aList: TStrings); overload;
    procedure ClearList(aList: TStrings);
    procedure DeleteListItem(const Index: Integer; aList: TStrings);

    function GetDataRecord(const Index: Integer; aList: TStrings): IDataRecord;
  end;

implementation

end.
