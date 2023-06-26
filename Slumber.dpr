program Slumber;

{$I Styles\Styles.inc}
{$I Resources\IconRes.inc}

uses
  System.StartUpCopy,
  FMX.Forms,
  SL.Client in 'Core\SL.Client.pas',
  SL.Consts in 'Core\SL.Consts.pas',
  SL.Model.Profile in 'Models\SL.Model.Profile.pas',
  SL.NodeEdit in 'Core\SL.NodeEdit.pas',
  SL.Storage.Profile in 'Storage\SL.Storage.Profile.pas',
  SL.Types in 'Core\SL.Types.pas',
  SL.View.FolderNode in 'Views\SL.View.FolderNode.pas' {FolderNodeView: TFrame},
  SL.View.Header in 'Views\SL.View.Header.pas' {HeaderView: TFrame},
  SL.View.Main in 'Views\SL.View.Main.pas' {MainView},
  SL.View.RequestNode in 'Views\SL.View.RequestNode.pas' {RequestNodeView: TFrame},
  SL.Config in 'Core\SL.Config.pas',
  SL.Resources in 'Core\SL.Resources.pas',
  SL.SVGResources in 'Core\SL.SVGResources.pas' {SVGResources: TDataModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
