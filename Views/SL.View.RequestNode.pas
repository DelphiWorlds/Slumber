unit SL.View.RequestNode;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  SL.NodeEdit;

type
  TRequestNodeView = class(TFrame)
    MethodLabel: TLabel;
    DescriptionEdit: TEdit;
    procedure DescriptionEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure DescriptionEditExit(Sender: TObject);
    procedure DescriptionEditChange(Sender: TObject);
  private
    FID: string;
    FIsModified: Boolean;
    FOnDescriptionChange: TNotifyEvent;
    procedure DoDescriptionChange;
    function GetDescription: string;
    function GetHTTPMethod: string;
    procedure SetDescription(const Value: string);
    procedure SetHTTPMethod(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure EnableEditing(const AEnable: Boolean);
    property ID: string read FID write FID;
    property Description: string read GetDescription write SetDescription;
    property HTTPMethod: string read GetHTTPMethod write SetHTTPMethod;
    property OnDescriptionChange: TNotifyEvent read FOnDescriptionChange write FOnDescriptionChange;
  end;

implementation

{$R *.fmx}

{ TRequestNodeView }

constructor TRequestNodeView.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
  SetDescription('');
  SetHTTPMethod('');
  EnableEditing(False);
end;

procedure TRequestNodeView.DescriptionEditChange(Sender: TObject);
begin
  FIsModified := True;
end;

procedure TRequestNodeView.DescriptionEditExit(Sender: TObject);
begin
  EnableEditing(False);
end;

procedure TRequestNodeView.DescriptionEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Key := 0;
    EnableEditing(False);
  end;
end;

procedure TRequestNodeView.DoDescriptionChange;
begin
  if Assigned(FOnDescriptionChange) then
    FOnDescriptionChange(Self);
end;

procedure TRequestNodeView.EnableEditing(const AEnable: Boolean);
const
  cEditingOpacity: array[Boolean] of Single = (0.8, 1);
begin
  DescriptionEdit.HitTest := AEnable;
  if AEnable then
    DescriptionEdit.SetFocus
  else
    DescriptionEdit.ResetFocus;
  DescriptionEdit.Opacity := cEditingOpacity[AEnable];
  if not AEnable and FIsModified then
    DoDescriptionChange;
end;

function TRequestNodeView.GetDescription: string;
begin
  Result := DescriptionEdit.Text;
end;

function TRequestNodeView.GetHTTPMethod: string;
begin
  Result := MethodLabel.Text;
end;

procedure TRequestNodeView.SetDescription(const Value: string);
begin
  DescriptionEdit.Text := Value;
  FIsModified := False;
end;

procedure TRequestNodeView.SetHTTPMethod(const Value: string);
begin
  MethodLabel.Text := Value;
end;

end.
