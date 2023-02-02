program Slumber;

uses
  System.StartUpCopy,
  FMX.Forms,
  SL.View.Main in 'Views\SL.View.Main.pas' {MainView},
  SL.View.Header in 'Views\SL.View.Header.pas' {HeaderView: TFrame},
  SL.Types in 'Core\SL.Types.pas',
  SL.Consts in 'Core\SL.Consts.pas',
  SL.Client in 'Core\SL.Client.pas',
  SL.Resources in 'Core\SL.Resources.pas' {Resources: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TResources, Resources);
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
