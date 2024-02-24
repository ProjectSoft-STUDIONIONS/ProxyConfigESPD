unit uIPEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls;

type
  TCustomIPEdit = class(TWinControl)
  private
    { Private declarations }
   FIPAddress: DWORD;
   FIPLimits: array [0..3] of word;
   FCurrentField : Integer;
   //procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
   procedure WMGetDlgCode(var Message: TWMGetDlgCode);message WM_GETDLGCODE;
   procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
   //procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
   procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
  protected
   { Protected declarations }
   function GetIP(Index: Integer): Byte;
   procedure SetIP(Index: Integer; Value: Byte);
   function GetMinIP(Index: Integer): Byte;
   procedure SetMinIP(Index: Integer; Value: Byte);
   function GetMaxIP(Index: Integer): Byte;
   procedure SetMaxIP(Index: Integer; Value: Byte);
   function GetIPString: string;
   procedure SetIPString( Value: string );
   function IsBlank: boolean;
   procedure SetCurrentField( Index: Integer );
   //
   procedure CreateParams(var Params: TCreateParams); override;
   procedure CreateWnd; override;
   //procedure KeyDown(var Key: Word; Shift: TShiftState);override;
   function IPDwordToString( dw: DWORD ): string;
   function IPStringToDword( s: string ): DWORD;
  public
    { Public declarations }
   constructor Create(AOwner: TComponent); override;
   property IP[Index: Integer]: byte read GetIP write SetIP;
   property MinIP[Index: Integer]: byte read GetMinIP write SetMinIP;
   property MaxIP[Index: Integer]: byte read GetMaxIP write SetMaxIP;
   property IPString : string read GetIPString write SetIPString;
   property CurrentField : Integer read FCurrentField write SetCurrentField;
   procedure Clear;

  end;

 TIPEdit = class(TCustomIPEdit)
 published
    property Align;
    property Anchors;
    property BorderWidth;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Hint;
    property Constraints;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    { Published declarations }
    property IPString;
 end;

procedure Register;

implementation

uses Vcl.Graphics, commctrl, Vcl.comctrls;

constructor TCustomIPEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIPAddress := 0;
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  Color := clBtnFace;
  Width := 160;
  Height := 25;
  Align := alNone;
  TabStop := True;
end;

procedure TCustomIPEdit.CreateParams(var Params: TCreateParams);
begin
  InitCommonControl(ICC_INTERNET_CLASSES);
  inherited CreateParams(Params);
  CreateSubClass(Params, WC_IPADDRESS);
  with Params do
  begin
    Style := WS_VISIBLE or WS_BORDER or WS_CHILD;
    if NewStyleControls and Ctl3D then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TCustomIPEdit.CreateWnd;
var i: Integer;
begin
 inherited CreateWnd;
 Clear;
{ for i := 0 to 3 do
  begin
   MinIP[i] := 0;
   MaxIP[i] := $FF;
  end;}
 CurrentField := 0;
end;

procedure TCustomIPEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := {Message.Result or} DLGC_WANTTAB;
end;


procedure TCustomIPEdit.CNNotify(var Message: TWMNotify);
begin
  with Message.NMHdr^ do begin
    case Code of
      IPN_FIELDCHANGED :
        begin
          FCurrentField := PNMIPAddress( Message.NMHdr )^.iField;
          {if Assigned(OnIpFieldChange) then
            with PNMIPAdress(Message.NMHdr)^ do begin
               OnIPFieldChange(Self, iField, iValue);}
        end;
    end;
  end;
end;

{procedure TCustomIPEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
 inherited KeyDown( Key, Shift );
 if Key = VK_TAB then
  if ssShift in Shift then
     CurrentField := (CurrentField - 1 + 4) mod 4
    else
     CurrentField := (CurrentField + 1) mod 4;
end;}

{procedure TCustomIPEdit.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  //Msg.Result := Ord(Char(Msg.CharCode) = #9);
end;}

procedure TCustomIPEdit.CMDialogChar(var Message: TCMDialogChar);
begin
 with Message do
   if CharCode = VK_TAB then
    begin
     Message.Result := 0;
     if GetKeyState(VK_SHIFT)<>0 then
      begin
       if (CurrentField=0) then Exit;
       CurrentField := CurrentField - 1;
      end
    else
      begin
       if (CurrentField=3) then Exit;
       CurrentField := CurrentField + 1;
      end;
    Message.Result := 1;
    end //VK_TAB
   else
     inherited;
end;

