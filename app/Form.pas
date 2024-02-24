unit Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ToolWin, Settings, System.UITypes,
  SBPro, Registry, StrUtils, System.Types, System.RegularExpressions,
  System.ImageList, Vcl.ImgList, System.IOUtils, ThreadUnit;

type
  TMainForm = class(TForm)
    ConnectionGroup: TGroupBox;
    Panel1: TPanel;
    ConnectionBtn: TBitBtn;
    ImageList1: TImageList;
    ds: TListBox;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    StatusBar1: TStatusBarPro;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ConnectionBtnClick(Sender: TObject);
    procedure OnEnabledTerminate(Sender: TObject);
    procedure OnDisabledTerminate(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LogApp(S: String; WR: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

const
  CurrentPath = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  SettingPath = 'Software\ProxyConfigApp';
  ProxyOverride = '*.localhost;*.school;*.localschool;*.hostname;<local>';
  ProxyVar = 'http=%ip:port%;https=%ip:port%';

var
  MainForm: TMainForm;
  i: Integer;
  Vers: Boolean;
  Reg: TRegistry;
  RegSetting: TRegistry;
  RegIP: TRegEx;
  RegPort: TRegEx;
  MainCanClose: Boolean;
  Proxy: String;
  MyThread: ExecuteCMD;
  InitialDir: String;
  userDirectory: String;
  logerPath: String;

implementation

{$R *.dfm}

procedure TMainForm.LogApp(S: String; WR: Boolean);
var
  text: string;
begin
  text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > ' + S;
  if Not WR then
    ds.Items.Add(text);
  SendMessage(ds.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TMainForm.ConnectionBtnClick(Sender: TObject);
begin
  ConnectionBtn.Enabled := False;
  if ConnectionBtn.ImageIndex = 1 then
  begin
    MyThread := ExecuteCMD.Create(False);
    MyThread.OnTerminate := OnDisabledTerminate;
  end
  else
  begin
    MyThread := ExecuteCMD.Create(False);
    MyThread.OnTerminate := OnEnabledTerminate;
  end;
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle and not WS_EX_APPWINDOW;
  Params.WndParent := Application.Handle;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ds.Items.Clear;
  userDirectory := TPath.Combine(TPath.GetHomePath, 'ProxyConfig');
  if Not TDirectory.Exists(userDirectory) then
    TDirectory.CreateDirectory(userDirectory);
  TrayIcon1.BalloonTitle := 'Прокси Конфиг';
  TrayIcon1.BalloonHint := '';
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels.Items[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

procedure TMainForm.OnDisabledTerminate(Sender: TObject);
begin
    LogApp('Proxy Отключен', False);
    ConnectionBtn.ImageIndex := 0;
    ConnectionBtn.DisabledImageIndex := 0;
    ConnectionBtn.HotImageIndex := 0;
    ConnectionBtn.PressedImageIndex := 0;
    ConnectionBtn.SelectedImageIndex := 0;
    StatusBar1.Panels.Items[0].ImageIndex := 0;
    ConnectionBtn.Caption := 'Не подключено';
    StatusBar1.Panels.Items[0].Text :=  'Не подключено';
    ConnectionBtn.Enabled := True;
    TrayIcon1.IconIndex := 0;
end;

procedure TMainForm.OnEnabledTerminate(Sender: TObject);
begin
    LogApp('Proxy Подключен', False);
    ConnectionBtn.ImageIndex := 1;
    ConnectionBtn.DisabledImageIndex := 1;
    ConnectionBtn.HotImageIndex := 1;
    ConnectionBtn.PressedImageIndex := 1;
    ConnectionBtn.SelectedImageIndex := 1;
    StatusBar1.Panels.Items[0].ImageIndex := 1;
    ConnectionBtn.Caption := 'Подключено';
    StatusBar1.Panels.Items[0].Text :=  'Подключено';
    ConnectionBtn.Enabled := True;
    TrayIcon1.IconIndex := 1;
end;

procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
  TrayIcon1.BalloonTitle := 'Прокси Конфиг';
  if TrayIcon1.IconIndex = 1 then
  begin
    TrayIcon1.BalloonHint := 'Прокси Включено.';
  end
  else
  begin
    TrayIcon1.BalloonHint := 'Прокси Отключено.';
  end;
  TrayIcon1.ShowBalloonHint;
end;

end.
