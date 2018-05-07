unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.StdCtrls,
  FMX.Objects, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Controls.Presentation,
  REST.Types,System.JSON, System.UIConsts;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Memo1: TMemo;
    Edit4: TEdit;
    Image1: TImage;
    Button1: TButton;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    IdHTTP1: TIdHTTP;
    procedure Button1Click(Sender: TObject);
    procedure RESTRequest1AfterExecute(Sender: TCustomRESTRequest);
  private
    { private 宣言 }
  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  RESTRequest1.ResetToDefaults;
  RESTClient1.ResetToDefaults;
  RESTResponse1.ResetToDefaults;

  RESTClient1.BaseURL := 'https://www.googleapis.com/';
  RESTRequest1.Resource := 'books/v1/volumes?q=isbn:{ISBN}';
  RESTRequest1.Params.AddItem('ISBN', Edit1.Text, TRESTRequestParameterKind.pkURLSEGMENT);
  RESTRequest1.Execute;
end;

procedure TForm1.RESTRequest1AfterExecute(Sender: TCustomRESTRequest);
var
  BookInfo : TJSONValue;
  BookItems : TJSONArray;
  Authors : TJSONArray;
  ThumbnailURL : string;
  ItemCount : integer;
  i : Integer;
  ImageStream : TMemoryStream;
begin
  BookInfo := RESTResponse1.JSONValue;

  // 項目をクリア
  Edit2.Text := '';
  Edit3.Text := '';
  Memo1.Text := '';
  Edit4.Text := '';
  Image1.Bitmap.Clear(claWhite);

  // アイテム数取得
  ItemCount := BookInfo.GetValue<Integer>('totalItems');

  if ItemCount > 0 then
  begin
    // 結果をパースする。
    BookItems := BookInfo.GetValue<TJSONArray>('items');
    with BookItems.Items[0] do
    begin
      // 題名
      Edit2.Text := GetValue<String>('volumeInfo.title');

      // 副題
      Edit3.Text := GetValue<String>('volumeInfo.subtitle');

      // 著者
      Authors := GetValue<TJSONArray>('volumeInfo.authors');
      for I := 0 to Authors.Count - 1 do
      begin
        Memo1.Lines.Add(Authors.Items[i].GetValue<String>());
      end;

      // 出版日
      Edit4.Text := GetValue<String>('volumeInfo.publishedDate');

      // 書影のサムネイル
      ThumbnailURL := GetValue<String>('volumeInfo.imageLinks.thumbnail');
      ImageStream := TMemoryStream.Create;
      IdHTTP1.Get(ThumbnailURL, ImageStream);
      Image1.Bitmap.LoadFromStream(ImageStream);
    end;
  end;
end;

end.
