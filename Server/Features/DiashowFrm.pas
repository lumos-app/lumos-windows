unit DiashowFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  DatabaseLib, FMX.Layouts, FMX.ExtCtrls, ImageHelperLib;

type
  TDiashowDlg = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    Image2: TImage;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormHide(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private-Deklarationen }
    procedure ToggleImage;
  public
    { Public-Deklarationen }
  end;

var
  DiashowDlg: TDiashowDlg;

implementation

uses
  ImageLib, FMX.Ani;

{$R *.fmx}

procedure TDiashowDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := false;
end;

procedure TDiashowDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  visibleCount: Integer;
begin
  visibleCount := 0;
  if Image1.Visible then Inc(visibleCount);
  if Image2.Visible then Inc(visibleCount);
  CanClose := visibleCount = 1;
end;

procedure TDiashowDlg.FormHide(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TDiashowDlg.FormShow(Sender: TObject);
begin
  Timer1.Enabled := false;
  Image2.Visible := false;

  if Screen.DisplayCount > 1 then
  begin
    self.Bounds := Screen.Displays[1].WorkArea;
    Self.WindowState := TWindowState.wsMaximized;
  end;
  Timer1Timer(nil);
  Timer1.Enabled := true;
end;

procedure TDiashowDlg.Timer1Timer(Sender: TObject);
var
  image: TLumosImage;
  bmp: TBitmap;
  resizedBmp: TBitmap;
  aspectRatio: TAspectRatio;
begin
  if TDatabase.Current.Images.Count = 0 then exit;
  Timer1.Enabled := false;
  try
    image := TDatabase.Current.fetchNextImage;
    if (image <> nil) and FileExists(image.CompleteFileName) and (not image.IsUpdating) then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromFile(image.CompleteFileName);
      if bmp.IsLandscape then aspectRatio := TAspectRatio.AspectFill else aspectRatio := TAspectRatio.AspectFit;
      resizedBmp := TImageHelper.getAspectBitmap(bmp, Image1.Size.Size, aspectRatio);

      if Image1.Visible then
      begin
        Image2.Bitmap.Assign(resizedBmp);
      end else
      begin
        Image1.Bitmap.Assign(resizedBmp);
      end;
      bmp.Free;
      resizedBmp.Free;

      ToggleImage;
    end;
  finally
    Timer1.Enabled := true;
  end;
end;

procedure TDiashowDlg.ToggleImage;
var
  VisibleImage: TImage;
  HiddenImage: TImage;
begin
  if Image1.Visible then
  begin
    VisibleImage := Image1;
    HiddenImage := Image2;
  end else
  begin
    VisibleImage := Image2;
    HiddenImage := Image1;
  end;

  HiddenImage.Opacity := 0;
  HiddenImage.Visible := true;
  TAnimator.AnimateFloat(VisibleImage, 'Opacity', 0, 2);
  TAnimator.AnimateFloatWait(HiddenImage, 'Opacity', 1, 2);
  VisibleImage.Visible := false;
end;

end.
