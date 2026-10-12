object fm_Main: Tfm_Main
  Left = 245
  Top = 198
  AutoScroll = False
  Caption = 'JEDI VCS Diff/Merge'
  ClientHeight = 411
  ClientWidth = 947
  Color = clBtnFace
  Constraints.MinHeight = 420
  Constraints.MinWidth = 595
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
  Menu = MainMenu1
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object dfsStatusBar1: TdfsStatusBar
    Left = 0
    Top = 392
    Width = 947
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = '0 - 0/000'
        Enabled = True
        Width = 100
        AutoFit = False
      end
      item
        PanelType = sptEllipsisText
        Text = 'Delta 000 Lines/ 000 Blocks'
        Enabled = True
        Width = 150
        AutoFit = False
        Hint = '...'
      end
      item
        GaugeAttrs.Color = clActiveCaption
        PanelType = sptEllipsisText
        Enabled = True
        Width = 50
        AutoFit = False
        Hint = '...'
      end>
    ParentShowHint = False
    ShowHint = True
    SimplePanel = False
  end
  object Panel7: TPanel
    Left = 0
    Top = 0
    Width = 947
    Height = 68
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ToolBar1: TToolBar
      Left = 0
      Top = 39
      Width = 947
      Height = 29
      Caption = 'ToolBar1'
      EdgeBorders = []
      Flat = True
      Images = ToolImages
      Indent = 4
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Wrapable = False
      object tbEnableEditor: TToolButton
        Left = 4
        Top = 0
        Action = acEnableEditor
        AllowAllUp = True
      end
      object ToolButton2: TToolButton
        Left = 27
        Top = 0
        Action = acUndo
      end
      object ToolButton3: TToolButton
        Left = 50
        Top = 0
        Action = acRedo
      end
      object ToolButton4: TToolButton
        Left = 73
        Top = 0
        Action = acSaveChanges
      end
      object ToolButton5: TToolButton
        Left = 96
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton6: TToolButton
        Left = 104
        Top = 0
        Action = acCompare
        AutoSize = True
        DropdownMenu = popmCompare
        Style = tbsDropDown
      end
      object ToolButton26: TToolButton
        Left = 148
        Top = 0
        Action = acSaveCompare
      end
      object ToolButton7: TToolButton
        Left = 171
        Top = 0
        Width = 8
        Caption = 'ToolButton7'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object ToolButton8: TToolButton
        Left = 179
        Top = 0
        Action = acFirstDiff
      end
      object ToolButton9: TToolButton
        Left = 202
        Top = 0
        Action = acPreviousDiff
      end
      object ToolButton10: TToolButton
        Left = 225
        Top = 0
        Action = acNextDiff
      end
      object ToolButton11: TToolButton
        Left = 248
        Top = 0
        Action = acLastDiff
      end
      object ToolButton12: TToolButton
        Left = 271
        Top = 0
        Width = 8
        Caption = 'ToolButton12'
        ImageIndex = 9
        Style = tbsSeparator
      end
      object ToolButton13: TToolButton
        Left = 279
        Top = 0
        Action = acSearch
        DropdownMenu = popmSearch
        Style = tbsDropDown
      end
      object ToolButton14: TToolButton
        Left = 317
        Top = 0
        Action = acReplace
      end
      object ToolButton15: TToolButton
        Left = 340
        Top = 0
        Width = 8
        Caption = 'ToolButton15'
        ImageIndex = 11
        Style = tbsSeparator
      end
      object ToolButton16: TToolButton
        Left = 348
        Top = 0
        Action = acReport
      end
      object ToolButton17: TToolButton
        Left = 371
        Top = 0
        Width = 8
        Caption = 'ToolButton17'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object cbxHighlighter: TComboBox
        Left = 379
        Top = 0
        Width = 200
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbxHighlighterChange
      end
      object ToolButton19: TToolButton
        Left = 579
        Top = 0
        Action = acHighLightProp
      end
      object ToolButton20: TToolButton
        Left = 602
        Top = 0
        Width = 8
        Caption = 'ToolButton20'
        ImageIndex = 14
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 610
        Top = 0
        Action = acHelp
      end
      object ToolButton25: TToolButton
        Left = 633
        Top = 0
        Width = 8
        Caption = 'ToolButton25'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object ToolButton21: TToolButton
        Left = 641
        Top = 0
        Action = acClose
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 947
      Height = 9
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        947
        9)
      object Bevel1: TBevel
        Left = 0
        Top = 2
        Width = 943
        Height = 2
        Anchors = [akLeft, akTop, akRight]
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 31
      Width = 947
      Height = 8
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      DesignSize = (
        947
        8)
      object Bevel2: TBevel
        Left = 0
        Top = 2
        Width = 944
        Height = 2
        Anchors = [akLeft, akTop, akRight]
      end
    end
    object ToolBar3: TToolBar
      Left = 0
      Top = 9
      Width = 947
      Height = 22
      Caption = 'ToolBar3'
      EdgeBorders = []
      Flat = True
      Images = ToolImages
      Indent = 4
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Wrapable = False
      object rcbSource: TJvComboBox
        Left = 4
        Top = 0
        Width = 350
        Height = 21
        DotNetHighlighting = True
        ItemHeight = 13
        TabOrder = 0
      end
      object ToolButton22: TToolButton
        Left = 354
        Top = 0
        Action = acBrowseSource
      end
      object rcbTarget: TJvComboBox
        Left = 377
        Top = 0
        Width = 350
        Height = 21
        DotNetHighlighting = True
        ItemHeight = 13
        TabOrder = 1
      end
      object ToolButton18: TToolButton
        Left = 727
        Top = 0
        Width = 8
        Caption = 'ToolButton18'
        Style = tbsSeparator
      end
      object ToolButton23: TToolButton
        Left = 735
        Top = 0
        Action = acBrowseTarget
      end
      object ToolButton24: TToolButton
        Left = 758
        Top = 0
        Width = 8
        Caption = 'ToolButton24'
        ImageIndex = 0
        Style = tbsSeparator
      end
      object ToolButton27: TToolButton
        Left = 766
        Top = 0
        Action = acFlip
      end
      object ToolButton33: TToolButton
        Left = 789
        Top = 0
        Width = 8
        Caption = 'ToolButton33'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object ToolButton34: TToolButton
        Left = 797
        Top = 0
        Action = acLastCompare
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 68
    Width = 947
    Height = 324
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 947
      Height = 193
      Align = alClient
      BevelOuter = bvLowered
      Caption = 'Panel4'
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 647
        Top = 1
        Width = 3
        Height = 191
        Cursor = crHSplit
        Align = alRight
      end
      object Panel1: TPanel
        Left = 1
        Top = 1
        Width = 646
        Height = 191
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel1'
        TabOrder = 0
        object mwceSource: TSynEdit
          Left = 0
          Top = 19
          Width = 646
          Height = 153
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          PopupMenu = popmEditor
          TabOrder = 0
          OnClick = mwceSourceClick
          OnEnter = mwceSourceEnter
          OnKeyUp = mwceSourceKeyUp
          BookMarkOptions.BookmarkImages = MarkImages
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Terminal'
          Gutter.Font.Style = []
          Gutter.Width = 35
          Lines.Strings = (
            'mwceSource')
          MaxUndo = 10
          ReadOnly = True
          ScrollBars = ssHorizontal
          SearchEngine = SynEditSearch1
          OnChange = mwceSourceChange
          OnPaint = mwceSourcePaint
          RemovedKeystrokes = <
            item
              Command = ecContextHelp
              ShortCut = 112
            end>
          AddedKeystrokes = <
            item
              Command = ecContextHelp
              ShortCut = 16496
            end>
        end
        object SourceHeader: TPanel
          Left = 0
          Top = 0
          Width = 646
          Height = 19
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = ' -file-'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object SourceFooter: TPanel
          Left = 0
          Top = 172
          Width = 646
          Height = 19
          Align = alBottom
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = 'SourceFooter'
          TabOrder = 2
        end
      end
      object Panel3: TPanel
        Left = 650
        Top = 1
        Width = 296
        Height = 191
        Align = alRight
        BevelOuter = bvNone
        Caption = 'Panel3'
        TabOrder = 1
        object mwceTarget: TSynEdit
          Left = 0
          Top = 19
          Width = 296
          Height = 153
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          PopupMenu = popmEditor
          TabOrder = 0
          OnClick = mwceSourceClick
          OnEnter = mwceSourceEnter
          OnKeyUp = mwceSourceKeyUp
          BookMarkOptions.EnableKeys = False
          BookMarkOptions.GlyphsVisible = False
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Terminal'
          Gutter.Font.Style = []
          Gutter.Visible = False
          Lines.Strings = (
            'mwceTarget')
          MaxUndo = 0
          ReadOnly = True
          SearchEngine = SynEditSearch1
          OnChange = mwceSourceChange
          OnPaint = mwceTargetPaint
          RemovedKeystrokes = <
            item
              Command = ecContextHelp
              ShortCut = 112
            end>
          AddedKeystrokes = <
            item
              Command = ecContextHelp
              ShortCut = 16496
            end>
        end
        object TargetHeader: TPanel
          Left = 0
          Top = 0
          Width = 296
          Height = 19
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = ' -file-'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object TargetFooter: TPanel
          Left = 0
          Top = 172
          Width = 296
          Height = 19
          Align = alBottom
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = 'TargetFooter'
          TabOrder = 2
        end
      end
    end
    object HexViewPanel: TPanel
      Left = 0
      Top = 243
      Width = 947
      Height = 81
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'HexViewPanel'
      TabOrder = 1
      Visible = False
      object Panel8: TPanel
        Left = 0
        Top = 0
        Width = 947
        Height = 19
        Align = alTop
        TabOrder = 0
        DesignSize = (
          947
          19)
        object spBtnHexViewClose: TSpeedButton
          Left = 926
          Top = 0
          Width = 19
          Height = 18
          Hint = 'Close View'
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            BE000000424DBE0000000000000076000000280000000A000000090000000100
            0400000000004800000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777700
            0000700777700700000077007700770000007770000777000000777700777700
            0000777000077700000077007700770000007007777007000000777777777700
            0000}
          ParentShowHint = False
          ShowHint = True
          OnClick = spBtnHexViewCloseClick
        end
        object HexViewLabel: TLabel
          Left = 4
          Top = 3
          Width = 66
          Height = 13
          Caption = 'HexViewLabel'
        end
        object spBtnHexViewRight: TSpeedButton
          Left = 907
          Top = 0
          Width = 19
          Height = 18
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            92000000424D9200000000000000760000002800000006000000070000000100
            0400000000001C00000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00707777007007
            77007000770070000700700077007007770070777700}
          OnClick = spBtnHexViewRightClick
        end
        object spBtnHexViewLeft: TSpeedButton
          Left = 888
          Top = 0
          Width = 19
          Height = 18
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            92000000424D9200000000000000760000002800000006000000070000000100
            0400000000001C00000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777707007770
            07007700070070000700770007007770070077770700}
          OnClick = spBtnHexViewLeftClick
        end
      end
      object HexView: TRichEdit
        Left = 0
        Top = 19
        Width = 947
        Height = 62
        Align = alClient
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
        WantReturns = False
        WordWrap = False
      end
    end
    object WholeLinePanel: TPanel
      Left = 0
      Top = 193
      Width = 947
      Height = 50
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
      object Panel9: TPanel
        Left = 0
        Top = 0
        Width = 947
        Height = 19
        Align = alTop
        TabOrder = 0
        DesignSize = (
          947
          19)
        object spBtnLineViewClose: TSpeedButton
          Left = 928
          Top = 0
          Width = 19
          Height = 18
          Hint = 'Close View'
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            BE000000424DBE0000000000000076000000280000000A000000090000000100
            0400000000004800000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777700
            0000700777700700000077007700770000007770000777000000777700777700
            0000777000077700000077007700770000007007777007000000777777777700
            0000}
          ParentShowHint = False
          ShowHint = True
          OnClick = spBtnLineViewCloseClick
        end
        object WholeLineLabel: TLabel
          Left = 4
          Top = 3
          Width = 74
          Height = 13
          Caption = 'WholeLineLabel'
        end
        object spBtnLineViewRight: TSpeedButton
          Left = 909
          Top = 0
          Width = 19
          Height = 18
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            92000000424D9200000000000000760000002800000006000000070000000100
            0400000000001C00000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00707777007007
            77007000770070000700700077007007770070777700}
          OnClick = spBtnLineViewRightClick
        end
        object spBtnLineViewLeft: TSpeedButton
          Left = 890
          Top = 0
          Width = 19
          Height = 18
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            92000000424D9200000000000000760000002800000006000000070000000100
            0400000000001C00000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777707007770
            07007700070070000700770007007770070077770700}
          OnClick = spBtnLineViewLeftClick
        end
      end
      object LineView: TMemo
        Left = 0
        Top = 19
        Width = 947
        Height = 31
        Align = alClient
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
        WantReturns = False
        WordWrap = False
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 443
    Top = 136
  end
  object StartTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = StartTimerTimer
    Left = 476
    Top = 136
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 347
    Top = 137
  end
  object mwPasSyn1: TSynPasSyn
    DefaultFilter = 'Pascal files (*.pas,*.inc)|*.PAS;*.INC'
    AsmAttri.Background = clWindow
    AsmAttri.Foreground = clWindowText
    CommentAttri.Background = clWindow
    CommentAttri.Foreground = clWindowText
    IdentifierAttri.Background = clWindow
    IdentifierAttri.Foreground = clWindowText
    KeyAttri.Background = clWindow
    KeyAttri.Foreground = clWindowText
    NumberAttri.Background = clWindow
    NumberAttri.Foreground = clWindowText
    SpaceAttri.Background = clWindow
    SpaceAttri.Foreground = clWindowText
    StringAttri.Background = clWindow
    StringAttri.Foreground = clWindowText
    SymbolAttri.Background = clWindow
    SymbolAttri.Foreground = clWindowText
    Left = 474
    Top = 201
  end
  object MainMenu1: TMainMenu
    Images = ToolImages
    Left = 540
    Top = 135
    object File1: TMenuItem
      Caption = '&File'
      object SelectBaseVersion1: TMenuItem
        Action = acBrowseSource
      end
      object SelectTarget1: TMenuItem
        Action = acBrowseTarget
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object Compare1: TMenuItem
        Action = acCompare
      end
      object SaveRecompare1: TMenuItem
        Action = acSaveCompare
      end
      object RepeatLastCompare1: TMenuItem
        Action = acLastCompare
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object SaveChanges1: TMenuItem
        Action = acSaveChanges
      end
      object SaveAs2: TMenuItem
        Caption = 'Save &As...'
        OnClick = SaveAs2Click
      end
      object N14: TMenuItem
        Caption = '-'
      end
      object ReportDifference1: TMenuItem
        Action = acReport
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object Delete1: TMenuItem
        Caption = '&Delete'
        OnClick = Delete1Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = acClose
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object Undo1: TMenuItem
        Action = acUndo
      end
      object Redo1: TMenuItem
        Action = acRedo
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Copy2: TMenuItem
        Action = acEditCopy
      end
      object Cut2: TMenuItem
        Action = acEditCut
      end
      object Paste2: TMenuItem
        Action = acEditPaste
      end
      object N13: TMenuItem
        Caption = '-'
      end
      object acEnableEditor1: TMenuItem
        Action = acEnableEditor
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object Search1: TMenuItem
        Action = acSearch
      end
      object SearchPrevious2: TMenuItem
        Action = acSearchPrev
      end
      object SearchNext2: TMenuItem
        Action = acSearchNext
      end
      object Replace1: TMenuItem
        Action = acReplace
      end
    end
    object GoTo2: TMenuItem
      Caption = '&GoTo'
      object FirstDifference1: TMenuItem
        Action = acFirstDiff
      end
      object PreviousDifference1: TMenuItem
        Action = acPreviousDiff
      end
      object NextDifference1: TMenuItem
        Action = acNextDiff
      end
      object LastDifference1: TMenuItem
        Action = acLastDiff
      end
    end
    object Bookmarks1: TMenuItem
      Caption = '&Bookmarks'
      object Define1: TMenuItem
        Caption = '&Define (Shift+Ctrl+0..9)'
        Enabled = False
        object Bookmark02: TMenuItem
          Caption = 'Bookmark &0'
          OnClick = Bookmark02Click
        end
        object Bookmark12: TMenuItem
          Tag = 1
          Caption = 'Bookmark &1'
          OnClick = Bookmark02Click
        end
        object Bookmark21: TMenuItem
          Tag = 2
          Caption = 'Bookmark &2'
          OnClick = Bookmark02Click
        end
        object Bookmark32: TMenuItem
          Tag = 3
          Caption = 'Bookmark &3'
          OnClick = Bookmark02Click
        end
        object Bookmark42: TMenuItem
          Tag = 4
          Caption = 'Bookmark &4'
          OnClick = Bookmark02Click
        end
        object Bookmark52: TMenuItem
          Tag = 5
          Caption = 'Bookmark &5'
          OnClick = Bookmark02Click
        end
        object Bookmark62: TMenuItem
          Tag = 6
          Caption = 'Bookmark &6'
          OnClick = Bookmark02Click
        end
        object Bookmark72: TMenuItem
          Tag = 7
          Caption = 'Bookmark &7'
          OnClick = Bookmark02Click
        end
        object Bookmark82: TMenuItem
          Tag = 8
          Caption = 'Bookmark &8'
          OnClick = Bookmark02Click
        end
        object Bookmark92: TMenuItem
          Tag = 9
          Caption = 'Bookmark &9'
          OnClick = Bookmark02Click
        end
      end
      object GoTo1: TMenuItem
        Caption = '&Go To  (Ctrl+0..9)'
        Enabled = False
        object Bookmark01: TMenuItem
          Caption = 'Bookmark &0'
          OnClick = Bookmark01Click
        end
        object Bookmark11: TMenuItem
          Tag = 1
          Caption = 'Bookmark &1'
        end
        object Bookmark22: TMenuItem
          Tag = 2
          Caption = 'Bookmark &2'
        end
        object Bookmark31: TMenuItem
          Tag = 3
          Caption = 'Bookmark &3'
        end
        object Bookmark41: TMenuItem
          Tag = 4
          Caption = 'Bookmark &4'
        end
        object Bookmark51: TMenuItem
          Tag = 5
          Caption = 'Bookmark &5'
        end
        object Bookmark61: TMenuItem
          Tag = 6
          Caption = 'Bookmark &6'
        end
        object Bookmark71: TMenuItem
          Tag = 7
          Caption = 'Bookmark &7'
        end
        object Bookmark81: TMenuItem
          Tag = 8
          Caption = 'Bookmark &8'
        end
        object Bookmark91: TMenuItem
          Tag = 9
          Caption = 'Bookmark &9'
        end
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object ClearAll1: TMenuItem
        Caption = '&Clear All'
        OnClick = ClearAll1Click
      end
    end
    object Properties1: TMenuItem
      Caption = '&Properties'
      object EditorProperties1: TMenuItem
        Caption = '&Editor Properties...'
        OnClick = EditorProperties1Click
      end
      object CustomizeHighlighter1: TMenuItem
        Action = acHighLightProp
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object IgnoreWhiteSpace2: TMenuItem
        Action = acIgWSpace
      end
      object HardSpaceA0isWhiteSpace2: TMenuItem
        Action = acHardSpace
      end
      object IgnoreCase2: TMenuItem
        Action = acIgCase
      end
      object acIgLFCR2: TMenuItem
        Action = acIgLFCR
      end
      object IgnoreHTMLTags2: TMenuItem
        Action = acIgHTML
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object DisableBinaryFileChecking1: TMenuItem
        Caption = '&Disable Binary File Checking'
        OnClick = DisableBinaryFileChecking1Click
      end
      object ShowResultDialog1: TMenuItem
        Caption = '&Show Compare Result Dialog'
        OnClick = ShowResultDialog1Click
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object HelpTopics1: TMenuItem
        Action = acHelp
      end
      object About1: TMenuItem
        Caption = '&About'
        OnClick = spBtnAboutClick
      end
    end
  end
  object ActionList1: TActionList
    Images = ToolImages
    Left = 509
    Top = 135
    object acBrowseSource: TAction
      Caption = 'Select &Base Version...'
      Hint = 'Select Base Version'
      ImageIndex = 0
      OnExecute = acBrowseSourceExecute
    end
    object acBrowseTarget: TAction
      Caption = 'Select &Target...'
      Hint = 'Browse'
      ImageIndex = 0
      OnExecute = acBrowseTargetExecute
    end
    object acFlip: TAction
      Caption = 'acFlip'
      Hint = 'Flip Files'
      ImageIndex = 16
      OnExecute = acFlipExecute
    end
    object acLastCompare: TAction
      Caption = 'Repeat &Last Compare'
      Hint = 'Repeat Last Compare'
      ImageIndex = 18
      OnExecute = acLastCompareExecute
    end
    object acEnableEditor: TAction
      Caption = '&Enable Editor'
      Hint = 'Enable Editor'
      ImageIndex = 1
      OnExecute = acEnableEditorExecute
    end
    object acUndo: TAction
      Caption = '&Undo'
      Hint = 'Undo'
      ImageIndex = 7
      OnExecute = acUndoExecute
    end
    object acRedo: TAction
      Caption = '&Redo'
      Hint = 'Redo'
      ImageIndex = 8
      OnExecute = acRedoExecute
    end
    object acSaveChanges: TAction
      Caption = '&Save'
      Enabled = False
      Hint = 'Save'
      ImageIndex = 6
      ShortCut = 16467
      OnExecute = acSaveChangesExecute
    end
    object acCompare: TAction
      Caption = 'Co&mpare'
      Hint = 'Compare'
      ImageIndex = 14
      ShortCut = 113
      OnExecute = acCompareExecute
    end
    object acIgWSpace: TAction
      Caption = 'Ignore &White Space'
      OnExecute = acIgWSpaceExecute
    end
    object acIgCase: TAction
      Caption = '&Ignore Case'
      OnExecute = acIgCaseExecute
    end
    object acIgLFCR: TAction
      Caption = 'Ig&nore CR/LF'
      Hint = 'Ignore CR/LF'
      OnExecute = acIgLFCRExecute
    end
    object acIgHTML: TAction
      Caption = 'Ignore &HTML Tags'
      OnExecute = acIgHTMLExecute
    end
    object acHardSpace: TAction
      Caption = '&Hard Space ($A0) is White Space'
      OnExecute = acHardSpaceExecute
    end
    object acFirstDiff: TAction
      Caption = '&First Difference'
      Hint = 'First Delta'
      ImageIndex = 2
      OnExecute = acFirstDiffExecute
    end
    object acPreviousDiff: TAction
      Caption = '&Previous Difference'
      Hint = 'Previous Delta'
      ImageIndex = 3
      ShortCut = 16464
      OnExecute = acPreviousDiffExecute
    end
    object acNextDiff: TAction
      Caption = '&Next Difference'
      Hint = 'Next Delta'
      ImageIndex = 4
      ShortCut = 16462
      OnExecute = acNextDiffExecute
    end
    object acLastDiff: TAction
      Caption = '&Last Difference'
      Hint = 'Last Delta'
      ImageIndex = 5
      OnExecute = acLastDiffExecute
    end
    object acSearch: TAction
      Caption = '&Search...'
      Hint = 'Search'
      ImageIndex = 11
      OnExecute = acSearchExecute
    end
    object acSearchPrev: TAction
      Caption = 'Search Pre&vious'
      ShortCut = 8306
      OnExecute = acSearchPrevExecute
    end
    object acSearchNext: TAction
      Caption = 'Search &Next'
      ShortCut = 114
      OnExecute = acSearchPrevExecute
    end
    object acReplace: TAction
      Caption = 'Repla&ce...'
      Hint = 'Replace'
      ImageIndex = 15
      OnExecute = acReplaceExecute
    end
    object acReport: TAction
      Caption = '&Report Difference...'
      Hint = 'Report Difference'
      ImageIndex = 9
      OnExecute = acReportExecute
    end
    object acHighLightProp: TAction
      Caption = 'Customize &Highlighter...'
      Hint = 'Customize Highlighter'
      ImageIndex = 17
      OnExecute = acHighLightPropExecute
    end
    object acClose: TAction
      Caption = 'E&xit'
      Hint = 'Exit'
      ImageIndex = 10
      OnExecute = acCloseExecute
    end
    object acHelp: TAction
      Caption = 'Help &Topics'
      Hint = 'Help Topics'
      ImageIndex = 12
      ShortCut = 112
      OnExecute = acHelpExecute
    end
    object acEditCopy: TAction
      Caption = '&Copy'
      ShortCut = 16451
      OnExecute = acEditCopyExecute
    end
    object acEditCut: TAction
      Caption = 'C&ut'
      ShortCut = 16472
      OnExecute = acEditCutExecute
    end
    object acEditPaste: TAction
      Caption = '&Paste'
      ShortCut = 16470
      OnExecute = acEditPasteExecute
    end
    object acSaveCompare: TAction
      Caption = 'Save + Re-Compare'
      Hint = 'Save + Re-Compare'
      ImageIndex = 19
      ShortCut = 120
      OnExecute = acSaveCompareExecute
    end
  end
  object MarkImages: TImageList
    Left = 347
    Top = 106
    Bitmap = {
      494C01010F001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      000000000000000000000000000000000000000000000000000000808000C0C0
      C00000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF00C0C0C0000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      00000000000000000000000000000000000000000000000000000080800000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000000000000000
      00000000000000000000000000000000000000000000000000000080800000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000000000000000000000808000C0C0
      C00000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF00C0C0C0000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000080
      800000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF00008080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000000000000000000000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000008080
      8000C0C0C00000FFFF0000FFFF00000000000000000000FFFF0000FFFF00C0C0
      C000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000000000000000000000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      00000080800000FFFF0000FFFF00000000000000000000FFFF0000FFFF000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000C0C0C00000FFFF00000000000000000000FFFF00C0C0C0008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000FFFF0000FFFF0000FFFF0000FFFF00008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000008080008080800000FFFF0000FFFF0080808000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000808000008080000080800000808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000800000808000000080000000FFFF0000800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000080800000008000008080000000FFFF0080800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF000000000000000000000000000000000000FF
      FF0000FFFF0000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000800000808000000080000000FFFF0000800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000000000000000000000
      000000FFFF0000FFFF00000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF008080000000FFFF0080800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF000000000000000000FF000000C0C0C0008080
      00008080000000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF00008000008080000000FFFF0000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000000000000000000000
      000000FFFF0000FFFF00000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF000000000000000000000000000000000000FF
      FF0000FFFF0000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF0000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF0000FFFF000080000080800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0000080
      000080800000008000008080000000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000000FFFF00008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000800000808000000080000000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000FFFF00808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000080800000008000008080000000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000000FFFF00008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000800000808000000080000000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF00008000008080000000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000080800000008000008080000000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF00808000000080000000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF008080000000800000808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF008080000000800000808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF00008000008080000000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF00808000000080000000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF0000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000800000808000000080000080800000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000FFFF00808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF008080000000800000808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000000FFFF00008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000FFFF00808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000FFFF00808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000000FFFF00008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000080800000008000008080000000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000000FFFF0000FFFF008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF0080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      000000FFFF008080000000FFFF00808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000080800000008000008080000000FFFF0080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      00008080000000FFFF0000FFFF00008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      000000FFFF0000800000808000000080000000FFFF0000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF0000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      0000008000008080000000FFFF00808000000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF0000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0008080
      00000080000000FFFF0000FFFF0000FFFF000080000080800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000C0C0C0000080
      0000808000000080000080800000008000008080000000800000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF0000000000000000000000000000000000000000000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000FF000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFF0000FFFFFF3FFFFF0000
      FFFFFF3FFFFF0000FFFFFFFFE0070000FFFFFF3FC0030000FFFFFF3FC0030000
      E007FFBFC0030000C003FF9FC0030000C003FFCFE0070000E007F9CFE0070000
      FFFFF9CFF00F0000FFFFFC0FF00F0000FFFFFE1FF81F0000FFFFFFFFF81F0000
      FFFFFFFFFC3F0000FFFFFFFFFFFF0000FFFFFFFFFFFFFFFF801F801FFFFFFFFF
      800F800FFE7FFCCF80078007FC3FF8C780078007FC3FF0C380078007FC3FE1E1
      80078007E007C3F080078007C003E1E180078007C003F0C380078007E007F8C7
      80078007FC3FFCCF80078007FC3FFFFF80078007FC3FFFFFC007C007FE7FFFFF
      E00FE00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF801F801F801F801F
      800F800F800F800F800780078007800780078007800780078007800780078007
      8007800780078007800780078007800780078007800780078007800780078007
      800780078007800780078007800780078007800780078007C007C007C007C007
      E00FE00FE00FE00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF801F801F801F801F
      800F800F800F800F800780078007800780078007800780078007800780078007
      8007800780078007800780078007800780078007800780078007800780078007
      800780078007800780078007800780078007800780078007C007C007C007C007
      E00FE00FE00FE00FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object ToolImages: TImageList
    Left = 380
    Top = 106
    Bitmap = {
      494C010114001800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000006000000001002000000000000060
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000BFBFBF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF000000
      00000000000000FFFF0000000000000000000000000000FFFF00000000000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF000000000000FFFF000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000000000FFFFFF000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000008080800000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000000000FFFFFF007F7F7F00FFFFFF000000000000FFFF0000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF0000FF
      FF0000000000FFFFFF0000FFFF007F7F7F0000FFFF00FFFFFF000000000000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF0000FFFF0000FF
      FF000000000000FFFF00FFFFFF007F7F7F00FFFFFF0000FFFF000000000000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      800000000000000000000000000000000000000000000000000000FFFF0000FF
      FF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000000000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000000000000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000000000FFFFFF0000FFFF00FFFFFF000000000000FFFF0000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000000000000000000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080000000000000000000000000000000
      000080808000000000000000000000000000000000000000000000FFFF000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000080000000FFFF0000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF008080
      80008080800080808000FFFFFF00000000000000000000000000000000008000
      0000FFFF0000FF000000FF000000000000000000000000000000000000008080
      800080808000808080000000FF000000FF008080800000000000808080000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00BFBFBF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000000080000000FFFF
      0000FF000000FF000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF0000000000808080000000
      0000000000000000000080808000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF008080
      800080808000808080000000000000000000000000008080800000000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF000000000000000000FFFF00008080800000000000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF00000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF008080
      800000000000FFFFFF00FFFF000000000000FFFF00008080800000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF0000000000FFFF0000FFFFFF00FFFF000000000000FFFF0000000000008080
      800080808000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF0000000000FFFFFF00FFFF0000FFFFFF00FFFF00000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000008080
      8000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000000000000000000000FFFF0000FFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFF0000FFFFFF0000000000808080008080
      800080808000FFFFFF0000000000000000000000000000000000000000008080
      8000000000000000000080808000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      000000FFFF00000000000000000000000000000000000000000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F7F7F0000FFFF007F7F7F0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000000000000000000008080800000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000FFFF0000FFFF000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF00000000000000000000FFFF0000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0080808000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF0000000000000000007F7F7F0000FFFF007F7F7F0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000008000FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      8000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000080000000
      800000008000FFFFFF0000000000000000000000000000000000000000000000
      000000008000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000080000000
      800000008000FFFFFF0000000000000000000000000000000000000000000000
      8000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      80000000800000008000FFFFFF00000000000000000000000000000080000000
      8000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000C0C0C0000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000080000000800000008000FFFFFF00000000000000800000008000FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000C0C0C0000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000800000008000000080000000800000008000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000080000000800000008000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000800000008000000080000000800000008000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000080000000800000008000FFFFFF000000000000008000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000080000000
      80000000800000008000FFFFFF00000000000000000000000000000080000000
      8000FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF008000
      0000FFFFFF008000000080000000800000008000000080000000800000008000
      0000FFFFFF000000000000000000000000000000000000008000000080000000
      800000008000FFFFFF0000000000000000000000000000000000000000000000
      800000008000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000800000008000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000800000008000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF0000BFBF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF0000BFBF0000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF0000BFBF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF0000BFBF0000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BFBF000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF0000000000FFFF
      FF000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF000000000000000000000000000000
      000000000000000000000000000000000000FFFF0000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF00000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF00000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF0000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000BFBF0000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBF0000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF000000000000000000000000000000
      000000000000000000000000000000000000FFFF00000000000000FFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000000000000000BFBF
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      000000000000000000000000000000000000000000000000000000000000BFBF
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00000000000000000000FFFF0000000000FFFFFF00FFFF
      FF000000000000000000FFFFFF00000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF0000BFBF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000BFBF0000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBF0000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000BFBF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000000000FFFFFF00FFFFFF000000000000000000FFFF
      FF0000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000600000000100010000000000000300000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFEFFFFFFFFFFFFFFFC7FFFFFFFFF
      F3FFFC7FFFFFFFFFE787D837FFFFFE7FEFC7E00FFBEFFC3FEFC7E00FF3CFF81F
      E737C007E38FF90FF07FC007C30FFB87FFFF0001820FFFC7FFCFC007C30FFFE7
      E1E7C007E38FFFF7E3F7E00FF3CFFFFFE3F7E00FFBEFFFFFECE7D837FFFFFFFF
      FE0FFEFFFFFFFFFFFFFFFEFFFFFFFFFFFEFFFE7FFFFFFFFFFC7FFE1F80F9FFC7
      FEFFFC0780F1FF9BFFFFFC0180E1E019FEFFF80080C3C019FC7FF8008027FC8B
      FC7F00008201FD87FC7F00008101F79FFC3F00018081E19FF61F00328041C9BF
      E30F003E8001C9FBE38F003EFC01F981E00F003EFF01D3FBF01F001DFF01E7FF
      F83F0023FF01FFFFFFFF003FFF07FFFFFFFFFFFFFFFFFFFFFFFFE003FFFF83E0
      FFFFC003FFF983E0FFFFC003E7FF83E0FFFFC003C3F38080E7FFC003C3E78000
      CF83C003E1C78000DFC3C003F08F8000DFE3C003F81FC001DFD3C003FC3FE083
      CF3BC003F81FE083E0FFC003F09FF1C7FFFFC003C1C7F1C7FFFFC00383E3F1C7
      FFFFC0078FF1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC001FFFF
      FFFFFFFF8031FFFFFEFFFEF78031FFFFFE7FFE778031FFFFFE3FFE378001FFE7
      E01FE0178001C1F3E00FE0078001C3FBE007E0078FF1C7FBE00FE0078FF1CBFB
      E01FE0178FF1DCF3FE3FFE378FF1FF07FE7FFE778FF1FFFFFEFFFEF78FF5FFFF
      FFFFFFFF8001FFFFFFFFFFFFFFFFFFFFBFFFFC00FFFFFFFFBFFFFC00FFFFFFFF
      B0492000FFFFFFFF807F0000DEFFFEFFB07F0000DCFFFCFFB9FF0000D8FFF8FF
      BFFF0000D00FF00FB0490000C00FE00F807F0000C00FC00FB07F0000C00FE00F
      B9FFE000D00FF00FBFFFF800D8FFF8FF048FF000DCFFFCFF07FFE001DEFFFEFF
      07FFC403FFFFFFFF9FFFEC07FFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object FindDialog1: TFindDialog
    Options = [frDown, frHideUpDown]
    OnFind = FindDialog1Find
    Left = 379
    Top = 137
  end
  object mwGeneralSyn1: TSynGeneralSyn
    CommentAttri.Background = clWindow
    CommentAttri.Foreground = clWindowText
    Comments = []
    DetectPreprocessor = False
    IdentifierAttri.Background = clWindow
    IdentifierAttri.Foreground = clWindowText
    IdentifierChars = 
      '!"#$%&'#39'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`' +
      'abcdefghijklmnopqrstuvwxyz{|}~'#8364#129#8218#402#8222#8230#8224#8225#710#8240#352#8249#338#141#381#143#144#8216#8217#8220#8221#8226#8211#8212#732#8482#353#8250#339#157#382#376#160 +
      #161#162#163#164#165#166#167#168#169#170#171#172#173#174#175#176#177#178#179#180#181#182#183#184#185#186#187#188#189#190#191#192#193#194#195#196#197#198#199#200#201#202#203#204#205#206#207#208#209#210#211#212#213#214#215#216#217#218#219#220#221#222#223#224 +
      #225#226#227#228#229#230#231#232#233#234#235#236#237#238#239#240#241#242#243#244#245#246#247#248#249#250#251#252#253#254#255
    KeyAttri.Background = clWindow
    KeyAttri.Foreground = clWindowText
    NumberAttri.Background = clWindow
    NumberAttri.Foreground = clWindowText
    SpaceAttri.Background = clWindow
    SpaceAttri.Foreground = clWindowText
    StringAttri.Background = clWindow
    StringAttri.Foreground = clWindowText
    SymbolAttri.Background = clWindow
    SymbolAttri.Foreground = clWindowText
    Left = 571
    Top = 169
  end
  object hkHTMLSyn1: TSynHTMLSyn
    DefaultFilter = 'HTML Document (*.htm,*.html)|*.htm;*.html'
    Left = 379
    Top = 169
  end
  object mwCSSSyn1: TSynCssSyn
    Left = 411
    Top = 169
  end
  object mwJScriptSyn1: TSynJScriptSyn
    DefaultFilter = 'Javascript files (*.js)|*.js'
    Left = 379
    Top = 201
  end
  object ReplaceDialog1: TReplaceDialog
    OnFind = FindDialog1Find
    OnReplace = ReplaceDialog1Replace
    Left = 411
    Top = 137
  end
  object popmCompare: TPopupMenu
    Left = 411
    Top = 106
    object IgnoreWhiteSpace1: TMenuItem
      Action = acIgWSpace
    end
    object HardSpaceA0isWhiteSpace1: TMenuItem
      Action = acHardSpace
    end
    object IgnoreCase1: TMenuItem
      Action = acIgCase
    end
    object acIgLFCR1: TMenuItem
      Action = acIgLFCR
    end
    object IgnoreHTMLTags1: TMenuItem
      Action = acIgHTML
    end
  end
  object popmSearch: TPopupMenu
    Left = 443
    Top = 106
    object SearchPrevious1: TMenuItem
      Action = acSearchPrev
    end
    object SearchNext1: TMenuItem
      Action = acSearchNext
    end
  end
  object popmEditor: TPopupMenu
    OnPopup = popmEditorPopup
    Left = 477
    Top = 105
    object Copy1: TMenuItem
      Action = acEditCopy
    end
    object Cut1: TMenuItem
      Action = acEditCut
    end
    object Paste1: TMenuItem
      Action = acEditPaste
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object CopyLinetoleftEditor1: TMenuItem
      Caption = 'Copy &Line to left Editor'
      ShortCut = 16460
      OnClick = CopyLinetoleftEditor1Click
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object ShowDiffasHexCode1: TMenuItem
      Caption = 'Show Diff as &Hex Code'
      ShortCut = 16456
      OnClick = ShowDiffasHexCode1Click
    end
    object ShowcompleteLines1: TMenuItem
      Caption = 'Sho&w complete Lines'
      OnClick = ShowcompleteLines1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object DeleteFile1: TMenuItem
      Caption = '&Delete File'
      OnClick = Delete1Click
    end
  end
  object JvMruListSource: TJvMruList
    OnEnumText = JvMruListSourceEnumText
    Active = False
    Left = 80
    Top = 8
  end
  object SynDfmSyn1: TSynDfmSyn
    Left = 440
    Top = 168
  end
  object SynCppSyn1: TSynCppSyn
    DefaultFilter = 'C++ Files (*.c,*.cpp,*.h,*.hpp)|*.c;*.cpp;*.h;*.hpp'
    Left = 472
    Top = 168
  end
  object SynCacheSyn1: TSynCacheSyn
    DefaultFilter = 'Cache Files (*.mac,*.inc,*.int)|*.mac;*.inc;*.int'
    Left = 504
    Top = 168
  end
  object SynCACSyn1: TSynCACSyn
    DefaultFilter = 'CA-Clipper Files (*.prg,*.ch,*.inc)|*.prg;*.ch;*.inc'
    Left = 536
    Top = 168
  end
  object SynCPMSyn1: TSynCPMSyn
    Left = 408
    Top = 200
  end
  object SynIdlSyn1: TSynIdlSyn
    Left = 440
    Top = 200
  end
  object SynFortranSyn1: TSynFortranSyn
    Left = 504
    Top = 200
  end
  object SynFoxproSyn1: TSynFoxproSyn
    Left = 536
    Top = 200
  end
  object SynIniSyn1: TSynIniSyn
    Left = 568
    Top = 200
  end
  object SynInnoSyn1: TSynInnoSyn
    DefaultFilter = 'Inno Setup Script Files (*.iss)|*.iss'
    Left = 376
    Top = 232
  end
  object SynJavaSyn1: TSynJavaSyn
    Left = 408
    Top = 232
  end
  object SynM3Syn1: TSynM3Syn
    Left = 440
    Top = 232
  end
  object SynVBScriptSyn1: TSynVBScriptSyn
    Left = 472
    Top = 232
  end
  object SynBatSyn1: TSynBatSyn
    Left = 504
    Top = 232
  end
  object SynPerlSyn1: TSynPerlSyn
    DefaultFilter = 'Perl Files (*.pl,*.pm,*.cgi)|*.pl;*.pm;*.cgi'
    Left = 536
    Top = 232
  end
  object SynPHPSyn1: TSynPHPSyn
    DefaultFilter = 
      'PHP Files (*.php,*.php3,*.phtml,*.inc)|*.php;*.php3;*.phtml;*.in' +
      'c'
    Left = 568
    Top = 232
  end
  object SynProgressSyn1: TSynProgressSyn
    DefaultFilter = 'Progress Files (*.w,*.p,*.i)|*.w;*.p;*.i'
    Left = 376
    Top = 264
  end
  object SynPythonSyn1: TSynPythonSyn
    Left = 408
    Top = 264
  end
  object SynSQLSyn1: TSynSQLSyn
    SQLDialect = sqlSybase
    Left = 440
    Top = 264
  end
  object SynTclTkSyn1: TSynTclTkSyn
    Left = 472
    Top = 264
  end
  object SynVBSyn1: TSynVBSyn
    Left = 504
    Top = 264
  end
  object SynAsmSyn1: TSynAsmSyn
    Left = 536
    Top = 264
  end
  object SynXMLSyn1: TSynXMLSyn
    DefaultFilter = 
      'XML Document (*.xml,*.xsd,*.xsl,*.xslt,*.dtd)|*.xml;*.xsd;*.xsl;' +
      '*.xslt;*.dtd'
    WantBracesParsed = False
    Left = 568
    Top = 264
  end
  object JvMruListTarget: TJvMruList
    OnEnumText = JvMruListTargetEnumText
    Active = False
    Left = 368
    Top = 8
  end
  object SynEditSearch1: TSynEditSearch
    Left = 344
    Top = 168
  end
end
