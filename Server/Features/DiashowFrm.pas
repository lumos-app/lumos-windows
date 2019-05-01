unit DiashowFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  DatabaseLib, FMX.Layouts, FMX.ExtCtrls;

type
  TDiashowDlg = class(TForm)
    Timer1: TTimer;
    ImageViewer1: TImageViewer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
    FDatabase: TDatabase;
    FImageIdx: Integer;
  public
    { Public-Deklarationen }
  end;

var
  DiashowDlg: TDiashowDlg;

implementation

uses
  ImageLib;

{$R *.fmx}

procedure TDiashowDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := false;
end;

procedure TDiashowDlg.FormCreate(Sender: TObject);
begin
  FDatabase := TDatabase.Create;
  Timer1.Enabled := false;
end;

procedure TDiashowDlg.FormDestroy(Sender: TObject);
begin
  FDatabase.Free;
end;

procedure TDiashowDlg.FormShow(Sender: TObject);
begin
  FImageIdx := 0;
  Timer1Timer(nil);
  Timer1.Enabled := true;
end;

procedure TDiashowDlg.Timer1Timer(Sender: TObject);
var
  image: TLumosImage;
begin
  FDatabase.Refresh;
  if FDatabase.Images.Count = 0 then exit;
  Timer1.Enabled := false;
  try
    Inc(FImageIdx);
    if FImageIdx >= FDatabase.Images.Count then FImageIdx := 0;

    image := FDatabase.Images[FImageIdx];
    if FileExists(image.CompleteFileName) and (not image.IsUpdating) then
    begin
      ImageViewer1.Bitmap.LoadFromFile(FDatabase.Images[FImageIdx].CompleteFileName);
      ImageViewer1.BestFit;
    end;
  finally
    Timer1.Enabled := true;
  end;
end;

end.
