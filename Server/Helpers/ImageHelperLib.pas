unit ImageHelperLib;

interface

uses
  System.Threading, CCR.Exif, ImageLib, FMX.Graphics, System.Types;

type
  TAspectRatio = (AspectFit, AspectFill);

  TAspectRatioHelper = record helper for TAspectRatio
    function AspectRatio(newSize, size: TRectF): Double;
  end;

  TBitmapHelper = class helper for TBitmap
  public
    function IsLandscape: Boolean;
  end;

  TImageHelper = class(TObject)
  private
    class function InternalCreateThumbnail(bmp: TBitmap; size: TSizeF; ratio: TAspectRatio): TBitmap;
    class function getScaledRect(newSize, size: TRectF; AspectRatio: TAspectRatio): TRectF;
  public
    class procedure CreateThumbnailSync(image: TLumosImage);
    class procedure CreateThumbnailAsync(image: TLumosImage);

    class function getAspectBitmap(bmp: TBitmap; size: TSizeF; ratio: TAspectRatio): TBitmap;
  end;

implementation

uses
  System.SysUtils, System.UITypes, System.Math, System.Classes;

{ TImageRotation }

class procedure TImageHelper.CreateThumbnailSync(image: TLumosImage);
var
  filename: string;
  exif: TExifData;
  bmp: TBitmap;
  deg: Integer;
  thumb: TBitmap;
  thumbFilename: string;
begin
  image.IsUpdating := true;
  try
    filename := image.CompleteFileName;
    thumbFilename := image.ThumbnailFilename;

    exif := TExifData.Create;
    exif.LoadFromGraphic(filename);
    case exif.Orientation of
      toBottomRight: deg := 180;
      toRightTop: deg := 90;
      toLeftBottom: deg := 270;
      else deg := 0;
    end;
    exif.Free;

    bmp := TBitmap.Create;
    bmp.LoadFromFile(filename);
    if deg <> 0 then
    begin
      bmp.Rotate(deg);
      bmp.SaveToFile(filename);
    end;
    thumb := InternalCreateThumbnail(bmp, TSize.Create(200, 200), TAspectRatio.AspectFill);
    thumb.SaveToFile(thumbFilename);
    thumb.Free;
    bmp.Free;
  finally
    image.IsUpdating := false;
  end;
end;

class procedure TImageHelper.CreateThumbnailAsync(image: TLumosImage);
begin
  TTask.Run(
    procedure
    begin
      TImageHelper.CreateThumbnailSync(image);
    end);
end;

class function TImageHelper.getAspectBitmap(bmp: TBitmap; size: TSizeF; ratio: TAspectRatio): TBitmap;
begin
  Result := InternalCreateThumbnail(bmp, size, ratio);
end;

class function TImageHelper.getScaledRect(newSize, size: TRectF; AspectRatio: TAspectRatio): TRectF;
var
  newX: Single;
  newY: Single;
  ratio: Double;
begin
  ratio := AspectRatio.AspectRatio(newSize, size);
  Result := TRect.Empty;
  Result.Width := size.Width * ratio;
  Result.Height := size.Height * ratio;

  newX := (newSize.Width - size.Width * ratio) / 2;
  newY := (newSize.Height - size.Height * ratio) / 2;
  Result.SetLocation(newX, newY);
end;

class function TImageHelper.InternalCreateThumbnail(bmp: TBitmap; size: TSizeF; ratio: TAspectRatio): TBitmap;
var
  FitRect: TRectF;
begin
  TMonitor.Enter(bmp);
  try
    Result := TBitmap.Create(Trunc(size.Width), Trunc(size.Height));
    Result.Clear(TAlphaColorRec.Black);
    if Result.Canvas.BeginScene then
    begin
      try
        FitRect := getScaledRect(TRectF.Create(0, 0, size.Width, size.Height), TRectF.Create(0, 0, bmp.Width, bmp.Height), ratio);
        Result.Canvas.DrawBitmap(bmp, TRectF.Create(0, 0, bmp.Width, bmp.Height), FitRect, 1);
      finally
        Result.Canvas.EndScene;
      end;
    end;
  finally
    TMonitor.Exit(bmp);
  end;
end;

{ TAspectRatioHelper }

function TAspectRatioHelper.AspectRatio(newSize, size: TRectF): Double;
var
  aspectWidth: Double;
  aspectHeight: Double;
begin
  aspectWidth := newSize.Width / size.Width;
  aspectHeight := newSize.Height / size.Height;
  case Self of
    AspectFit: Result := Min(aspectWidth, aspectHeight);
    AspectFill: Result := Max(aspectWidth, aspectHeight);
    else Result := 1;
  end;
end;

{ TBitmapHelper }

function TBitmapHelper.IsLandscape: Boolean;
begin
  Result := Self.Width > self.Height;
end;

end.
