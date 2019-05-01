unit ImageHelperLib;

interface

uses
  System.Threading, CCR.Exif, ImageLib;

type
  TImageRotation = class(TObject)
  private
    class var global: TImageRotation;
  public
    class function Current: TImageRotation;
  private
    procedure ResetOrientationEvent(Sender: TObject);
  public
    procedure ResetOrientation(image: TLumosImage);
  end;

implementation

uses
  FMX.Graphics, System.SysUtils;

{ TImageRotation }

class function TImageRotation.Current: TImageRotation;
begin
  if global = nil then global := TImageRotation.Create;
  Result := global;
end;

procedure TImageRotation.ResetOrientation(image: TLumosImage);
begin
  TTask.Run(image, ResetOrientationEvent);
end;


procedure TImageRotation.ResetOrientationEvent(Sender: TObject);
var
  filename: string;
  exif: TExifData;
  bmp: TBitmap;
  deg: Integer;
  thumb: TBitmap;
  thumbFilename: string;
begin
  if Sender is TLumosImage then
  begin
    TLumosImage(Sender).IsUpdating := true;
    try
      filename := TLumosImage(Sender).CompleteFileName;
      thumbFilename := TLumosImage(Sender).ThumbnailFilename;

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
      TLumosImage(Sender).IsUpdating := false;
    end;
  end;
end;

end.
