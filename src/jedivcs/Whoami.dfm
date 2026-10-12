object VCSWhoami: TVCSWhoami
  Left = 324
  Top = 308
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'JediVCS Application Server'
  ClientHeight = 243
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 96
    Top = 12
    Width = 65
    Height = 13
    Alignment = taRightJustify
    Caption = 'You are user:'
  end
  object Label2: TLabel
    Left = 62
    Top = 28
    Width = 99
    Height = 13
    Alignment = taRightJustify
    Caption = 'Default access level:'
  end
  object Label3: TLabel
    Left = 61
    Top = 44
    Width = 101
    Height = 13
    Alignment = taRightJustify
    Caption = 'Current access level:'
  end
  object Label4: TLabel
    Left = 92
    Top = 76
    Width = 69
    Height = 13
    Alignment = taRightJustify
    Caption = 'Connected to:'
  end
  object Label5: TLabel
    Left = 84
    Top = 108
    Width = 77
    Height = 13
    Alignment = taRightJustify
    Caption = 'Version archive:'
  end
  object Label6: TLabel
    Left = 70
    Top = 124
    Width = 90
    Height = 13
    Alignment = taRightJustify
    Caption = 'Stored IP address:'
  end
  object Label7: TLabel
    Left = 76
    Top = 140
    Width = 85
    Height = 13
    Alignment = taRightJustify
    Caption = 'Client IP address:'
  end
  object Label8: TLabel
    Left = 74
    Top = 172
    Width = 87
    Height = 13
    Alignment = taRightJustify
    Caption = 'Idle timer expires:'
  end
  object Label9: TLabel
    Left = 60
    Top = 188
    Width = 101
    Height = 13
    Alignment = taRightJustify
    Caption = 'Login time remaining:'
  end
  object lblUser: TLabel
    Left = 167
    Top = 12
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblDefaultRight: TLabel
    Left = 167
    Top = 28
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblProjectRight: TLabel
    Left = 167
    Top = 44
    Width = 14
    Height = 13
    Caption = 'NA'
    ParentShowHint = False
    ShowHint = True
  end
  object lblServer: TLabel
    Left = 167
    Top = 76
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblArchive: TLabel
    Left = 167
    Top = 108
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblStoredIP: TLabel
    Left = 167
    Top = 124
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblCurrentIP: TLabel
    Left = 167
    Top = 140
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblLogin: TLabel
    Left = 167
    Top = 172
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object lblLoginRemain: TLabel
    Left = 167
    Top = 188
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object Label10: TLabel
    Left = 85
    Top = 92
    Width = 76
    Height = 13
    Alignment = taRightJustify
    Caption = 'Server location:'
  end
  object lblServerLoc: TLabel
    Left = 167
    Top = 92
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object Label11: TLabel
    Left = 68
    Top = 60
    Width = 92
    Height = 13
    Alignment = taRightJustify
    Caption = '(related to project)'
  end
  object lblProject: TLabel
    Left = 167
    Top = 60
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object Image1: TImage
    Left = 13
    Top = 12
    Width = 32
    Height = 32
    AutoSize = True
    Picture.Data = {
      07544269746D617076020000424D760200000000000076000000280000002000
      0000200000000100040000000000000200000000000000000000100000001000
      000000000000000080000080000000808000800000008000800080800000C0C0
      C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF00777777777777777777788777777777777777777777777777778887777777
      77777777777777777777700887777777777777777777777777770F0887777777
      77777777777777777770FF08877777777777777777777777780FFF0887777777
      7777777777777788880FFF08888877777777777777778880007FFF0888888877
      7777777777780007FFFFFF70008888877777777777007FFFFFFFFFFFF7008888
      77777777707FFFFFFFFFFFFFFFF70888877777770FFFFFFFFFFFFFFFFFFFF088
      88777770FFFFFFFFFFFFFFFFFFFFFF088887778FFFFFFFFCCCCCCCCCFFFFFFF0
      8887787FFFFFFFFFFCCCCCFFFFFFFFF7088878FFFFFFFFFFFCCCCCFFFFFFFFFF
      088887FFFFFFFFFFFCCCCCFFFFFFFFFF70888FFFFFFFFFFFFCCCCCFFFFFFFFFF
      F0888FFFFFFFFFFFFCCCCCFFFFFFFFFFF0888FFFFFFFFFFFFCCCCCFFFFFFFFFF
      F0888FFFFFFFFFFFFCCCCCFFFFFFFFFFF0888FFFFFFFFFFCCCCCCCFFFFFFFFFF
      F08787FFFFFFFFFFFFFFFFFFFFFFFFFF708778FFFFFFFFFFFFFFFFFFFFFFFFFF
      0877787FFFFFFFFF7CCCC7FFFFFFFFF70777778FFFFFFFFFCCCCCCFFFFFFFFF0
      77777778FFFFFFFFCCCCCCFFFFFFFF07777777778FFFFFFF7CCCC7FFFFFFF077
      77777777787FFFFFFFFFFFFFFFF787777777777777887FFFFFFFFFFFF7887777
      7777777777778887FFFFFF788877777777777777777777788888888777777777
      7777}
    Transparent = True
  end
  object Label12: TLabel
    Left = 77
    Top = 156
    Width = 84
    Height = 13
    Alignment = taRightJustify
    Caption = 'Login time (GMT):'
  end
  object lblServerLogin: TLabel
    Left = 167
    Top = 156
    Width = 14
    Height = 13
    Caption = 'NA'
  end
  object btnClose: TButton
    Left = 179
    Top = 211
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object btnStatistic: TButton
    Left = 85
    Top = 211
    Width = 75
    Height = 25
    Caption = '&Statistic'
    TabOrder = 1
    OnClick = btnStatisticClick
  end
end
