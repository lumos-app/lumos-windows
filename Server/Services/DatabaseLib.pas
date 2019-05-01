unit DatabaseLib;

interface

uses FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, ImageLib, System.Generics.Collections,
  FireDAC.FMXUI.Wait;

type
  TLumosImageList = class(TObjectList<TLumosImage>)
  public
    function Contains(uuid: String): Boolean;
  end;

  TDatabase = class(TObject)
  private
    fConnection: TFDConnection;
    tbImages: TFDTable;
    FImages: TLumosImageList;
    procedure CreateTable;
    procedure LoadImages;
  public
    constructor Create;
    destructor Destroy;override;

    procedure Refresh;
    procedure SaveImage(image: TLumosImage);

    property Images: TLumosImageList read FImages;
  end;

implementation

uses
  OptionsLib, System.IOUtils, System.SysUtils;

{ TDatabase }

constructor TDatabase.Create;
var
  databaseName: String;
begin
  FImages := TLumosImageList.Create;
  databaseName := TPath.Combine(TServerOptions.Current.ImagePath, 'images.db');
  fConnection := TFDConnection.Create(nil);
  fConnection.Params.Add(Format('Database=%s', [databaseName]));
  fConnection.Params.Add('LockingMode=Normal');
  fConnection.Params.Add('DriverID=SQLite');
  fConnection.Open;
  CreateTable;

  tbImages := TFDTable.Create(nil);
  tbImages.Connection := fConnection;
  tbImages.TableName := 'images';
  tbImages.Open;

  LoadImages;
end;

procedure TDatabase.CreateTable;
var
  q: string;
begin
  q := 'Create Table If not exists "images" (' +
       '"uuid" GUID, ' +
       '"filename" Varchar(250),' +
       '"uploadedFrom" Varchar(50),' +
       '"createdDate" DateTime, ' +
       '"lastViewedDate" DateTime,' +
       '"totalViewCount" Integer DEFAULT 0,' +
       '"sortViewCount" Integer DEFAULT 0,' +
       '"show" Boolean DEFAULT true'+
       ');';
  fConnection.ExecSQL(q);
end;

destructor TDatabase.Destroy;
begin
  FImages.Free;
  tbImages.Free;
  fConnection.Free;
  inherited;
end;

procedure TDatabase.LoadImages;
var
  image: TLumosImage;
begin
  FImages.Clear;
  tbImages.First;

  while not tbImages.Eof do
  begin
    image := TLumosImage.Create;
    image.Assign(tbImages);
    FImages.Add(image);
    tbImages.Next;
  end;
end;

procedure TDatabase.Refresh;
var
  image: TLumosImage;
begin
  tbImages.Refresh;
  tbImages.First;

  while not tbImages.Eof do
  begin
    if not FImages.Contains(tbImages.FieldByName('uuid').AsString) then
    begin
      image := TLumosImage.Create;
      image.Assign(tbImages);
      FImages.Add(image);
    end;
    tbImages.Next;
  end;
end;

procedure TDatabase.SaveImage(image: TLumosImage);
begin
  if tbImages.Locate('uuid', image.Uuid) then tbImages.Edit else tbImages.Append;

  tbImages.FieldByName('uuid').AsString := image.Uuid;
  tbImages.FieldByName('filename').AsString := image.Filename;
  tbImages.FieldByName('uploadedFrom').AsString := image.uploadedFrom;
  tbImages.FieldByName('createdDate').AsDateTime := Now;
  tbImages.FieldByName('lastViewedDate').AsDateTime:= 0;
  tbImages.FieldByName('totalViewCount').AsInteger := 0;
  tbImages.FieldByName('sortViewCount').AsInteger := 0;
  tbImages.FieldByName('show').AsBoolean := true;
  tbImages.Post;
end;

{ TLumosImageList }

function TLumosImageList.Contains(uuid: String): Boolean;
var
  image: TLumosImage;
begin
  Result := false;
  for image in Self do
  begin
    if SameText(image.Uuid, uuid) then
    begin
      Result := true;
    end;
  end;
end;

end.
