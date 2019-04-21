unit LumosServerFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ServerLib, Vcl.StdCtrls;

type
  TLumosServerDlg = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
    FServer: TLumosServer;
  public
    { Public-Deklarationen }
  end;

var
  LumosServerDlg: TLumosServerDlg;

implementation

{$R *.dfm}

procedure TLumosServerDlg.FormCreate(Sender: TObject);
begin
  FServer := TLumosServer.Create;
end;

procedure TLumosServerDlg.FormDestroy(Sender: TObject);
begin
  FServer.Free;
end;

end.
