unit SL.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.TabControl, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Edit, System.Actions, FMX.ActnList, System.ImageList, FMX.ImgList, FMX.TreeView, FMX.Menus, FMX.Objects,
  SL.Client, SL.Model.Profile, SL.Config;

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
    SaveProfileAction: TAction;
    FoldersMenuSep1: TMenuItem;
    SaveProfileMenuItem: TMenuItem;
    LoadProfileAction: TAction;
    LoadProfileMenuItem: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    ResponseWordWrapCheckBox: TCheckBox;
    ResponseHeadersTab: TTabItem;
    ResponseHeadersMemo: TMemo;
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
    procedure ActionKindComboBoxClosePopup(Sender: TObject);
    procedure SaveProfileActionUpdate(Sender: TObject);
    procedure SaveProfileActionExecute(Sender: TObject);
    procedure LoadProfileActionExecute(Sender: TObject);
    procedure FoldersTreeViewChange(Sender: TObject);
    procedure URLEditChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure RequestContentMemoChange(Sender: TObject);
    procedure ResponseWordWrapCheckBoxChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RequestLayoutResized(Sender: TObject);
    procedure NavigatorLayoutResized(Sender: TObject);
    procedure URLEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    FClickedNode: TTreeViewItem;
    FConfig: TSlumberConfig;
    FDefaultHeader: TSlumberHeader;
    FIgnoreTreeViewChange: Boolean;
    FIsLoading: Boolean;
    FProfile: TSlumberProfile;
    procedure AddActionKinds;
    function AddFolderNode(const AParent: TFmxObject; const AFolder: TSlumberFolder; const AFocusView: Boolean = False): TTreeViewItem;
    procedure AddFolderNodes;
    procedure AddHeaderView(const AHeader: TSlumberHeader);
    function AddRequestNode(const AParent: TFmxObject; const ARequest: TSlumberRequest; const AFocusView: Boolean = False): TTreeViewItem;
    procedure CheckRequestSelected;
    function GetFolderFromNode(const ANode: TTreeViewItem): TSlumberFolder;
    function FindActiveSlumberRequest(out ARequest: TSlumberRequest): Boolean;
    procedure FocusHeaderView;
    procedure FolderNodeDescriptionChangeHandler(Sender: TObject);
    procedure HandleResponse(const AResponse: IHTTPResponse);
    function HasClickedNode: Boolean;
    function HasInactiveHeaderView: Boolean;
    procedure HeaderViewActiveHandler(Sender: TObject);
    procedure HeaderViewDeleteHandler(Sender: TObject);
    procedure HeaderViewChangedHandler(Sender: TObject);
    function IsNodeSelected: Boolean;
    procedure LoadFromProfile;
    procedure NewRequest(const AURL: string = '');
    procedure RequestNodeDescriptionChangeHandler(Sender: TObject);
    procedure SaveConfig;
    procedure SendRequest;
    procedure UpdateDimensions;
    procedure UpdateFolderNode(const ANode: TTreeViewItem; const AFolder: TSlumberFolder);
    procedure UpdateRequestNode(const ANode: TTreeViewItem; const ARequest: TSlumberRequest);
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainView: TMainView;

implementation

{$R *.fmx}

uses
  System.IOUtils, System.JSON, System.Net.URLClient,
  FMX.Platform,
  DW.JSON, DW.IOUtils.Helpers,
  SL.View.Header, SL.Consts, SL.Types, SL.Resources, SL.Storage.Profile, SL.View.FolderNode, SL.View.RequestNode;

const
  cNodeDataFormat = '%s|%s';

type
  TTreeNodeKind = (None, Folder, Request);

  TTreeNodeInfo = record
    ID: string;
    Kind: TTreeNodeKind;
  end;

  TTreeViewItemHelper = class helper for TTreeViewItem
  public
    function TreeNodeInfo: TTreeNodeInfo;
    function GetFolderNodeView: TFolderNodeView;
    function GetFirstRequestNode: TTreeViewItem;
    function GetRequestNodeView: TRequestNodeView;
  end;

  TActionListHelper = class helper for TActionList
  public
    procedure UpdateActions;
  end;

