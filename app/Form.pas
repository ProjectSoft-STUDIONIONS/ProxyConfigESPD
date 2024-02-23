unit Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.ComCtrls, Vcl.ToolWin, Settings;

type
  TMainForm = class(TForm)
    ConnectionGroup: TGroupBox;
    Panel1: TPanel;
    ConnectionBtn: TBitBtn;
    ImageList1: TImageList;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ConnectionBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.ConnectionBtnClick(Sender: TObject);
begin
  SettingsForm.ShowModal;
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle and not WS_EX_APPWINDOW;
  Params.WndParent := Application.Handle;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ListBox1.Items.Clear;
end;

end.
