object VCSPHistoryFilter: TVCSPHistoryFilter
  Left = 285
  Top = 179
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Project History Filter'
  ClientHeight = 199
  ClientWidth = 243
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
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Help: TSpeedButton
    Left = 8
    Top = 168
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
  object btnOk: TButton
    Left = 77
    Top = 168
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 161
    Top = 168
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 242
    Height = 161
    ActivePage = TabSheet5
    TabIndex = 4
    TabOrder = 0
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = '&Projects'
      object Label6: TLabel
        Left = 12
        Top = 84
        Width = 38
        Height = 13
        Caption = 'Pr&oject:'
        FocusControl = cbProjects
      end
      object rbAllProject: TRadioButton
        Left = 8
        Top = 8
        Width = 127
        Height = 17
        Caption = '&All projects'
        TabOrder = 0
        OnClick = rbProjectModuleUserClick
      end
      object rbCurrentProject: TRadioButton
        Left = 8
        Top = 35
        Width = 201
        Height = 17
        Caption = 'Current project'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = rbProjectModuleUserClick
      end
      object cbProjects: TComboBox
        Left = 10
        Top = 100
        Width = 207
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 3
      end
      object rbSelectProject: TRadioButton
        Left = 8
        Top = 62
        Width = 151
        Height = 17
        Caption = 'Select a project'
        TabOrder = 2
        OnClick = rbProjectModuleUserClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = '&Modules'
      ImageIndex = 1
      object Label7: TLabel
        Left = 12
        Top = 84
        Width = 38
        Height = 13
        Caption = 'M&odule:'
        FocusControl = cbModule
      end
      object rbAllModules: TRadioButton
        Left = 8
        Top = 8
        Width = 130
        Height = 17
        Caption = '&All modules'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbProjectModuleUserClick
      end
      object cbModule: TComboBox
        Left = 10
        Top = 100
        Width = 207
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 1
      end
      object rbSelectModule: TRadioButton
        Left = 8
        Top = 62
        Width = 154
        Height = 17
        Caption = 'Select a module'
        TabOrder = 2
        OnClick = rbProjectModuleUserClick
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&Users'
      ImageIndex = 2
      object Label8: TLabel
        Left = 12
        Top = 84
        Width = 26
        Height = 13
        Caption = 'Us&er:'
        FocusControl = cbUser
      end
      object rbAllUsers: TRadioButton
        Left = 8
        Top = 8
        Width = 110
        Height = 17
        Caption = '&All users'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbProjectModuleUserClick
      end
      object rbCurrentUser: TRadioButton
        Left = 8
        Top = 35
        Width = 209
        Height = 17
        Caption = 'Current user'
        TabOrder = 1
        OnClick = rbProjectModuleUserClick
      end
      object cbUser: TComboBox
        Left = 10
        Top = 100
        Width = 207
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 3
      end
      object rbSelectUser: TRadioButton
        Left = 8
        Top = 62
        Width = 134
        Height = 17
        Caption = 'Select a user'
        TabOrder = 2
        OnClick = rbProjectModuleUserClick
      end
    end
    object TabSheet4: TTabSheet
      Caption = '&Date'
      ImageIndex = 3
      object Label3: TLabel
        Left = 8
        Top = 20
        Width = 28
        Height = 13
        Alignment = taRightJustify
        Caption = '&From:'
        FocusControl = dtpStartDate
      end
      object Label4: TLabel
        Left = 20
        Top = 68
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Caption = '&To:'
        FocusControl = dtpEndDate
      end
      object Label5: TLabel
        Left = 22
        Top = 116
        Width = 185
        Height = 13
        Alignment = taCenter
        Caption = '(Result set includes the selected days)'
      end
      object dtpStartDate: TDateTimePicker
        Left = 40
        Top = 16
        Width = 169
        Height = 21
        CalAlignment = dtaLeft
        Date = 36418.9555762384
        Time = 36418.9555762384
        DateFormat = dfShort
        DateMode = dmComboBox
        Kind = dtkDate
        ParseInput = False
        TabOrder = 0
      end
      object dtpEndDate: TDateTimePicker
        Left = 40
        Top = 64
        Width = 169
        Height = 21
        CalAlignment = dtaLeft
        Date = 36418.9563792361
        Time = 36418.9563792361
        DateFormat = dfShort
        DateMode = dmComboBox
        Kind = dtkDate
        ParseInput = False
        TabOrder = 3
      end
      object cbUntilNow: TCheckBox
        Left = 40
        Top = 92
        Width = 128
        Height = 17
        Caption = '&Always until now'
        TabOrder = 4
        OnClick = cbUntilNowClick
      end
      object cbLastWeek: TCheckBox
        Left = 40
        Top = 42
        Width = 84
        Height = 17
        Caption = 'Last &week'
        TabOrder = 1
        OnClick = cbLastWeekClick
      end
      object cbLastMonth: TCheckBox
        Left = 126
        Top = 42
        Width = 95
        Height = 17
        Caption = '&Last month'
        TabOrder = 2
        OnClick = cbLastMonthClick
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'A&ction'
      ImageIndex = 4
      object Label1: TLabel
        Left = 27
        Top = 112
        Width = 30
        Height = 13
        Caption = '&Set All'
        FocusControl = btnSetAll
        Visible = False
      end
      object Label2: TLabel
        Left = 131
        Top = 112
        Width = 39
        Height = 13
        Caption = 'C&lear All'
        FocusControl = btnClearAll
        Visible = False
      end
      object cbAdd: TCheckBox
        Left = 8
        Top = 26
        Width = 104
        Height = 17
        Caption = 'Add &new files'
        TabOrder = 1
      end
      object cbRemove: TCheckBox
        Left = 8
        Top = 42
        Width = 104
        Height = 17
        Caption = '&Remove files'
        TabOrder = 2
      end
      object cbChkIn: TCheckBox
        Left = 8
        Top = 58
        Width = 104
        Height = 17
        Caption = 'Check &In'
        TabOrder = 3
      end
      object cbChkOut: TCheckBox
        Left = 8
        Top = 74
        Width = 104
        Height = 17
        Caption = 'C&heck Out'
        TabOrder = 4
      end
      object cbMerge: TCheckBox
        Left = 112
        Top = 42
        Width = 113
        Height = 17
        Caption = 'Me&rge'
        TabOrder = 8
      end
      object cbSync: TCheckBox
        Left = 112
        Top = 26
        Width = 113
        Height = 17
        Caption = 'Synchroni&ze'
        TabOrder = 7
      end
      object cbUndoChkOut: TCheckBox
        Left = 8
        Top = 90
        Width = 104
        Height = 17
        Caption = 'Un&do Check Out'
        TabOrder = 5
      end
      object cbBranch: TCheckBox
        Left = 112
        Top = 58
        Width = 113
        Height = 17
        Caption = '&Branch'
        TabOrder = 9
      end
      object cbProjRemove: TCheckBox
        Left = 112
        Top = 74
        Width = 113
        Height = 17
        Caption = 'Project remo&ved'
        TabOrder = 10
      end
      object cbArchTest: TCheckBox
        Left = 112
        Top = 90
        Width = 113
        Height = 17
        Caption = 'Archive &tested'
        TabOrder = 11
      end
      object cbGet: TCheckBox
        Left = 112
        Top = 10
        Width = 113
        Height = 17
        Caption = '&Get module'
        TabOrder = 6
      end
      object cbAllTypes: TCheckBox
        Left = 8
        Top = 8
        Width = 104
        Height = 17
        Caption = '&All actions'
        TabOrder = 0
        OnClick = cbAllTypesClick
      end
      object btnSetAll: TButton
        Left = 8
        Top = 111
        Width = 14
        Height = 14
        TabOrder = 12
        Visible = False
        OnClick = btnSetAllClick
      end
      object btnClearAll: TButton
        Left = 112
        Top = 111
        Width = 14
        Height = 14
        TabOrder = 13
        Visible = False
        OnClick = btnSetAllClick
      end
    end
  end
end