function GetHTTPMethod(const AValue: string): THTTPMethod;
begin
  Result := THTTPMethod.Get;
  if AValue.Equals('POST') then
    Result := THTTPMethod.Post
  else if AValue.Equals('PUT') then
    Result := THTTPMethod.Put
  else if AValue.Equals('PATCH') then
    Result := THTTPMethod.Patch
  else if AValue.Equals('DELETE') then
    Result := THTTPMethod.Delete;
end;

{ TTreeViewItemHelper }

function TTreeViewItemHelper.TreeNodeInfo: TTreeNodeInfo;
var
  LParts: TArray<string>;
begin
  LParts := TagString.Split(['|']);
  if Length(LParts) > 1 then
  begin
    Result.Kind := TTreeNodeKind(StrToIntDef(LParts[0], 0));
    Result.ID := LParts[1];
  end;
end;

function TTreeViewItemHelper.GetFirstRequestNode: TTreeViewItem;
var
  I: Integer;
  LNode: TTreeViewItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    LNode := Items[I];
    if LNode.TreeNodeInfo.Kind = TTreeNodeKind.Request then
    begin
      Result := LNode;
      Break;
    end;
  end;
  if Result = nil then
  begin
    for I := 0 to Count - 1 do
    begin
      if Items[I].TreeNodeInfo.Kind = TTreeNodeKind.Folder then
      begin
        LNode := Items[I].GetFirstRequestNode;
        if LNode <> nil then
        begin
          Result := LNode;
          Break;
        end;
      end;
    end;
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
  FIsLoading := True;
  inherited;
  Resources := TResources.Create(Self);
  StyleBook := Resources.StyleBook;
  FConfig.Load;
  UpdateDimensions;
  FProfile := TSlumberProfile.Create;
  Resources.LoadButtonImage(cButtonImageListPlusIndex, AddItemImage.Bitmap);
  RequestTabControl.ActiveTab := RequestContentTab;
  ResponseTabControl.ActiveTab := ResponseContentTab;
  AddActionKinds;
  FDefaultHeader := Default(TSlumberHeader);
  FDefaultHeader.Index := -1;
  {$IF Defined(MACOS)}
  ResponseContentMemo.TextSettings.Font.Family := 'Monaco';
  ResponseHeadersMemo.TextSettings.Font.Family := ResponseContentMemo.TextSettings.Font.Family;
  {$ENDIF}
  NewRequest;
end;

destructor TMainView.Destroy;
begin
  FProfile.Free;
  inherited;
end;

procedure TMainView.UpdateDimensions;
begin
  if FIsLoading then
  begin
    ResponseWordWrapCheckBox.IsChecked := FConfig.ResponseContentMemoWordWrap;
    NavigatorLayout.Width := FConfig.NavigatorLayoutWidth;
    RequestLayout.Width := FConfig.RequestLayoutWidth;
    if not FConfig.MainViewDimensions.IsZero then
    begin
      Left := FConfig.MainViewDimensions.Left;
      Top := FConfig.MainViewDimensions.Top;
      Width := FConfig.MainViewDimensions.Width;
      Height := FConfig.MainViewDimensions.Height;
    end;
  end;
  FIsLoading := False;
end;

procedure TMainView.DoShow;
begin
  // UpdateDimensions;
  inherited;
end;

function TMainView.GetFolderFromNode(const ANode: TTreeViewItem): TSlumberFolder;
var
  LInfo: TTreeNodeInfo;
begin
  Result := nil;
  LInfo := ANode.TreeNodeInfo;
  case LInfo.Kind of
    TTreeNodeKind.Folder:
      FProfile.FindFolder(LInfo.ID, Result);
    TTreeNodeKind.Request:
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
  LParentNode: TTreeViewItem;
