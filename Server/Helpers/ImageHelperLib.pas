unit ImageHelperLib;

interface

uses
  System.Threading, CCR.Exif, ImageLib;

type
  TImageRotation = class(TObject)
  public
    class procedure CreateThumbnail(image: TLumosImage);
  end;

implementation

uses
  FMX.Graphics, System.SysUtils;

{ TImageRotation }

class procedure TImageRotation.CreateThumbnail(image: TLumosImage);
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
    thumb := bmp.CreateThumbnail(200, 200);
    thumb.SaveToFile(thumbFilename);
    thumb.Free;
    bmp.Free;
  finally
    image.IsUpdating := false;
  end;
end;

end.
