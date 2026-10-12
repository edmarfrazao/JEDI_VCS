object VCSSearchModules: TVCSSearchModules
  Left = 319
  Top = 290
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Search Modules'
  ClientHeight = 203
  ClientWidth = 442
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 158
    Width = 442
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      442
      45)
    object Label1: TLabel
      Left = 41
      Top = 4
      Width = 153
      Height = 13
      Caption = '&Mask (available wildcards: *, ?):'
    end
    object Help: TSpeedButton
      Left = 6
      Top = 11
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
      Left = 363
      Top = 11
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Close'
      TabOrder = 3
      OnClick = btnCancelClick
    end
    object btnSearch: TButton
      Left = 201
      Top = 11
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Search'
      Default = True
      Enabled = False
      TabOrder = 1
      OnClick = btnSearchClick
    end
    object btnReport: TButton
      Left = 282
      Top = 11
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Report...'
      TabOrder = 2
      OnClick = btnReportClick
    end
    object rcbxMask: TJvComboBox
      Left = 40
      Top = 19
      Width = 153
      Height = 21
      AutoComplete = False
      ItemHeight = 13
      TabOrder = 0
      OnChange = rcbxMaskChange
    end
  end
  object elvResult: TdfsEnhListView
    Left = 0
    Top = 0
    Width = 442
    Height = 158
    AutoColumnSort = acsSortToggle
    NoColumnResize = False
    ShowSortArrows = True
    Style = lvOwnerDrawFixed
    OnDrawItem = elvResultDrawItem
    OnDrawSubItem = elvResultDrawSubItem
    OnDrawHeader = elvResultDrawHeader
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
      end
      item
        Caption = 'Name'
        Width = 80
      end
      item
        Caption = 'Path'
        Width = 140
      end
      item
        Caption = 'Project'
        Width = 80
      end>
    ReadOnly = True
    HideSelection = False
    PopupMenu = PopupMenu1
    TabOrder = 1
    ViewStyle = vsReport
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 336
    Top = 72
    object mnOpenFile: TMenuItem
      Caption = '&View...'
      Hint = 'View modules'
      ImageIndex = 23
      ShortCut = 113
      OnClick = mnOpenFileClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object mnCheckIn: TMenuItem
      Caption = 'Check &In/ Put...'
      ImageIndex = 3
      OnClick = mnCheckInClick
    end
    object mnCheckOut: TMenuItem
      Caption = 'Check &Out...'
      ImageIndex = 4
      OnClick = mnCheckOutClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnCompare: TMenuItem
      Caption = 'Diff/ &Merge Module...'
      ImageIndex = 24
      OnClick = mnCompareClick
    end
    object ModuleHistory1: TMenuItem
      Caption = 'Module &History'
      ImageIndex = 9
      OnClick = ModuleHistory1Click
    end
    object mnLineHistory: TMenuItem
      Caption = 'Line History'
      ImageIndex = 49
      OnClick = mnLineHistoryClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object mnOpenParentFolder: TMenuItem
      Caption = 'Open &Parent Folder'
      ShortCut = 117
      OnClick = mnOpenParentFolderClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Addtocurrentproject1: TMenuItem
      Caption = '&Add to Current Project'
      OnClick = Addtocurrentproject1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mnOpenProject: TMenuItem
      Caption = 'Open Project'
      OnClick = mnOpenProjectClick
    end
  end
end
