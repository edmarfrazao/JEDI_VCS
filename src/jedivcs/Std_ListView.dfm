object VCSStdListView: TVCSStdListView
  Left = 398
  Top = 268
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'VCSStdListView'
  ClientHeight = 183
  ClientWidth = 232
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 149
    Width = 232
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      232
      34)
    object lblHint: TLabel
      Left = 40
      Top = 12
      Width = 14
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object Help: TSpeedButton
      Left = 6
      Top = 6
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
    object btnClose: TButton
      Left = 149
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Close'
      Default = True
      TabOrder = 1
      OnClick = btnCloseClick
    end
    object btnReport: TButton
      Left = 64
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Report...'
      TabOrder = 0
      OnClick = btnReportClick
    end
  end
  object elv: TdfsEnhListView
    Left = 0
    Top = 0
    Width = 232
    Height = 149
    AutoColumnSort = acsSortToggle
    NoColumnResize = False
    ShowSortArrows = True
    Style = lvOwnerDrawFixed
    OnDrawItem = elvDrawItem
    OnDrawSubItem = elvDrawSubItem
    OnDrawHeader = elvDrawHeader
    Align = alClient
    Columns = <>
    ReadOnly = True
    HideSelection = False
    OnChange = elvChange
    TabOrder = 0
    ViewStyle = vsReport
  end
  object popmDeserted: TPopupMenu
    Left = 16
    Top = 56
    object ModuleHistory1: TMenuItem
      Caption = 'Module &History'
      OnClick = ModuleHistory1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Addtocurrentproject1: TMenuItem
      Caption = '&Add to Current Project'
      OnClick = Addtocurrentproject1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Removefromarchive1: TMenuItem
      Caption = '&Remove from Archive'
      OnClick = Removefromarchive1Click
    end
  end
  object popmDeletedP: TPopupMenu
    Left = 16
    Top = 24
    object Restoreproject1: TMenuItem
      Caption = '&Restore Project'
      OnClick = Restoreproject1Click
    end
  end
  object popmCompDate: TPopupMenu
    Left = 48
    Top = 24
    object SelectAll1: TMenuItem
      Caption = '&Select All'
      OnClick = SelectAll1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object CopyModulesto1: TMenuItem
      Caption = '&Copy Modules to...'
      OnClick = CopyModulesto1Click
    end
  end
  object popmUsedBugs: TPopupMenu
    Left = 48
    Top = 56
    object RemoveBug1: TMenuItem
      Caption = '&Remove Bug'
      OnClick = RemoveBug1Click
    end
  end
  object popmSharedby: TPopupMenu
    OnPopup = popmSharedbyPopup
    Left = 81
    Top = 25
    object mnOpenFile: TMenuItem
      Caption = '&View...'
      Hint = 'View modules'
      ImageIndex = 23
      ShortCut = 113
      OnClick = mnOpenFileClick
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object mnCheckIn: TMenuItem
      Caption = 'Check &In/ Put...'
      ImageIndex = 3
      OnClick = mnCheckInClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object mnUndoCheckOut: TMenuItem
      Caption = '&Undo CheckOut'
      ImageIndex = 18
      OnClick = mnUndoCheckOutClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object ShowsharedBy1: TMenuItem
      Caption = 'Show shared &By'
      ImageIndex = 28
      OnClick = ShowsharedBy1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object mnCompare: TMenuItem
      Caption = 'Diff/ &Merge Module...'
      ImageIndex = 24
      OnClick = mnCompareClick
    end
    object mnHistory: TMenuItem
      Caption = 'Module &History'
      ImageIndex = 9
      OnClick = mnHistoryClick
    end
    object mnLineHistory: TMenuItem
      Caption = 'Line History'
      ImageIndex = 49
      OnClick = mnLineHistoryClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object mnOpenParentFolder: TMenuItem
      Caption = 'Open &Parent Folder'
      ShortCut = 117
      OnClick = mnOpenParentFolderClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object mnOpenProject: TMenuItem
      Caption = 'Open First Available Project'
      OnClick = mnOpenProjectClick
    end
  end
  object popMCleanSeq: TPopupMenu
    Left = 80
    Top = 56
    object Movetorecyclebin1: TMenuItem
      Caption = '&Move to Recycle Bin'
      OnClick = Movetorecyclebin1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Delete1: TMenuItem
      Caption = '&Delete'
      OnClick = Movetorecyclebin1Click
    end
  end
  object popmLabelUsedby: TPopupMenu
    Left = 112
    Top = 56
  end
  object ShowTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = ShowTimerTimer
    Left = 152
    Top = 56
  end
end
