unit SL.Storage.Profile;

interface

uses
  System.JSON,
  SL.Model.Profile;

type
  TSlumberProfileHelper = class helper for TSlumberProfile
  private
    function GetFoldersJSONValue: TJSONValue;
    procedure LoadFolders(const AValue: TJSONArray);
  public
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
  end;

implementation

uses
  System.IOUtils, System.Rtti, System.SysUtils,
  DW.JSON;

type
  TSlumberHeaderHelper = record helper for TSlumberHeader
  public
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TSlumberFolderHelper = class helper for TSlumberFolder
  private
    function GetRequestsJSONValue: TJSONValue;
    procedure LoadRequests(const AValue: TJSONArray);
  public
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TSlumberRequestHelper = class helper for TSlumberRequest
  private
    function GetHeadersJSONValue: TJSONValue;
    procedure LoadHeaders(const AValue: TJSONArray);
  public
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

{ TSlumberHeaderHelper }

procedure TSlumberHeaderHelper.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('Index', Index);
  AValue.TryGetValue('IsEnabled', IsEnabled);
  AValue.TryGetValue('Name', Name);
  AValue.TryGetValue('Value', Value);
end;

function TSlumberHeaderHelper.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Index', TJSONNumber.Create(Index));
  LJSON.AddPair('IsEnabled', TJSONBool.Create(IsEnabled));
  LJSON.AddPair('Name', TJSONString.Create(Name));
  LJSON.AddPair('Value', TJSONString.Create(Value));
  Result := LJSON;
end;

{ TSlumberFolderHelper }

function TSlumberFolderHelper.GetRequestsJSONValue: TJSONValue;
var
  LRequest: TSlumberRequest;
  LArray: TJSONArray;
begin
  LArray := TJSONArray.Create;
  for LRequest in Requests do
    LArray.AddElement(LRequest.ToJSONValue);
  Result := LArray;
end;

procedure TSlumberFolderHelper.LoadRequests(const AValue: TJSONArray);
var
  LRequestValue: TJSONValue;
  LRequest: TSlumberRequest;
  LID: string;
begin
  for LRequestValue in AValue do
  begin
    if LRequestValue.TryGetValue('ID', LID) then
    begin
      LRequest := TSlumberRequest.Create(Self, LID);
      LRequest.FromJSONValue(LRequestValue);
      Requests.Add(LRequest);
    end;
  end;
end;

procedure TSlumberFolderHelper.FromJSONValue(const AValue: TJSONValue);
var
  LRequests: TJSONArray;
begin
  AValue.TryGetValue('Name', FName);
  AValue.TryGetValue('ParentID', FParentID);
  if AValue.TryGetValue('Requests', LRequests) then
    LoadRequests(LRequests);
end;

function TSlumberFolderHelper.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('ID', TJSONString.Create(ID));
  LJSON.AddPair('Name', TJSONString.Create(Name));
  LJSON.AddPair('ParentID', TJSONString.Create(ParentID));
  LJSON.AddPair('Requests', GetRequestsJSONValue);
  Result := LJSON;
end;

{ TSlumberRequestHelper }

procedure TSlumberRequestHelper.FromJSONValue(const AValue: TJSONValue);
var
  LHeaders: TJSONArray;
begin
  AValue.TryGetValue('Content', FContent);
  AValue.TryGetValue('HTTPMethod', FHTTPMethod);
  AValue.TryGetValue('Name', FName);
  AValue.TryGetValue('URL', FURL);
  if AValue.TryGetValue('Headers', LHeaders) then
    LoadHeaders(LHeaders);
end;

function TSlumberRequestHelper.GetHeadersJSONValue: TJSONValue;
var
  LHeader: TSlumberHeader;
  LArray: TJSONArray;
begin
  LArray := TJSONArray.Create;
  for LHeader in Headers do
    LArray.AddElement(LHeader.ToJSONValue);
  Result := LArray;
end;

procedure TSlumberRequestHelper.LoadHeaders(const AValue: TJSONArray);
var
  LHeaderValue: TJSONValue;
  LHeader: TSlumberHeader;
begin
  for LHeaderValue in AValue do
  begin
    LHeader.FromJSONValue(LHeaderValue);
    FHeaders := FHeaders + [LHeader];
  end;
end;

function TSlumberRequestHelper.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Content', TJSONString.Create(Content));
  LJSON.AddPair('ID', TJSONString.Create(ID));
  LJSON.AddPair('HTTPMethod', TJSONString.Create(HTTPMethod));
  LJSON.AddPair('Name', TJSONString.Create(Name));
  LJSON.AddPair('URL', TJSONString.Create(URL));
  LJSON.AddPair('Headers', GetHeadersJSONValue);
  Result := LJSON;
end;

{ TSlumberProfileHelper }

function TSlumberProfileHelper.GetFoldersJSONValue: TJSONValue;
var
  LFolder: TSlumberFolder;
  LArray: TJSONArray;
begin
  LArray := TJSONArray.Create;
  for LFolder in Folders do
    LArray.AddElement(LFolder.ToJSONValue);
  Result := LArray;
end;

procedure TSlumberProfileHelper.LoadFolders(const AValue: TJSONArray);
var
  LFolderValue: TJSONValue;
  LFolder: TSlumberFolder;
  LID: string;
begin
  Folders.Clear;
  for LFolderValue in AValue do
  begin
    if LFolderValue.TryGetValue('ID', LID) then
    begin
      LFolder := TSlumberFolder.Create(LID);
      LFolder.FromJSONValue(LFolderValue);
      Folders.Add(LFolder);
    end;
  end;
end;

procedure TSlumberProfileHelper.LoadFromFile(const AFileName: string);
var
  LJSON: TJSONValue;
  LFolders: TJSONArray;
begin
  if TFile.Exists(AFileName) then
  begin
    LJSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(AFileName));
    if LJSON <> nil then
    try
      if LJSON.TryGetValue('Folders', LFolders) then
        LoadFolders(LFolders);
    finally
      LJSON.Free;
    end;
  end;
end;

procedure TSlumberProfileHelper.SaveToFile(const AFileName: string);
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  try
    LJSON.AddPair('Folders', GetFoldersJSONValue);
    TFile.WriteAllText(AFileName, TJsonHelper.Tidy(LJSON));
  finally
    LJSON.Free;
  end;
end;

end.
