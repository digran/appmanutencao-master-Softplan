unit ClienteServidor;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  System.Threading, Main;
type
  TServidor = class
  private
    FPath: string; // AnsiString;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
  end;
  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: string; //AnsiString;
    FServidor: TServidor;
    function InitDataset: TClientDataset;
  public
  end;
var
  fClienteServidor: TfClienteServidor;
const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max      := QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
//    cds.Append;
    if cds.Active then cds.Close; // fecha o dataset (e libera memória)
    cds.CreateDataset;
    cds.Insert; // insere um novo registro
    TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
    cds.Post;
    ProgressBar.Position := ProgressBar.Position + 1;
    {$REGION Simulação de erro, não alterar}
    if i = (QTD_ARQUIVOS_ENVIAR/2) then
      FServidor.SalvarArquivos(NULL);
    {$ENDREGION}
  end;
//  FServidor.SalvarArquivos(cds.Data);
  try
    FServidor.SalvarArquivos(cds.Data);
    ShowMessage('Arquivo enviado com sucesso!');
  except
    on E: Exception do
       ShowMessage('Erro no envio do arquivo: ' + E.Message);
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
begin
  cds := InitDataset;
  ProgressBar.Max      := QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;

  TParallel.For(0, Pred(QTD_ARQUIVOS_ENVIAR),
            procedure (i: integer)
            begin
              TThread.Queue(TThread.CurrentThread,
                procedure
                begin
                  if cds.Active then cds.Close; // fecha o dataset (e libera memória)
                  cds.CreateDataset;
                  cds.Insert; // insere um novo registro
                  TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
                  cds.Post;
                  ProgressBar.Position := ProgressBar.Position + 1;
                end)
            end);
  try
    FServidor.SalvarArquivos(cds.Data);
    ShowMessage('Arquivo enviado com sucesso!');
  except
    on E: Exception do
       ShowMessage('Erro no envio do arquivo: ' + E.Message);
  end;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max      := QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
//    cds.Append;
    if cds.Active then cds.Close; // fecha o dataset (e libera memória)
    cds.CreateDataset;
    cds.Insert; // insere um novo registro
    TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
    cds.Post;
    ProgressBar.Position := ProgressBar.Position + 1;
  end;
//  FServidor.SalvarArquivos(cds.Data);
  try
    FServidor.SalvarArquivos(cds.Data);
    ShowMessage('Arquivo enviado com sucesso!');
  except
    on E: Exception do
       ShowMessage('Erro no envio do arquivo: ' + E.Message);
  end;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
//  FPath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }
constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    cds := TClientDataset.Create(nil);
    cds.Data := AData;
    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
    begin
      Result := False;
      Exit;
    end;
    {$ENDREGION}
    cds.First;
    while not cds.Eof do
    begin
      FileName := FPath + cds.RecNo.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);
      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;
    Result := True;
  except
//    Result := False;
    raise;
  end;
end;

end.
