unit ImageLib;

interface

uses
  System.Classes, System.JSON;

type
  TLumosImage = class(TObject)
  private
    FName: String;
    FUuid: String;
    FImage: TMemoryStream;
    function getFileName: String;
  public
    constructor Create(Uuid, Name, Image: String);
    destructor Destroy;override;

    function ToJSON: TJSONObject;

    property Uuid: String read FUuid;
    property Filename: String read getFileName;
    property Name: String read FName;
    property Image: TMemoryStream read FImage;
  end;

implementation

uses
  System.NetEncoding, System.SysUtils, OptionsLib;

{ TLumosImage }

constructor TLumosImage.Create(Uuid, Name, Image: String);
var
  inputStream: TStringStream;
  outputStream: TFileStream;
  filename: string;
begin
  FImage := TMemoryStream.Create;

  FUuid := Uuid;
  FName := Name;

  inputStream := TStringStream.Create(Image);
  filename := TServerOptions.Current.ImagePath+Uuid+'.png';
  outputStream := TFileStream.Create(filename, fmCreate);
  TNetEncoding.Base64.Decode(inputStream, outputStream);
  inputStream.Free;
  outputStream.Free;
end;

destructor TLumosImage.Destroy;
begin
  FImage.Free;
  inherited;
end;

function TLumosImage.getFileName: String;
begin
  Result := Uuid+'.png';
end;

function TLumosImage.ToJSON: TJSONObject;
var
  base64: TBase64Encoding;
  inputStr: TFileStream;
  outputStr: TStringStream;
begin
  Result := TJSONObject.Create;
  Result.AddPair('uuid', 'Test');
  Result.AddPair('filename', 'Test');
  Result.AddPair('uploadedFrom', 'Dennis');
  Result.AddPair('totalViewCount', TJSONNumber.Create(5));
  Result.AddPair('show', TJSONBool.Create(true));
  Result.AddPair('createdDate', '2019-04-20');
//  Result.AddPair('data', '');

  inputStr := TFileStream.Create('C:\temp\bilder\thumb.png', fmOpenRead or fmShareDenyWrite);
  outputStr := TStringStream.Create;
  base64 := TBase64Encoding.Create(64);
  base64.Encode(inputStr, outputStr);
  Result.AddPair('data', 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGPC/' +
                         'xhBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9YGARc5KB0XV+IAAAAd' +
                         'dEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAF1JREFUGN' +
                         'O9zL0NglAAxPEfdLTs4BZM4DIO4C7OwQg2JoQ9LE1exdlYvBBeZ7jqch9//q1u' +
                         'H4TLzw4d6+ErXMMcXuHWxId3KOETnnXXV6MJpcq2MLaI97CER3N0vr4MkhoXe0rZigAAAABJRU5ErkJggg==');//outputStr.DataString);
  inputStr.Free;
  outputStr.Free;
end;

end.
