program LumosServer;

uses
  Vcl.Forms,
  LumosServerFrm in 'LumosServerFrm.pas' {LumosServerDlg},
  ServerLib in 'Services\ServerLib.pas',
  ServerHelperLib in 'Helpers\ServerHelperLib.pas',
  ImageLib in 'Classes\ImageLib.pas',
  OptionsLib in 'Classes\OptionsLib.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TLumosServerDlg, LumosServerDlg);
  Application.Run;
end.
