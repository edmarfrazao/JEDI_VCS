object VCSSimpleReport: TVCSSimpleReport
  Left = 317
  Top = 214
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Report'
  ClientHeight = 190
  ClientWidth = 302
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
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 302
    Height = 151
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object imgClipBrd: TImage
      Left = 9
      Top = 10
      Width = 13
      Height = 13
      AutoSize = True
      Picture.Data = {
        07544269746D6170DE000000424DDE0000000000000076000000280000000D00
        00000D0000000100040000000000680000000000000000000000100000001000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00777777777777700077777777777770007777777777777000777700777777
        7000777000077777700077000000777770007700700007777000770777000077
        7000777777700077700077777777007770007777777770777000777777777777
        70007777777777777000}
      Transparent = True
      Visible = False
    end
    object Label1: TLabel
      Left = 192
      Top = 8
      Width = 78
      Height = 13
      Caption = '&Include Columns'
      FocusControl = clbInclude
    end
    object imgSaved: TImage
      Left = 276
      Top = 9
      Width = 11
      Height = 11
      AutoSize = True
      Center = True
      Picture.Data = {
        07544269746D6170CE000000424DCE0000000000000076000000280000000B00
        00000B0000000100040000000000580000000000000000000000100000001000
        0000000000000000800000800000008080008000000080008000808000008080
        8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF0080000000008000000C088F80CC0000000C088F80CC0000000CC00000CC00
        00000CCCCCCCCC0000000CC00000CC0000000C0FFFFF0C0000000C0FFFFF0C00
        00000C0FFFFF0C0000000C0FFFFF0C0000000000000000000000}
      Stretch = True
      Transparent = True
      Visible = False
    end
    object rbClipBoard: TRadioButton
      Left = 24
      Top = 8
      Width = 136
      Height = 17
      Caption = 'C&opy report to Clipboard'
      TabOrder = 0
      OnClick = rbClipBoardClick
    end
    object rbSave: TRadioButton
      Left = 24
      Top = 28
      Width = 142
      Height = 17
      Caption = 'Save report as &Text file'
      TabOrder = 1
      OnClick = rbClipBoardClick
    end
    object rbCSVReport: TRadioButton
      Left = 24
      Top = 48
      Width = 134
      Height = 17
      Caption = 'Save report as CS&V file'
      TabOrder = 2
      OnClick = rbClipBoardClick
    end
    object rbHTML: TRadioButton
      Left = 24
      Top = 68
      Width = 148
      Height = 17
      Caption = 'Save report as &HTML file'
      TabOrder = 3
      OnClick = rbClipBoardClick
    end
    object rbRTF: TRadioButton
      Left = 24
      Top = 88
      Width = 150
      Height = 17
      Caption = 'Save report as RT&F file'
      TabOrder = 4
      OnClick = rbClipBoardClick
    end
    object rbPrint: TRadioButton
      Left = 24
      Top = 108
      Width = 161
      Height = 17
      Caption = 'Pr&int report'
      TabOrder = 5
      OnClick = rbClipBoardClick
    end
    object cbShowResult: TCheckBox
      Left = 24
      Top = 132
      Width = 169
      Height = 17
      Caption = '&Show result in Editor/Browser'
      TabOrder = 6
    end
    object clbInclude: TJvxCheckListBox
      Left = 190
      Top = 23
      Width = 102
      Height = 120
      ItemHeight = 13
      PopupMenu = PopupMenu1
      TabOrder = 7
      OnClick = clbIncludeClick
      OnKeyUp = clbIncludeKeyUp
      InternalVersion = 202
    end
  end
  object btnReport: TButton
    Left = 128
    Top = 158
    Width = 75
    Height = 25
    Caption = '&Report'
    Default = True
    TabOrder = 2
    OnClick = btnReportClick
  end
  object btnPreview: TButton
    Left = 40
    Top = 158
    Width = 75
    Height = 25
    Caption = 'Pre&view'
    TabOrder = 1
    OnClick = btnPreviewClick
  end
  object btnClose: TButton
    Left = 216
    Top = 158
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object PrintDialog1: TPrintDialog
    Left = 228
    Top = 104
  end
  object PopupMenu1: TPopupMenu
    Left = 256
    Top = 104
    object SelectAllColumns1: TMenuItem
      Caption = '&Select All Columns'
      OnClick = SelectAllColumns1Click
    end
    object UnselectAllColumns1: TMenuItem
      Caption = '&Unselect All Columns'
      OnClick = UnselectAllColumns1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object SaveasDefault1: TMenuItem
      Caption = 'Save as &Default'
      OnClick = SaveasDefault1Click
    end
  end
end