begin
  LParentNode := nil;
  LParentFolder := nil;
  if HasClickedNode then
  begin
    LParentNode := FClickedNode;
    if not FProfile.FindFolder(FClickedNode.TreeNodeInfo.ID, LParentFolder) then
      // else something is horribly wrong..
  end;
  LFolder := FProfile.AddFolder(LParentFolder);
  LFolder.Name := 'New folder';
  FoldersTreeView.Selected := AddFolderNode(LParentNode, LFolder, True);
end;

procedure TMainView.AddFolderActionUpdate(Sender: TObject);
begin
  AddFolderAction.Enabled := not HasClickedNode or (FClickedNode.TreeNodeInfo.Kind = TTreeNodeKind.Folder);
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
  AddRequestAction.Enabled := not HasClickedNode or (FClickedNode.TreeNodeInfo.Kind = TTreeNodeKind.Folder);
end;

procedure TMainView.DeleteItemActionExecute(Sender: TObject);
var
  LInfo: TTreeNodeInfo;
begin
  if HasClickedNode then
  begin
    LInfo := FClickedNode.TreeNodeInfo;
    case LInfo.Kind of
      TTreeNodeKind.Folder:
      begin
        // If any sub-nodes, delete them
      end;
      TTreeNodeKind.Request:
      begin
        // Check if it is the currently loaded request
      end;
    end;
  end;
end;

procedure TMainView.DeleteItemActionUpdate(Sender: TObject);
const
  cDeleteCaptions: array[TTreeNodeKind] of string = ('Delete Folder', 'Delete Folder', 'Delete Request');
var
  LInfo: TTreeNodeInfo;
begin
  LInfo := Default(TTreeNodeInfo);
  if (FClickedNode <> nil) then
    LInfo := FClickedNode.TreeNodeInfo;
  DeleteItemAction.Text := cDeleteCaptions[LInfo.Kind];
  DeleteItemAction.Enabled := LInfo.Kind in [TTreeNodeKind.Folder, TTreeNodeKind.Request];
end;

procedure TMainView.EditItemActionExecute(Sender: TObject);
var
  LInfo: TTreeNodeInfo;
  LFolderNodeView: TFolderNodeView;
  LRequestNodeView: TRequestNodeView;
begin
  if HasClickedNode then
  begin
    LInfo := FClickedNode.TreeNodeInfo;
    case LInfo.Kind of
      TTreeNodeKind.Folder:
      begin
        LFolderNodeView := FClickedNode.GetFolderNodeView;
        if LFolderNodeView <> nil then
          LFolderNodeView.EnableEditing(True);
      end;
      TTreeNodeKind.Request:
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
  cEditCaptions: array[TTreeNodeKind] of string = ('Edit Folder', 'Edit Folder', 'Edit Request');
var
  LInfo: TTreeNodeInfo;
begin
  LInfo := Default(TTreeNodeInfo);
  if HasClickedNode then
    LInfo := FClickedNode.TreeNodeInfo;
  EditItemAction.Text := cEditCaptions[LInfo.Kind];
  EditItemAction.Enabled := LInfo.Kind in [TTreeNodeKind.Folder, TTreeNodeKind.Request];
end;

procedure TMainView.SaveProfileActionUpdate(Sender: TObject);
begin
  SaveProfileAction.Enabled := not FProfile.IsEmpty;
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
  LMethod: string;
begin
  LClient := THTTPClientEx.Create;
  try
    for I := 0 to RequestHeadersVertScrollBox.Content.ChildrenCount - 1 do
    begin
      LHeaderView := THeaderView(RequestHeadersVertScrollBox.Content.Children[I]);
      if LHeaderView.IsHeaderEnabled and not LHeaderView.HeaderValue.IsEmpty then
        LClient.Headers[LHeaderView.HeaderName] := LHeaderView.HeaderValue;
    end;
    LMethod := ActionKindComboBox.Items[ActionKindComboBox.ItemIndex];
    LResponse := LClient.Send(URLEdit.Text, GetHTTPMethod(LMethod), RequestContentMemo.Text);
    TThread.Synchronize(nil, procedure begin HandleResponse(LResponse) end);
  finally
    LClient.Free;
  end;
