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
  private
    FID: string;
    FOnDescriptionChange: TNotifyEvent;
    function GetDescription: string;
    function GetHTTPMethod: string;
    procedure SetDescription(const Value: string);
    procedure SetHTTPMethod(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure GainFocus;
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
end;

procedure TRequestNodeView.GainFocus;
begin
  DescriptionEdit.SetFocus;
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
end;

procedure TRequestNodeView.SetHTTPMethod(const Value: string);
begin
  MethodLabel.Text := Value;
end;

end.
