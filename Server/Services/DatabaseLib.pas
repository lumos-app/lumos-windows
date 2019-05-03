unit DatabaseLib;

interface

uses FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, ImageLib, System.Generics.Collections,
  FireDAC.FMXUI.Wait, System.Generics.Defaults, System.DateUtils;

type
  TLumosImageList = class(TObjectList<TLumosImage>)
  public
    function Contains(uuid: String): Boolean;
    function getMaximumViewCount: Integer;

    function firstNotViewed: TLumosImage;
    procedure SortByViewCount;

    function SortByCreateDate: TArray<TLumosImage>;
  end;

  TDatabase = class(TObject)
  private
    class var global: TDatabase;
  public
    class constructor Create;
    class destructor Destroy;
    class function Current: TDatabase;
  private
    fConnection: TFDConnection;
    tbImages: TFDTable;
    FImages: TLumosImageList;
    procedure CreateTable;
    procedure LoadImages;
    procedure SaveViewCount(image: TLumosImage);
  public
    constructor Create;
    destructor Destroy;override;

    procedure Refresh;
    procedure SaveImage(image: TLumosImage);

    function fetchNextImage: TLumosImage;

    property Images: TLumosImageList read FImages;
  end;

implementation

uses
  OptionsLib, System.IOUtils, System.SysUtils, System.Math;

{ TDatabase }

constructor TDatabase.Create;
var
  databaseName: String;
begin
  FImages := TLumosImageList.Create;
  databaseName := TPath.Combine(TServerOptions.Current.DatabasePath, 'images.db');
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

class constructor TDatabase.Create;
begin
  TDatabase.global := nil;
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

class function TDatabase.Current: TDatabase;
begin
  if global = nil then global := TDatabase.Create;
  Result := global;
end;

class destructor TDatabase.Destroy;
begin
  TDatabase.global.Free;
  TDatabase.global := nil;
end;

destructor TDatabase.Destroy;
begin
  FImages.Free;
  tbImages.Free;
  fConnection.Free;
  inherited;
end;

function TDatabase.fetchNextImage: TLumosImage;
var
  firstNotViewed: TLumosImage;
begin
  Result := nil;
  Images.SortByViewCount;
  if Images.Count > 0 then
  begin
    firstNotViewed := Images.firstNotViewed;
    if firstNotViewed <> nil then
    begin
      Result := firstNotViewed;
    end else
    begin
      Result := Images.First;
    end;
    Result.lastViewedDate := Now;
    Result.IncViewCount;
    SaveViewCount(Result);
  end;
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
  tbImages.FieldByName('totalViewCount').AsInteger := image.totalViewCount;
  tbImages.FieldByName('sortViewCount').AsInteger := image.sortViewCount;
  tbImages.FieldByName('show').AsBoolean := true;
  tbImages.Post;
end;

procedure TDatabase.SaveViewCount(image: TLumosImage);
begin
  if tbImages.Locate('uuid', image.Uuid) then
  begin
    tbImages.Edit;
    tbImages.FieldByName('lastViewedDate').AsDateTime := Now;
    tbImages.FieldByName('totalViewCount').AsInteger := image.totalViewCount;
    tbImages.FieldByName('sortViewCount').AsInteger := image.sortViewCount;
    tbImages.Post;
  end;
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

function TLumosImageList.firstNotViewed: TLumosImage;
var
  image: TLumosImage;
begin
  Result := nIl;
  for image in Self do
  begin
    if image.lastViewedDate = 0 then
    begin
      Result := image;
      break;
    end;
  end;
end;

function TLumosImageList.getMaximumViewCount: Integer;
var
  image: TLumosImage;
begin
  Result := 0;
  for image in Self do
  begin
    Result := Max(Result, image.totalViewCount);
  end;
end;

function TLumosImageList.SortByCreateDate: TArray<TLumosImage>;
begin
  Result := Self.ToArray;
  TArray.Sort<TLumosImage>(Result, TComparer<TLumosImage>.Construct(
    function (const item1, item2: TLumosImage): Integer
    begin
      Result := CompareDateTime(item1.createdDate, item2.createdDate)*-1;
    end));
end;

procedure TLumosImageList.SortByViewCount;
begin
  Self.Sort(TComparer<TLumosImage>.Construct(
    function(const item1, item2: TLumosImage): Integer
    begin
      Result := CompareValue(item1.sortViewCount, item2.sortViewCount);
      if Result = 0 then Result := CompareDateTime(item1.lastViewedDate, item2.lastViewedDate);
    end));
end;

end.
