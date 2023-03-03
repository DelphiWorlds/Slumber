unit SL.View.FolderNode;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  SL.NodeEdit;

type
  TFolderNodeView = class(TFrame)
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
    procedure SetDescription(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure EnableEditing(const AEnable: Boolean);
    property ID: string read FID write FID;
    property Description: string read GetDescription write SetDescription;
    property OnDescriptionChange: TNotifyEvent read FOnDescriptionChange write FOnDescriptionChange;
  end;

implementation

{$R *.fmx}

{ TFolderNodeView }

constructor TFolderNodeView.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
  SetDescription('');
  EnableEditing(False);
end;

procedure TFolderNodeView.DescriptionEditChange(Sender: TObject);
begin
  FIsModified := True;
end;

procedure TFolderNodeView.DescriptionEditExit(Sender: TObject);
begin
  EnableEditing(False);
end;

procedure TFolderNodeView.DescriptionEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Key := 0;
    EnableEditing(False);
  end;
end;

procedure TFolderNodeView.DoDescriptionChange;
begin
  if Assigned(FOnDescriptionChange) then
    FOnDescriptionChange(Self);
end;

procedure TFolderNodeView.EnableEditing(const AEnable: Boolean);
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

function TFolderNodeView.GetDescription: string;
begin
  Result := DescriptionEdit.Text;
end;

procedure TFolderNodeView.SetDescription(const Value: string);
begin
  DescriptionEdit.Text := Value;
  FIsModified := False;
end;

end.
