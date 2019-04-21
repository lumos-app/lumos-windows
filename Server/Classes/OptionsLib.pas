unit OptionsLib;

interface

type
  TServerOptions = class(TObject)
  private
    class var globalServerOptions: TServerOptions;
  public
    class function Current: TServerOptions;
  private
    function getImagePath: String;
  public
    property ImagePath: String read getImagePath;
  end;

implementation

{ TServerOptions }

class function TServerOptions.Current: TServerOptions;
begin
  if globalServerOptions = nil then globalServerOptions := TServerOptions.Create;
  Result := globalServerOptions;
end;

function TServerOptions.getImagePath: String;
begin
  Result := 'C:\temp\bilder\';
end;

end.
