unit SL.Resources;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Graphics,
  FMX.SVGIconImageList;

const
  cButtonImageCogIndex = 0;
  cButtonImageGrabIndex = 1;
  cButtonImageDeleteIndex = 2;
  cButtonImageListPlusIndex = 3;

type
  TResources = class(TDataModule)
    StyleBook: TStyleBook;
  private
    FButtonImageSize: TSizeF;
    FButtonImageList: TSVGIconImageList;
    function CreateImageList(const ASize: Integer): TSVGIconImageList;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadButtonImage(const AIndex: Integer; const ABitmap: TBitmap);
  end;

var
  Resources: TResources;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{$I SVGIconImageList.inc}

uses
  {$IFDEF Image32_SVGEngine}
  FMX.Image32SVG,
  {$ENDIF}
  {$IFDEF Skia_SVGEngine}
  FMX.ImageSkiaSVG,
  {$ENDIF}
  FMX.ImageSVG,
  DW.StyleHelpers;

type
  TOpenFmxImageSVG = class(TFmxImageSVG);

  TSVGIconImageListHelper = class helper for TSVGIconImageList
  public
    procedure AddResourceSVG(const AResourceName: string);
  end;

{ TSVGIconImageListHelper }

procedure TSVGIconImageListHelper.AddResourceSVG(const AResourceName: string);
var
  LSVG: TFmxImageSVG;
  LItem: TSVGIconSourceItem;
  LStream: TStream;
begin
  if FindResource(HInstance, PChar(AResourceName), RT_RCDATA) > 0 then
  begin
    LStream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
    try
      {$IFDEF Image32_SVGEngine}
      LSVG := TFmxImage32SVG.Create;
      {$ENDIF}
      {$IFDEF Skia_SVGEngine}
      LSVG := TFmxImageSKIASVG.Create;
      {$ENDIF}
      try
        TOpenFmxImageSVG(LSVG).LoadFromStream(LStream);
        LItem := InsertIcon(Source.Count, LSVG.Source, AResourceName);
        LItem.SVG := LSVG;
      finally
        LSVG.Free;
      end;
    finally
      LStream.Free;
    end;
  end;
end;

{ TResources }

constructor TResources.Create(AOwner: TComponent);
var
  LStyleResource: TStyleResource;
begin
  inherited;
  StyleBook.LoadFromResource;
  LStyleResource.LoadFromResource;
  // More refactoring
  FButtonImageList := CreateImageList(24);
  FButtonImageList.FixedColor := LStyleResource.ButtonColor;
  FButtonImageList.AddResourceSVG('ButtonIcons_cog');
  FButtonImageList.AddResourceSVG('ButtonIcons_menu');
  FButtonImageList.AddResourceSVG('ButtonIcons_x_circle');
  FButtonImageList.AddResourceSVG('ButtonIcons_list_plus');
end;

function TResources.CreateImageList(const ASize: Integer): TSVGIconImageList;
begin
  Result := TSVGIconImageList.Create(Self);
  Result.Size := ASize;
  Result.Height := ASize;
  Result.Width := ASize;
  FButtonImageSize := TSizeF.Create(ASize, ASize);
end;

procedure TResources.LoadButtonImage(const AIndex: Integer; const ABitmap: TBitmap);
begin
  ABitmap.Assign(FButtonImageList.Bitmap(FButtonImageSize, AIndex));
end;

end.
