{ 10.04.99 10:23:59 > [Administrator on K6] checked out /kompl. Änderung V 1.3 }
unit Historylist;

interface

uses Windows, Classes, SysUtils;

type
  THistoryList = class(TStringList)
  private
    FMaxLen : Integer;
    FCaseSens : Boolean;
    procedure SetMaxLen(AInt : Integer);
    procedure SetCaseSens(ABool : Boolean);
  public
    constructor Create;
    property MaxLen : Integer read FMaxLen write SetMaxLen;
    property CaseSens : Boolean read FCaseSens write SetCaseSens;
    procedure AddString(S : String);
    procedure RemoveString(S : String);
    procedure SaveToReg(Key : String);
    procedure LoadFromReg(Key : String);
  end;

implementation

uses Registry;

constructor THistoryList.Create;
begin
  inherited Create;
  FMaxLen := 10;
  FCaseSens := false;
  Sorted := false;
  Duplicates := dupIgnore;
end;

procedure THistoryList.SetMaxLen(AInt : Integer);
begin
  if (AInt <> FMaxLen) and (AInt >= 1) and (AInt <= 100)
    then FMaxLen := AInt;
end;

procedure THistoryList.SetCaseSens(ABool : Boolean);
begin
  if (ABool <> FCaseSens) then FCaseSens := ABool;
end;

procedure THistoryList.AddString(S : String);
var OldIndex : Integer;
begin
  if not FCaseSens then S := ANSILowerCase(S);
  OldIndex := IndexOf(S);
  if OldIndex <> -1 then Delete(OldIndex);
  Insert(0, S);
  if Count > FMaxLen then Delete(Count - 1);
end;

procedure THistoryList.RemoveString(S : String);
var OldIndex : Integer;
begin
  OldIndex := IndexOf(S);
  if OldIndex <> -1 then Delete(OldIndex);
end;

procedure THistoryList.SaveToReg(Key : String);
var Reg : TRegistry;
    i   : Integer;
begin
  Reg := TRegistry.Create;
  with Reg do begin
    RootKey := HKEY_CURRENT_USER;
    try
      DeleteKey(Key);
      OpenKey(Key, true);
      for i := 0 to Count-1 do
        WriteString(IntToStr(i + 1), Strings[i]);
      CloseKey;
    finally
      Free;
    end; // try finally
  end; // with Reg do begin
end;

procedure THistoryList.LoadFromReg(Key : String);
var Reg : TRegistry;
    i   : Integer;
    S   : String;
begin
  Clear;
  Reg := TRegistry.Create;
  with Reg do begin
    RootKey := HKEY_CURRENT_USER;
    try
      OpenKeyReadOnly(Key);
      for i := 0 to FMaxLen-1 do begin
        if ValueExists(IntToStr(i + 1)) then begin
          if not FCaseSens then S := ANSILowerCase(ReadString(IntToStr(i + 1)))
            else S := ReadString(IntToStr(i + 1))
        end else S := '';
        if S <> '' then Insert(Count, S);
      end; // for i := 0 to FMaxLen-1 do begin
    finally
      Reg.Free;
    end; // try finally
  end; // with Reg do begin
end;


end.
