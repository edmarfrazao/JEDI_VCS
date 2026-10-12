object VCSToDoEdit: TVCSToDoEdit
  Left = 387
  Top = 259
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Edit ToDo Item'
  ClientHeight = 312
  ClientWidth = 288
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHead: TPanel
    Left = 0
    Top = 0
    Width = 288
    Height = 130
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      288
      130)
    object Label1: TLabel
      Left = 7
      Top = 9
      Width = 38
      Height = 13
      Caption = 'Pri&ority:'
      FocusControl = spePriority
    end
    object Label2: TLabel
      Left = 127
      Top = 9
      Width = 27
      Height = 13
      Alignment = taRightJustify
      Caption = 'Date:'
    end
    object Label4: TLabel
      Left = 7
      Top = 33
      Width = 61
      Height = 13
      Caption = '&Responsible:'
      FocusControl = cbxUser
    end
    object Label5: TLabel
      Left = 7
      Top = 108
      Width = 57
      Height = 13
      Caption = 'Target dat&e'
      FocusControl = dtpTarget
    end
    object Label7: TLabel
      Left = 7
      Top = 83
      Width = 49
      Height = 13
      Caption = '&Category:'
    end
    object Label8: TLabel
      Left = 7
      Top = 58
      Width = 38
      Height = 13
      Caption = '&Project:'
      FocusControl = cbxProject
    end
    object spBtnClrTarget: TSpeedButton
      Left = 165
      Top = 102
      Width = 24
      Height = 20
      Hint = 'Clear target date'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888880088800888008880880808808088088088080880808808808808088080
        8808808808088080880888008880088800888888888888888888888888888888
        8888888888888888888888888888888888888888888888888888}
      OnClick = spBtnClrTargetClick
    end
    object btnToday: TSpeedButton
      Left = 190
      Top = 102
      Width = 30
      Height = 20
      Hint = 'Today'
      Caption = 'Now'
      OnClick = btnTodayClick
    end
    object edDate: TEdit
      Left = 160
      Top = 5
      Width = 119
      Height = 21
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
    end
    object dtpTarget: TDateTimePicker
      Left = 74
      Top = 102
      Width = 85
      Height = 21
      CalAlignment = dtaLeft
      Date = 36436.2038945023
      Time = 36436.2038945023
      DateFormat = dfShort
      DateMode = dmComboBox
      Kind = dtkDate
      ParseInput = False
      TabOrder = 5
    end
    object spePriority: TJvSpinEdit
      Left = 74
      Top = 5
      Width = 41
      Height = 21
      ButtonKind = bkStandard
      MaxValue = 9
      MinValue = 1
      Value = 1
      MaxLength = 1
      TabOrder = 0
    end
    object cbxUser: TComboBox
      Left = 74
      Top = 29
      Width = 206
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 2
    end
    object cbxProject: TComboBox
      Left = 74
      Top = 53
      Width = 206
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 3
    end
    object rcbxCategory: TJvComboBox
      Left = 74
      Top = 77
      Width = 206
      Height = 21
      AutoComplete = False
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      PopupMenu = PopupMenu1
      TabOrder = 4
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 280
    Width = 288
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      288
      32)
    object Help: TSpeedButton
      Left = 6
      Top = 5
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
      Left = 207
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnOK: TButton
      Left = 119
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      Default = True
      TabOrder = 1
      OnClick = btnOKClick
    end
    object cbDone: TCheckBox
      Left = 40
      Top = 5
      Width = 53
      Height = 17
      Caption = '&Done'
      TabOrder = 0
    end
  end
  object gbDescription: TGroupBox
    Left = 0
    Top = 130
    Width = 288
    Height = 150
    Align = alClient
    Caption = '&Description'
    TabOrder = 1
    object meToDo: TJvMemo
      Left = 2
      Top = 15
      Width = 284
      Height = 133
      AutoSize = False
      MaxLines = 0
      HideCaret = False
      Align = alClient
      MaxLength = 2000
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 36
    Top = 178
    object Clearhistory1: TMenuItem
      Caption = '&Clear MRU List Categories'
      OnClick = Clearhistory1Click
    end
  end
end
