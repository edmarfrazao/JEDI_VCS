object VCSServerOptions: TVCSServerOptions
  Left = 379
  Top = 241
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Server Properties'
  ClientHeight = 217
  ClientWidth = 216
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010002002020100000000000E80200002600000010101000000000002801
    00000E0300002800000020000000400000000100040000000000800200000000
    0000000000000000000000000000000000000000800000800000008080008000
    00008000800080800000C0C0C000808080000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000003B3B3B3B3B3B3B3B3B3B3B3B3B00000
    3B3B3B3B3B3B3B3B3B3B3B3B3B000000B3B3B3B3B3B3B3B3B3B3B3B3B300000B
    3B3B3B3B3B3B3B3B3B3B3B3B30B00003B3B3B3B3B3B3B3B3B3B3B3B3B0F0003B
    3B3B3B3B3B3B3B3B3B3B3B3B00B000B3B3B3B3B3B3B3B3B3B3B3B3B300F00B3B
    3B3B3B3B3B3B3B3B3B3B3B30F0B00000000000000000000000000000F0F00000
    0B0FFFF00FFFFFFFFFFFFFFFF0B000000F0FFFF00FFFFFFFFFFFFFFFF0F00000
    0B0FFFF00FFFFFFFFFFFFFFFF0B000000F0FFFF00FF000000000000FF0F00000
    0B0FFFF00FFFFFFFFFFFFFFFF0B000000F0FFFF00FFFFFFFFFFFFFFFF0F00000
    0B0FFFFF0FFFFFFFFFFFFFFFF0B000000F0FFFFF0FF000000000000FF0F00000
    0B0000000FFFFFFFFFFFFFFFF0B000000FFBFFFB0FFFFFFFFFFFFFFFF0F00000
    00FFFBFF0FFFFFFFFFFFFFFFF0000000000BFFFB0FF000000000000FF0000000
    000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000
    000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000F000
    0000E0000000E0000000C0000000C00000008000000080000000000000000000
    0000F0000000F0000000F0000000F0000000F0000000F0000000F0000000F000
    0000F0000000F0000000F0000000FC000003FE000003FFF00003FFF00003FFF0
    0003FFF00003FFFFFFFFFFFFFFFF280000001000000020000000010004000000
    0000C00000000000000000000000000000000000000000000000000080000080
    000000808000800000008000800080800000C0C0C000808080000000FF0000FF
    000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000000000000000
    000000000000000000000000000000003B3B3B3B3B000003B3B3B3B3B000000B
    3B3B3B3BB00000B3B3B3B3BB0B00000000000000030000BB0FF0FFFF0B0000B3
    0FF0FFFF0300003B0000F00F0B00000B3B30FFFF03000000B3B0F00F0B000000
    0000FFFF000000000000000000000000000000000000FFFF0000FFFF0000E001
    0000E0010000C0010000C0010000800100008001000080010000800100008001
    0000C0010000E0010000F0030000FE070000FFFF0000}
  KeyPreview = True
  OldCreateOrder = False
  ShowHint = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Help: TSpeedButton
    Left = 8
    Top = 186
    Width = 25
    Height = 25
    Hint = 'Help (F1)'
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777707777
      77777777770B0777777777777770777777777777777777777777777777707777
      77777777770B077777777777770B077777777777770B077777777777770BB077
      777777770770BB0777777770B0770BB077777770B07770B077777770BB000BB0
      777777770BBBBB07777777777000007777777777777777777777}
    OnClick = HelpClick
  end
  object btnCancel: TButton
    Left = 136
    Top = 186
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnOK: TButton
    Left = 52
    Top = 186
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 217
    Height = 178
    ActivePage = TabSheet1
    TabIndex = 0
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '&Security'
      object Label1: TLabel
        Left = 16
        Top = 16
        Width = 93
        Height = 13
        Caption = 'Co&nnection timeout'
      end
      object Label2: TLabel
        Left = 16
        Top = 84
        Width = 64
        Height = 13
        Caption = 'Login &timeout'
        FocusControl = speLoginTO
      end
      object Label5: TLabel
        Left = 178
        Top = 16
        Width = 16
        Height = 13
        Caption = 'sec'
      end
      object Label6: TLabel
        Left = 178
        Top = 84
        Width = 16
        Height = 13
        Caption = 'min'
      end
      object speLoginTO: TJvSpinEdit
        Left = 113
        Top = 80
        Width = 58
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 600
        MinValue = 5
        Value = 5
        TabOrder = 3
        OnChange = OnValuesChanged
      end
      object speConnectTO: TJvSpinEdit
        Left = 113
        Top = 12
        Width = 58
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 3600
        MinValue = 10
        Value = 10
        TabOrder = 0
        OnChange = OnValuesChanged
      end
      object cbCheckIP: TCheckBox
        Left = 8
        Top = 42
        Width = 193
        Height = 17
        Caption = 'Login restricted to stored IP &address'
        TabOrder = 1
        OnClick = OnValuesChanged
      end
      object cbLoginExpires: TCheckBox
        Left = 8
        Top = 61
        Width = 134
        Height = 17
        Caption = 'Login &idle timer active'
        TabOrder = 2
        OnClick = cbLoginExpiresClick
      end
      object cbLocalLogin: TCheckBox
        Left = 8
        Top = 108
        Width = 185
        Height = 17
        Caption = 'Enable local login &w/o password'
        TabOrder = 4
        OnClick = OnValuesChanged
      end
      object cbAutologon: TCheckBox
        Left = 8
        Top = 128
        Width = 185
        Height = 17
        Caption = '&DBMS auto logon on server start'
        TabOrder = 5
        OnClick = OnValuesChanged
      end
    end
    object TabSheet2: TTabSheet
      Caption = '&Checkin'
      ImageIndex = 1
      object Label3: TLabel
        Left = 16
        Top = 36
        Width = 167
        Height = 26
        Caption = '(Modules must not be checked out before checkin is allowed)'
        WordWrap = True
      end
      object Label4: TLabel
        Left = 16
        Top = 92
        Width = 152
        Height = 26
        Caption = '(Modules MUST be checked out before checkin is allowed)'
        WordWrap = True
      end
      object rbCasCheckin: TRadioButton
        Left = 8
        Top = 16
        Width = 105
        Height = 17
        Caption = 'C&asually Check In'
        TabOrder = 0
        OnClick = OnValuesChanged
      end
      object rbResCheckin: TRadioButton
        Left = 8
        Top = 72
        Width = 191
        Height = 17
        Caption = 'Restrictive Check In (recommended)'
        TabOrder = 1
        OnClick = OnValuesChanged
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&Log/ Stat'
      ImageIndex = 2
      object lblSrvLogSize: TLabel
        Left = 60
        Top = 62
        Width = 39
        Height = 13
        Caption = '99.999k'
      end
      object spBtnShowSrvLog: TSpeedButton
        Left = 137
        Top = 46
        Width = 23
        Height = 22
        Hint = 'View server log'
        Glyph.Data = {
          E6000000424DE60000000000000076000000280000000E0000000E0000000100
          0400000000007000000000000000000000001000000010000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3300333333333333330033333333333333003300033300033300307F70307F70
          330030F7F030F7F0330030FF7030FF7033003800070700033300330333333303
          3300330303333303030033303333333033003333333333333300333333333333
          33003333333333333300}
        OnClick = spBtnShowSrvLogClick
      end
      object spBtnClearLog: TSpeedButton
        Left = 166
        Top = 46
        Width = 23
        Height = 22
        Hint = 'Clear server log'
        Glyph.Data = {
          42010000424D4201000000000000760000002800000011000000110000000100
          040000000000CC00000000000000000000001000000010000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          777770000000777777777777777770000000777777777777770F700000007777
          0F777777777770000000777000F7777770F770000000777000F777770F777000
          00007777000F77700F777000000077777000F700F7777000000077777700000F
          7777700000007777777000F777777000000077777700000F7777700000007777
          7000F70F7777700000007770000F77700F7770000000770000F7777700F77000
          00007700F7777777700F70000000777777777777777770000000777777777777
          777770000000}
        OnClick = spBtnClearLogClick
      end
      object Label11: TLabel
        Left = 30
        Top = 62
        Width = 23
        Height = 13
        Caption = 'Size:'
      end
      object Label12: TLabel
        Left = 92
        Top = 126
        Width = 111
        Height = 13
        Caption = 'Admin access required!'
      end
      object cbVCSLog: TCheckBox
        Left = 8
        Top = 16
        Width = 171
        Height = 17
        Caption = '&VCS log active (recommended)'
        TabOrder = 0
        OnClick = OnValuesChanged
      end
      object cbServerLog: TCheckBox
        Left = 8
        Top = 40
        Width = 105
        Height = 17
        Caption = 'S&erver log active'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = OnValuesChanged
      end
      object cbLogAccessFault: TCheckBox
        Left = 8
        Top = 84
        Width = 177
        Height = 17
        Caption = 'Log &unauthorized client requests'
        TabOrder = 2
        OnClick = OnValuesChanged
      end
      object btnStat: TButton
        Left = 8
        Top = 120
        Width = 75
        Height = 25
        Caption = 'St&atistics'
        TabOrder = 3
        OnClick = btnStatClick
      end
    end
    object TabSheet4: TTabSheet
      Caption = '&Backup'
      ImageIndex = 3
      object Label8: TLabel
        Left = 8
        Top = 54
        Width = 192
        Height = 41
        AutoSize = False
        Caption = 
          'Remember that the target folder must be a folder on the applicat' +
          'ion servers machine! The folder must already exist!'
        WordWrap = True
      end
      object Label10: TLabel
        Left = 8
        Top = 16
        Width = 141
        Height = 13
        Caption = '&Version archive backup folder'
        FocusControl = edBackupPath
      end
      object Label7: TLabel
        Left = 8
        Top = 100
        Width = 61
        Height = 13
        Caption = 'Last Backup:'
      end
      object lblLastBackup: TLabel
        Left = 76
        Top = 100
        Width = 64
        Height = 13
        Hint = 'Server time'
        Caption = 'lblLastBackup'
        ParentShowHint = False
        ShowHint = True
      end
      object Label9: TLabel
        Left = 92
        Top = 126
        Width = 111
        Height = 13
        Caption = 'Admin access required!'
      end
      object edBackupPath: TEdit
        Left = 8
        Top = 32
        Width = 193
        Height = 21
        TabOrder = 0
        OnChange = edBackupPathChange
      end
      object btnBackup: TButton
        Left = 8
        Top = 120
        Width = 75
        Height = 25
        Caption = '&Execute Now'
        Enabled = False
        TabOrder = 1
        OnClick = btnBackupClick
      end
    end
  end
end
