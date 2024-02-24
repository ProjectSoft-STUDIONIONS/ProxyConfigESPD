{------------------------------------------------------------------------------}
{                                                                              }
{  TStatusBarPro v1.80                                                         }
{  by Kambiz R. Khojasteh                                                      }
{                                                                              }
{  kambiz@delphiarea.com                                                       }
{  http://www.delphiarea.com                                                   }
{                                                                              }
{------------------------------------------------------------------------------}

{$I DELPHIAREA.INC}

unit SBProReg;

interface

uses
  Windows, Classes,
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors {$ELSE} DsgnIntf {$ENDIF};

type
  TStatusBarProEditor = class(TDefaultEditor)
  protected
    {$IFNDEF COMPILER6_UP}
    procedure PanelsEditor(Prop: TPropertyEditor);
    {$ENDIF}
  public
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
    {$IFDEF COMPILER6_UP}
    procedure EditProperty(const Prop: IProperty; var Continue: Boolean); override;
    {$ELSE}
    procedure Edit; override;
    {$ENDIF}
  end;

procedure Register;

implementation

uses
  SBPro, TypInfo;

function TStatusBarProEditor.GetVerbCount: Integer;
begin
  Result:= 1;
end;

function TStatusBarProEditor.GetVerb(Index: Integer): string;
begin
  if Index = 0 then
    Result := 'Panels Editor...'
  else
    Result := inherited GetVerb(Index);
end;

procedure TStatusBarProEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 0 then
    Edit
  else
    inherited ExecuteVerb(Index);
end;

{$IFDEF COMPILER6_UP}

procedure TStatusBarProEditor.EditProperty(const Prop: IProperty;
  var Continue: Boolean);
begin
  if Prop.GetName = 'Panels' then
  begin
    Prop.Edit;
    Continue := False;
  end;
end;

{$ELSE}

procedure TStatusBarProEditor.PanelsEditor(Prop: TPropertyEditor);
begin
  if Prop.GetName = 'Panels' then
    Prop.Edit;
end;

procedure TStatusBarProEditor.Edit;
var
  {$IFDEF COMPILER5_UP}
  List: TDesignerSelectionList;
  {$ELSE}
  List: TComponentList;
  {$ENDIF}
begin
  {$IFDEF COMPILER5_UP}
  List := TDesignerSelectionList.Create;
  {$ELSE}
  List := TComponentList.Create;
  {$ENDIF}
  try
    List.Add(Component);
    GetComponentProperties(List, [tkClass], Designer, PanelsEditor);
  finally
    List.Free;
  end;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents('Delphi Area', [TStatusBarPro]);
  RegisterComponentEditor(TStatusBarPro, TStatusBarProEditor);
end;

end.
