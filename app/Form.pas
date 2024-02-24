unit Form;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
    Vcl.Buttons, Vcl.ComCtrls, Vcl.ToolWin, System.UITypes,
    SBPro, Registry, StrUtils, System.Types, System.RegularExpressions,
    System.ImageList, Vcl.ImgList, System.IOUtils, ThreadUnit, Vcl.Menus,
    Vcl.XPMan;

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
        PopupMenu1: TPopupMenu;
        N1: TMenuItem;
        PopupMenu2: TPopupMenu;
        ImageList2: TImageList;
        N2: TMenuItem;
        N3: TMenuItem;
        N4: TMenuItem;
        procedure FormCreate(Sender: TObject);
        procedure Timer1Timer(Sender: TObject);
        procedure ConnectionBtnClick(Sender: TObject);
        procedure OnEnabledTerminate(Sender: TObject);
        procedure OnDisabledTerminate(Sender: TObject);
        procedure MenuItem1Click(Sender: TObject);
        procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure TrayIcon1Click(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure PopupMenu2Popup(Sender: TObject);
        procedure N2Click(Sender: TObject);
        function SetProxy: String;
        function WinVerNum: Integer;
    private
        { Private declarations }
    public
        { Public declarations }
        function ReadSetting: String;
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
    MyThread: ExecuteCMD;
    i: Integer;
    Vers: Boolean;
    Reg: TRegistry;
    RegSetting: TRegistry;
    RegIP: TRegEx;
    RegPort: TRegEx;
    MainCanClose: Boolean;
    Proxy: String;
    InitialDir: String;
    userDirectory: String;

implementation

{$R *.dfm}

uses Settings;

function TMainForm.ReadSetting: String;
var
    tProxy: String;
    Values: TStringDynArray;
begin
    RegIP := TRegEx.Create('^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$');
    RegPort := TRegEx.Create('^\d{1,4}$');
    RegSetting := TRegistry.Create;
    RegSetting.RootKey := HKEY_CURRENT_USER;
    RegSetting.OpenKey(SettingPath, true);
    tProxy := RegSetting.ReadString('ProxyServer');
    if tProxy = '' then
    begin
        tProxy := '127.0.0.1:80';
    end;
    Values := SplitString(tProxy, ':');
    { * Если что-то ни так, то приводим к дефолту * }
    if Length(Values) < 1 then
        Values[1] := '80';
    if Not RegIP.IsMatch(Values[0]) then
        Values[0] := '127.0.0.1';
    if Not RegPort.IsMatch(Values[1]) then
        Values[1] := '80';
    tProxy := Values[0] + ':' + Values[1];
    RegSetting.WriteString('ProxyServer', tProxy);
    RegSetting.Free;
    Result := tProxy;
end;


function TMainForm.SetProxy: String;
var
  sProxy: String;
begin
  sProxy := ReadSetting;
  LogApp('Load Config: ' + sProxy, False);
  if WinVerNum >= 62 then
  begin
    // Windows 8 и Старше
    Vers := true;
    Result := sProxy;
  end
  else
  begin
    // Младше Windows 8
    Vers := False;
    Result := StringReplace(ProxyVar, '%ip:port%', sProxy,
      [rfReplaceAll, rfIgnoreCase]);
  end;
end;
{ *
  ** Определение версии Windows
  * }
function TMainForm.WinVerNum: Integer;
var
  ver: TOSVersionInfo;
begin
  ver.dwOSVersionInfoSize := SizeOf(ver);
  if GetVersionEx(ver) then
  begin
    with ver do
      Result := StrToInt(IntToStr(dwMajorVersion) + '' +
        IntToStr(dwMinorVersion));
  end
  else
    Result := 1;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if MainCanClose then
        LogApp('=========  Остановка Программы  ==========', true)
    else
        MainForm.Visible := False;
    CanClose := MainCanClose;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
    ds.Items.Clear;
    userDirectory := TPath.Combine(TPath.GetHomePath, 'ProxyConfig');
    if Not TDirectory.Exists(userDirectory) then
        TDirectory.CreateDirectory(userDirectory);
    MainCanClose := False;
    TrayIcon1.BalloonTitle := 'Прокси Конфиг';
    TrayIcon1.BalloonHint := '';
    ShowMessage(ReadSetting);
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
    inherited;
        Params.ExStyle := Params.ExStyle and not WS_EX_APPWINDOW;
        Params.WndParent := Application.Handle;
end;

procedure TMainForm.LogApp(S: String; WR: Boolean);
var
    text: string;
begin
    text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > ' + S;
    if Not WR then
        ds.Items.Add(text);
    SendMessage(ds.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
    MainForm.Visible := True;
    MainForm.FormStyle := fsStayOnTop;
    MainForm.FormStyle := fsNormal;
    SettingsForm.ShowModal;
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
    if not SettingsForm.Visible then
    begin
      if MainForm.Visible = False then
      begin
          MainForm.Visible := True;
          MainForm.FormStyle := fsStayOnTop;
          MainForm.FormStyle := fsNormal;
      end
      else
      begin
          MainForm.Visible := False;
      end;
    end;
end;

procedure TMainForm.ConnectionBtnClick(Sender: TObject);
begin
    ConnectionBtn.Enabled := False;
    TrayIcon1.PopupMenu := nil;
    StatusBar1.PopupMenu := nil;
    ds.PopupMenu := nil;
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
    TrayIcon1.Animate := True;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
    StatusBar1.Panels.Items[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
    if MainForm.Visible = False then
        MainForm.Visible := True;
    MainForm.FormStyle := fsStayOnTop;
    MainForm.FormStyle := fsNormal;
end;

procedure TMainForm.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if MainForm.Visible = False then
        MainForm.Visible := True;
    MainForm.FormStyle := fsStayOnTop;
    MainForm.FormStyle := fsNormal;
end;

procedure TMainForm.OnDisabledTerminate(Sender: TObject);
begin
    LogApp('Proxy Отключен', False);
    TrayIcon1.Animate := False;
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
    TrayIcon1.PopupMenu := PopupMenu2;
    StatusBar1.PopupMenu := PopupMenu1;
    ds.PopupMenu := PopupMenu1;
end;

procedure TMainForm.OnEnabledTerminate(Sender: TObject);
begin
    LogApp('Proxy Подключен', False);
    TrayIcon1.Animate := False;
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
    TrayIcon1.PopupMenu := PopupMenu2;
    StatusBar1.PopupMenu := PopupMenu1;
    ds.PopupMenu := PopupMenu1;
end;

procedure TMainForm.PopupMenu2Popup(Sender: TObject);
begin
    if not SettingsForm.Showing then
    begin
        N2.Enabled := True;
        N4.Enabled := True;
    end
    else
    begin
        N2.Enabled := False;
        N4.Enabled := False;
    end;
    if MainForm.Visible then
    begin
        N2.Caption := 'Свернуть';
        N2.ImageIndex := 3;
    end
    else
    begin
        N2.Caption := 'Развернуть';
        N2.ImageIndex := 4;
    end;
end;

end.
