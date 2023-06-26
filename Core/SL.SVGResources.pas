unit SL.SVGResources;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  System.Generics.Collections, System.Skia, FMX.Types, FMX.Controls,
  FMX.Graphics, FMX.Skia;

type
  TSkSvgBrushes = TObjectList<TSkSvgBrush>;

  TSVGResources = class(TDataModule)
    StyleBook: TStyleBook;
  private
    FButtonImageSize: TSizeF;
    FButtonBrushes: TSkSvgBrushes;
    FFixedColor: TAlphaColor;
    procedure DrawSVG(const ABrush: TSkSvgBrush; const ACanvas: ISkCanvas);
    function GetResourceSVG(const AResourceName: string): string;
  protected
    procedure AddResourceSVG(const AResourceName: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadButtonImage(const AIndex: Integer; const ABitmap: TBitmap);
  end;

var
  SVGResources: TSVGResources;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  DW.OSLog, DW.StyleHelpers;

{ TSVGResources }

constructor TSVGResources.Create(AOwner: TComponent);
var
  LStyleResource: TStyleResource;
begin
  inherited;
  if not StyleBook.LoadFromResource then
    TOSLog.e('Could not find StyleBook resource');
  LStyleResource.LoadFromResource;
  FButtonImageSize := TSizeF.Create(48, 48);
  FButtonBrushes := TSkSvgBrushes.Create(True);
  FFixedColor := LStyleResource.ButtonColor;
end;

destructor TSVGResources.Destroy;
begin
  FButtonBrushes.Free;
  inherited;
end;

function TSVGResources.GetResourceSVG(const AResourceName: string): string;
var
  LResStream: TStream;
  LStream: TStringStream;
begin
  Result := '';
  if FindResource(HInstance, PChar(AResourceName), RT_RCDATA) > 0 then
  begin
    LResStream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
    try
      LStream := TStringStream.Create;
      try
        LStream.CopyFrom(LResStream);
        Result := LStream.DataString;
      finally
        LStream.Free;
      end;
    finally
      LResStream.Free;
    end;
  end
  else
    TOSLog.e('Could not find "%s" in resources', [AResourceName]);
end;

procedure TSVGResources.AddResourceSVG(const AResourceName: string);
var
  LBrush: TSkSvgBrush;
begin
  LBrush := TSkSvgBrush.Create;
  LBrush.Source := GetResourceSVG(AResourceName);
  FButtonBrushes.Add(LBrush);
end;

procedure TSVGResources.DrawSVG(const ABrush: TSkSvgBrush; const ACanvas: ISkCanvas);
var
  LRect: TRectF;
begin
  LRect := RectF(0, 0, FButtonImageSize.Width, FButtonImageSize.Height);
  ABrush.OverrideColor := FFixedColor;
  ABrush.Render(ACanvas, LRect, 1);
end;

procedure TSVGResources.LoadButtonImage(const AIndex: Integer; const ABitmap: TBitmap);
begin
  ABitmap.SetSize(Round(FButtonImageSize.Width), Round(FButtonImageSize.Height));
  ABitmap.SkiaDraw(
    procedure(const ACanvas: ISkCanvas)
    begin
      DrawSVG(FButtonBrushes.Items[AIndex], ACanvas);
    end);
end;

end.

