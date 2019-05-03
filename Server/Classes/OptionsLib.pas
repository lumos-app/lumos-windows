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
  public
    property ImagePath: String read getImagePath;
  end;

implementation

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

function TServerOptions.getImagePath: String;
begin
  Result := 'C:\temp\bilder\';
end;

end.
