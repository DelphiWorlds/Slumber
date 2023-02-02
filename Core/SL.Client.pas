unit SL.Client;

interface

uses
  System.JSON,
  System.Net.URLClient, System.Net.HttpClient;

type
  THTTPMethod = (Delete, Get, Patch, Post, Put);
  // TNetHeaders = System.Net.URLClient.TNetHeaders;
  IHTTPResponse = System.Net.HttpClient.IHTTPResponse;

  // THTTPResponseProc = reference to procedure(const AResponse: IHTTPResponse);

  THTTPClientEx = class(TObject)
  private
    FHeaders: TNetHeaders;
    FHost: string;
    FPort: Integer;
    function GetHeader(const AName: string): string;
    function GetURL(const APath: string): string;
    procedure SetHeader(const AName, AValue: string);
  public
    procedure ClearHeaders;
    function Send(const AMethod: THTTPMethod; const APath: string; const ARequest: string = ''): IHTTPResponse; overload;
    function Send(const AURL: string; const AMethod: THTTPMethod; const ARequest: string = ''): IHTTPResponse; overload;
    // procedure SendAsync(const AMethod: THTTPMethod; const APath: string; const AHandler: THTTPResponseProc; const ARequest: string = ''); overload;
    // procedure SendAsync(const AURL: string; const AMethod: THTTPMethod; const AHandler: THTTPResponseProc; const ARequest: string = ''); overload;
    property Headers[const AName: string]: string read GetHeader write SetHeader;
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
  end;

implementation

uses
  System.Classes, System.SysUtils,
  System.NetConsts;

{ THTTPClientEx }

procedure THTTPClientEx.ClearHeaders;
begin
  FHeaders := [];
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

function THTTPClientEx.Send(const AMethod: THTTPMethod; const APath: string; const ARequest: string = ''): IHTTPResponse;
begin
  Result := Send(GetURL(APath), AMethod, ARequest);
end;

function THTTPClientEx.Send(const AURL: string; const AMethod: THTTPMethod; const ARequest: string = ''): IHTTPResponse;
var
  LHTTP: THTTPClient;
  LRequest: TStream;
begin
  // TOSLog.d('Execute: %s', [LURL]);
  LHTTP := THTTPClient.Create;
  try
    LHTTP.ConnectionTimeout := 5000;
    LRequest := TStringStream.Create(ARequest);
    try
      case AMethod of
        THTTPMethod.Delete:
          Result := LHTTP.Delete(AURL, nil, FHeaders);
        THTTPMethod.Get:
          Result := LHTTP.Get(AURL, nil, FHeaders);
        THTTPMethod.Patch:
          Result := LHTTP.Patch(AURL, LRequest, nil, FHeaders);
        THTTPMethod.Post:
          Result := LHTTP.Post(AURL, LRequest, nil, FHeaders);
        THTTPMethod.Put:
          Result := LHTTP.Put(AURL, LRequest, nil, FHeaders);
      end;
    finally
      LRequest.Free;
    end;
  finally
    LHTTP.Free;
  end;
  // TOSLog.d('Response:');
  // TOSLog.d(TJSONHelper.Tidy(LResponse.ContentAsString));
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