end;

procedure TMainView.HandleResponse(const AResponse: IHTTPResponse);
var
  LContent: string;
  LHeader: TNameValuePair;
begin
  ResponseStatusCodeLabel.Text := AResponse.StatusCode.ToString;
  if (AResponse.StatusCode < 200) or (AResponse.StatusCode > 299) then
    ResponseStatusCodeLabel.TextSettings.FontColor := TAlphaColors.Red
  else
    ResponseStatusCodeLabel.TextSettings.FontColor := TAlphaColors.Limegreen;
  ResponseStatusTextLabel.Text := AResponse.StatusText;
  LContent := AResponse.ContentAsString;
  if TJsonHelper.IsJson(LContent) then
    ResponseContentMemo.Text := TJsonHelper.Tidy(LContent)
  else
    ResponseContentMemo.Text := LContent;
  ResponseHeadersMemo.Lines.Clear;
  for LHeader in AResponse.Headers do
    ResponseHeadersMemo.Lines.Add(Format('%s: %s', [LHeader.Name, LHeader.Value]));
end;

procedure TMainView.SendActionUpdate(Sender: TObject);
begin
  // Can send if:
  //   Valid URL ("turn it red" if invalid)
  SendAction.Enabled := not URLEdit.Text.Trim.IsEmpty;
end;

procedure TMainView.ActionKindComboBoxClosePopup(Sender: TObject);
var
  LRequest: TSlumberRequest;
begin
  if FindActiveSlumberRequest(LRequest) then
  begin
    LRequest.HTTPMethod := ActionKindComboBox.Items[ActionKindComboBox.ItemIndex];
    UpdateRequestNode(FoldersTreeView.Selected, LRequest);
  end;
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

procedure TMainView.URLEditChange(Sender: TObject);
var
  LRequest: TSlumberRequest;
begin
  if FindActiveSlumberRequest(LRequest) then
    LRequest.URL := URLEdit.Text;
end;

procedure TMainView.URLEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Key := 0;
    KeyChar := #0;
    SendAction.Execute;
  end;
end;

procedure TMainView.FolderNodeDescriptionChangeHandler(Sender: TObject);
var
  LView: TFolderNodeView;
  LFolder: TSlumberFolder;
begin
  LView := TFolderNodeView(Sender);
  if FProfile.FindFolder(LView.ID, LFolder) then
    LFolder.Name := LView.Description;
end;

procedure TMainView.FoldersTreeViewChange(Sender: TObject);
begin
  if not FIgnoreTreeViewChange then
    CheckRequestSelected;
end;

procedure TMainView.CheckRequestSelected;
var
  LRequest: TSlumberRequest;
  LIndex: Integer;
  LHeader: TSlumberHeader;
begin
  if FindActiveSlumberRequest(LRequest) then
  begin
    LIndex := ActionKindComboBox.Items.IndexOf(LRequest.HTTPMethod);
    if LIndex > -1 then
      ActionKindComboBox.ItemIndex := LIndex;
    URLEdit.Text := LRequest.URL;
    RequestContentMemo.Text := LRequest.Content;
    RequestHeadersVertScrollBox.Content.DeleteChildren;
    for LHeader in LRequest.Headers do
      AddHeaderView(LHeader);
    if RequestContentMemo.Text.IsEmpty and (Length(LRequest.Headers) > 0) then
      RequestTabControl.ActiveTab := RequestHeadersTab
    else
      RequestTabControl.ActiveTab := RequestContentTab;
    AddHeaderView(FDefaultHeader);
  end;
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

