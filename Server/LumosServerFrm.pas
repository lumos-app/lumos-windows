unit LumosServerFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, ServerLib,
  FMX.Controls.Presentation, FMX.StdCtrls, SimpleBonjourLib;

type
  TLumosServerDlg = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    FServer: TLumosServer;
    FBonjourService: TBonjourPublishService;
  public
    { Public-Deklarationen }
  end;

var
  LumosServerDlg: TLumosServerDlg;

implementation

uses
  DiashowFrm;

{$R *.fmx}

procedure TLumosServerDlg.Button1Click(Sender: TObject);
begin
  DiashowDlg.Show;
end;

procedure TLumosServerDlg.FormCreate(Sender: TObject);
var
  serviceInfo: TBonjourService;
begin
  FServer := TLumosServer.Create;

  serviceInfo.ServiceName := 'Lumos Windows Server';
  serviceInfo.ServiceType := '_lumos._tcp';
  serviceInfo.ServicePort := 8082;

  FBonjourService := TBonjourPublishService.Create;
  FBonjourService.publishService(serviceInfo);
end;

procedure TLumosServerDlg.FormDestroy(Sender: TObject);
begin
  FServer.Free;
  FBonjourService.Free;
end;

end.
