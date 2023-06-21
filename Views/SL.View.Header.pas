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
    procedure HeaderValueEditChangeTracking(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ActionButtonClick(Sender: TObject);
    procedure HeaderKindComboEditClosePopup(Sender: TObject);
    procedure HeaderKindComboEditPopup(Sender: TObject);
    procedure HeaderKindComboEditChangeTracking(Sender: TObject);
    procedure HeaderKindComboEditExit(Sender: TObject);
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
    procedure FocusHeaderValueEdit;
    function GetHeaderIndex: Integer;
    function GetHeaderName: string;
    function GetHeaderValue: string;
    function GetIsHeaderEnabled: Boolean;
    procedure SetIsActive(const Value: Boolean);
    procedure SetHeaderIndex(const Value: Integer);
    procedure SetHeaderName(const Value: string);
    procedure SetHeaderValue(const Value: string);
    procedure SetIsHeaderEnabled(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
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
  SL.Consts, SL.Resources;

{ THeaderView }

constructor THeaderView.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
  HeaderKindComboEdit.Items.AddStrings(cHeaderKindNames);
  HeaderKindComboEdit.ItemIndex := 0;
  Resources.LoadButtonImage(cButtonImageDeleteIndex, DeleteImage.Bitmap);
  SetIsActive(False);
end;

function THeaderView.GetIsHeaderEnabled: Boolean;
begin
  Result := EnabledCheckBox.IsChecked;
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
