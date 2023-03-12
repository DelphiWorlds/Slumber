unit SL.Model.Profile;

interface

uses
  System.Net.URLClient, System.Generics.Collections;

type
  TSlumberHeader = record
    Index: Integer;
    IsEnabled: Boolean;
    Name: string;
    Value: string;
  end;

  TSlumberHeaders = TArray<TSlumberHeader>;

  TSlumberFolder = class;

  TSlumberRequest = class(TObject)
  private
    FFolder: TSlumberFolder;
  protected
    FContent: string;
    FHeaders: TSlumberHeaders;
    FHTTPMethod: string;
    FID: string;
    FName: string;
    FURL: string;
  public
    constructor Create(const AFolder: TSlumberFolder; const AID: string = '');
    function AddHeader(const AHeader: TSlumberHeader): Integer;
    function IndexOfHeader(const AIndex: Integer): Integer;
    property Content: string read FContent write FContent;
    property Folder: TSlumberFolder read FFolder;
    property Headers: TSlumberHeaders read FHeaders write FHeaders;
    property ID: string read FID;
    property HTTPMethod: string read FHTTPMethod write FHTTPMethod;
    property Name: string read FName write FName;
    property URL: string read FURL write FURL;
  end;

  TSlumberRequests = TObjectList<TSlumberRequest>;

  TSlumberFolder = class(TObject)
  protected
    FID: string;
    FName: string;
    FParentID: string;
    FRequests: TSlumberRequests;
    function FindRequest( const AID: string; out ARequest: TSlumberRequest): Boolean;
    function IsEmpty: Boolean;
    procedure SetParentID(const AParentID: string);
  public
    constructor Create(const AID: string = '');
    destructor Destroy; override;
    function AddRequest: TSlumberRequest;
    function IsRoot: Boolean;
    property ID: string read FID;
    property Name: string read FName write FName;
    property ParentID: string read FParentID;
    property Requests: TSlumberRequests read FRequests;
  end;

  TSlumberFolders = TObjectList<TSlumberFolder>;

  TSlumberProfile = class(TObject)
  private
    class function GetNewID: string;
  private
    FFolders: TSlumberFolders;
    function GetRootFolder: TSlumberFolder;
  public
    constructor Create;
    destructor Destroy; override;
    function AddFolder(const AParent: TSlumberFolder): TSlumberFolder;
    function FindFolder(const AID: string; out AFolder: TSlumberFolder): Boolean;
    function FindRequest(const AID: string; out ARequest: TSlumberRequest): Boolean;
    function IsEmpty: Boolean;
    property Folders: TSlumberFolders read FFolders;
    property RootFolder: TSlumberFolder read GetRootFolder;
  end;

implementation

uses
  System.SysUtils,
  SL.Types, SL.Consts;

const
  cRootFolderID = 'D50AF03C-55C3-4FE5-83FA-B350EF074215';

{ TSlumberRequest }

constructor TSlumberRequest.Create(const AFolder: TSlumberFolder; const AID: string = '');
begin
  inherited Create;
  FFolder := AFolder;
  if AID.IsEmpty then
    FID := TSlumberProfile.GetNewID
  else
    FID := AID;
end;

function TSlumberRequest.IndexOfHeader(const AIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(FHeaders) - 1 do
  begin
    if FHeaders[I].Index = AIndex then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TSlumberRequest.AddHeader(const AHeader: TSlumberHeader): Integer;
begin
  Result := Length(FHeaders);
  SetLength(FHeaders, Result + 1);
  FHeaders[Result] := AHeader;
  FHeaders[Result].Index := Result;
end;

{ TSlumberFolder }

constructor TSlumberFolder.Create(const AID: string = '');
begin
  inherited Create;
  if AID.IsEmpty then
    FID := TSlumberProfile.GetNewID
  else
    FID := AID;
  if AID.Equals(cRootFolderID) then
    FName := 'Root';
  FRequests := TSlumberRequests.Create
end;

destructor TSlumberFolder.Destroy;
begin
  FRequests.Free;
  inherited;
end;

function TSlumberFolder.FindRequest(const AID: string; out ARequest: TSlumberRequest): Boolean;
var
  LRequest: TSlumberRequest;
begin
  Result := False;
  for LRequest in FRequests do
  begin
    if LRequest.ID.Equals(AID) then
    begin
      ARequest := LRequest;
      Result := True;
      Break;
    end;
  end;
end;

function TSlumberFolder.IsEmpty: Boolean;
begin
  Result := FRequests.Count = 0;
end;

function TSlumberFolder.IsRoot: Boolean;
begin
  Result := FID.Equals(cRootFolderID);
end;

procedure TSlumberFolder.SetParentID(const AParentID: string);
begin
  FParentID := AParentID;
end;

function TSlumberFolder.AddRequest: TSlumberRequest;
begin
  Result := TSlumberRequest.Create(Self);
  FRequests.Add(Result);
end;

{ TSlumberProfile }

constructor TSlumberProfile.Create;
begin
  inherited;
  FFolders := TSlumberFolders.Create;
  FFolders.Add(TSlumberFolder.Create(cRootFolderID));
end;

destructor TSlumberProfile.Destroy;
begin
  FFolders.Free;
  inherited;
end;

class function TSlumberProfile.GetNewID: string;
begin
  Result := TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '');
end;

function TSlumberProfile.AddFolder(const AParent: TSlumberFolder): TSlumberFolder;
begin
  Result := TSlumberFolder.Create;
  FFolders.Add(Result);
  if AParent <> nil then
    Result.SetParentID(AParent.ID);
end;

function TSlumberProfile.GetRootFolder: TSlumberFolder;
var
  LFolder: TSlumberFolder;
begin
  Result := nil;
  for LFolder in FFolders do
  begin
    if LFolder.IsRoot then
    begin
      Result := LFolder;
      Break;
    end;
  end;
end;

function TSlumberProfile.IsEmpty: Boolean;
var
  LRoot: TSlumberFolder;
begin
  LRoot := GetRootFolder;
  Result := (LRoot = nil) or (LRoot.IsEmpty and (FFolders.Count = 1));
end;

function TSlumberProfile.FindFolder(const AID: string; out AFolder: TSlumberFolder): Boolean;
var
  LFolder: TSlumberFolder;
begin
  Result := False;
  for LFolder in FFolders do
  begin
    if LFolder.ID.Equals(AID) then
    begin
      AFolder := LFolder;
      Result := True;
      Break;
    end;
  end;
end;

function TSlumberProfile.FindRequest(const AID: string; out ARequest: TSlumberRequest): Boolean;
var
  LFolder: TSlumberFolder;
begin
  Result := False;
  for LFolder in FFolders do
  begin
    if LFolder.FindRequest(AID, ARequest) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

end.
