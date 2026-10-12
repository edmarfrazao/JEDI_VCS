object VCSSelCrossRef: TVCSSelCrossRef
  Left = 400
  Top = 284
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Cross-References'
  ClientHeight = 393
  ClientWidth = 432
  Color = clBtnFace
  ParentFont = True
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
  OldCreateOrder = True
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 361
    Width = 432
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Help: TSpeedButton
      Left = 9
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
    object btnPGroup: TButton
      Left = 66
      Top = 5
      Width = 93
      Height = 25
      Caption = 'Project &Group'
      TabOrder = 0
      OnClick = btnPGroupClick
    end
    object OKBtn: TButton
      Left = 173
      Top = 5
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
      OnClick = OKBtnClick
    end
    object CancelBtn: TButton
      Left = 261
      Top = 5
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
      OnClick = CancelBtnClick
    end
  end
  object gbAvailableProjects: TGroupBox
    Left = 0
    Top = 0
    Width = 200
    Height = 361
    Align = alLeft
    Caption = '&Available projects:'
    TabOrder = 1
    object SrcList: TListBox
      Left = 2
      Top = 15
      Width = 196
      Height = 344
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      Sorted = True
      TabOrder = 0
      OnClick = SrcListClick
      OnDblClick = IncludeBtnClick
    end
  end
  object gbRefProjects: TGroupBox
    Left = 232
    Top = 0
    Width = 200
    Height = 361
    Align = alClient
    Caption = '&Referenced projects:'
    TabOrder = 2
    object DstList: TListBox
      Left = 2
      Top = 15
      Width = 196
      Height = 344
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
      OnClick = SrcListClick
      OnDblClick = ExcludeBtnClick
    end
  end
  object pnlLeftRight: TPanel
    Left = 200
    Top = 0
    Width = 32
    Height = 361
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 3
    object IncludeBtn: TSpeedButton
      Left = 4
      Top = 16
      Width = 24
      Height = 24
      Hint = 'Add (Ctrl+A)'
      Caption = '>'
      OnClick = IncludeBtnClick
    end
    object IncAllBtn: TSpeedButton
      Left = 4
      Top = 48
      Width = 24
      Height = 24
      Hint = 'Add All'
      Caption = '>>'
      OnClick = IncAllBtnClick
    end
    object ExcludeBtn: TSpeedButton
      Left = 4
      Top = 80
      Width = 24
      Height = 24
      Hint = 'Remove (Ctrl+R)'
      Caption = '<'
      Enabled = False
      OnClick = ExcludeBtnClick
    end
    object ExAllBtn: TSpeedButton
      Left = 4
      Top = 112
      Width = 24
      Height = 24
      Hint = 'Remove All'
      Caption = '<<'
      Enabled = False
      OnClick = ExcAllBtnClick
    end
  end
end
