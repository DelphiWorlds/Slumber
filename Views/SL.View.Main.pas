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
    DeleteItemAction: TAction;
    ItemLayout: TLayout;
    ItemEditLayout: TLayout;
    ItemEdit: TEdit;
    AddItemButton: TSpeedButton;
    AddItemImage: TImage;
    EditItemAction: TAction;
    FoldersEditMenuItem: TMenuItem;
    procedure SendActionExecute(Sender: TObject);
    procedure SendActionUpdate(Sender: TObject);
    procedure DeleteItemActionUpdate(Sender: TObject);
    procedure DeleteItemActionExecute(Sender: TObject);
    procedure AddFolderActionExecute(Sender: TObject);
    procedure AddFolderActionUpdate(Sender: TObject);
    procedure AddItemButtonClick(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure AddRequestActionExecute(Sender: TObject);
    procedure ActionListExecute(Action: TBasicAction; var Handled: Boolean);
    procedure ItemEditChangeTracking(Sender: TObject);
    procedure AddItemPopupMenuPopup(Sender: TObject);
    procedure AddRequestActionUpdate(Sender: TObject);
    procedure EditItemActionUpdate(Sender: TObject);
    procedure EditItemActionExecute(Sender: TObject);
  private
    FProfile: TSlumberProfile;
    FClickedNode: TTreeViewItem;
    procedure AddActionKinds;
    function AddFolderNode(const AParent: TFmxObject; const AFolder: TSlumberFolder; const AFocusView: Boolean = False): TTreeViewItem;
    procedure AddFolderNodes;
    procedure AddHeaderView(const AHeaderName: string = ''; const AHeaderValue: string = '');
    function AddRequestNode(const AParent: TFmxObject; const ARequest: TSlumberRequest; const AFocusView: Boolean = False): TTreeViewItem;
    function GetFolderFromNode(const ANode: TTreeViewItem): TSlumberFolder;
    procedure FocusHeaderView;
    procedure FolderNodeDescriptionChangeHandler(Sender: TObject);
    procedure HandleResponse(const AResponse: IHTTPResponse);
    function HasClickedNode: Boolean;
    function HasInactiveHeaderView: Boolean;
    procedure HeaderViewActiveHandler(Sender: TObject);
    procedure HeaderViewDeleteHandler(Sender: TObject);
    function IsNodeSelected: Boolean;
    procedure NewRequest(const AURL: string = '');
    procedure RequestNodeDescriptionChangeHandler(Sender: TObject);
    procedure SendRequest;
    procedure UpdateFolderNode(const ANode: TTreeViewItem; const AFolder: TSlumberFolder);
    procedure UpdateRequestNode(const ANode: TTreeViewItem; const ARequest: TSlumberRequest);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainView: TMainView;

implementation

{$R *.fmx}

uses
  FMX.Platform,
  DW.JSON, DW.IOUtils.Helpers,
  SL.View.Header, SL.Consts, SL.Types, SL.Resources, SL.Storage.Profile, SL.View.FolderNode, SL.View.RequestNode;

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
    function GetFolderNodeView: TFolderNodeView;
    function GetRequestNodeView: TRequestNodeView;
  end;

  TActionListHelper = class helper for TActionList
  public
    procedure UpdateActions;
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

function TTreeViewItemHelper.GetFolderNodeView: TFolderNodeView;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildrenCount - 1 do
  begin
    if Children[I] is TFolderNodeView then
    begin
      Result := TFolderNodeView(Children[I]);
      Break;
    end;
  end;
end;

function TTreeViewItemHelper.GetRequestNodeView: TRequestNodeView;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildrenCount - 1 do
  begin
    if Children[I] is TRequestNodeView then
    begin
      Result := TRequestNodeView(Children[I]);
      Break;
    end;
  end;
end;

{ TActionListHelper }

procedure TActionListHelper.UpdateActions;
var
  I: Integer;
begin
  for I := 0 to ActionCount - 1 do
    Actions[I].Update;
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
var
  LFolder, LParentFolder: TSlumberFolder;
  LInfo: TFolderNodeInfo;
  LParentNode: TTreeViewItem;
begin
  LParentNode := nil;
  LParentFolder := nil;
  if HasClickedNode then
  begin
    LParentNode := FClickedNode;
    if not FProfile.FindFolder(FClickedNode.FolderNodeInfo.ID, LParentFolder) then
      // else something is horribly wrong..
  end;
  LFolder := FProfile.AddFolder(LParentFolder);
  LFolder.Name := 'New folder';
  FoldersTreeView.Selected := AddFolderNode(LParentNode, LFolder, True);
end;

procedure TMainView.AddFolderActionUpdate(Sender: TObject);
begin
  AddFolderAction.Enabled := not HasClickedNode or (FClickedNode.FolderNodeInfo.Kind = TFolderNodeKind.Folder);
end;

procedure TMainView.AddRequestActionExecute(Sender: TObject);
var
  LFolder: TSlumberFolder;
  LRequest: TSlumberRequest;
  LParentNode: TTreeViewItem;
begin
  LParentNode := nil;
  if HasClickedNode then
  begin
    LFolder := GetFolderFromNode(FClickedNode);
    LParentNode := FClickedNode;
  end
  else
    LFolder := FProfile.RootFolder;
  // In theory, this should never be nil
  if LFolder <> nil then
  begin
    LRequest := LFolder.AddRequest;
    LRequest.HTTPMethod := 'GET';
    LRequest.Name := 'New request';
    // Now clear the edits etc blah blah
    FoldersTreeView.Selected := AddRequestNode(LParentNode, LRequest, True);
  end;
end;

procedure TMainView.AddRequestActionUpdate(Sender: TObject);
begin
  AddRequestAction.Enabled := not HasClickedNode or (FClickedNode.FolderNodeInfo.Kind = TFolderNodeKind.Folder);
end;

procedure TMainView.DeleteItemActionExecute(Sender: TObject);
var
  LInfo: TFolderNodeInfo;
begin
  if HasClickedNode then
  begin
    LInfo := FClickedNode.FolderNodeInfo;
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

procedure TMainView.DeleteItemActionUpdate(Sender: TObject);
const
  cDeleteCaptions: array[TFolderNodeKind] of string = ('Delete Folder', 'Delete Folder', 'Delete Request');
var
  LInfo: TFolderNodeInfo;
begin
  LInfo := Default(TFolderNodeInfo);
  if (FClickedNode <> nil) then
    LInfo := FClickedNode.FolderNodeInfo;
  DeleteItemAction.Text := cDeleteCaptions[LInfo.Kind];
  DeleteItemAction.Enabled := LInfo.Kind in [TFolderNodeKind.Folder, TFolderNodeKind.Request];
end;

procedure TMainView.EditItemActionExecute(Sender: TObject);
var
  LInfo: TFolderNodeInfo;
  LFolderNodeView: TFolderNodeView;
  LRequestNodeView: TRequestNodeView;
begin
  if HasClickedNode then
  begin
    LInfo := FClickedNode.FolderNodeInfo;
    case LInfo.Kind of
      TFolderNodeKind.Folder:
      begin
        LFolderNodeView := FClickedNode.GetFolderNodeView;
        if LFolderNodeView <> nil then
          LFolderNodeView.EnableEditing(True);
      end;
      TFolderNodeKind.Request:
      begin
        LRequestNodeView := FClickedNode.GetRequestNodeView;
        if LRequestNodeView <> nil then
          LRequestNodeView.EnableEditing(True);
      end;
    end;
  end;
end;

procedure TMainView.EditItemActionUpdate(Sender: TObject);
const
  cEditCaptions: array[TFolderNodeKind] of string = ('Edit Folder', 'Edit Folder', 'Edit Request');
var
  LInfo: TFolderNodeInfo;
begin
  LInfo := Default(TFolderNodeInfo);
  if HasClickedNode then
    LInfo := FClickedNode.FolderNodeInfo;
  EditItemAction.Text := cEditCaptions[LInfo.Kind];
  EditItemAction.Enabled := LInfo.Kind in [TFolderNodeKind.Folder, TFolderNodeKind.Request];
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

procedure TMainView.UpdateFolderNode(const ANode: TTreeViewItem; const AFolder: TSlumberFolder);
begin
  ANode.Text := AFolder.Name;
end;

procedure TMainView.UpdateRequestNode(const ANode: TTreeViewItem; const ARequest: TSlumberRequest);
var
  LView: TRequestNodeView;
  I: Integer;
begin
  for I := 0 to ANode.ChildrenCount - 1 do
  begin
    if ANode.Children[I] is TRequestNodeView then
    begin
      LView := TRequestNodeView(ANode.Children[I]);
      LView.HTTPMethod :=  ARequest.HTTPMethod;
      LView.Description := ARequest.Name;
    end;
  end;
end;

procedure TMainView.FolderNodeDescriptionChangeHandler(Sender: TObject);
var
  // LNode: TTreeViewItem;
  LView: TFolderNodeView;
begin
  LView := TFolderNodeView(Sender);
  //
end;

function TMainView.AddFolderNode(const AParent: TFmxObject; const AFolder: TSlumberFolder; const AFocusView: Boolean = False): TTreeViewItem;
var
  LChildFolder: TSlumberFolder;
  LRequest: TSlumberRequest;
  LNode: TTreeViewItem;
  LParent: TFmxObject;
  LView: TFolderNodeView;
begin
  if not AFolder.IsRoot then
  begin
    LNode := TTreeViewItem.Create(Self);
    // Need to change TextSettings
    LNode.TagString := Format(cNodeDataFormat, ['1', AFolder.ID]);
    if AParent = nil then
      FoldersTreeView.AddObject(LNode)
    else
      AParent.AddObject(LNode);
    LView := TFolderNodeView.Create(Self);
    LView.ID := AFolder.ID;
    LView.Description := AFolder.Name;
    LView.Margins.Left := 12;
    LView.OnDescriptionChange := FolderNodeDescriptionChangeHandler;
    LView.Parent := LNode;
    // Add child folders
    for LChildFolder in FProfile.Folders do
    begin
      if LChildFolder.ParentID.Equals(AFolder.ID) then
        AddFolderNode(LNode, LChildFolder);
    end;
    LParent := LNode;
    if AFocusView then
      LView.EnableEditing(True);
  end
  else
    LParent := AParent;
  // Add request nodes
  for LRequest in AFolder.Requests do
    AddRequestNode(LParent, LRequest);
  Result := TTreeViewItem(LParent);
end;

procedure TMainView.RequestNodeDescriptionChangeHandler(Sender: TObject);
var
  // LNode: TTreeViewItem;
  LView: TRequestNodeView;
begin
  LView := TRequestNodeView(Sender);
  //
end;

function TMainView.AddRequestNode(const AParent: TFmxObject; const ARequest: TSlumberRequest; const AFocusView: Boolean = False): TTreeViewItem;
var
  LView: TRequestNodeView;
begin
  Result := TTreeViewItem.Create(Self);
  Result.TagString := Format(cNodeDataFormat, ['2', ARequest.ID]);
  if AParent = nil then
    FoldersTreeView.AddObject(Result)
  else
    AParent.AddObject(Result);
  LView := TRequestNodeView.Create(Self);
  LView.ID := ARequest.ID;
  LView.HTTPMethod := ARequest.HTTPMethod;
  LView.Description := ARequest.Name;
  LView.OnDescriptionChange := RequestNodeDescriptionChangeHandler;
  LView.Parent := Result;
  if AFocusView then
    LView.EnableEditing(True);
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

procedure TMainView.AddItemPopupMenuPopup(Sender: TObject);
var
  LPoint: TPointF;
  LMouseService: IFMXMouseService;
begin
  FClickedNode := nil;
  if TPlatformServices.Current.SupportsPlatformService(IFMXMouseService, LMouseService) then
  begin
    LPoint := FoldersTreeView.AbsoluteToLocal(ScreenToClient(LMouseService.GetMousePos));
    FClickedNode := FoldersTreeView.ItemByPoint(LPoint.X, LPoint.Y);
    ActionList.UpdateActions;
  end;
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

procedure TMainView.ItemEditChangeTracking(Sender: TObject);
var
  LInfo: TFolderNodeInfo;
  LFolder: TSlumberFolder;
  LRequest: TSlumberRequest;
begin
  if IsNodeSelected then
  begin
    LInfo := FoldersTreeView.Selected.FolderNodeInfo;
    case LInfo.Kind of
      TFolderNodeKind.Folder:
      begin
        if FProfile.FindFolder(LInfo.ID, LFolder) then
        begin
          LFolder.Name := ItemEdit.Text;
          UpdateFolderNode(FoldersTreeView.Selected, LFolder);
        end;
      end;
      TFolderNodeKind.Request:
      begin
        if FProfile.FindRequest(LInfo.ID, LRequest) then
        begin
          LRequest.Name := ItemEdit.Text;
          UpdateRequestNode(FoldersTreeView.Selected, LRequest);
        end;
      end;
    end;
  end;
end;

function TMainView.HasClickedNode: Boolean;
begin
  Result := FClickedNode <> nil;
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
