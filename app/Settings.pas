unit Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, IniFiles, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox, uIPEdit,
  Vcl.Buttons, Registry, System.Types, StrUtils, System.RegularExpressions,
  Vcl.ExtCtrls;

type
  TSettingsForm = class(TForm)
    GroupBox1: TGroupBox;
    Port: TEdit;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    IpAdress: TIPEdit;
    ComboBox1: TComboBox;
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure LoadLangs;
    procedure WriteLangs;
    procedure ComboBox1Change(Sender: TObject);
    procedure PortExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
    SettingsForm: TSettingsForm;
    Reg: TRegistry;
    RegIP: TRegEx;
    RegPort: TRegEx;
    tmpProxy: String;
    Values: TStringDynArray;

implementation

{$R *.dfm}

uses Form;

{ TForm1 }

procedure TSettingsForm.BitBtn1Click(Sender: TObject);
begin
    if StrToInt(Port.Text) = 1 then
        Port.Text := '80';
    RegIP := TRegEx.Create('^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$');
    RegPort := TRegEx.Create('^\d{1,4}$');
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey(CurrentPath, true);
    Reg.WriteString('ProxyServer', IpAdress.IPString + ':' + Port.Text);
    Reg.Free;
    WriteLangs;

end;

procedure TSettingsForm.LoadLangs;
var
    ini: TIniFile;
    i: Integer;
    str: String;
    list: TStringList;
begin
    Label1.Caption := LangStr;
    list := TStringList.Create;
    ini := TIniFile.Create(TPath.Combine(userDirectory, 'Language.ini'));
    Label1.Caption := LangStr;
    Caption := N4Caption;
    GroupBox1.Caption := Caption;
    ini.ReadSections(list);
    ini.Free;
    ComboBox1.Clear;
    for i := 0 to list.Count - 1 do
    begin
        str := list.Strings[i];
        if AnsiCompareStr(str, 'Language') <> 0 then
        begin
            ComboBox1.Items.Add(str);
            if AnsiCompareStr(str, Lang) = 0 then
            begin
                ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(str);
            end;
        end;
    end;
end;

procedure TSettingsForm.PortExit(Sender: TObject);
begin
    if StrToInt(Port.Text) <= 0 then
       Port.Text := '80';
end;

procedure TSettingsForm.WriteLangs;
var
    ini: TIniFile;
begin
    ini := TIniFile.Create(TPath.Combine(userDirectory, 'Language.ini'));
    ini.WriteString('Language', 'lang', ComboBox1.Text);
    ini.Free;
end;

procedure TSettingsForm.ComboBox1Change(Sender: TObject);
var
    ini: TIniFile;
    lng: String;
begin
    ini := TIniFile.Create(TPath.Combine(userDirectory, 'Language.ini'));
    lng := ComboBox1.Text;
    Caption := ini.ReadString(lng, 'N4Caption', 'Ќастройки');
    GroupBox1.Caption := Caption;
    Label1.Caption := ini.ReadString(lng, 'LangStr', 'язык');
    ini.Free;
end;

procedure TSettingsForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
    Params.ExStyle := Params.ExStyle and not WS_EX_APPWINDOW;
    Params.WndParent := Application.Handle;
end;

procedure TSettingsForm.FormShow(Sender: TObject);
begin
    // ShowMessage(MainForm.ReadSetting);
    // Port.ValueInt;
    RegIP := TRegEx.Create('^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$');
    RegPort := TRegEx.Create('^\d{1,4}$');
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey(CurrentPath, true);
    tmpProxy := Reg.ReadString('ProxyServer');
    ShowMessage(tmpProxy);
    if tmpProxy = '' then
    begin
        tmpProxy := '127.0.0.1:80';
        Reg.WriteString('ProxyServer', tmpProxy);
    end;
    Values := SplitString(tmpProxy, ':');
    if Length(Values) < 2 then
        Values[1] := '80';
    if Not RegIP.IsMatch(Values[0]) then
        Values[0] := '127.0.0.1';
    if Not RegPort.IsMatch(Values[1]) then
        Values[1] := '80';
    if IpAdress.IPStringToDword(Values[0]) <= 0 then
        Values[0] := '127.0.0.1';
    if StrToInt(Values[1]) <= 0 then
        Values[1] := '80';
    Reg.WriteString('ProxyServer', Values[0] + ':' + Values[1]);
    IpAdress.IPString := Values[0];
    Port.Text := Values[1];
    Reg.Free;
    LoadLangs;
end;

end.
