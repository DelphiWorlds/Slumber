unit SL.Resources;

interface

uses
  System.Classes,
  SL.SVGResources;

const
  cButtonImageCogIndex = 0;
  cButtonImageGrabIndex = 1;
  cButtonImageDeleteIndex = 2;
  cButtonImageListPlusIndex = 3;

type
  TResources = class(TSVGResources)
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  Resources: TResources;

implementation

{ TResources }

constructor TResources.Create(AOwner: TComponent);
begin
  inherited;
  AddResourceSVG('ButtonIcons_cog');
  AddResourceSVG('ButtonIcons_menu');
  AddResourceSVG('ButtonIcons_x_circle');
  AddResourceSVG('ButtonIcons_list_plus');
  Resources := Self;
end;

end.
