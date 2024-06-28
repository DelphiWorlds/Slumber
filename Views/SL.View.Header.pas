unit SL.View.Header;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, FMX.Layouts,
  FMX.Objects, FMX.ComboEdit;

type
  THeaderView = class(TFrame)
    ActionButton: TSpeedButton;
    HeaderValueEdit: TEdit;
    DeleteButton: TSpeedButton;
    EnabledCheckBox: TCheckBox;
    HeaderKindLayout: TLayout;
    HeaderValueLayout: TLayout;
    NewHeaderLabel: TLabel;
    ActionImage: TImage;
    DeleteImage: TImage;
    HeaderKindComboEdit: TComboEdit;
    ClearHeaderValueEditButton: TClearEditButton;
    SuggestionListBox: TListBox;
    SuggestionTimer: TTimer;
    procedure HeaderValueEditChangeTracking(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ActionButtonClick(Sender: TObject);
    procedure HeaderKindComboEditClosePopup(Sender: TObject);
    procedure HeaderKindComboEditPopup(Sender: TObject);
    procedure HeaderKindComboEditChangeTracking(Sender: TObject);
    procedure HeaderKindComboEditExit(Sender: TObject);
    procedure ClearHeaderValueEditButtonClick(Sender: TObject);
    procedure SuggestionTimerTimer(Sender: TObject);
    procedure HeaderValueEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure SuggestionListBoxClick(Sender: TObject);
    procedure SuggestionListBoxKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  private
    FIsActive: Boolean;
    FHeaderIndex: Integer;
    FHeaderKindChanged: Boolean;
    FHeaderKindIndex: Integer;
    FOnActive: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnDelete: TNotifyEvent;
    procedure DoActive;
    procedure DoChanged;
    procedure DoDelete;
    procedure FilterSuggestions;
    procedure FocusHeaderValueEdit;
    function GetHeaderIndex: Integer;
    function GetHeaderName: string;
    function GetHeaderValue: string;
    function GetIsHeaderEnabled: Boolean;
    function SelectSuggestion: Boolean;
    procedure SetIsActive(const Value: Boolean);
    procedure SetHeaderIndex(const Value: Integer);
    procedure SetHeaderName(const Value: string);
    procedure SetHeaderValue(const Value: string);
    procedure SetIsHeaderEnabled(const Value: Boolean);
    procedure ShowSuggestions;
  public
    constructor Create(AOwner: TComponent); override;
    procedure FormMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FormMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    function GainFocus: Boolean;
    property HeaderIndex: Integer read GetHeaderIndex write SetHeaderIndex;
    property HeaderName: string read GetHeaderName write SetHeaderName;
    property HeaderValue: string read GetHeaderValue write SetHeaderValue;
    property IsActive: Boolean read FIsActive;
    property IsHeaderEnabled: Boolean read GetIsHeaderEnabled write SetIsHeaderEnabled;
    property OnActive: TNotifyEvent read FOnActive write FOnActive;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
  end;

implementation

{$R *.fmx}

uses
  System.StrUtils,
  SL.Consts, SL.Resources, SL.Core;

type
  TOpenControl = class(TControl);

{ THeaderView }

constructor THeaderView.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
  HeaderValues.Load;
  HeaderKindComboEdit.Items.AddStrings(HeaderValues.GetKinds);
  HeaderKindComboEdit.ItemIndex := 0;
  Resources.LoadButtonImage(cButtonImageDeleteIndex, DeleteImage.Bitmap);
  SetIsActive(False);
end;

function THeaderView.GetIsHeaderEnabled: Boolean;
begin
  Result := EnabledCheckBox.IsChecked;
end;

procedure THeaderView.ClearHeaderValueEditButtonClick(Sender: TObject);
begin
  HeaderValueEdit.Text := '';
  SuggestionTimer.Enabled := False;
  SuggestionListBox.Visible := False;
end;

procedure THeaderView.DeleteButtonClick(Sender: TObject);
begin
  // ForceQueue is used here to allow the OnClick handler to complete before calling DoDeleted
  // This is so that the mouse capture is released from the button
  TThread.ForceQueue(nil, DoDelete);
end;

procedure THeaderView.DoActive;
begin
  if Assigned(FOnActive) then
    FOnActive(Self);
end;

procedure THeaderView.DoChanged;
begin
  FHeaderKindChanged := False;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure THeaderView.DoDelete;
begin
  if Assigned(FOnDelete) then
    FOnDelete(Self);
end;

procedure THeaderView.FocusHeaderValueEdit;
begin
  HeaderValueEdit.SetFocus;
  HeaderValueEdit.SelLength := 0;
  HeaderValueEdit.SelStart := 0;
end;

procedure THeaderView.FormMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LPoint: TPointF;
begin
  if SuggestionListBox.Visible then
  begin
    LPoint := SuggestionListBox.AbsoluteToLocal(PointF(X, Y));
    if SuggestionListBox.BoundsRect.Contains(LPoint) then
      TOpenControl(SuggestionListBox).MouseDown(Button, Shift, LPoint.X, LPoint.Y);
  end;
end;

procedure THeaderView.FormMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LPoint: TPointF;
begin
  if SuggestionListBox.Visible then
  begin
    LPoint := SuggestionListBox.AbsoluteToLocal(PointF(X, Y));
    if SuggestionListBox.BoundsRect.Contains(LPoint) then
      TOpenControl(SuggestionListBox).MouseUp(Button, Shift, LPoint.X, LPoint.Y);
  end;
end;

function THeaderView.GainFocus: Boolean;
begin
  if IsActive then
  begin
    FocusHeaderValueEdit;
    Result := True;
  end
  else
    Result := False;
end;

function THeaderView.GetHeaderIndex: Integer;
begin
  Result := FHeaderIndex;
end;

function THeaderView.GetHeaderName: string;
begin
  Result := HeaderKindComboEdit.Text;
end;

function THeaderView.GetHeaderValue: string;
begin
  Result := HeaderValueEdit.Text;
end;

procedure THeaderView.HeaderKindComboEditChangeTracking(Sender: TObject);
begin
  FHeaderKindChanged := True;
end;

procedure THeaderView.HeaderKindComboEditClosePopup(Sender: TObject);
begin
  if HeaderKindComboEdit.ItemIndex <> FHeaderKindIndex then
  begin
    HeaderValueEdit.Text := '';
    SuggestionTimer.Enabled := False;
    SuggestionListBox.Visible := False;
    FocusHeaderValueEdit;
    DoChanged;
  end;
end;

procedure THeaderView.HeaderKindComboEditExit(Sender: TObject);
begin
  if FHeaderKindChanged then
    DoChanged;
end;

procedure THeaderView.HeaderKindComboEditPopup(Sender: TObject);
begin
  FHeaderKindIndex := HeaderKindComboEdit.ItemIndex;
end;

procedure THeaderView.HeaderValueEditChangeTracking(Sender: TObject);
begin
  DoChanged;
  SuggestionTimer.Enabled := True;
end;

procedure THeaderView.HeaderValueEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    vkReturn:
    begin
      if SelectSuggestion then
      begin
        Key := 0;
        KeyChar := #0;
      end;
    end;
    vkUp, vkDown:
    begin
      if (Key = vkDown) and not SuggestionListBox.Visible then
        ShowSuggestions
      else
        TOpenControl(SuggestionListBox).KeyDown(Key, KeyChar, Shift);
    end;
    vkEscape:
      SuggestionListBox.Visible := False;
  end;
end;

procedure THeaderView.FilterSuggestions;
var
  LMatches, LValues: TArray<string>;
  LSelectedValue, LValue: string;
  I, LIndex: Integer;
begin
  LMatches := HeaderValues.GetMatches(HeaderKindComboEdit.Text, HeaderValueEdit.Text);
  LSelectedValue := '';
  if SuggestionListBox.ItemIndex > 0 then
    LSelectedValue := SuggestionListBox.Items[SuggestionListBox.ItemIndex];
  SuggestionListBox.Items.BeginUpdate;
  try
    SuggestionListBox.Items.Clear;
    SuggestionListBox.Items.AddStrings(LMatches);
    for I := 0 to SuggestionListBox.Items.Count - 1 do
      SuggestionListBox.ListItems[I].HitTest := True;
    LIndex := SuggestionListBox.Items.IndexOf(LSelectedValue);
    if LIndex > -1 then
      SuggestionListBox.ItemIndex := LIndex
    else if SuggestionListBox.Items.Count > 0 then
      SuggestionListBox.ItemIndex := 0;
  finally
    SuggestionListBox.Items.EndUpdate;
  end;
end;

procedure THeaderView.ShowSuggestions;
var
  LPoint: TPointF;
begin
  FilterSuggestions;
  if SuggestionListBox.Items.Count > 0 then
  begin
    SuggestionListBox.Width := HeaderValueEdit.Width;
    SuggestionListBox.Position.X := HeaderValueEdit.Position.X;
    SuggestionListBox.Position.Y := HeaderValueEdit.BoundsRect.Bottom + 2;
    SuggestionListBox.Visible := True;
    SuggestionListBox.BringToFront;
  end
  else
    SuggestionListBox.Visible := False;
end;

procedure THeaderView.SuggestionListBoxClick(Sender: TObject);
begin
  SelectSuggestion;
end;

procedure THeaderView.SuggestionListBoxKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkReturn) and SelectSuggestion then
  begin
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure THeaderView.SuggestionTimerTimer(Sender: TObject);
begin
  SuggestionTimer.Enabled := False;
  ShowSuggestions;
