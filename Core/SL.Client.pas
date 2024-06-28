unit SL.Client;

interface

uses
  System.JSON,
  System.Net.URLClient, System.Net.HttpClient,
  SL.Types;

type
  IHTTPResponse = System.Net.HttpClient.IHTTPResponse;

  THTTPClientEx = class(TObject)
  private
    FHeaders: TNetHeaders;
    FHost: string;
    FPort: Integer;
    function FormEncode(const ARequest: string): string;
    function GetHeader(const AName: string): string;
    function GetURL(const APath: string): string;
    function IsFormEncoded: Boolean;
    procedure SetHeader(const AName, AValue: string);
  public
    procedure ClearHeaders;
    function Send(const AMethod: THTTPMethod; const APath: string; const ARequest: string = ''): IHTTPResponse; overload;
    function Send(const AURL: string; const AMethod: THTTPMethod; const ARequest: string = ''): IHTTPResponse; overload;
    property Headers[const AName: string]: string read GetHeader write SetHeader;
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
  end;

implementation

uses
  System.Classes, System.SysUtils,
  System.NetConsts, System.NetEncoding;

{ THTTPClientEx }

procedure THTTPClientEx.ClearHeaders;
begin
  FHeaders := [];
end;

function THTTPClientEx.FormEncode(const ARequest: string): string;
var
  LParams: TStrings;
  I: Integer;
begin
  Result := '';
  LParams := TStringList.Create;
  try
    LParams.Text := ARequest;
    for I := 0 to LParams.Count - 1 do
    begin
      if not Result.IsEmpty then
        Result := Result + '&';
      Result := Result + TNetEncoding.URL.Encode(LParams.Names[I]) + '=' + TNetEncoding.URL.Encode(LParams.ValueFromIndex[I]);
    end;
  finally
    LParams.Free;
  end;
end;

function THTTPClientEx.GetHeader(const AName: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(FHeaders) - 1 do
  begin
    if FHeaders[I].Name.Equals(AName) then
    begin
      Result := FHeaders[I].Value;
      Break;
    end;
  end;
end;

function THTTPClientEx.IsFormEncoded: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FHeaders) - 1 do
  begin
    if FHeaders[I].Value.ToLower.Contains('form-urlencoded') then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function THTTPClientEx.Send(const AMethod: THTTPMethod; const APath: string; const ARequest: string = ''): IHTTPResponse;
begin
  Result := Send(GetURL(APath), AMethod, ARequest);
end;

function THTTPClientEx.Send(const AURL: string; const AMethod: THTTPMethod; const ARequest: string = ''): IHTTPResponse;
var
  LHTTP: THTTPClient;
  LRequest: string;
  LStream: TStream;
begin
  LHTTP := THTTPClient.Create;
  try
    LHTTP.ConnectionTimeout := 5000;
    if IsFormEncoded then
      LRequest := FormEncode(ARequest)
    else
      LRequest := ARequest;
    LStream := TStringStream.Create(LRequest);
    try
      case AMethod of
        THTTPMethod.Delete:
          Result := LHTTP.Delete(AURL, nil, FHeaders);
        THTTPMethod.Get:
          Result := LHTTP.Get(AURL, nil, FHeaders);
        THTTPMethod.Patch:
          Result := LHTTP.Patch(AURL, LStream, nil, FHeaders);
        THTTPMethod.Post:
          Result := LHTTP.Post(AURL, LStream, nil, FHeaders);
        THTTPMethod.Put:
          Result := LHTTP.Put(AURL, LStream, nil, FHeaders);
      end;
    finally
      LStream.Free;
    end;
  finally
    LHTTP.Free;
  end;
end;

procedure THTTPClientEx.SetHeader(const AName, AValue: string);
var
  I, LIndex: Integer;
begin
  LIndex := -1;
  for I := 0 to Length(FHeaders) - 1 do
  begin
    if FHeaders[I].Name.Equals(AName) then
    begin
      LIndex := I;
      Break;
    end;
  end;
  if LIndex = -1 then
  begin
    LIndex := Length(FHeaders);
    SetLength(FHeaders, LIndex + 1);
  end;
  FHeaders[LIndex].Name := AName;
  FHeaders[LIndex].Value := AValue;
end;

function THTTPClientEx.GetURL(const APath: string): string;
var
  LURI: TURI;
begin
  LURI.Scheme := TURI.SCHEME_HTTP;
  LURI.Host := FHost;
  LURI.Port := FPort;
  LURI.Path := APath;
  Result := LURI.ToString;
end;

end.
