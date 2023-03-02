unit SL.View.FolderNode;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  SL.NodeEdit;

type
  TFolderNodeView = class(TFrame)
    DescriptionEdit: TEdit;
  private
    FID: string;
    FOnDescriptionChange: TNotifyEvent;
    function GetDescription: string;
    procedure SetDescription(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure GainFocus;
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
end;

procedure TFolderNodeView.GainFocus;
begin
  DescriptionEdit.SetFocus;
end;

function TFolderNodeView.GetDescription: string;
begin
  Result := DescriptionEdit.Text;
end;

procedure TFolderNodeView.SetDescription(const Value: string);
begin
  DescriptionEdit.Text := Value;
end;

end.
