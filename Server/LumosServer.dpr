program LumosServer;

uses
  System.StartUpCopy,
  FMX.Forms,
  DatabaseLib in 'Services\DatabaseLib.pas',
  ServerLib in 'Services\ServerLib.pas',
  DateHelperLib in 'Helpers\DateHelperLib.pas',
  ServerHelperLib in 'Helpers\ServerHelperLib.pas',
  ImageLib in 'Classes\ImageLib.pas',
  OptionsLib in 'Classes\OptionsLib.pas',
  DiashowFrm in 'Features\DiashowFrm.pas' {DiashowDlg},
  CCR.Exif.BaseUtils in 'lib\CCR.Exif.BaseUtils.pas',
  CCR.Exif.Consts in 'lib\CCR.Exif.Consts.pas',
  CCR.Exif.IPTC in 'lib\CCR.Exif.IPTC.pas',
  CCR.Exif in 'lib\CCR.Exif.pas',
  CCR.Exif.StreamHelper in 'lib\CCR.Exif.StreamHelper.pas',
  CCR.Exif.TagIDs in 'lib\CCR.Exif.TagIDs.pas',
  CCR.Exif.TiffUtils in 'lib\CCR.Exif.TiffUtils.pas',
  CCR.Exif.XMPUtils in 'lib\CCR.Exif.XMPUtils.pas',
  ImageHelperLib in 'Helpers\ImageHelperLib.pas',
  SimpleBonjourLib in 'lib\SimpleBonjourLib.pas',
  Deltics.Bonjour.API in 'lib\Deltics.Bonjour.API.pas';

{$R *.res}

var
  FServer: TLumosServer;
begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  FServer := TLumosServer.Create;
  Application.CreateForm(TDiashowDlg, DiashowDlg);
  Application.Run;
  FServer.Free;
end.
