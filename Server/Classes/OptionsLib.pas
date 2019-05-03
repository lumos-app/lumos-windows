unit OptionsLib;

interface

type
  TServerOptions = class(TObject)
  private
    class var globalServerOptions: TServerOptions;
  public
    class constructor Create;
    class destructor Destroy;
    class function Current: TServerOptions;
  private
    function getImagePath: String;
    function getDatabasePath: String;
  public
    property ImagePath: String read getImagePath;
    property DatabasePath: String read getDatabasePath;
  end;

implementation

uses
  System.IOUtils, System.SysUtils;

{ TServerOptions }

class constructor TServerOptions.Create;
begin
  TServerOptions.globalServerOptions := nil;
end;

class function TServerOptions.Current: TServerOptions;
begin
  if globalServerOptions = nil then globalServerOptions := TServerOptions.Create;
  Result := globalServerOptions;
end;

class destructor TServerOptions.Destroy;
begin
  TServerOptions.globalServerOptions.Free;
  TServerOptions.globalServerOptions := nil;
end;

function TServerOptions.getDatabasePath: String;
begin
  Result := TPath.Combine(TPath.GetDownloadsPath, 'Lumos');
  TDirectory.CreateDirectory(Result);
end;

function TServerOptions.getImagePath: String;
begin
  Result := TPath.Combine(TPath.GetPicturesPath, 'Lumos');
  TDirectory.CreateDirectory(Result);
  Result := IncludeTrailingPathDelimiter(Result);
end;

end.