procedure TMainView.RequestContentMemoChange(Sender: TObject);
var
  LRequest: TSlumberRequest;
begin
  if FindActiveSlumberRequest(LRequest) then
    LRequest.Content := RequestContentMemo.Text;
end;

procedure TMainView.RequestLayoutResized(Sender: TObject);
begin
  SaveConfig;
end;

procedure TMainView.RequestNodeDescriptionChangeHandler(Sender: TObject);
var
  LView: TRequestNodeView;
  LRequest: TSlumberRequest;
begin
  LView := TRequestNodeView(Sender);
  if FProfile.FindRequest(LView.ID, LRequest) then
    LRequest.Name := LView.Description;
end;

procedure TMainView.ResponseWordWrapCheckBoxChange(Sender: TObject);
begin
  ResponseContentMemo.TextSettings.WordWrap := ResponseWordWrapCheckBox.IsChecked;
  SaveConfig;
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
  LView.Margins.Left := 12;
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
    if not LFolder.IsRoot and LFolder.ParentID.IsEmpty then
      AddFolderNode(FoldersTreeView, LFolder);
  end;
end;

procedure TMainView.AddHeaderView(const AHeader: TSlumberHeader);
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
  if not AHeader.Name.IsEmpty then
    LHeaderView.HeaderName := AHeader.Name;
  if not AHeader.Value.IsEmpty then
    LHeaderView.HeaderValue := AHeader.Value;
  LHeaderView.HeaderIndex := AHeader.Index;
  LHeaderView.IsHeaderEnabled := AHeader.IsEnabled;
  LHeaderView.OnActive := HeaderViewActiveHandler;
  LHeaderView.OnDelete := HeaderViewDeleteHandler;
  LHeaderView.OnChanged := HeaderViewChangedHandler;
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

procedure TMainView.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = vkS) then
  begin
    if not string(OpenDialog.FileName).IsEmpty and TFile.Exists(OpenDialog.FileName) then
      FProfile.SaveToFile(OpenDialog.FileName)
    else
      SaveProfileAction.Execute;
  end;
end;

procedure TMainView.FormResize(Sender: TObject);
begin
  SaveConfig;
end;

function TMainView.FindActiveSlumberRequest(out ARequest: TSlumberRequest): Boolean;
var
  LInfo: TTreeNodeInfo;
begin
  Result := False;
  if IsNodeSelected then
  begin
    LInfo := FoldersTreeView.Selected.TreeNodeInfo;
    if LInfo.Kind = TTreeNodeKind.Request then
      Result := FProfile.FindRequest(LInfo.ID, ARequest);
  end;
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
  LInfo: TTreeNodeInfo;
  LFolder: TSlumberFolder;
  LRequest: TSlumberRequest;
begin
  if IsNodeSelected then
  begin
    LInfo := FoldersTreeView.Selected.TreeNodeInfo;
    case LInfo.Kind of
      TTreeNodeKind.Folder:
      begin
        if FProfile.FindFolder(LInfo.ID, LFolder) then
        begin
          LFolder.Name := ItemEdit.Text;
          UpdateFolderNode(FoldersTreeView.Selected, LFolder);
        end;
      end;
      TTreeNodeKind.Request:
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

procedure TMainView.LoadProfileActionExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    FProfile.LoadFromFile(OpenDialog.FileName);
    LoadFromProfile;
  end;
end;

procedure TMainView.LoadFromProfile;
var
  I: Integer;
  LNode, LRequestNode: TTreeViewItem;
