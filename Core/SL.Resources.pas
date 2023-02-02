unit SL.Resources;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, System.Types,
  FMX.ImgList, FMX.Graphics;

const
  cGeneralImageCogIndex = 0;
  cGeneralImageGrabIndex = 1;
  cGeneralImageDeleteIndex = 2;

type
  TResources = class(TDataModule)
    GeneralImageList: TImageList;
  private
    FGeneralImageSize: TSizeF;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadGeneralImage(const ABitmap: TBitmap; const AIndex: Integer);
  end;

var
  Resources: TResources;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

constructor TResources.Create(AOwner: TComponent);
begin
  inherited;
  FGeneralImageSize := TSizeF.Create(64, 64);
end;

procedure TResources.LoadGeneralImage(const ABitmap: TBitmap; const AIndex: Integer);
begin
  ABitmap.Assign(GeneralImageList.Bitmap(FGeneralImageSize, AIndex));
end;

end.
