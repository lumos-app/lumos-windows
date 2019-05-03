unit ServerLib;

interface

uses
  System.Generics.Collections, IdContext, IdCustomHTTPServer,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer, DatabaseLib,
  SimpleBonjourLib;

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
    FBonjourService: TBonjourPublishService;

    FRoutes: TObjectList<TLumosServerRoute>;
    FServer: TIdHTTPServer;
    procedure SetUpRoutes;
    procedure ServerOnGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);

    procedure UploadImageRequest(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetImagesRequest(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

    procedure PublishBonjourService;
  public
    constructor Create;
    destructor Destroy;override;
  end;

implementation

uses
  System.SysUtils, System.JSON, ServerHelperLib, ImageLib, System.NetEncoding,
  System.Classes, ImageHelperLib;

{ TLumosServer }

constructor TLumosServer.Create;
begin
  FRoutes := TObjectList<TLumosServerRoute>.Create;
  FServer := TIdHTTPServer.Create(nil);
  FServer.OnCommandGet := ServerOnGet;
  SetUpRoutes;
  FServer.DefaultPort := 8082;
  FServer.Active := true;

  FBonjourService := TBonjourPublishService.Create;
  PublishBonjourService;
end;

destructor TLumosServer.Destroy;
begin
  FRoutes.Free;
  FServer.Free;
  FBonjourService.Free;
  inherited;
end;

procedure TLumosServer.GetImagesRequest(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  jsonObj: TJSONObject;
  imageArray: TJSONArray;
  imageObj: TJSONObject;
  image: TLumosImage;
begin
  jsonObj := TJSONObject.Create;
  jsonObj.AddPair('success', TJSONBool.Create(true));

  imageArray := TJSONArray.Create;

  for image in TDatabase.Current.Images.SortByCreateDate do
  begin
    imageObj := image.ToJSON;
    imageArray.Add(imageObj);
  end;

  jsonObj.AddPair('images', imageArray);
  AResponseInfo.ContentText := jsonObj.ToJSON;

  jsonObj.Free;
end;

procedure TLumosServer.PublishBonjourService;
var
  serviceInfo: TBonjourService;
begin
  serviceInfo.ServiceName := 'Lumos Windows Server';
  serviceInfo.ServiceType := '_lumos._tcp';
  serviceInfo.ServicePort := 8082;

  FBonjourService.publishService(serviceInfo);
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
  lumosImage: TLumosImage;
begin
  try
    jsonObj := TJSONObject.ParseJSONValue(ARequestInfo.PostStreamAsString) as TJSONObject;

    lumosImage := TLumosImage.Create;
    lumosImage.FromJSON(jsonObj);
    lumosImage.sortViewCount := TDatabase.Current.Images.getMaximumViewCount;
    TDatabase.Current.SaveImage(lumosImage);
    TDatabase.Current.Images.Add(lumosImage);

    TImageHelper.CreateThumbnailAsync(lumosImage);

    jsonObj.Free;

    jsonObj := TJSONObject.Create(TJSONPair.Create('result', 'success'));
    AResponseInfo.ContentText := jsonObj.ToJSON;
    AResponseInfo.ResponseNo := 200;
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
