unit SL.View.RequestNode;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TRequestNodeView = class(TFrame)
    MethodLabel: TLabel;
    DescriptionLabel: TLabel;
  private
    function GetDescription: string;
    function GetHTTPMethod: string;
    procedure SetDescription(const Value: string);
    procedure SetHTTPMethod(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    property Description: string read GetDescription write SetDescription;
    property HTTPMethod: string read GetHTTPMethod write SetHTTPMethod;
  end;

implementation

{$R *.fmx}

{ TRequestNodeView }

constructor TRequestNodeView.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
end;

function TRequestNodeView.GetDescription: string;
begin
  Result := DescriptionLabel.Text;
end;

function TRequestNodeView.GetHTTPMethod: string;
begin
  Result := MethodLabel.Text;
end;

procedure TRequestNodeView.SetDescription(const Value: string);
begin
  DescriptionLabel.Text := Value;
end;

procedure TRequestNodeView.SetHTTPMethod(const Value: string);
begin
  MethodLabel.Text := Value;
end;

end.
