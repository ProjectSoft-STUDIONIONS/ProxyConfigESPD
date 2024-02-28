program Proxy;

uses
  Vcl.Forms,
  Form in 'Form.pas' {MainForm} ,
  Settings in 'Settings.pas' {SettingsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.Run;

end.
