object VCSShowTimeLog: TVCSShowTimeLog
  Left = 313
  Top = 212
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'VCS Time Log'
  ClientHeight = 258
  ClientWidth = 392
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 161
    Width = 392
    Height = 97
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      392
      97)
    object Help: TSpeedButton
      Left = 6
      Top = 70
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
    object Label4: TLabel
      Left = 9
      Top = 11
      Width = 24
      Height = 13
      Alignment = taRightJustify
      Caption = 'Filter'
    end
    object btnCalc: TSpeedButton
      Left = 6
      Top = 39
      Width = 25
      Height = 25
      Hint = 'Calculate'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000010000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00337000000000
        73333337777777773F333308888888880333337F3F3F3FFF7F33330808089998
        0333337F737377737F333308888888880333337F3F3F3F3F7F33330808080808
        0333337F737373737F333308888888880333337F3F3F3F3F7F33330808080808
        0333337F737373737F333308888888880333337F3F3F3F3F7F33330808080808
        0333337F737373737F333308888888880333337F3FFFFFFF7F33330800000008
        0333337F7777777F7F333308000E0E080333337F7FFFFF7F7F33330800000008
        0333337F777777737F333308888888880333337F333333337F33330888888888
        03333373FFFFFFFF733333700000000073333337777777773333}
      NumGlyphs = 2
      OnClick = btnCalcClick
    end
    object btnClose: TButton
      Left = 310
      Top = 70
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Close'
      Default = True
      TabOrder = 6
      OnClick = btnCloseClick
    end
    object cbTimeLog: TCheckBox
      Left = 214
      Top = 43
      Width = 93
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Time log &active'
      TabOrder = 3
      OnClick = cbTimeLogClick
    end
    object btnClear: TButton
      Left = 310
      Top = 38
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'C&lear'
      TabOrder = 4
      OnClick = spBtnClearClick
    end
    object pnResult: TPanel
      Left = 38
      Top = 38
      Width = 166
      Height = 56
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvLowered
      PopupMenu = PopupMenu1
      TabOrder = 0
      DesignSize = (
        166
        56)
      object Label1: TLabel
        Left = 6
        Top = 4
        Width = 30
        Height = 13
        Caption = 'Begin:'
      end
      object lblTime: TLabel
        Left = 47
        Top = 4
        Width = 118
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
      end
      object Label2: TLabel
        Left = 6
        Top = 21
        Width = 22
        Height = 13
        Caption = 'End:'
      end
      object lblTime2: TLabel
        Left = 47
        Top = 21
        Width = 118
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
      end
      object lblSum: TLabel
        Left = 47
        Top = 38
        Width = 118
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
      end
      object Label3: TLabel
        Left = 6
        Top = 38
        Width = 24
        Height = 13
        Caption = 'Sum:'
      end
    end
    object btnReport: TButton
      Left = 222
      Top = 70
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Report...'
      TabOrder = 5
      OnClick = btnReportClick
    end
    object pnFilter: TPanel
      Left = 38
      Top = 7
      Width = 259
      Height = 21
      Alignment = taLeftJustify
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvLowered
      TabOrder = 2
    end
    object btnFilter: TButton
      Left = 310
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Filter...'
      TabOrder = 1
      OnClick = btnFilterClick
    end
  end
  object lvTimeLog: TListView
    Left = 0
    Top = 0
    Width = 392
    Height = 161
    Align = alClient
    Columns = <
      item
        Caption = 'User'
        Width = 75
      end
      item
        Caption = 'Start'
        Width = 100
      end
      item
        Caption = 'End'
        Width = 100
      end
      item
        Alignment = taRightJustify
        Caption = 'Time'
        Width = 75
      end
      item
        Alignment = taRightJustify
        Caption = 'Cost'
        Width = 70
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDeletion = lvTimeLogDeletion
  end
  object PopupMenu1: TPopupMenu
    Left = 328
    Top = 24
    object MoreDetails1: TMenuItem
      Caption = 'More &Details'
      OnClick = MoreDetails1Click
    end
  end
end
