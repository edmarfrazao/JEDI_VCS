object JVCSBrowserFrm: TJVCSBrowserFrm
  Left = 0
  Top = 0
  Width = 738
  Height = 432
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 738
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lbRefreshWait: TLabel
      Left = 376
      Top = 13
      Width = 184
      Height = 13
      Caption = 'Server request: File list. Please wait...'
      Visible = False
    end
    object btnRefresh: TButton
      Left = 0
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Refresh'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object edDirectory: TEdit
      Left = 81
      Top = 10
      Width = 289
      Height = 21
      TabOrder = 1
      OnKeyDown = edDirectoryKeyDown
    end
  end
  object VST: TVirtualStringTree
    Left = 0
    Top = 41
    Width = 738
    Height = 391
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    Header.Style = hsFlatButtons
    Images = ImageList
    PopupMenu = popmSharedby
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnDblClick = VSTDblClick
    OnGetText = VSTGetText
    OnGetImageIndex = VSTGetImageIndex
    Columns = <
      item
        Position = 0
        Width = 144
        WideText = 'Name'
      end
      item
        Position = 1
        Width = 56
        WideText = 'Revision'
      end
      item
        Alignment = taRightJustify
        Position = 2
        Width = 56
        WideText = 'Size'
      end
      item
        Position = 3
        Width = 112
        WideText = 'Date'
      end
      item
        Position = 4
        Width = 96
        WideText = 'Author'
      end
      item
        Position = 5
        Width = 368
        WideText = 'Comment'
      end>
  end
  object ImageList: TImageList
    ShareImages = True
    Left = 192
    Top = 48
  end
  object popmSharedby: TPopupMenu
    OnPopup = popmSharedbyPopup
    Left = 105
    Top = 81
    object mnOpenFile: TMenuItem
      Caption = '&View...'
      Hint = 'View modules'
      ImageIndex = 23
      ShortCut = 113
      OnClick = mnOpenFileClick
    end
    object N2: TMenuItem
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
  object RefreshWaitTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = RefreshWaitTimerTimer
    Left = 232
    Top = 48
  end
end
