unit SL.Storage.Profile;

interface

uses
  SL.Model.Profile;

type
  TSlumberProfileHelper = class helper for TSlumberProfile
  public
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
  end;

implementation

uses
  System.IOUtils, System.Rtti, System.SysUtils;

{ TSlumberProfileHelper }

procedure TSlumberProfileHelper.LoadFromFile(const AFileName: string);
begin
  // TODO
end;

procedure TSlumberProfileHelper.SaveToFile(const AFileName: string);
begin
  // TODO
end;

end.
