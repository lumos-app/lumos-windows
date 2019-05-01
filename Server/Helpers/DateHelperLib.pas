unit DateHelperLib;

interface

uses
  System.SysUtils;

type
  TDateTimeHelper = record helper for TDateTime
  public
    function ToISO8601: String;
  end;

implementation

{ TDateTimeHelper }

function TDateTimeHelper.ToISO8601: String;
begin
  Result := FormatDateTime('yyyy''-''mm''-''dd''T''hh'':''nn'':''ss''Z''', Self);
end;

end.
