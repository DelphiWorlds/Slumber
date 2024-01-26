unit SL.Config;

interface

uses
  System.JSON;

type
  TViewDimensions = record
    Left: Integer;
    Top: Integer;
    Width: Integer;
    Height: Integer;
    procedure FromJSONValue(const AValue: TJSONValue);
    function IsZero: Boolean;
    function ToJSONValue: TJSONValue;
  end;

  TSlumberConfig = record
  private
    function GetFileName: string;
  public
    MainViewDimensions: TViewDimensions;
    NavigatorLayoutWidth: Single;
    ProfileFileName: string;
    RequestLayoutWidth: Single;
    ResponseContentMemoWordWrap: Boolean;
    procedure Load;
    procedure Save;
  end;

implementation

uses
  System.IOUtils, System.SysUtils,
  DW.IOUtils.Helpers, DW.JSON;

{ TViewDimensions }

procedure TViewDimensions.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('Left', Left);
  AValue.TryGetValue('Top', Top);
  AValue.TryGetValue('Width', Width);
  AValue.TryGetValue('Height', Height);
end;

function TViewDimensions.IsZero: Boolean;
begin
  Result := (Width = 0) or (Height = 0);
end;

function TViewDimensions.ToJSONValue: TJSONValue;
var
  LValue: TJSONObject;
begin
  LValue := TJSONObject.Create;
  LValue.AddPair('Left', Left);
  LValue.AddPair('Top', Top);
  LValue.AddPair('Width', Width);
  LValue.AddPair('Height', Height);
  Result := LValue;
end;

{ TSlumberConfig }

function TSlumberConfig.GetFileName: string;
begin
  Result := TPathHelper.GetAppDocumentsFile('config.json');
  ForceDirectories(TPath.GetDirectoryName(Result));
end;

procedure TSlumberConfig.Load;
var
  LJSON, LDimensions: TJSONValue;
begin
  if TFile.Exists(GetFileName) then
  begin
    LJSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(GetFileName));
    if LJSON <> nil then
    try
      LJSON.TryGetValue('ProfileFileName', ProfileFileName);
      LJSON.TryGetValue('NavigatorLayoutWidth', NavigatorLayoutWidth);
      LJSON.TryGetValue('RequestLayoutWidth', RequestLayoutWidth);
      LJSON.TryGetValue('ResponseContentMemoWordWrap', ResponseContentMemoWordWrap);
      if LJSON.TryGetValue('MainViewDimensions', LDimensions) then
        MainViewDimensions.FromJSONValue(LDimensions);
    finally
      LJSON.Free;
    end;
  end;
end;

procedure TSlumberConfig.Save;
var
  LValue: TJSONObject;
begin
  LValue := TJSONObject.Create;
  try
    LValue.AddPair('ProfileFileName', ProfileFileName);
    LValue.AddPair('NavigatorLayoutWidth', NavigatorLayoutWidth);
    LValue.AddPair('RequestLayoutWidth', RequestLayoutWidth);
    LValue.AddPair('ResponseContentMemoWordWrap', ResponseContentMemoWordWrap);
    LValue.AddPair('MainViewDimensions', MainViewDimensions.ToJSONValue);
    TFile.WriteAllText(GetFileName, TJsonHelper.Tidy(LValue.ToJSON));
  finally
    LValue.Free;
  end;
end;

end.
