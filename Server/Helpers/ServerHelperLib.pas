unit ServerHelperLib;

interface

uses
  IdCustomHTTPServer;

type
  TIdHTTPRequestInfoHelper = class helper for TIdHTTPRequestInfo
    function PostStreamAsString: String;
  end;

implementation

uses
  System.Classes, System.SysUtils;

{ TIdHTTPRequestInfoHelper }

function TIdHTTPRequestInfoHelper.PostStreamAsString: String;
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create('', TEncoding.UTF8);
  strStream.CopyFrom(PostStream, PostStream.Size);
  Result := strStream.DataString;
  strStream.Free;
end;

end.