begin
  FIgnoreTreeViewChange := True;
  try
    FoldersTreeView.Clear;
    AddFolderNodes;
  finally
    FIgnoreTreeViewChange := False;
  end;
  LRequestNode := nil;
  for I := 0 to FoldersTreeView.Count - 1 do
  begin
    LNode := FoldersTreeView.Items[I];
    if LNode.TreeNodeInfo.Kind = TTreeNodeKind.Folder then
    begin
      LRequestNode := LNode.GetFirstRequestNode;
      if LRequestNode <> nil then
      begin
        LNode.Expand;
        FoldersTreeView.Selected := LRequestNode;
        Break;
      end;
    end;
  end;
  if LRequestNode = nil then
  begin
    for I := 0 to FoldersTreeView.Count - 1 do
    begin
      LNode := FoldersTreeView.Items[I];
      if (LNode.Level = 1) and (LNode.TreeNodeInfo.Kind = TTreeNodeKind.Request) then
      begin
        FoldersTreeView.Selected := LNode;
        Break;
      end;
    end;
  end;
end;

procedure TMainView.SaveConfig;
begin
  if not FIsLoading then
  begin
    FConfig.MainViewDimensions.Left := Left;
    FConfig.MainViewDimensions.Top := Top;
    FConfig.MainViewDimensions.Width := Width;
    FConfig.MainViewDimensions.Height := Height;
    FConfig.NavigatorLayoutWidth := NavigatorLayout.Width;
    FConfig.RequestLayoutWidth := RequestLayout.Width;
    FConfig.ResponseContentMemoWordWrap := ResponseWordWrapCheckBox.IsChecked;
    FConfig.Save;
  end;
end;

procedure TMainView.SaveProfileActionExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
    FProfile.SaveToFile(SaveDialog.FileName);
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
var
  LView: THeaderView;
  LRequest: TSlumberRequest;
  LHeader: TSlumberHeader;
begin
  LView := THeaderView(Sender);
  if FindActiveSlumberRequest(LRequest) then
  begin
    LHeader.IsEnabled := LView.IsHeaderEnabled;
    LHeader.Name := LView.HeaderName;
    LHeader.Value := LView.HeaderValue;
    LView.HeaderIndex := LRequest.AddHeader(LHeader);
  end;
  AddHeaderView(FDefaultHeader);
end;

procedure TMainView.HeaderViewChangedHandler(Sender: TObject);
var
  LRequest: TSlumberRequest;
  LView: THeaderView;
  LHeaderIndex: Integer;
begin
  if FindActiveSlumberRequest(LRequest) then
  begin
    LView := THeaderView(Sender);
    LHeaderIndex := LRequest.IndexOfHeader(LView.HeaderIndex);
    if LHeaderIndex > -1 then
    begin
      LRequest.Headers[LHeaderIndex].IsEnabled := LView.IsHeaderEnabled;
      LRequest.Headers[LHeaderIndex].Name := LView.HeaderName;
      LRequest.Headers[LHeaderIndex].Value := LView.HeaderValue;
    end;
  end;
end;

procedure TMainView.HeaderViewDeleteHandler(Sender: TObject);
var
  LRequest: TSlumberRequest;
  LView: THeaderView;
  LHeaderIndex: Integer;
begin
  if FindActiveSlumberRequest(LRequest) then
  begin
    LView := THeaderView(Sender);
    LHeaderIndex := LRequest.IndexOfHeader(LView.HeaderIndex);
    if LHeaderIndex > -1 then
      LRequest.DeleteHeader(LHeaderIndex);
  end;
  Sender.Free;
  if not HasInactiveHeaderView then
    AddHeaderView(FDefaultHeader)
  else
    FocusHeaderView;
end;

function TMainView.IsNodeSelected: Boolean;
begin
  Result := FoldersTreeView.Selected <> nil;
end;

procedure TMainView.NavigatorLayoutResized(Sender: TObject);
begin
  SaveConfig;
end;

procedure TMainView.NewRequest(const AURL: string = '');
begin
  ResponseStatusCodeLabel.Text := '';
  ResponseStatusTextLabel.Text := '';
  URLEdit.Text := AURL;
  RequestHeadersVertScrollBox.Content.DeleteChildren;
  AddHeaderView(FDefaultHeader);
end;

end.
