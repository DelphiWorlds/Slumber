unit SL.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.TabControl, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Edit, System.Actions, FMX.ActnList, System.ImageList, FMX.ImgList, FMX.TreeView,
  SL.Client;

type
  TMainView = class(TForm)
    MainLayout: TLayout;
    NavigatorLayout: TLayout;
    RequestLayout: TLayout;
    ResponseLayout: TLayout;
    RequestSplitter: TSplitter;
    ResponseSplitter: TSplitter;
    RequestTabControl: TTabControl;
    ResponseTabControl: TTabControl;
    RequestContentTab: TTabItem;
    RequestHeadersTab: TTabItem;
    ResponseContentTab: TTabItem;
    RequestContentMemo: TMemo;
    RequestHeadersVertScrollBox: TVertScrollBox;
    NavigatorTopLayout: TLayout;
    RequestResponseLayout: TLayout;
    RequestActionLayout: TLayout;
    SlumberLabel: TLabel;
    ActionKindLayout: TLayout;
    ActionKindComboBox: TComboBox;
    URLLayout: TLayout;
    URLEdit: TEdit;
    SendButton: TButton;
    ResponseContentMemo: TMemo;
    ActionList: TActionList;
    SendAction: TAction;
    ResponseStatusLayout: TLayout;
    ResponseStatusCodeLabel: TLabel;
    ResponseStatusTextLabel: TLabel;
    RequestsTreeView: TTreeView;
    procedure SendActionExecute(Sender: TObject);
    procedure SendActionUpdate(Sender: TObject);
  private
    procedure AddActionKinds;
    procedure AddHeaderView(const AHeaderName: string = ''; const AHeaderValue: string = '');
    procedure HandleResponse(const AResponse: IHTTPResponse);
    function HasInactiveHeaderView: Boolean;
    procedure HeaderViewActiveHandler(Sender: TObject);
    procedure HeaderViewDeleteHandler(Sender: TObject);
    procedure NewRequest(const AURL: string = '');
    procedure SendRequest;
    procedure TestAddAuthorization;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainView: TMainView;

implementation

{$R *.fmx}

uses
  DW.JSON,
  SL.View.Header, SL.Consts, SL.Resources;

const
  cGithubAPISearchRepos = 'https://api.github.com/search/repositories?q=user:DelphiWorlds';

{ TMainView }

constructor TMainView.Create(AOwner: TComponent);
begin
  inherited;
  RequestTabControl.ActiveTab := RequestContentTab;
  AddActionKinds;
  URLEdit.Text := cGithubAPISearchRepos;
  NewRequest;
end;

procedure TMainView.SendActionExecute(Sender: TObject);
begin
  ResponseStatusCodeLabel.Text := '';
  ResponseStatusTextLabel.Text := '';
  ResponseContentMemo.Text := 'Sending..';
  TThread.CreateAnonymousThread(SendRequest).Start;
end;

procedure TMainView.SendRequest;
var
  LClient: THTTPClientEx;
  LResponse: IHTTPResponse;
  I: Integer;
  LHeaderView: THeaderView;
begin
  LClient := THTTPClientEx.Create;
  try
    for I := 0 to RequestHeadersVertScrollBox.Content.ChildrenCount - 1 do
    begin
      LHeaderView := THeaderView(RequestHeadersVertScrollBox.Content.Children[I]);
      if LHeaderView.IsChecked and not LHeaderView.HeaderValue.IsEmpty then
        LClient.Headers[LHeaderView.HeaderName] := LHeaderView.HeaderValue;
    end;
    LResponse := LClient.Send(URLEdit.Text, THTTPMethod.Get, RequestContentMemo.Text);
    TThread.Synchronize(nil, procedure begin HandleResponse(LResponse) end);
  finally
    LClient.Free;
  end;
end;

procedure TMainView.HandleResponse(const AResponse: IHTTPResponse);
begin
  ResponseStatusCodeLabel.Text := AResponse.StatusCode.ToString;
  if (AResponse.StatusCode < 200) or (AResponse.StatusCode > 299) then
    ResponseStatusCodeLabel.TextSettings.FontColor := TAlphaColors.Red
  else
    ResponseStatusCodeLabel.TextSettings.FontColor := TAlphaColors.Green;
  ResponseStatusTextLabel.Text := AResponse.StatusText;
  ResponseContentMemo.Text := TJsonHelper.Tidy(AResponse.ContentAsString);
end;

procedure TMainView.SendActionUpdate(Sender: TObject);
begin
  // Can send if:
  //   Valid URL ("turn it red" if invalid)
end;

procedure TMainView.AddActionKinds;
begin
  ActionKindComboBox.Items.Clear;
  ActionKindComboBox.Items.AddStrings(cActionKindNames);
  ActionKindComboBox.ItemIndex := ActionKindComboBox.Items.IndexOf(cHTTPMethodGet);
end;

procedure TMainView.AddHeaderView(const AHeaderName: string = ''; const AHeaderValue: string = '');
var
  LHeaderView: THeaderView;
  LBottomMost: Single;
  I: Integer;
begin
  LBottomMost := -1;
  for I := 0 to RequestHeadersVertScrollBox.Content.ChildrenCount - 1 do
  begin
    LHeaderView := THeaderView(RequestHeadersVertScrollBox.Content.Children[I]);
    if LHeaderView.IsActive and (LHeaderView.Position.Y > LBottomMost) then
      LBottomMost := LHeaderView.Position.Y;
  end;
  LHeaderView := THeaderView.Create(Self);
  if not AHeaderName.IsEmpty then
    LHeaderView.HeaderName := AHeaderName;
  if not AHeaderValue.IsEmpty then
    LHeaderView.HeaderValue := AHeaderValue;
  LHeaderView.OnActive := HeaderViewActiveHandler;
  LHeaderView.OnDelete := HeaderViewDeleteHandler;
  LHeaderView.Position.Y := LBottomMost + 1;
  LHeaderView.Parent := RequestHeadersVertScrollBox;
end;

function TMainView.HasInactiveHeaderView: Boolean;
var
  I: Integer;
  LHeaderView: THeaderView;
begin
  Result := False;
  for I := 0 to RequestHeadersVertScrollBox.Content.ChildrenCount - 1 do
  begin
    LHeaderView := THeaderView(RequestHeadersVertScrollBox.Content.Children[I]);
    if not LHeaderView.IsActive then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TMainView.HeaderViewActiveHandler(Sender: TObject);
begin
  AddHeaderView;
end;

procedure TMainView.HeaderViewDeleteHandler(Sender: TObject);
begin
  Sender.Free;
  if not HasInactiveHeaderView then
    AddHeaderView;
end;

procedure TMainView.NewRequest(const AURL: string = '');
begin
  // Clear the edits
  ResponseStatusCodeLabel.Text := '';
  ResponseStatusTextLabel.Text := '';
  // URLEdit.Text := AURL;
  // Clear the request headers
  RequestHeadersVertScrollBox.Content.DeleteChildren;
  // AddHeaderView;
  TestAddAuthorization;
end;

procedure TMainView.TestAddAuthorization;
begin
  AddHeaderView('Authorization', 'token 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');
  AddHeaderView;
end;

end.
