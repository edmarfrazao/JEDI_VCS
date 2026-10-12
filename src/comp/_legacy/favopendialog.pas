{ History:
  REM this version is JVCS related, no bugfixes or new features, only removed
      hints and warnings.
  2006/01/22  THuber  - hints/warnings fixed
}
unit FavOpenDialog;

{ TODO -oFL : Unit to be review for LCL implementation }

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs,buttons,extctrls,stdctrls,commdlg,registry {$ifdef VCL}, Dlgs{$endif};


type
  TFavOpenDialog = class(TOpenDialog)
  private
    { Private-Deklarationen }
    fpanel : tpanel;
    fbutton : tbutton;
    fcombo     : tcombobox;
    flabel     : tlabel;

//+++++++++++++++++++++++++++++
//    fcheck  : tcheckbox;
//+++++++++++++++++++++++++++++

    fmaxcount : integer;

    fshowfullpath : boolean;
    fsetinitdir : boolean;

    fstrings : tstrings;
    fassociated : tfavopendialog;
    procedure fbuttonclick(sender:tobject);
    procedure fcomboclick(sender:tobject);
    procedure addfavorite(sr:tstrings;val:string;insert:boolean);
    function getfolderpath:string;
  protected
    { Protected-Deklarationen }
    procedure notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoClose; override;
    procedure DoShow; override;
    procedure DoFolderChange; override;
    procedure setshowfullpath(val:boolean);
    procedure setstring(index:integer;val:string);
    function getstring(index:integer):string;
    procedure SetFavorites(index:integer;value : tstrings);
    procedure setfassociated(value : tfavopendialog);
    function TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool; {override;}
  public

    { Public-Deklarationen }
    constructor create(aowner:tcomponent); override;
    destructor Destroy; override;
    function Execute: Boolean; override;
    procedure FavToRegistry(Rootkey:HKEY;Key:string);
    procedure FavFromRegistry (Rootkey:HKEY;Key:string);
  published
    { Published-Deklarationen }
    property MaxCount : integer read fmaxcount write fmaxcount;
    property ShowFullPath : boolean read fshowfullpath write setshowfullpath;
    property ComboHint : string index 1 read getstring
             write setstring ;
    property ButtonHint : string index 2 read getstring
             write setstring ;
    property LabelCaption : string index 3 read getstring
             write setstring ;
    property Favorites : tstrings index 1 read fstrings write setfavorites;
    property Associated : tfavopendialog read fassociated write setfassociated;
    property SetInitDirFrom1st : boolean read fsetinitdir write fsetinitdir;

  end;

  TFavSaveDialog = class(TfavOpenDialog)
    function Execute: Boolean; override;
  end;

procedure Register;

implementation

uses filectrl,shellapi,commctrl;

{$r myfdlg.res}

procedure Register;
begin
  RegisterComponents('Merkes'' Dialogs', [TFavOpenDialog,TFavSaveDialog]);
end;

constructor TFavOpenDialog.create(aowner:tcomponent);
begin
  inherited create(aowner);
  FPanel := TPanel.Create(Self);
  fmaxcount := 10;
  fshowfullpath := false;
  fstrings := tstringlist.create;
  fassociated := nil;
  with FPanel do
  begin
    Name := 'clientPanel';
    Caption := '';
    BevelOuter := bvnone;
    BorderWidth := 0;
    TabOrder := 1;
    Fcombo := Tcombobox.Create(Self);
    with Fcombo do
    begin
      Name := 'favcombo';
      Parent := FPanel;
      TabOrder := 0;
      Anchors := [akLeft,akTop,akRight];
      Hint := '';
      parentshowhint := false;
      showhint := true;
      OnClick := fcomboClick;
    end;
    Fbutton := TButton.Create(Self);
    with FButton do
    begin
      Name := 'addfavButton';
      Enabled := true;
      caption := '&Add to MRU';
      TabOrder := 1;
      Anchors := [akTop,akRight];
      Hint := '';
      ParentShowHint := False;
      ShowHint := True;
      OnClick := fbuttonClick;
      Parent := FPanel;
    end;
    Flabel := Tlabel.Create(Self);
    with Flabel do
    begin
      Name := 'favorites';
      caption := 'MRU folders:';
      transparent := true;
      focuscontrol := fcombo;
      ParentShowHint := False;
      ShowHint := false;
      Parent := FPanel;
    end;
  end;
