object VCSToDoFilter: TVCSToDoFilter
  Left = 360
  Top = 249
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'ToDo Filter'
  ClientHeight = 181
  ClientWidth = 224
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
    Top = 152
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
    Left = 61
    Top = 152
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 145
    Top = 152
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
    Width = 225
    Height = 145
    ActivePage = TabSheet5
    TabIndex = 3
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '&Projects'
      object Label3: TLabel
        Left = 12
        Top = 68
        Width = 38
        Height = 13
        Caption = 'Proj&ect:'
        FocusControl = cbProjects
      end
      object rbAllProject: TRadioButton
        Left = 8
        Top = 8
        Width = 124
        Height = 17
        Caption = '&All projects'
        TabOrder = 0
      end
      object rbCurrentProject: TRadioButton
        Left = 8
        Top = 27
        Width = 201
        Height = 17
        Caption = 'Current project'
        Checked = True
        TabOrder = 1
        TabStop = True
      end
      object cbProjects: TJvComboBox
        Left = 10
        Top = 84
        Width = 199
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
      end
      object rbSelectProject: TRadioButton
        Left = 8
        Top = 46
        Width = 156
        Height = 17
        Caption = 'Select a project'
        TabOrder = 3
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&Users'
      ImageIndex = 2
      object Label5: TLabel
        Left = 12
        Top = 68
        Width = 26
        Height = 13
        Caption = 'U&ser:'
        FocusControl = cbUser
      end
      object rbAllUsers: TRadioButton
        Left = 8
        Top = 8
        Width = 104
        Height = 17
        Caption = '&All users'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbCurrentUser: TRadioButton
        Left = 8
        Top = 27
        Width = 209
        Height = 17
        Caption = 'Current user'
        TabOrder = 1
      end
      object cbUser: TJvComboBox
        Left = 10
        Top = 84
        Width = 199
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
      end
      object rbSelectUser: TRadioButton
        Left = 8
        Top = 46
        Width = 128
        Height = 17
        Caption = 'Select a user'
        TabOrder = 3
      end
    end
    object TabSheet4: TTabSheet
      Caption = '&Target date'
      ImageIndex = 3
      object Label4: TLabel
        Left = 12
        Top = 68
        Width = 71
        Height = 13
        Caption = 'Overdue &date:'
        FocusControl = dtpTargetDate
      end
      object dtpTargetDate: TDateTimePicker
        Left = 10
        Top = 84
        Width = 199
        Height = 21
        CalAlignment = dtaLeft
        Date = 36418.9555762384
        Time = 36418.9555762384
        DateFormat = dfShort
        DateMode = dmComboBox
        Kind = dtkDate
        ParseInput = False
        TabOrder = 3
      end
      object rbIgnoreOverdue: TRadioButton
        Left = 8
        Top = 8
        Width = 157
        Height = 17
        Caption = '&Ignore target date'
        TabOrder = 0
      end
      object rbOverdueAt: TRadioButton
        Left = 8
        Top = 46
        Width = 125
        Height = 17
        Caption = 'Overdue at'
        TabOrder = 2
      end
      object rbOverdueNow: TRadioButton
        Left = 8
        Top = 27
        Width = 133
        Height = 17
        Caption = 'Overdue now'
        TabOrder = 1
      end
    end
    object TabSheet5: TTabSheet
      Caption = '&Other'
      ImageIndex = 4
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 49
        Height = 13
        Caption = 'C&ategory:'
        FocusControl = cbCategory
      end
      object Label2: TLabel
        Left = 35
        Top = 68
        Width = 38
        Height = 13
        Alignment = taRightJustify
        Caption = 'Pr&iority:'
        FocusControl = cbPriority
      end
      object cbCategory: TJvComboBox
        Left = 8
        Top = 28
        Width = 199
        Height = 21
        AutoComplete = False
        AutoDropDown = True
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
      end
      object cbNotDone: TCheckBox
        Left = 8
        Top = 96
        Width = 137
        Height = 17
        Caption = '&Not finished tasks'
        TabOrder = 1
      end
      object cbPriority: TJvComboBox
        Left = 78
        Top = 64
        Width = 129
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        Items.Strings = (
          'Ignore priority'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
      end
    end
  end
end
