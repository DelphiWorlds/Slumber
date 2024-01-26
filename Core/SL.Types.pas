unit SL.Types;

{$SCOPEDENUMS ON}

interface

uses
  System.JSON;

type
  THTTPMethod = (Delete, Get, Patch, Post, Put);

  THeaderKind = (Accept, AcceptCharset, AcceptEncoding, AccessControlRequestHeaders, AccessControlRequestMethod, Authorization, CacheControl,
    ContentType, UserAgent);

  TRequestHeader = record
    Index: Integer;
    Name: string;
    Value: string;
  end;

  TRequestHeaders = TArray<TRequestHeader>;

  TRequest = record
    ID: string;
    Name: string;
    Headers: TRequestHeaders;
    Method: string;
    URL: string;
  end;

  TRequests = TArray<TRequest>;

  TRequestCollection = record
    ID: string;
    Name: string;
    Requests: TRequests;
  end;

  THeaderValueItem = record
    Kind: string;
    Predefined: TArray<string>;
    constructor Create(const AValue: TJSONValue);
  end;

  THeaderValueItems = TArray<THeaderValueItem>;

  THeaderValues = record
    Items: THeaderValueItems;
    function GetKinds: TArray<string>;
    function GetMatches(const AKind, AValue: string): TArray<string>;
    procedure Load;
  end;

implementation

uses
  System.SysUtils, System.IOUtils,
  DW.IOUtils.Helpers;

{ THeaderValueItem }

constructor THeaderValueItem.Create(const AValue: TJSONValue);
var
  LPredefined: TJSONArray;
  LValue: TJSONValue;
begin
  Predefined := [];
  AValue.TryGetValue('Kind', Kind);
  if AValue.TryGetValue('Predefined', LPredefined) then
  begin
    for LValue in LPredefined do
      Predefined := Predefined + [LValue.Value];
  end;
end;

{ THeaderValues }

function THeaderValues.GetKinds: TArray<string>;
var
  LItem: THeaderValueItem;
begin
  Result := [];
  for LItem in Items do
    Result := Result + [LItem.Kind];
end;

function THeaderValues.GetMatches(const AKind, AValue: string): TArray<string>;
var
  LItem: THeaderValueItem;
  LPredefined: string;
begin
  Result := [];
  for LItem in Items do
  begin
    if LItem.Kind.Equals(AKind) then
    begin
      for LPredefined in LItem.Predefined do
      begin
        if LPredefined.StartsWith(AValue, True) then
          Result := Result + [LPredefined];
      end;
      Break;
    end;
  end;
end;

procedure THeaderValues.Load;
var
  LFileName: string;
  LJSON, LValue: TJSONValue;
  LItem: THeaderValueItem;
begin
  Items := [];
  LFileName := TPathHelper.GetAppDocumentsFile('headervalues.json');
  if TFile.Exists(LFileName) then
  begin
    LJSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(LFileName));
    if LJSON <> nil then
    try
      if LJSON is TJSONArray then
      begin
        for LValue in TJSONArray(LJSON) do
          Items := Items + [THeaderValueItem.Create(LValue)];
      end;
    finally
      LJSON.Free;
    end;
  end;
end;

end.
