program Slumber;

{$I Styles\Styles.inc}
{$I Resources\IconRes.inc}

uses
  System.StartUpCopy,
  FMX.Forms,
  SL.View.Main in 'Views\SL.View.Main.pas' {MainView},
  SL.View.Header in 'Views\SL.View.Header.pas' {HeaderView: TFrame},
  SL.Types in 'Core\SL.Types.pas',
  SL.Consts in 'Core\SL.Consts.pas',
  SL.Client in 'Core\SL.Client.pas',
  SL.Resources in 'Core\SL.Resources.pas' {Resources: TDataModule},
  SL.Model.Profile in 'Models\SL.Model.Profile.pas',
  SL.Storage.Profile in 'Storage\SL.Storage.Profile.pas',
  SL.View.RequestNode in 'Views\SL.View.RequestNode.pas' {RequestNodeView: TFrame},
  SL.View.FolderNode in 'Views\SL.View.FolderNode.pas' {FolderNodeView: TFrame},
  SL.NodeEdit in 'Core\SL.NodeEdit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TResources, Resources);
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
