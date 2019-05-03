unit ImageLib;

interface

uses
  System.Classes, System.JSON, Data.DB;

type
  TLumosImage = class(TObject)
  private
    FUuid: String;
    Ffilename: String;
    FuploadedFrom: String;
    FcreatedDate: TDateTime;
    FlastViewedDate: TDateTime;
    FtotalViewCount: Integer;
    FsortViewCount: Integer;
    Fshow: Boolean;
    FIsUpdating: Boolean;
    function getThumbnailFilename: String;
    function getCompleteFileName: String;
  public
    constructor Create;
    destructor Destroy;override;

    procedure Assign(ds: TDataset);
    procedure FromJSON(jsonObj: TJSONObject);
    function ToJSON: TJSONObject;
    procedure IncViewCount;

    property Uuid: String read FUuid;
    property filename: String read Ffilename;
    property uploadedFrom: String read FuploadedFrom;
    property createdDate: TDateTime read FcreatedDate;
    property lastViewedDate: TDateTime read FlastViewedDate write FlastViewedDate;
    property totalViewCount: Integer read FtotalViewCount write FtotalViewCount;
    property sortViewCount: Integer read FsortViewCount write FsortViewCount;
    property show: Boolean read Fshow;

    property CompleteFileName: String read getCompleteFileName;
    property ThumbnailFilename: String read getThumbnailFilename;

    property IsUpdating: Boolean read FIsUpdating write FIsUpdating;
  end;

implementation

uses
  System.NetEncoding, System.SysUtils, OptionsLib, Soap.XSBuiltIns,
  System.IOUtils, System.DateUtils, DateHelperLib;

{ TLumosImage }

procedure TLumosImage.Assign(ds: TDataset);
begin
  FUuid := ds.FieldByName('uuid').AsString;
  Ffilename := ds.FieldByName('filename').AsString;
  FuploadedFrom := ds.FieldByName('uploadedFrom').AsString;
  FcreatedDate := ds.FieldByName('createdDate').AsDateTime;
  FlastViewedDate := ds.FieldByName('lastViewedDate').AsDateTime;
  FtotalViewCount := ds.FieldByName('totalViewCount').AsInteger;
  FsortViewCount := ds.FieldByName('sortViewCount').AsInteger;
  Fshow := ds.FieldByName('show').AsBoolean;
end;

constructor TLumosImage.Create;
begin
  Fshow := true;
  FIsUpdating := false;
end;

destructor TLumosImage.Destroy;
begin
  inherited;
end;

procedure TLumosImage.FromJSON(jsonObj: TJSONObject);
var
  inputStream: TStringStream;
  outputStream: TFileStream;
  imageData: string;
  tmpFileName: string;
begin
  FUuid := jsonObj.Values['uuid'].Value;
  FuploadedFrom := jsonObj.Values['name'].Value;
  imageData := jsonObj.Values['image'].Value;

  inputStream := TStringStream.Create(imageData);
  Ffilename := Uuid+'.jpg';
  tmpFileName := TServerOptions.Current.ImagePath+Uuid+'.jpg';
  outputStream := TFileStream.Create(tmpFileName, fmCreate);
  TNetEncoding.Base64.Decode(inputStream, outputStream);
  inputStream.Free;
  outputStream.Free;
end;

function TLumosImage.getCompleteFileName: String;
begin
  Result := TPath.Combine(TServerOptions.Current.ImagePath, filename);
end;

function TLumosImage.getThumbnailFilename: String;
begin
  Result := TPath.Combine(TServerOptions.Current.ImagePath, 'thumbnails');
  ForceDirectories(Result);
  Result := TPath.Combine(Result, ChangeFileExt(filename, '')+'_thumb.jpg');
end;

procedure TLumosImage.IncViewCount;
begin
  Inc(FtotalViewCount);
  Inc(FsortViewCount);
end;

function TLumosImage.ToJSON: TJSONObject;
var
  base64: TBase64Encoding;
  inputStr: TFileStream;
  outputStr: TStringStream;
begin
  Result := TJSONObject.Create;
  Result.AddPair('uuid', Uuid);
  Result.AddPair('filename', filename);
  Result.AddPair('uploadedFrom', uploadedFrom);
  Result.AddPair('totalViewCount', TJSONNumber.Create(totalViewCount));
  Result.AddPair('show', TJSONBool.Create(show));
  Result.AddPair('createdDate', createdDate.ToISO8601);

  if FileExists(ThumbnailFilename) then
  begin
    inputStr := TFileStream.Create(ThumbnailFilename, fmOpenRead or fmShareDenyWrite);
    outputStr := TStringStream.Create('', TEncoding.UTF8);
    base64 := TBase64Encoding.Create(64, '');
    base64.Encode(inputStr, outputStr);
    Result.AddPair('data', outputStr.DataString);
    inputStr.Free;
    outputStr.Free;
    base64.Free;
  end else
  begin
    Result.AddPair('data', '');
  end;
end;

end.
