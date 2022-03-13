unit Main;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.AppEvnts, System.UITypes;
type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    ApplicationEvents: TApplicationEvents;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure btThreadsClick(Sender: TObject);
  private
  public
  end;
var
  fMain: TfMain;
implementation
uses
  DatasetLoop, ClienteServidor, Threads;
{$R *.dfm}

procedure TfMain.ApplicationEventsException(Sender: TObject; E: Exception);
var
  CaminhoArquivoLog: string;
  ArquivoLog: TextFile;
  DataHora: string;
  StringBuilder: TStringBuilder;
begin
  CaminhoArquivoLog := GetCurrentDir + '\LogExcecoes.txt';

  AssignFile(ArquivoLog, CaminhoArquivoLog);

  if FileExists(CaminhoArquivoLog) then
    Append(ArquivoLog)
  else
    ReWrite(ArquivoLog);

  DataHora := FormatDateTime('dd-mm-yyyy_hh-nn-ss', Now);

  WriteLn(ArquivoLog, 'Data/Hora.......: ' + DateTimeToStr(Now));
  WriteLn(ArquivoLog, 'Mensagem........: ' + E.Message);
  WriteLn(ArquivoLog, 'Classe Exceção..: ' + E.ClassName);
  WriteLn(ArquivoLog, 'Formulário......: ' + Screen.ActiveForm.Name);
  WriteLn(ArquivoLog, 'Unit............: ' + Sender.UnitName);
  WriteLn(ArquivoLog, 'Controle Visual.: ' + Screen.ActiveControl.Name);
  WriteLn(ArquivoLog, StringOfChar('-', 70));

  CloseFile(ArquivoLog);

  StringBuilder := TStringBuilder.Create;
  try
     StringBuilder
      .AppendLine('Ocorreu um erro na aplicação.')
      .AppendLine('O problema será analisado pelos desenvolvedores.')
      .AppendLine(EmptyStr)
      .AppendLine('Descrição técnica:')
      .AppendLine(E.Message);

    MessageDlg(StringBuilder.ToString, mtWarning, [mbOK], 0);
  finally
    StringBuilder.Free;
  end;
end;

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  fThreads.Show;
end;

end.