{procedure TCustomIPEdit.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Focused or Windows.IsChild(Handle, Windows.GetFocus)) and
    (Message.CharCode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then
   begin
    if GetKeyState(VK_SHIFT)<>0 then
     CurrentField := (CurrentField - 1 + 4) mod 4
    else
     CurrentField := (CurrentField + 1) mod 4;
    Message.Result := 1;
   end
 else
  inherited;
end;}


 function TCustomIPEdit.GetIP(Index: Integer): Byte;
 begin
  SendMessage( Handle,IPM_GETADDRESS,0,longint(@FipAddress));
  case Index of
   1 : Result := FIRST_IPADDRESS(FipAddress);
   2 : Result := SECOND_IPADDRESS(FipAddress);
   3 : Result := THIRD_IPADDRESS(FipAddress);
   4 : Result := FOURTH_IPADDRESS(FipAddress);
  else Result := 0;
  end;
 end;

 procedure TCustomIPEdit.SetIP(Index: Integer; Value: Byte);
 begin
  case Index of
   1: FIPAddress := FIPAddress AND $FFFFFF or DWORD(Value) shl 24;
   2: FIPAddress := FIPAddress AND $FF00FFFF or DWORD(Value) shl 16;
   3: FIPAddress := FIPAddress AND $FFFF00FF or DWORD(Value) shl 8;
   4: FIPAddress := FIPAddress AND $FFFFFF00 or DWORD(Value);
   else Exit;
  end;
  SendMessage( Handle, IPM_SETADDRESS, 0, FIPAddress );
 end;

 function TCustomIPEdit.GetMinIP(Index: Integer): Byte;
 begin
  if (Index<0) or (Index>3) then
   Result := 0
  else
   Result := LoByte( FIPLimits[Index] );
 end;

 procedure TCustomIPEdit.SetMinIP(Index: Integer; Value: Byte);
 begin
  if (Index<0) or (Index>3) then Exit;
  FIPLimits[Index] := MAKEIPRANGE( HiByte(FIPLimits[Index]), Value );
  SendMessage( Handle, IPM_SETRANGE, Index, FIPLimits[Index] );
 end;

 function TCustomIPEdit.GetMaxIP(Index: Integer): Byte;
 begin
  if (Index<0) or (Index>3) then
   Result := 0
  else
   Result := HiByte( FIPLimits[Index] );
 end;

 procedure TCustomIPEdit.SetMaxIP(Index: Integer; Value: Byte);
 begin
  if (Index<0) or (Index>3) then Exit;
  FIPLimits[Index] := MAKEIPRANGE( Value, LoByte(FIPLimits[Index]) );
  SendMessage( Handle, IPM_SETRANGE, Index, FIPLimits[Index] );
 end;

 procedure TCustomIPEdit.Clear;
 begin
  SendMessage( Handle, IPM_CLEARADDRESS, 0, 0 );
 end;

 function TCustomIPEdit.IsBlank: boolean;
 begin
  Result:= SendMessage( Handle, IPM_ISBLANK, 0, 0 ) = 0;
 end;

 procedure TCustomIPEdit.SetCurrentField( Index: Integer );
 begin
  if (Index<0) or (Index>3) then Exit;
  FCurrentField := Index;
  SendMessage( Handle, IPM_SETFOCUS, wParam(FCurrentField), 0 );
 end;

 function TCustomIPEdit.IPDwordToString( dw: DWORD ): string;
 begin
   Result := Format('%d.%d.%d.%d',
   [FIRST_IPADDRESS( dw ),
   SECOND_IPADDRESS( dw ),
   THIRD_IPADDRESS( dw ),
   FOURTH_IPADDRESS( dw )]);
 end;

 function TCustomIPEdit.IPStringToDword( s: string ): DWORD;
 var i,j : Integer;
  NewAddr, Part : DWORD;
 begin
 NewAddr := 0;
 try
 i := 0;
  repeat
   j := Pos( '.', s );
   if j<=1 then
    if i<3 then
     Abort
    else
     Part := StrToInt( s )
   else
    Part := StrToInt( Copy( s, 1, j-1 ) );
   if Part>255 then Abort;
   Delete( s, 1, j );
   NewAddr := (NewAddr shl 8) or Part;
   Inc(i);
  until i>3;
  Result := NewAddr;
  //Windows.MessageBox( 0, pChar(IntToHex(FIPAddress, 8 )), '', MB_Ok );
 except
 end;

 end;

 function TCustomIPEdit.GetIPString: string;
 begin
  SendMessage( Handle,IPM_GETADDRESS,0, longint(@FIPAddress) );
  Result := IpDwordToString( FIPAddress );
 end;

 procedure TCustomIPEdit.SetIPString( Value: string );
 begin
  FIPAddress := IPStringToDword( Value );
  SendMessage( Handle, IPM_SETADDRESS, 0, FIPAddress);
 end;

 procedure Register;
 begin
  RegisterComponents('Samples', [TIPEdit]);
 end;

end.
