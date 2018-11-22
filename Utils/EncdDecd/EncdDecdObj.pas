{------------------------------------
  功能说明：实现IEncdDecd接口(加解密接口)
  创建日期：2008/12/21
  作者：WZW
  版权：WZW
-------------------------------------}
unit EncdDecdObj;

interface

uses
  SysUtils,
  Classes,
  Windows,
  EncdDecdIntf,
  SvcInfoIntf;

type
  TEncdDecdObj = class(TInterfacedObject, IEncdDecd, ISvcInfo)
  private
  protected
    {IEncdDecd}
    function Encrypt(const Key, SrcStr: string): string;
    function Decrypt(const Key, SrcStr: string): string;
    function MD5(const Input: string): string;
    procedure Base64EncodeStream(Input, Output: TStream);
    procedure Base64DecodeStream(Input, Output: TStream);
    function Base64EncodeString(const Input: string): string;
    function Base64DecodeString(const Input: string): string;
    {ISvcInfo}
    function GetModuleName: string;
    function GetTitle: string;
    function GetVersion: string;
    function GetComments: string;
  public
  end;

implementation

uses
  SysFactory,
  Base64EncdDecd;

const
  EncryptDefaultKey = 'aAbcDe*1';
  ADVAPI32 = 'advapi32.dll';

function CryptAcquireContext(phProv: PULONG; pszContainer: PAnsiChar;
  pszProvider: PAnsiChar; dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;
  external ADVAPI32 name 'CryptAcquireContextA';

function CryptCreateHash(hProv: ULONG; Algid: ULONG; hKey: ULONG; dwFlags: DWORD;
  phHash: PULONG): BOOL; stdcall; external ADVAPI32 name 'CryptCreateHash';

function CryptHashData(hHash: ULONG; const pbData: PByte; dwDataLen: DWORD;
  dwFlags: DWORD): BOOL; stdcall; external ADVAPI32 name 'CryptHashData';

function CryptGetHashParam(hHash: ULONG; dwParam: DWORD; pbData: PByte;
  pdwDataLen: PDWORD; dwFlags: DWORD): BOOL; stdcall; external ADVAPI32 name
  'CryptGetHashParam';

function CryptDestroyHash(hHash: ULONG): BOOL; stdcall; external ADVAPI32 name
  'CryptDestroyHash';

function CryptReleaseContext(hProv: ULONG; dwFlags: DWORD): BOOL; stdcall;
  external ADVAPI32 name 'CryptReleaseContext';

{ TEncdDecdObj }

function TEncdDecdObj.Encrypt(const Key, SrcStr: string): string;
var
  KeyLen: Integer;
  KeyPos: Integer;
  offset: Integer;
  keyStr, dest: string;
  SrcPos: Integer;
  SrcAsc: Integer;
  Range: Integer;
begin
  if Key = '' then
    keyStr := EncryptDefaultKey
  else
    keyStr := Key;
  KeyLen := Length(keyStr);
  KeyPos := 0;
  Range := $FFFF + 1;
  Randomize;
  offset := Random(Range);
  dest := Format('%1.4x', [offset]);
  for SrcPos := 1 to Length(SrcStr) do
  begin
    SrcAsc := (Ord(SrcStr[SrcPos]) + offset) mod $FFFF;
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    SrcAsc := SrcAsc xor Ord(keyStr[KeyPos]);
    dest := dest + Format('%1.4x', [SrcAsc]);
    offset := SrcAsc;
  end;
  Result := dest;
end;

function TEncdDecdObj.Decrypt(const Key, SrcStr: string): string;
var
  KeyLen: Integer;
  KeyPos: Integer;
  offset: Integer;
  keyStr, dest: string;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
begin
  if SrcStr = '' then
    Exit;
  if Key = '' then
    keyStr := EncryptDefaultKey
  else
    keyStr := Key;
  KeyLen := Length(keyStr);
  KeyPos := 0;
  offset := StrToInt('$' + Copy(SrcStr, 1, 4));
  SrcPos := 5;
  if Copy(SrcStr, SrcPos, 2) <> '' then
  begin
    repeat
      SrcAsc := StrToInt('$' + Copy(SrcStr, SrcPos, 4));
      if KeyPos < KeyLen then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;
      TmpSrcAsc := SrcAsc xor Ord(keyStr[KeyPos]);
      if TmpSrcAsc <= offset then
        TmpSrcAsc := $FFFF + TmpSrcAsc - offset
      else
        TmpSrcAsc := TmpSrcAsc - offset;
      dest := dest + Chr(TmpSrcAsc);
      offset := SrcAsc;
      SrcPos := SrcPos + 4;
    until SrcPos >= Length(SrcStr);
    Result := dest;
  end
  else
    Result := '';
end;

function TEncdDecdObj.MD5(const Input: string): string;
const
  HP_HASHVAL = $0002;
  PROV_RSA_FULL = 1;
  CRYPT_VERIFYCONTEXT = $F0000000;
  CRYPT_MACHINE_KEYSET = $00000020;
  ALG_CLASS_HASH = (4 shl 13);
  ALG_TYPE_ANY = 0;
  ALG_SID_MD5 = 3;
  CALG_MD5 = (ALG_CLASS_HASH or ALG_TYPE_ANY or ALG_SID_MD5);
var
  hCryptProvider: ULONG;
  hHash: ULONG;
  bHash: array[0..$7F] of Byte;
  dwHashLen: DWORD;
  pbContent: PByte;
  I: Integer;
begin
  dwHashLen := 16;
  pbContent := Pointer(PChar(Input));
  Result := '';
  if CryptAcquireContext(@hCryptProvider, nil, nil, PROV_RSA_FULL,
    CRYPT_VERIFYCONTEXT or CRYPT_MACHINE_KEYSET) then
  begin
    if CryptCreateHash(hCryptProvider, CALG_MD5, 0, 0, @hHash) then
    begin
      if CryptHashData(hHash, pbContent, Length(Input), 0) then
      begin
        if CryptGetHashParam(hHash, HP_HASHVAL, @bHash[0], @dwHashLen, 0) then
        begin
          for I := 0 to dwHashLen - 1 do
            Result := Result + Format('%.2x', [bHash[I]]);
        end;
      end;
      CryptDestroyHash(hHash);
    end;
    CryptReleaseContext(hCryptProvider, 0);
  end;
  Result := AnsiLowerCase(Result);
end;

function Create_EncdDecdObj(param: Integer): TObject;
begin
  Result := TEncdDecdObj.Create;
end;

function TEncdDecdObj.GetComments: string;
begin
  Result := '封装常用的加解密函数';
end;

function TEncdDecdObj.GetModuleName: string;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TEncdDecdObj.GetTitle: string;
begin
  Result := '加解密接口(IEncdDecd)';
end;

function TEncdDecdObj.GetVersion: string;
begin
  Result := '20100421.001';
end;

procedure TEncdDecdObj.Base64DecodeStream(Input, Output: TStream);
begin
  DecodeStream(Input, Output);
end;

function TEncdDecdObj.Base64DecodeString(const Input: string): string;
begin
  Result := DecodeString(Input);
end;

procedure TEncdDecdObj.Base64EncodeStream(Input, Output: TStream);
begin
  EncodeStream(Input, Output);
end;

function TEncdDecdObj.Base64EncodeString(const Input: string): string;
begin
  Result := EncodeString(Input);
end;

initialization
  TIntfFactory.Create(IEncdDecd, @Create_EncdDecdObj);

finalization

end.

