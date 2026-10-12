object VCSSelectFolder: TVCSSelectFolder
  Left = 329
  Top = 228
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Select Folder'
  ClientHeight = 273
  ClientWidth = 292
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
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 292
    Height = 47
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      292
      47)
    object lblStatus: TLabel
      Left = 7
      Top = 3
      Width = 257
      Height = 13
      AutoSize = False
    end
    object rcbxRecent: TJvComboBox
      Left = 8
      Top = 20
      Width = 278
      Height = 21
      AutoComplete = False
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
      OnChange = rcbxRecentChange
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 235
    Width = 292
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      292
      38)
    object Help: TSpeedButton
      Left = 7
      Top = 8
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
    object btnOK: TButton
      Left = 124
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Select'
      Enabled = False
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 208
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnNew: TButton
      Left = 40
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&New Folder'
      TabOrder = 0
      OnClick = btnNewClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 47
    Width = 292
    Height = 188
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object SystemTree: TdfsSystemTreeView
      Left = 0
      Top = 78
      Width = 292
      Height = 110
      PopupMenuMethod = pmmUser
      Align = alClient
      Indent = 19
      OnChange = SystemTreeChange
      PopupMenu = PopupMenu1
      RightClickSelect = True
      TabOrder = 1
    end
    object PanelRecursive: TPanel
      Left = 0
      Top = 0
      Width = 292
      Height = 78
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        292
        78)
      object spBtnSetFilter: TSpeedButton
        Left = 264
        Top = 26
        Width = 22
        Height = 21
        Hint = 'Filter setup'
        Anchors = [akTop, akRight]
        Caption = '...'
        OnClick = spBtnSetFilterClick
      end
      object spBtnExclude: TSpeedButton
        Left = 264
        Top = 51
        Width = 22
        Height = 21
        Hint = 'Exclude filter'
        Anchors = [akTop, akRight]
        Caption = '...'
        OnClick = spBtnExcludeClick
      end
      object Label1: TLabel
        Left = 27
        Top = 31
        Width = 35
        Height = 13
        Caption = '&Include'
        FocusControl = cbxFilters
      end
      object cbRecursive: TCheckBox
        Left = 222
        Top = 3
        Width = 63
        Height = 17
        Alignment = taLeftJustify
        Anchors = [akTop, akRight]
        Caption = '&Recurse'
        TabOrder = 1
      end
      object cbExclude: TCheckBox
        Left = 8
        Top = 53
        Width = 60
        Height = 17
        Caption = '&Exclude'
        TabOrder = 3
        OnClick = cbExcludeClick
      end
      object edExclude: TEdit
        Left = 73
        Top = 51
        Width = 184
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
      end
      object cbxFilters: TComboBox
        Left = 73
        Top = 26
        Width = 184
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
        OnChange = cbxFiltersChange
      end
      object cbProjectFolders: TCheckBox
        Left = 8
        Top = 3
        Width = 139
        Height = 17
        Caption = '&All known project folders'
        TabOrder = 0
        OnClick = cbProjectFoldersClick
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 256
    Top = 200
    object Newfolder1: TMenuItem
      Caption = '&New Folder...'
      ShortCut = 45
      OnClick = btnNewClick
    end
    object Rename1: TMenuItem
      Caption = '&Rename Folder'
      OnClick = Rename1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Mapnetworkdir1: TMenuItem
      Caption = '&Map Network Drive...'
      OnClick = Mapnetworkdir1Click
    end
    object DisconnectNetworkDrive1: TMenuItem
      Caption = '&Disconnect Network Drive...'
      OnClick = DisconnectNetworkDrive1Click
    end
  end
end
