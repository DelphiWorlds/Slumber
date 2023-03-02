unit SL.NodeEdit;

interface

uses
  System.UITypes, System.Classes,
  FMX.Objects, FMX.Graphics, FMX.Edit, FMX.Controls, FMX.Types;

type
  /// <summary>
  ///   Interposer class that overrides FMX's silly idea of making edit controls a fixed height on some OS's
  ///   Plus does other stuff ;-)
  /// </summary>
  TEdit = class(FMX.Edit.TEdit)
  private
    FRectangle: TRectangle;
    function GetFill: TBrush;
    function GetStroke: TStrokeBrush;
  protected
    procedure AdjustFixedSize(const Ref: TControl); override;
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    function GetStyleObject: TFmxObject; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Fill: TBrush read GetFill;
    property Stroke: TStrokeBrush read GetStroke;
  end;

implementation

uses
  FMX.Styles.Objects;

{ TEdit }

constructor TEdit.Create(AOwner: TComponent);
begin
  inherited;
  FRectangle := TRectangle.Create(Self);
  FRectangle.StyleName := 'rect';
  FRectangle.Align := TAlignLayout.Contents;
  FRectangle.HitTest := False;
  FRectangle.Fill.Color := TAlphaColors.Null;
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

function TEdit.GetFill: TBrush;
begin
  Result := FRectangle.Fill;
end;

function TEdit.GetStroke: TStrokeBrush;
begin
  Result := FRectangle.Stroke;
end;

function TEdit.GetStyleObject: TFmxObject;
begin
  Result := inherited GetStyleObject;
  if Result <> nil then
    Result.InsertObject(0, FRectangle);
end;

end.
