unit ServerLib;

interface

uses
  System.Generics.Collections, IdContext, IdCustomHTTPServer,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer;

type
  TCommandType = (ctGet, ctPost, ctDelete);
  TOnExecuteEvent = reference to procedure(ARequestInfo: TIdHTTPRequestInfo;
    AResponseInfo: TIdHTTPResponseInfo);

  TLumosServerRoute = class(TObject)
  private
    FCommandType: TCommandType;
    FRoute: String;
    FOnExecute: TOnExecuteEvent;
  public
    property CommandType: TCommandType read FCommandType write FCommandType;
    property Route: String read FRoute write FRoute;
    property OnExecute: TOnExecuteEvent read FOnExecute write FOnExecute;

    function Matches(ARequestInfo: TIdHTTPRequestInfo): Boolean;
  end;

  TLumosServer = class(TObject)
  private
    FRoutes: TObjectList<TLumosServerRoute>;
    FServer: TIdHTTPServer;
    procedure SetUpRoutes;
    procedure ServerOnGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);

    procedure UploadImageRequest(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetSingleImageRequest(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetImagesRequest(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create;
    destructor Destroy;override;
  end;

implementation

uses
  System.SysUtils, System.JSON, ServerHelperLib, ImageLib, System.NetEncoding,
  System.Classes;

{ TLumosServer }

constructor TLumosServer.Create;
begin
  FRoutes := TObjectList<TLumosServerRoute>.Create;
  FServer := TIdHTTPServer.Create(nil);
  FServer.OnCommandGet := ServerOnGet;
  SetUpRoutes;
  FServer.DefaultPort := 8082;
  FServer.Active := true;
end;

destructor TLumosServer.Destroy;
begin
  FRoutes.Free;
  FServer.Free;
  inherited;
end;

procedure TLumosServer.GetImagesRequest(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  jsonObj: TJSONObject;
  imageArray: TJSONArray;
  imageObj: TJSONObject;
  inputStr: TFileStream;
  outputStr: TStringStream;
  sl: TStringList;
  image: TLumosImage;
begin
  jsonObj := TJSONObject.Create;
  jsonObj.AddPair('success', TJSONBool.Create(true));

  imageArray := TJSONArray.Create;

//  imageObj := TJSONObject.Create;
//  imageObj.AddPair('uuid', '76A4C2CA-8548-463E-83A9-D8FFE3FB5D94');
//  imageObj.AddPair('filename', '76A4C2CA-8548-463E-83A9-D8FFE3FB5D94.png');
//  imageObj.AddPair('uploadedFrom', '???');
//  imageObj.AddPair('totalViewCount', TJSONNumber.Create(0));
//  imageObj.AddPair('show', TJSONBool.Create(true));
//  imageObj.AddPair('createdDate', '2019-04-20');

//  inputStr := TFileStream.Create('C:\temp\bilder\thumb.png', fmOpenRead or fmShareDenyWrite);
//  outputStr := TStringStream.Create;
//  TNetEncoding.Base64.Encode(inputStr, outputStr);
//  imageObj.AddPair('data', outputStr.DataString);
//  outputStr.SaveToFile('C:\temp\bilder\debug.txt');
//  inputStr.Free;
//  outputStr.Free;

  image := TLumosImage.Create('76A4C2CA-8548-463E-83A9-D8FFE3FB5D94', 'Test', '');
  imageObj := image.ToJSON;
  image.Free;

  imageArray.Add(imageObj);

  jsonObj.AddPair('images', imageArray);
  AResponseInfo.ContentText := jsonObj.ToJSON;

  sl := TStringList.Create;
  sl.Text := jsonObj.ToJSON;
  sl.SaveToFile('C:\temp\bilder\debug.json');
  sl.Free;

  jsonObj.Free;
end;

procedure TLumosServer.GetSingleImageRequest(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
begin

end;

procedure TLumosServer.ServerOnGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  route: TLumosServerRoute;
  handled: Boolean;
begin
  handled := false;
  for route in FRoutes do
  begin
    if route.Matches(ARequestInfo) then
    begin
      route.OnExecute(ARequestInfo, AResponseInfo);
      handled := true;
      break;
    end;
  end;

  if handled then
  begin
    AResponseInfo.ContentType := 'application/json';
  end else
  begin
    AResponseInfo.ResponseNo := 405;
  end;
end;

procedure TLumosServer.SetUpRoutes;
var
  route: TLumosServerRoute;
begin
  route := TLumosServerRoute.Create;
  route.CommandType := ctGet;
  route.Route := '/api/v1/test';
  route.OnExecute :=
    procedure (ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo)
    var
      jsonObj: TJSONObject;
    begin
      AResponseInfo.ResponseNo := 200;
      jsonObj := TJSONObject.Create(TJSONPair.Create('result', 'success'));
      AResponseInfo.ContentText := jsonObj.ToJSON;
      jsonObj.Free;
    end;
  FRoutes.Add(route);

  route := TLumosServerRoute.Create;
  route.CommandType := ctPost;
  route.Route := '/api/v1/images/upload';
  route.OnExecute := UploadImageRequest;
  FRoutes.Add(route);

  route := TLumosServerRoute.Create;
  route.CommandType := ctGet;
  route.Route := '/api/v1/images';
  route.OnExecute := GetImagesRequest;
  FRoutes.Add(route);
end;

procedure TLumosServer.UploadImageRequest(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  jsonObj: TJSONObject;
  uuid: string;
  name: string;
  image: string;
  lumosImage: TLumosImage;
begin
  try
    jsonObj := TJSONObject.ParseJSONValue(ARequestInfo.PostStreamAsString) as TJSONObject;
    uuid := jsonObj.Values['uuid'].Value;
    name := jsonObj.Values['name'].Value;
    image := jsonObj.Values['image'].Value;
    jsonObj.Free;

    lumosImage := TLumosImage.Create(uuid, name, image);
    lumosImage.Free;

    jsonObj := TJSONObject.Create(TJSONPair.Create('result', 'success'));
    AResponseInfo.ContentText := jsonObj.ToJSON;
    jsonObj.Free;
  except
    on E:Exception do
    begin
      AResponseInfo.ResponseNo := 500;
      jsonObj := TJSONObject.Create(TJSONPair.Create('result', 'failure'));
      AResponseInfo.ContentText := jsonObj.ToJSON;
      jsonObj.Free;
    end;
  end;
end;

{ TLumosServerRoute }

function TLumosServerRoute.Matches(ARequestInfo: TIdHTTPRequestInfo): Boolean;
begin
  Result := false;
  case ARequestInfo.CommandType of
    hcGET: Result := Self.CommandType = ctGet;
    hcPOST: Result := Self.CommandType = ctPost;
    hcDELETE: Result := Self.CommandType = ctDelete;
  end;

  if Result then
  begin
    Result := SameText(ARequestInfo.URI, self.Route);
  end;
end;

end.
