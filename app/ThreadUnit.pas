unit ThreadUnit;

interface

uses
  System.Classes,
  ShellApi,
  Windows;

type
  ExecuteCMD = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  Form;

{ *
  ** ��� ������� cmd
  * }
procedure ExecuteWait(const sProgramm: string; const sParams: string = '';
  fHide: Boolean = false);
var
  ShExecInfo: TShellExecuteInfo;
begin
  try
    FillChar(ShExecInfo, sizeof(ShExecInfo), 0);
    with ShExecInfo do
    begin
      cbSize := sizeof(ShExecInfo);
      fMask := SEE_MASK_NOCLOSEPROCESS;
      lpFile := PChar(sProgramm);
      lpParameters := PChar(sParams);
      lpVerb := 'open';
      if (not fHide) then
        nShow := SW_SHOW
      else
        nShow := SW_HIDE
    end;
    if (ShellExecuteEx(@ShExecInfo) and (ShExecInfo.hProcess <> 0)) then
      try
        WaitForSingleObject(ShExecInfo.hProcess, INFINITE)
      finally
        CloseHandle(ShExecInfo.hProcess);
      end;
  finally

  end;
end;

{ ExecuteCMD }

procedure ExecuteCMD.Execute;
begin
  Synchronize(
    procedure
    begin
      // ����� ���� DNS
      MainForm.LogApp('����� ���� DNS', false);
      ExecuteWait('ipconfig.exe', '/flushdns', True);
    end);

  Synchronize(
    procedure
    begin
      // ������� ARP
      MainForm.LogApp('������� ARP', false);
      ExecuteWait('arp.exe', '-d', True);
    end);

  Synchronize(
    procedure
    begin
      // ����� IP �������
      MainForm.LogApp('����� IP �������', false);
      ExecuteWait('ipconfig.exe', '/release', True);
      ExecuteWait('ipconfig.exe', '/renew ', True);
    end);

  Synchronize(
    procedure
    begin
      // ���������� �������
      MainForm.LogApp('���������� �������', false);
      ExecuteWait('RUNDLL32.EXE', 'user32.dll,UpdatePerUserSystemParameters ', True);
    end);

end;

end.
