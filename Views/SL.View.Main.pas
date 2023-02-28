unit SL.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.TabControl, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Edit, System.Actions, FMX.ActnList, System.ImageList, FMX.ImgList, FMX.TreeView, FMX.Menus, FMX.Objects,
  SL.Client, SL.Model.Profile;

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
    FoldersTreeView: TTreeView;
    AddItemPopupMenu: TPopupMenu;
    FoldersAddFolderMenuItem: TMenuItem;
    FoldersAddRequestMenuItem: TMenuItem;
    FoldersDeleteMenuItem: TMenuItem;
    AddFolderAction: TAction;
    AddRequestAction: TAction;
    DeleteFolderAction: TAction;
    ItemLayout: TLayout;
    ItemEditLayout: TLayout;
    ItemEdit: TEdit;
    AddItemButton: TSpeedButton;
    AddItemImage: TImage;
    procedure SendActionExecute(Sender: TObject);
    procedure SendActionUpdate(Sender: TObject);
    procedure DeleteFolderActionUpdate(Sender: TObject);
    procedure DeleteFolderActionExecute(Sender: TObject);
    procedure AddFolderActionExecute(Sender: TObject);
    procedure AddFolderActionUpdate(Sender: TObject);
    procedure AddItemButtonClick(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure AddRequestActionExecute(Sender: TObject);
    procedure ActionListExecute(Action: TBasicAction; var Handled: Boolean);
  private
    FProfile: TSlumberProfile;
    procedure AddActionKinds;
    procedure AddFolderNode(const AParent: TFmxObject; const AFolder: TSlumberFolder);
    procedure AddFolderNodes;
    procedure AddHeaderView(const AHeaderName: string = ''; const AHeaderValue: string = '');
    procedure AddRequestNode(const AParent: TFmxObject; const ARequest: TSlumberRequest);
    function GetFolderFromNode(const ANode: TTreeViewItem): TSlumberFolder;
    procedure FocusHeaderView;
    procedure HandleResponse(const AResponse: IHTTPResponse);
    function HasInactiveHeaderView: Boolean;
    procedure HeaderViewActiveHandler(Sender: TObject);
    procedure HeaderViewDeleteHandler(Sender: TObject);
    function IsNodeSelected: Boolean;
    procedure NewRequest(const AURL: string = '');
    procedure SendRequest;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainView: TMainView;

implementation

{$R *.fmx}

uses
  DW.JSON, DW.IOUtils.Helpers,
  SL.View.Header, SL.Consts, SL.Resources, SL.Storage.Profile, SL.View.RequestNode, SL.Types;

const
  cNodeDataFormat = '%s|%s';

type
  TFolderNodeKind = (None, Folder, Request);

  TFolderNodeInfo = record
    ID: string;
    Kind: TFolderNodeKind;
  end;

  TTreeViewItemHelper = class helper for TTreeViewItem
  public
    function FolderNodeInfo: TFolderNodeInfo;
  end;

{ TTreeViewItemHelper }

function TTreeViewItemHelper.FolderNodeInfo: TFolderNodeInfo;
var
  LParts: TArray<string>;
begin
  LParts := TagString.Split(['|']);
  if Length(LParts) > 1 then
  begin
    Result.Kind := TFolderNodeKind(StrToIntDef(LParts[0], 0));
    Result.ID := LParts[1];
  end;
end;

{ TMainView }

constructor TMainView.Create(AOwner: TComponent);
begin
  inherited;
  FProfile := TSlumberProfile.Create;
  Resources.LoadButtonImage(cButtonImageListPlusIndex, AddItemImage.Bitmap);
  RequestTabControl.ActiveTab := RequestContentTab;
  AddActionKinds;
  NewRequest;
end;

destructor TMainView.Destroy;
begin
  FProfile.Free;
  inherited;
end;

function TMainView.GetFolderFromNode(const ANode: TTreeViewItem): TSlumberFolder;
var
  LInfo: TFolderNodeInfo;
begin
  Result := nil;
  LInfo := ANode.FolderNodeInfo;
  case LInfo.Kind of
    TFolderNodeKind.Folder:
      FProfile.FindFolder(LInfo.ID, Result);
    TFolderNodeKind.Request:
    begin
      if ANode.ParentItem <> nil then
        Result := GetFolderFromNode(ANode.ParentItem)
      else
        Result := FProfile.RootFolder;
    end;
  end;
end;

procedure TMainView.AddFolderActionExecute(Sender: TObject);
begin
  //
end;

procedure TMainView.AddFolderActionUpdate(Sender: TObject);
begin
  AddFolderAction.Enabled := not IsNodeSelected or (FoldersTreeView.Selected.FolderNodeInfo.Kind = TFolderNodeKind.Folder);
end;

procedure TMainView.AddRequestActionExecute(Sender: TObject);
var
  LFolder: TSlumberFolder;
  LRequest: TSlumberRequest;
begin
  if IsNodeSelected then
    LFolder := GetFolderFromNode(FoldersTreeView.Selected)
  else
    LFolder := FProfile.RootFolder;
  // In theory, this should never be nil
  if LFolder <> nil then
  begin
    LRequest := LFolder.AddRequest;
    // Now clear the edits etc blah blah
    AddRequestNode(FoldersTreeView.Selected, LRequest);
  end;
end;

procedure TMainView.DeleteFolderActionExecute(Sender: TObject);
var
  LInfo: TFolderNodeInfo;
begin
  if FoldersTreeView.Selected <> nil then
  begin
    LInfo := FoldersTreeView.Selected.FolderNodeInfo;
    case LInfo.Kind of
      TFolderNodeKind.Folder:
      begin
        // If any sub-nodes, delete them
      end;
      TFolderNodeKind.Request:
      begin
        // Check if it is the currently loaded request
      end;
    end;
  end;
end;

procedure TMainView.DeleteFolderActionUpdate(Sender: TObject);
const
  cDeleteCaptions: array[TFolderNodeKind] of string = ('', 'Delete Folder', 'Delete Request');
var
  LInfo: TFolderNodeInfo;
begin
  LInfo := Default(TFolderNodeInfo);
  if IsNodeSelected then
    LInfo := FoldersTreeView.Selected.FolderNodeInfo;
  DeleteFolderAction.Text := cDeleteCaptions[LInfo.Kind];
  DeleteFolderAction.Visible := LInfo.Kind in [TFolderNodeKind.Folder, TFolderNodeKind.Request];
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
    ResponseStatusCodeLabel.TextSettings.FontColor := TAlphaColors.Limegreen;
  ResponseStatusTextLabel.Text := AResponse.StatusText;
  ResponseContentMemo.Text := TJsonHelper.Tidy(AResponse.ContentAsString);
end;

procedure TMainView.SendActionUpdate(Sender: TObject);
begin
  // Can send if:
  //   Valid URL ("turn it red" if invalid)
end;

procedure TMainView.ActionListExecute(Action: TBasicAction; var Handled: Boolean);
begin
  AddItemPopupMenu.Tag := 0;
end;

procedure TMainView.AddActionKinds;
begin
  ActionKindComboBox.Items.Clear;
  ActionKindComboBox.Items.AddStrings(cActionKindNames);
  ActionKindComboBox.ItemIndex := ActionKindComboBox.Items.IndexOf(cHTTPMethodGet);
end;

procedure TMainView.AddFolderNode(const AParent: TFmxObject; const AFolder: TSlumberFolder);
var
  LChildFolder: TSlumberFolder;
  LRequest: TSlumberRequest;
  LNode: TTreeViewItem;
  LParent: TFmxObject;
begin
  if not AFolder.IsRoot then
  begin
    LNode := TTreeViewItem.Create(Self);
    LNode.Text := AFolder.Name;
    LNode.TagString := Format(cNodeDataFormat, ['0', AFolder.ID]);
    AParent.AddObject(LNode);
    // Add child folders
    for LChildFolder in FProfile.Folders do
    begin
      if LChildFolder.ParentID.Equals(AFolder.ID) then
        AddFolderNode(LNode, LChildFolder);
    end;
    LParent := LNode;
  end
  else
    LParent := AParent;
  // Add request nodes
  for LRequest in AFolder.Requests do
    AddRequestNode(LParent, LRequest);
end;

procedure TMainView.AddRequestNode(const AParent: TFmxObject; const ARequest: TSlumberRequest);
var
  LNode: TTreeViewItem;
  LView: TRequestNodeView;
begin
  LNode := TTreeViewItem.Create(Self);
  LNode.TagString := Format(cNodeDataFormat, ['1', ARequest.ID]);
  LView := TRequestNodeView.Create(Self);
  LView.HTTPMethod := ARequest.HTTPMethod;
  LView.Description := ARequest.Name;
  AParent.AddObject(LNode);
end;

procedure TMainView.AddFolderNodes;
var
  LFolder: TSlumberFolder;
begin
  for LFolder in FProfile.Folders do
  begin
    if LFolder.IsRoot then
    begin
      AddFolderNode(FoldersTreeView, LFolder);
      Break;
    end;
  end;
  for LFolder in FProfile.Folders do
  begin
    if LFolder.ParentID.IsEmpty then
      AddFolderNode(FoldersTreeView, LFolder);
  end;
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

procedure TMainView.AddItemButtonClick(Sender: TObject);
var
  LPoint: TPointF;
begin
  if AddItemPopupMenu.Tag = 0 then
  begin
    LPoint := ClientToScreen(AddItemButton.AbsoluteRect.TopLeft);
    AddItemPopupMenu.Popup(LPoint.X + 2, LPoint.Y + AddItemButton.Height);
    AddItemPopupMenu.Tag := 1;
  end
  else
    AddItemPopupMenu.Tag := 0;
end;

procedure TMainView.FormFocusChanged(Sender: TObject);
begin
  AddItemPopupMenu.Tag := 0;
end;

procedure TMainView.FocusHeaderView;
var
  LHeaderView: THeaderView;
  I: Integer;
begin
  for I := 0 to RequestHeadersVertScrollBox.Content.ChildrenCount - 1 do
  begin
    LHeaderView := THeaderView(RequestHeadersVertScrollBox.Content.Children[I]);
    if LHeaderView.GainFocus then
      Break;
  end;
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
    AddHeaderView
  else
    FocusHeaderView;
end;

function TMainView.IsNodeSelected: Boolean;
begin
  Result := FoldersTreeView.Selected <> nil;
end;

procedure TMainView.NewRequest(const AURL: string = '');
begin
  ResponseStatusCodeLabel.Text := '';
  ResponseStatusTextLabel.Text := '';
  URLEdit.Text := AURL;
  RequestHeadersVertScrollBox.Content.DeleteChildren;
  AddHeaderView;
end;

end.