end;

function THeaderView.SelectSuggestion: Boolean;
begin
  Result := False;
  if SuggestionListBox.Visible and (SuggestionListBox.ItemIndex > -1) then
  begin
    HeaderValueEdit.Text := SuggestionListBox.Items[SuggestionListBox.ItemIndex];
    HeaderValueEdit.SelStart := Length(HeaderValueEdit.Text);
    SuggestionTimer.Enabled := False;
    SuggestionListBox.Visible := False;
    HeaderValueEdit.SetFocus;
    Result := True;
  end;
end;

procedure THeaderView.SetHeaderIndex(const Value: Integer);
begin
  FHeaderIndex := Value;
  SetIsActive(FHeaderIndex > -1);
end;

procedure THeaderView.SetHeaderName(const Value: string);
begin
  HeaderKindComboEdit.Text := Value;
  FHeaderKindChanged := False;
end;

procedure THeaderView.SetHeaderValue(const Value: string);
begin
  SetIsActive(True);
  HeaderValueEdit.Text := Value;
  SuggestionTimer.Enabled := False;
end;

procedure THeaderView.ActionButtonClick(Sender: TObject);
begin
  if not FIsActive then
  begin
    SetIsActive(True);
    DoActive;
    FocusHeaderValueEdit;
  end;
end;

procedure THeaderView.SetIsActive(const Value: Boolean);
begin
  FIsActive := Value;
  if FIsActive then
    Resources.LoadButtonImage(cButtonImageGrabIndex, ActionImage.Bitmap)
  else
    Resources.LoadButtonImage(cButtonImageCogIndex, ActionImage.Bitmap);
  HeaderKindComboEdit.Visible := FIsActive;
  HeaderValueEdit.Visible := FIsActive;
  EnabledCheckBox.Visible := FIsActive;
  EnabledCheckBox.IsChecked := FIsActive;
  DeleteButton.Visible := FIsActive;
  NewHeaderLabel.Visible := not FIsActive;
end;

procedure THeaderView.SetIsHeaderEnabled(const Value: Boolean);
begin
  EnabledCheckBox.IsChecked := Value;
end;

end.
