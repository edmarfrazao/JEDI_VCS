object VCSSync: TVCSSync
  Left = 301
  Top = 200
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'VCS Synchronize/ Restore'
  ClientHeight = 405
  ClientWidth = 672
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
  PopupMenu = PopupMenu1
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object JvNetscapeSplitter1: TJvNetscapeSplitter
    Left = 149
    Top = 0
    Height = 335
    Cursor = crHSplit
    Align = alLeft
    MinSize = 1
    Maximized = False
    Minimized = False
    ButtonCursor = crDefault
  end
  object Panel1: TPanel
    Left = 575
    Top = 0
    Width = 97
    Height = 335
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      97
      335)
    object Help: TSpeedButton
      Left = 13
      Top = 303
      Width = 75
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
    object TransLED1: TJvLED
      Left = 80
      Top = 112
    end
    object btnSync: TButton
      Left = 13
      Top = 2
      Width = 75
      Height = 25
      Caption = '&Sync'
      Default = True
      TabOrder = 0
      OnClick = btnSyncClick
    end
    object btnClose: TButton
      Left = 13
      Top = 59
      Width = 75
      Height = 25
      Caption = '&Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
    object btnVerify: TButton
      Left = 13
      Top = 88
      Width = 75
      Height = 25
      Caption = '&Verify'
      TabOrder = 2
      OnClick = btnVerifyClick
    end
    object btnCompare: TButton
      Left = 13
      Top = 202
      Width = 75
      Height = 25
      Caption = 'Co&mpare'
      TabOrder = 4
      OnClick = btnCompareClick
    end
    object GroupBox3: TGroupBox
      Left = 8
      Top = 115
      Width = 85
      Height = 86
      Caption = ' Select: '
      TabOrder = 3
      object rbselOld: TRadioButton
        Left = 3
        Top = 14
        Width = 72
        Height = 17
        Caption = '&newer files'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbselOldClick
      end
      object rbSelDiff: TRadioButton
        Left = 3
        Top = 32
        Width = 78
        Height = 17
        Caption = 'different files'
        TabOrder = 1
        OnClick = rbselOldClick
      end
      object cbCRC32: TCheckBox
        Left = 4
        Top = 51
        Width = 72
        Height = 17
        Caption = 'by CRC32'
        TabOrder = 2
        OnClick = cbCRC32Click
      end
      object cbROFlag: TCheckBox
        Left = 4
        Top = 67
        Width = 72
        Height = 17
        Caption = 'by RO flag'
        TabOrder = 3
        OnClick = cbROFlagClick
      end
    end
    object btnHistory: TButton
      Left = 13
      Top = 252
      Width = 75
      Height = 25
      Caption = 'Histor&y'
      TabOrder = 5
      OnClick = btnHistoryClick
    end
    object btnReport: TButton
      Left = 13
      Top = 277
      Width = 75
      Height = 25
      Caption = 'R&eport'
      TabOrder = 6
      OnClick = btnReportClick
    end
    object btnSearchFiles: TButton
      Left = 12
      Top = 30
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Search &Files'
      TabOrder = 7
      OnClick = btnSearchFilesClick
    end
    object btnDiff: TButton
      Left = 13
      Top = 227
      Width = 75
      Height = 25
      Caption = 'Diff'
      TabOrder = 8
      OnClick = btnCompareClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 335
    Width = 672
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      672
      70)
    object GroupBox1: TGroupBox
      Left = 8
      Top = 2
      Width = 656
      Height = 45
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        '&Target folder (selecting a different folder will break the modu' +
        'le'#39's history)'
      TabOrder = 0
      DesignSize = (
        656
        45)
      object spBtnBrowse: TSpeedButton
        Left = 623
        Top = 16
        Width = 23
        Height = 22
        Hint = 'Browse...'
        Anchors = [akTop, akRight]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00303333333333
          333337F3333333333333303333333333333337F33FFFFF3FF3FF303300000300
          300337FF77777F77377330000BBB0333333337777F337F33333330330BB00333
          333337F373F773333333303330033333333337F3377333333333303333333333
          333337F33FFFFF3FF3FF303300000300300337FF77777F77377330000BBB0333
          333337777F337F33333330330BB00333333337F373F773333333303330033333
          333337F3377333333333303333333333333337FFFF3FF3FFF333000003003000
          333377777F77377733330BBB0333333333337F337F33333333330BB003333333
          333373F773333333333330033333333333333773333333333333}
        NumGlyphs = 2
        OnClick = spBtnBrowseClick
      end
      object rbChkInfld: TRadioButton
        Left = 8
        Top = 19
        Width = 233
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Origin &folder'
        TabOrder = 0
        TabStop = True
        OnClick = rbChkInfldClick
      end
      object rbNewfldr: TRadioButton
        Left = 91
        Top = 19
        Width = 15
        Height = 17
        TabOrder = 1
        OnClick = rbChkInfldClick
      end
      object rcbxNewFolder: TJvComboBox
        Left = 112
        Top = 16
        Width = 505
        Height = 21
        AutoComplete = False
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
      end
    end
    object StatusBar: TdfsStatusBar
      Left = 0
      Top = 51
      Width = 672
      Height = 19
      Panels = <
        item
          Enabled = True
          Width = 100
          AutoFit = False
        end
        item
          GaugeAttrs.Style = gsIndeterminate2
          GaugeAttrs.Position = 100
          GaugeAttrs.Speed = 0
          GaugeAttrs.Color = clGreen
          Alignment = taCenter
          Bevel = pbNone
          PanelType = sptOwnerDraw
          Enabled = False
          Width = 19
          AutoFit = False
          OnDrawPanel = StatusBarPanels1DrawPanel
        end
        item
          Enabled = True
          Width = 100
          AutoFit = False
        end>
      SimplePanel = False
    end
  end
  object Panel5: TPanel
    Left = 159
    Top = 0
    Width = 416
    Height = 335
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 416
      Height = 288
      ActivePage = SheetDate
      Align = alClient
      TabIndex = 0
      TabOrder = 0
      OnChange = PageControl1Change
      object SheetDate: TTabSheet
        Caption = 'Synchroni&ze to latest'
        object lvDateItems: TdfsEnhListView
          Left = 0
          Top = 0
          Width = 408
          Height = 260
          AutoColumnSort = acsSortToggle
          NoColumnResize = False
          ShowSortArrows = True
          OnSortItems = lvSortItems
          Align = alClient
          OnClick = lvDateItemsClick
          Columns = <
            item
              Caption = 'File'
              Width = 130
            end
            item
              Alignment = taCenter
              Caption = 'Ver/ Rev'
              Width = 60
            end
            item
              Caption = 'Date'
              Width = 100
            end
            item
              Caption = 'CRC32'
              Width = 80
            end
            item
              Caption = 'Original path'
              Width = 150
            end
            item
              Alignment = taRightJustify
              Caption = 'M ID'
            end
            item
              Caption = 'R ID'
            end
            item
              Caption = 'Parent'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Date Val'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Project_ID'
              Width = 0
            end
            item
              Caption = 'Diff Type'
              Width = 0
            end>
          ReadOnly = True
          HideSelection = False
          OnMouseDown = lvDateItemsMouseDown
          TabOrder = 0
          ViewStyle = vsReport
          OnKeyDown = lvDateItemsKeyDown
          SmallImages = SysImageList
          StateImages = StateImageList
        end
      end
      object SheetVer: TTabSheet
        Caption = 'Restore version n&umber'
        ImageIndex = 2
        object Panel7: TPanel
          Left = 0
          Top = 0
          Width = 408
          Height = 29
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object Label1: TLabel
            Left = 3
            Top = 8
            Width = 39
            Height = 13
            Alignment = taRightJustify
            Caption = 'Vers&ion:'
            FocusControl = speVer
          end
          object Label4: TLabel
            Left = 124
            Top = 8
            Width = 44
            Height = 13
            Alignment = taRightJustify
            Caption = 'Revisi&on:'
            FocusControl = speRev
          end
          object speVer: TJvSpinEdit
            Left = 44
            Top = 4
            Width = 57
            Height = 21
            BeepOnError = False
            ButtonKind = bkStandard
            TabOrder = 0
            OnChange = speVerChange
            ClipboardCommands = []
          end
          object speRev: TJvSpinEdit
            Left = 172
            Top = 4
            Width = 57
            Height = 21
            BeepOnError = False
            ButtonKind = bkStandard
            TabOrder = 1
            ClipboardCommands = []
          end
        end
        object lvVersion: TdfsEnhListView
          Left = 0
          Top = 29
          Width = 408
          Height = 231
          AutoColumnSort = acsSortToggle
          NoColumnResize = False
          ShowSortArrows = True
          OnSortItems = lvSortItems
          Align = alClient
          OnClick = lvDateItemsClick
          Columns = <
            item
              Caption = 'File'
              Width = 130
            end
            item
              Alignment = taCenter
              Caption = 'Ver/ Rev'
              Width = 60
            end
            item
              Caption = 'Date'
              Width = 100
            end
            item
              Caption = 'CRC32'
              Width = 80
            end
            item
              Caption = 'Original path'
              Width = 100
            end
            item
              Caption = 'M ID'
            end
            item
              Alignment = taRightJustify
              Caption = 'R ID'
            end
            item
              Caption = 'Parent'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Date Val'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Project_ID'
              Width = 0
            end
            item
              Caption = 'Diff Type'
              Width = 0
            end>
          ReadOnly = True
          HideSelection = False
          OnMouseDown = lvDateItemsMouseDown
          TabOrder = 1
          ViewStyle = vsReport
          OnKeyDown = lvDateItemsKeyDown
          SmallImages = SysImageList
          StateImages = StateImageList
        end
      end
      object SheetKey: TTabSheet
        Caption = 'Restore &labeled version'
        ImageIndex = 1
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 408
          Height = 29
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          DesignSize = (
            408
            29)
          object Label2: TLabel
            Left = 0
            Top = 8
            Width = 29
            Height = 13
            Alignment = taRightJustify
            Caption = 'L&abel:'
          end
          object ecbxKeyword: TJvComboBox
            Left = 40
            Top = 4
            Width = 251
            Height = 21
            AutoComplete = False
            Style = csDropDownList
            Anchors = [akLeft, akTop, akRight]
            ItemHeight = 0
            TabOrder = 0
            OnChange = ecbxKeywordChange
          end
        end
        object lvKWItems: TdfsEnhListView
          Left = 0
          Top = 29
          Width = 408
          Height = 231
          AutoColumnSort = acsSortToggle
          NoColumnResize = False
          ShowSortArrows = True
          OnSortItems = lvSortItems
          Align = alClient
          OnClick = lvDateItemsClick
          Columns = <
            item
              Caption = 'File'
              Width = 130
            end
            item
              Alignment = taCenter
              Caption = 'Ver/ Rev'
              Width = 60
            end
            item
              Caption = 'Date'
              Width = 100
            end
            item
              Caption = 'CRC32'
              Width = 80
            end
            item
              Caption = 'Original path'
              Width = 100
            end
            item
              Caption = 'M ID'
            end
            item
              Alignment = taRightJustify
              Caption = 'R ID'
            end
            item
              Caption = 'Parent'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Date Val'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Project_ID'
              Width = 0
            end
            item
              Caption = 'Diff Type'
              Width = 0
            end>
          ReadOnly = True
          HideSelection = False
          OnMouseDown = lvDateItemsMouseDown
          TabOrder = 1
          ViewStyle = vsReport
          OnKeyDown = lvDateItemsKeyDown
          SmallImages = SysImageList
          StateImages = StateImageList
        end
      end
      object SheetRollBack: TTabSheet
        Caption = 'Roll&back'
        ImageIndex = 3
        object TPanel
          Left = 0
          Top = 0
          Width = 408
          Height = 29
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object Date: TLabel
            Left = 3
            Top = 8
            Width = 27
            Height = 13
            Alignment = taRightJustify
            Caption = '&Date:'
          end
          object dtpRollbackDate: TDateTimePicker
            Left = 40
            Top = 4
            Width = 104
            Height = 21
            CalAlignment = dtaLeft
            Date = 36744.9192192824
            Time = 36744.9192192824
            DateFormat = dfShort
            DateMode = dmComboBox
            Kind = dtkDate
            ParseInput = False
            TabOrder = 0
            OnChange = dtpRollbackDateChange
          end
          object dtpRollbackTime: TDateTimePicker
            Left = 148
            Top = 4
            Width = 104
            Height = 21
            CalAlignment = dtaLeft
            Date = 36744.9193852662
            Time = 36744.9193852662
            DateFormat = dfShort
            DateMode = dmComboBox
            Kind = dtkTime
            ParseInput = False
            TabOrder = 1
          end
        end
        object lvRollBack: TdfsEnhListView
          Left = 0
          Top = 29
          Width = 408
          Height = 231
          AutoColumnSort = acsSortToggle
          NoColumnResize = False
          ShowSortArrows = True
          OnSortItems = lvSortItems
          Align = alClient
          OnClick = lvDateItemsClick
          Columns = <
            item
              Caption = 'File'
              Width = 130
            end
            item
              Alignment = taCenter
              Caption = 'Ver/ Rev'
              Width = 60
            end
            item
              Caption = 'Date'
              Width = 100
            end
            item
              Caption = 'CRC32'
              Width = 80
            end
            item
              Caption = 'Original path'
              Width = 100
            end
            item
              Caption = 'M ID'
            end
            item
              Alignment = taRightJustify
              Caption = 'R ID'
            end
            item
              Caption = 'Parent'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Date Val'
              MaxWidth = 1
              Width = 0
            end
            item
              Caption = 'Project_ID'
              Width = 0
            end
            item
              Caption = 'Diff Type'
              Width = 0
            end>
          ReadOnly = True
          HideSelection = False
          OnMouseDown = lvDateItemsMouseDown
          TabOrder = 1
          ViewStyle = vsReport
          OnKeyDown = lvDateItemsKeyDown
          SmallImages = SysImageList
          StateImages = StateImageList
        end
      end
    end
    object Panel6: TPanel
      Left = 0
      Top = 288
      Width = 416
      Height = 47
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object cbReload: TCheckBox
        Left = 127
        Top = 4
        Width = 135
        Height = 17
        Caption = '&Reload synchronized M.'
        TabOrder = 1
      end
      object cbSummary: TCheckBox
        Left = 275
        Top = 4
        Width = 95
        Height = 17
        Caption = 'Show s&ummary'
        TabOrder = 2
      end
      object cbInclHidden: TCheckBox
        Left = 8
        Top = 4
        Width = 108
        Height = 17
        Caption = 'Include &hidden M.'
        TabOrder = 0
        OnClick = cbInclHiddenClick
      end
      object cbRemoveHidden: TCheckBox
        Left = 8
        Top = 24
        Width = 185
        Height = 17
        Caption = 'Remove hidden M. in target folder'
        TabOrder = 3
      end
      object cbInclChkOutByMe: TCheckBox
        Left = 192
        Top = 24
        Width = 169
        Height = 17
        Caption = 'Include M. checked out by me'
        TabOrder = 4
      end
    end
  end
  object pan_Project_List: TPanel
    Left = 0
    Top = 0
    Width = 149
    Height = 335
    Align = alLeft
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 3
    DesignSize = (
      149
      335)
    object sbLoadProjectTree: TSpeedButton
      Left = 0
      Top = 0
      Width = 97
      Height = 17
      Caption = 'Load Project Tree'
      Flat = True
      OnClick = sbLoadProjectTreeClick
    end
    object tv_Project_List: TJvCheckTreeView
      Left = 0
      Top = 17
      Width = 149
      Height = 319
      Anchors = [akLeft, akTop, akRight, akBottom]
      HideSelection = False
      Images = StateImageList
      Indent = 19
      PopupMenu = pm_tv_Project_List
      ReadOnly = True
      ShowRoot = False
      TabOrder = 0
      LineColor = 13160660
      Checkboxes = True
      CheckBoxOptions.Style = cbsJVCL
      CheckBoxOptions.CascadeOptions = []
    end
    object cbLoadProjectTree: TCheckBox
      Left = 100
      Top = 0
      Width = 49
      Height = 17
      Caption = 'Auto'
      TabOrder = 1
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 216
    Top = 192
    object SelectAll1: TMenuItem
      Caption = '&Select All'
      OnClick = SelectAll1Click
    end
    object UnselectAll1: TMenuItem
      Caption = '&Unselect All'
      OnClick = SelectAll1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mmiHideUncheckedModules: TMenuItem
      Caption = 'Hide &Unchecked Modules'
      OnClick = mmiHideUncheckedModulesClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mmiIgnoreModuleRevision: TMenuItem
      Caption = '&Ignore Module/Revision'
      OnClick = mmiIgnoreModuleRevisionClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object HelpTopicF11: TMenuItem
      Caption = 'Help Topic   F1'
      OnClick = HelpTopicF11Click
    end
  end
  object SysImageList: TImageList
    Left = 280
    Top = 192
  end
  object StateImageList: TImageList
    Left = 248
    Top = 192
    Bitmap = {
      494C010107000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000840000008400000084000000840084848400848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      84000000FF000000FF000000FF000000FF000000FF000000FF000000FF008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00000084008484840000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000000084000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF008484840084848400000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000084000000FF000000FF000000
      FF00FFFFFF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF000000
      FF000000FF000000FF0084848400000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000084000000FF000000FF000000
      FF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF000000FF0084848400848484000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000
      FF000000FF000000FF0000008400848484000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFF
      FF00000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000
      FF000000FF000000FF0000008400848484000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000
      FF000000FF000000FF0000008400848484000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00000000000000000000000000000000000000FF000000FF000000FF000000
      FF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF000000FF000000
      FF000000FF000000FF0000008400000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000084000000FF000000FF00FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF000000FF00FFFFFF00FFFFFF000000
      FF000000FF000000FF0084848400000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF00FFFFFF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000840000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000084000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000084000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000084000000FF000000FF000000FF000000FF0000008400000084000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFC0F0000FFFFFFFFF8070000
      FFFFFFFFF0030000FFFFFE7FE0010000FFFFFC3FC0010000FFFFF81FC0000000
      FFFFF90FC0000000FFFFFB87C0000000FFFFFFC7C0000000FFFFFFE7C0010000
      FFFFFFF7E0010000FFFFFFFFF0030000FFFFFFFFF8070000FFFFFFFFFC0F0000
      FFFFFFFFFFFF0000FFFFFFFFFFFF0000FFFFFFFFFC3FFFFFFFFFFFFFF00FFFFF
      FFFFFFFFE003FFFFE007E007C003E007E007E0078001E007E007E0070001E007
      E007E0070000E007E007E0070000E007E007E0070000E007E007E0070000E007
      E007E0070001E007E007E0070001E007E007E0078003E007FFFFFFFF8007FFFF
      FFFFFFFFC00FFFFFFFFFFFFFF01FFFFF00000000000000000000000000000000
      000000000000}
  end
  object TimerCloseForm: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = TimerCloseFormTimer
    Left = 311
    Top = 192
  end
  object pm_tv_Project_List: TPopupMenu
    Left = 88
    Top = 124
    object CheckAll1: TMenuItem
      Caption = 'Check All'
      OnClick = CheckAll1Click
    end
    object UncheckAll1: TMenuItem
      Caption = 'Uncheck All'
      OnClick = UncheckAll1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object CheckBranch1: TMenuItem
      Caption = 'Check Branch'
      OnClick = CheckBranch1Click
    end
    object UncheckBranch1: TMenuItem
      Caption = 'Uncheck Branch'
      OnClick = UncheckBranch1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object FullExpand1: TMenuItem
      Caption = 'Full Expand'
      OnClick = FullExpand1Click
    end
    object FullCollapce1: TMenuItem
      Caption = 'Full Collapse'
      OnClick = FullCollapce1Click
    end
  end
end
