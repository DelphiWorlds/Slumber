unit SL.NodeEdit;

interface

uses
  System.UITypes, System.Classes,
  FMX.Objects, FMX.Edit, FMX.Controls, FMX.Types;

type
  /// <summary>
  ///   Interposer class that overrides FMX's silly idea of making edit controls a fixed height on some OS's
  ///   Plus does other stuff ;-)
  /// </summary>
  TEdit = class(FMX.Edit.TEdit)
  private
    FColor: TAlphaColor;
    FRectangle: TRectangle;
    procedure SetColor(const Value: TAlphaColor);
  protected
    procedure AdjustFixedSize(const Ref: TControl); override;
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    function GetStyleObject: TFmxObject; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Color: TAlphaColor read FColor write SetColor;
  end;

implementation

uses
  FMX.Graphics, FMX.Styles.Objects;

{ TEdit }

constructor TEdit.Create(AOwner: TComponent);
begin
  inherited;
  FRectangle := TRectangle.Create(Self);
  FRectangle.StyleName := 'rect';
  FRectangle.Align := TAlignLayout.Contents;
  FRectangle.HitTest := False;
  FRectangle.Stroke.Kind := TBrushKind.None;
  FRectangle.Fill.Color := TAlphaColors.Null;
  FRectangle.Sides := [];
  FRectangle.XRadius := 4;
  FRectangle.YRadius := 4;
end;

procedure TEdit.AdjustFixedSize(const Ref: TControl);
begin
  SetAdjustType(TAdjustType.None);
end;

procedure TEdit.ApplyStyle;
var
  LBackground: TFmxObject;
begin
  inherited;
  LBackground := FindStyleResource('background');
  if LBackground is TCustomStyleObject then
    TCustomStyleObject(LBackground).Visible := False;
end;

procedure TEdit.FreeStyle;
begin
  FRectangle.Parent := nil;
  inherited;
end;

function TEdit.GetStyleObject: TFmxObject;
begin
  Result := inherited GetStyleObject;
  if Result <> nil then
    Result.InsertObject(0, FRectangle);
end;

procedure TEdit.SetColor(const Value: TAlphaColor);
begin
  FRectangle.Fill.Color := Value;
end;

end.
