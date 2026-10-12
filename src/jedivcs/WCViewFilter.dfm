object VCSWCViewFilter: TVCSWCViewFilter
  Left = 329
  Top = 303
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Wildcard View Filter'
  ClientHeight = 164
  ClientWidth = 241
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
  object PageControl1: TPageControl
    Left = 2
    Top = 1
    Width = 237
    Height = 129
    ActivePage = SheetWC
    TabIndex = 0
    TabOrder = 0
    object SheetWC: TTabSheet
      Caption = '&Wildcards'
      DesignSize = (
        229
        101)
      object Label1: TLabel
        Left = 34
        Top = 6
        Width = 86
        Height = 13
        Caption = 'Custom &View filter'
      end
      object spBtnSetFilter: TSpeedButton
        Left = 199
        Top = 65
        Width = 22
        Height = 21
        Hint = 'Filter setup'
        Anchors = [akTop, akRight]
        Caption = '...'
        OnClick = spBtnSetFilterClick
      end
      object Label2: TLabel
        Left = 34
        Top = 48
        Width = 86
        Height = 13
        Caption = '&Pre-defined filters'
        FocusControl = cbxFileFilters
      end
      object rbUseCustom: TRadioButton
        Left = 8
        Top = 24
        Width = 17
        Height = 17
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbUseCustomClick
      end
      object rbUseDefined: TRadioButton
        Left = 8
        Top = 66
        Width = 17
        Height = 17
        TabOrder = 1
        OnClick = rbUseCustomClick
      end
      object cbxFileFilters: TComboBox
        Left = 32
        Top = 64
        Width = 161
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        OnChange = cbxFileFiltersChange
      end
      object rcbxWildcards: TJvComboBox
        Left = 32
        Top = 22
        Width = 161
        Height = 21
        AutoComplete = False
        ItemHeight = 13
        TabOrder = 2
      end
    end
    object SheetStatus: TTabSheet
      Caption = 'Module &Status'
      ImageIndex = 1
      object Label3: TLabel
        Left = 28
        Top = 16
        Width = 43
        Height = 13
        Alignment = taRightJustify
        Caption = '&Bug filter'
        FocusControl = cbBugFilter
      end
      object cbBugFilter: TComboBox
        Left = 80
        Top = 13
        Width = 128
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'Ignore bug state'
          '>= Minor'
          '>= Awkward'
          '>= Significant'
          '>= Serious'
          '>= Fatal')
      end
    end
  end
  object btnClose: TButton
    Left = 163
    Top = 136
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object btnApply: TButton
    Left = 3
    Top = 136
    Width = 75
    Height = 25
    Caption = '&Apply'
    Default = True
    TabOrder = 1
    OnClick = btnApplyClick
  end
  object btnClear: TButton
    Left = 83
    Top = 136
    Width = 75
    Height = 25
    Caption = '&Clear'
    TabOrder = 2
    OnClick = btnClearClick
  end
end
