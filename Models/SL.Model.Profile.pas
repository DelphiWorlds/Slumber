unit SL.Model.Profile;

interface

uses
  System.Net.URLClient, System.Generics.Collections;

type
  TSlumberHeaders = TArray<TNameValuePair>;

  TSlumberFolder = class;

  TSlumberRequest = class(TObject)
  private
    FContent: string;
    FFolder: TSlumberFolder;
    FHeaders: TSlumberHeaders;
    FHTTPMethod: string;
    FID: string;
    FName: string;
    FURL: string;
  public
    constructor Create(const AFolder: TSlumberFolder);
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
  private
    FID: string;
    FName: string;
    FParentID: string;
    FRequests: TSlumberRequests;
  protected
    function FindRequest( const AID: string; out ARequest: TSlumberRequest): Boolean;
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
    function FindFolder(const AID: string; out AFolder: TSlumberFolder): Boolean;
    function FindRequest(const AID: string; out ARequest: TSlumberRequest): Boolean;
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

constructor TSlumberRequest.Create(const AFolder: TSlumberFolder);
begin
  inherited Create;
  FFolder := AFolder;
  FID := TSlumberProfile.GetNewID;
end;

{ TSlumberFolder }

constructor TSlumberFolder.Create(const AID: string = '');
begin
  inherited Create;
  if AID.IsEmpty then
    FID := TSlumberProfile.GetNewID
  else
    FID := AID;
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

function TSlumberFolder.IsRoot: Boolean;
begin
  Result := FID.Equals(cRootFolderID);
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