end;

destructor tfavopendialog.Destroy;
begin
  FButton.Free;
  Fcombo.Free;
  flabel.free;
  FPanel.Free;
  fstrings.free;
  inherited Destroy;
end;

function tfavopendialog.Execute: Boolean;
begin
  {$ifdef VCL}                   // dedicated VCL/Windows feature
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'MYDLGO' else
    Template := nil;
  {$endif}
  if fsetinitdir then if fstrings.count > 0 then initialdir := fstrings[0];
  Result := inherited execute;
end;

procedure TfavopenDialog.DoClose;
begin
  inherited DoClose;
  { Hide any hint windows left behind }
  Application.HideHint;
  fstrings.assign(fcombo.items);
  if assigned(fassociated) then fassociated.setfavorites(0,fstrings);
end;

procedure TfavopenDialog.DoShow;
var
  PreviewRect: TRect;
  fh : integer;
begin
  // Set preview area to entire dialog
  GetClientRect(Handle, PreviewRect);
  // Move preview area to right of static area
  //PreviewRect.top := GetStaticRect.bottom;
  // Panel
  FPanel.BoundsRect := PreviewRect;
  FPanel.ParentWindow := Handle;
  // Button
  fh := (fpanel.clientHeight-25) div 2;
  FButton.setbounds(Round(PreviewRect.Right * 0.795),fh,
                    Round(PreviewRect.Right * 0.175),25);
  // ComboBox
  fh := (fpanel.clientHeight-fcombo.height) div 2;
  fcombo.setbounds(Round(PreviewRect.Right * 0.195),fh,
                   Round(PreviewRect.Right * 0.55),fcombo.height);
  // Label
  fh := (fpanel.clientHeight-flabel.height) div 2;
  Flabel.setbounds(8,fh,flabel.width,flabel.height);

  // Set preview area to entire dialog
{  GetClientRect(Handle, PreviewRect);
  // Move preview area to right of static area
  PreviewRect.top := GetStaticRect.bottom;
  FPanel.BoundsRect := PreviewRect;
  FPanel.ParentWindow := Handle;
  fh := (fpanel.clientHeight-25) div 2;
  FButton.setbounds(333,fh,75,25);
  fh := (fpanel.clientHeight-fcombo.height) div 2;
  fcombo.setbounds(80,fh,235,fcombo.height);
  fh := (fpanel.clientHeight-flabel.height) div 2;
  Flabel.setbounds(8,fh,flabel.width,flabel.height);}

  inherited DoShow;
  if assigned(fassociated) then setfavorites(0,fassociated.favorites);
  fcombo.items.assign(fstrings);
  fcombo.itemindex := 0;
end;

procedure tfavopendialog.setfavorites(index:integer;value:tstrings);
var ct : integer;
    max : integer;
begin
     fstrings.clear;
     max := value.count -1;
     if max > fmaxcount then max := fmaxcount -1;
     if value.count > 0 then for ct := 0 to max do
        addfavorite(fstrings,value[ct],false);
     if index = 1 then if assigned(fassociated) then fassociated.setfavorites(0,fstrings);
end;

procedure tfavopendialog.addfavorite(sr:tstrings;val:string;insert:boolean);
var ct : integer;
begin
     if val = '' then exit;
     if val[length(val)] = '\' then
        val := copy(val,1,length(val)-1);
     // überprüfen, ob schon vorhanden
     if sr.count > 0 then
     for ct := 0 to sr.count-1 do begin
        if lstrcmpi(pchar(sr[ct]),pchar(val)) = 0 then begin
           sr.delete(ct);
           break;
        end;
     end;
     while sr.count >= fmaxcount do sr.delete(sr.count-1);
     if not insert then sr.add(val) else sr.insert(0,val);
end;

function tfavopendialog.getfolderpath:string;
var
    buf : array [0..max_path+1] of char;
begin
     sendmessage(getparent(handle),cdm_getfolderpath,max_path,integer(@buf));
     result := strpas(buf);
     if result <> '' then if result[length(result)] = '\' then delete(result,length(result),1);
end;


