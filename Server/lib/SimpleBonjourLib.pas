unit SimpleBonjourLib;

interface

uses
  Deltics.Bonjour.API, System.SysUtils;

type
  TBonjourService = record
    ServiceName: String;
    ServiceType: String;
    ServicePort: Integer;
  end;

  TBonjourPublishService = class(TObject)
  private
    fHandle: TDNSServiceRef;
  public
    constructor Create;
    destructor Destroy;override;

    procedure publishService(serviceInfo: TBonjourService);
  end;

implementation

uses
  Winapi.WinSock;

{ TBonjourPublishService }

constructor TBonjourPublishService.Create;
begin
  fHandle := nil;
end;

destructor TBonjourPublishService.Destroy;
begin
  if Assigned(fHandle) then
  begin
    DNSServiceRefDeallocate(fHandle);
    fHandle := nil;
  end;
  inherited;
end;

procedure TBonjourPublishService.publishService(serviceInfo: TBonjourService);
var
  flags: TDNSServiceFlags;
  pName: AnsiString;
  sType: AnsiString;
  fPort: Word;
begin
  flags := 0;
  pName := AnsiString(serviceInfo.ServiceName);
  sType := AnsiString(serviceInfo.ServiceType);
  fPort := serviceInfo.ServicePort;
  DNSServiceRegister(fHandle,
                     flags,
                     0   { interfaceID - register on all interfaces },
                     PAnsiChar(pName),
                     PUTF8Char(sType),
                     NIL { domain - register in all available },
                     NIL { hostname - use default },
                     htons(fPort),
                     0   { txtLen },
                     nil, { txtRecord }
                     nil,
                     self);
end;

end.