procedure tfavopendialog.fbuttonclick(sender:tobject);
var sr :string;
begin
     sr := getfolderpath;
     if fileexists(sr) or directoryexists(sr) or directoryexists(sr+'\') then begin
        addfavorite(fcombo.items,sr,true);
        fcombo.ItemIndex := 0;
        fbutton.enabled := false;
     end;
end;

procedure tfavopendialog.fcomboclick(sender:tobject);
var sr : string;
    sr1 : array [0..max_path+1] of char;
  PathWnd: HWND;
begin
  //PathWnd := GetDlgItem(GetParent(Handle), edt1);
  {if PathWnd = 0 then
    PathWnd := GetDlgItem(GetParent(Handle), cmb13);
     sr := fcombo.items[fcombo.itemindex];
     if not directoryexists(sr) then exit;
     setfocus(PathWnd);
     sendmessage(PathWnd,wm_gettext,max_path,integer(@sr1));
     sendmessage(PathWnd,wm_settext,0,integer(pchar(sr+'\')));
     sendmessage(getdlgitem(getparent(handle),1),bm_click,0,0);
     sendmessage(PathWnd,wm_settext,0,integer(@sr1));
     fcombo.items.delete(fcombo.itemindex);
     fcombo.items.insert(0,sr);
     fcombo.itemindex := 0;}
end;

procedure tfavopendialog.setshowfullpath(val:boolean);
begin
     if val <> fshowfullpath then begin
        fshowfullpath := val;
        fcombo.update;
     end;
end;
procedure tfavopendialog.setstring(index:integer;val:string);
begin
     case index of
          1 : fcombo.hint := val;
          2 : fbutton.hint := val;
          3 : flabel.Caption := val;
     end;
end;

function tfavopendialog.getstring(index:integer):string;
begin
     case index of
          1 : result := fcombo.hint;
          2 : result := fbutton.hint;
          3 : result := flabel.caption;
     end;
end;
procedure tfavopendialog.FavToRegistry(Rootkey:HKEY;Key:string);
var reg : tregistry;
    ct : integer;
begin
     reg := tregistry.create;
     try
        reg.RootKey:=rootkey;
        if reg.openkey(key,true) then begin
           ct := fstrings.count;
           reg.writeinteger('Count',ct);
           if ct > 0 then for ct := 0 to ct-1 do
              reg.writestring(inttostr(ct),fstrings[ct]);
        end;
     finally
            reg.free;
     end;
end;

procedure tfavopendialog.FavFromRegistry (Rootkey:HKEY;Key:string);
var reg : tregistry;
    ct : integer;
begin
     reg := tregistry.create;
     try
        reg.RootKey:=rootkey;
        if reg.openkey(key,false) then if reg.valueexists('Count') then begin
           fstrings.clear;
           ct := reg.readinteger('Count');
           if ct > 0 then for ct := 0 to ct-1 do
              fstrings.add(reg.readstring(inttostr(ct)));
        end;
        if assigned(fassociated) then fassociated.setfavorites(0,fstrings);
     finally
            reg.free;
     end;
end;

procedure tfavopendialog.setfassociated(value : tfavopendialog);
begin
     if value <> self then if value <> fassociated then fassociated := value;
end;

procedure tfavopendialog.notification(AComponent: TComponent; Operation: TOperation);
begin
  if operation = opremove then
    if acomponent = fassociated then
      fassociated := nil;
  inherited;
end;

procedure tfavopendialog.DoFolderChange;
var sr : string;
    ct : integer;
    ena : boolean;
begin
     // überprüfen, ob aktueller folder in history schon drin ist
     sr := getfolderpath;
     ena := true;
     if fcombo.items.count > 0 then for ct := 0 to pred(fcombo.items.count) do begin
        if lstrcmpi(pchar(sr),pchar(fcombo.items[ct])) = 0 then begin
           ena := false;
           fcombo.itemindex := ct;
           break;
        end;
     end;
     fbutton.enabled := ena;
     inherited dofolderchange;
end;

function tfavopendialog.TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool;
begin
  {if Assigned(Template) then
    TOpenFileName(DialogData).hInstance := FindClassHInstance(Self.ClassType);
  Result := inherited TaskModalDialog(DialogFunc, DialogData);}
end;

function tfavsavedialog.Execute: Boolean;
begin
  {$ifdef VCL}                           // dedicated VCL/Windows feature
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'MYDLGO' else
    Template := nil;
  {$endif}
  {$ifdef VCL}
  Result := DoExecute(@GetSaveFileName);
  {$else}
  Result:= DoExecute;
  {$endif}
end;


end.
