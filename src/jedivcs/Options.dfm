object VCSOptions: TVCSOptions
  Left = 343
  Top = 275
  Anchors = [akLeft, akTop, akRight, akBottom]
  BorderIcons = [biSystemMenu]
  Caption = 'VCS Properties'
  ClientHeight = 298
  ClientWidth = 422
  Color = clBtnFace
  Constraints.MinHeight = 325
  Constraints.MinWidth = 430
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
  OldCreateOrder = True
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  ExplicitWidth = 320
  ExplicitHeight = 240
  DesignSize = (
    422
    298)
  PixelsPerInch = 96
  TextHeight = 13
  object Label14: TLabel
    Left = 4
    Top = 2
    Width = 49
    Height = 13
    Caption = '&Customize'
    FocusControl = lbSelectSheet
  end
  object PanelInterface: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 10
    Visible = False
    object Label22: TLabel
      Left = 8
      Top = 12
      Width = 123
      Height = 13
      Caption = '&On module double click do'
      FocusControl = cbxPMDoubleClick
    end
    object Label36: TLabel
      Left = 8
      Top = 38
      Width = 123
      Height = 13
      Caption = '&Find module timer interval'
    end
    object Label37: TLabel
      Left = 260
      Top = 38
      Width = 24
      Height = 13
      Caption = 'msec'
    end
    object Label48: TLabel
      Left = 16
      Top = 193
      Width = 112
      Height = 13
      Caption = '&Modules in work by you'
      FocusControl = ccbxLVOut
    end
    object Label49: TLabel
      Left = 16
      Top = 218
      Width = 125
      Height = 13
      Caption = 'Mo&dules in work by others'
      FocusControl = ccbxLVNA
    end
    object Label1: TLabel
      Left = 16
      Top = 168
      Width = 113
      Height = 13
      Caption = '&New (not filed) modules'
      FocusControl = ccbxLVNew
    end
    object cbDoBeep: TCheckBox
      Left = 8
      Top = 120
      Width = 87
      Height = 17
      Caption = '&Beep on error'
      TabOrder = 5
      OnClick = edArchLimitChange
    end
    object cbShowToolTip: TCheckBox
      Left = 8
      Top = 102
      Width = 97
      Height = 17
      Hint = 'Tooltip'
      Caption = 'S&how tooltips'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = edArchLimitChange
    end
    object cbxPMDoubleClick: TComboBox
      Left = 142
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = edArchLimitChange
      Items.Strings = (
        'nothing'
        'View module'
        'Check In module'
        'Check Out module'
        'Get module'
        'Compare module'
        'Show history'
        'Maintain labels'
        'Open parent folder')
    end
    object speSearchTime: TJvSpinEdit
      Left = 142
      Top = 34
      Width = 114
      Height = 21
      ButtonKind = bkStandard
      MaxValue = 5000.000000000000000000
      MinValue = 500.000000000000000000
      Value = 500.000000000000000000
      TabOrder = 1
      OnChange = edArchLimitChange
    end
    object ccbxLVOut: TJvColorComboBox
      Left = 142
      Top = 188
      Width = 145
      Height = 20
      ColorDialogText = '(Other...)'
      DroppedDownWidth = 145
      NewColorText = 'Custom'
      TabOrder = 8
      OnChange = edArchLimitChange
    end
    object ccbxLVNA: TJvColorComboBox
      Left = 142
      Top = 214
      Width = 145
      Height = 20
      ColorDialogText = '(Other...)'
      DroppedDownWidth = 145
      NewColorText = 'Custom'
      TabOrder = 9
      OnChange = edArchLimitChange
    end
    object cbShowLVColor: TCheckBox
      Left = 8
      Top = 142
      Width = 153
      Height = 17
      Caption = 'Show &Listview colors/ fonts'
      TabOrder = 6
      OnClick = cbShowLVColorClick
    end
    object ccbxLVNew: TJvColorComboBox
      Left = 142
      Top = 162
      Width = 145
      Height = 20
      ColorNameMap.Strings = (
        'clBlack'
        'clWhite'
        'clRed'
        'clGreen')
      ColorDialogText = '(Other...)'
      DroppedDownWidth = 145
      NewColorText = 'Custom'
      TabOrder = 7
      OnChange = edArchLimitChange
    end
    object cbLocalInfo: TCheckBox
      Left = 8
      Top = 66
      Width = 233
      Height = 17
      Caption = '&Show local info (Original name/ Size/ Attr...)'
      TabOrder = 2
      OnClick = edArchLimitChange
    end
    object cbTypeInfo: TCheckBox
      Left = 8
      Top = 84
      Width = 273
      Height = 17
      Caption = 'Sho&w detailed file type information (i.e. "Delphi Unit")'
      TabOrder = 3
      OnClick = edArchLimitChange
    end
  end
  object PanelMRU: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 11
    Visible = False
    DesignSize = (
      290
      250)
    object Label51: TLabel
      Left = 8
      Top = 12
      Width = 38
      Height = 13
      Caption = '&MRU list'
      FocusControl = cbxMRUList
    end
    object Label52: TLabel
      Left = 8
      Top = 32
      Width = 39
      Height = 13
      Caption = 'C&ontent'
    end
    object Label47: TLabel
      Left = 8
      Top = 223
      Width = 50
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Ma&x count'
      FocusControl = speFDlgMRUMax
    end
    object speFDlgMRUMax: TJvSpinEdit
      Left = 61
      Top = 219
      Width = 40
      Height = 21
      ButtonKind = bkStandard
      MaxValue = 30.000000000000000000
      MinValue = 5.000000000000000000
      Value = 5.000000000000000000
      Anchors = [akLeft, akBottom]
      TabOrder = 2
      OnChange = edArchLimitChange
    end
    object cbxMRUList: TComboBox
      Left = 65
      Top = 8
      Width = 210
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbxMRUListChange
      Items.Strings = (
        'Save file dialog folder'
        'Open file dialog folder'
        'Check Out target folder'
        'Project folder (Toolbar)'
        'Server name/address'
        'Restore target path'
        'Archive module search mask'
        'New synchronize folder'
        'To Do category'
        'Wildcard view filter'
        'Compare date module list'
        'Recent projects'
        'Select folder dialog'
        'Compare folder (Base)'
        'Compare folder (Target)'
        'Touch folder'
        'Source distribution file'
        'Direct SQL queries'
        'Label filter mask'
        'Check In comments'
        'Check Out comments')
    end
    object btnClrMRUItem: TButton
      Left = 115
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Remove'
      Enabled = False
      TabOrder = 3
      OnClick = btnClrMRUItemClick
    end
    object btnClrMRUAll: TButton
      Left = 203
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'C&lear List'
      TabOrder = 4
      OnClick = btnClrMRUAllClick
    end
    object lbMRUList: TJvTextListBox
      Left = 8
      Top = 48
      Width = 268
      Height = 161
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 1
      OnClick = lbMRUListClick
    end
  end
  object PanelKWExpansion: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 14
    Visible = False
    DesignSize = (
      290
      250)
    object Label39: TLabel
      Left = 27
      Top = 167
      Width = 236
      Height = 27
      AutoSize = False
      Caption = 
        'See the related help topic for available keywords, syntax and pe' +
        'rformance issues.'
      WordWrap = True
    end
    object Label53: TLabel
      Left = 8
      Top = 123
      Width = 66
      Height = 13
      Caption = 'Search in &files'
      FocusControl = edKWExp
    end
    object spBtnInsCT: TSpeedButton
      Left = 8
      Top = 208
      Width = 25
      Height = 25
      Hint = 'Insert IDE code template'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        77777777777887777777777777800877777777777800F008777777778010FF00
        8777777801100FFF008777801109900FFF077701109999900F87770109999999
        9007770099999999907777009999999907777777009999907777777777009907
        7777777777770077777777777777777777777777777777777777}
      OnClick = spBtnInsCTClick
    end
    object Label54: TLabel
      Left = 40
      Top = 207
      Width = 191
      Height = 27
      AutoSize = False
      Caption = 
        'Insert a keyword header code template into IDE'#39's code insight wi' +
        'ndow.'
      WordWrap = True
    end
    object spBtnEditKWExp: TSpeedButton
      Left = 260
      Top = 139
      Width = 23
      Height = 22
      Hint = 'Edit file extensions'
      Anchors = [akTop, akRight]
      Caption = '...'
      OnClick = spBtnEditKWExpClick
    end
    object Image4: TImage
      Left = 8
      Top = 167
      Width = 16
      Height = 16
      AutoSize = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        0000100000000100040000000000800000000000000000000000100000001000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFF0BBBBBBBBBB
        BB0FF0BBBBB00BBBBB0FFF0BBBB00BBBB0FFFF0BBBBBBBBBB0FFFFF0BBB00BBB
        0FFFFFF0BBB00BBB0FFFFFFF0BB00BB0FFFFFFFF0BB00BB0FFFFFFFFF0B00B0F
        FFFFFFFFF0BBBB0FFFFFFFFFFF0BB0FFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object cbKWExpCheckIn: TCheckBox
      Left = 8
      Top = 26
      Width = 201
      Height = 17
      Caption = 'Keyword expansion when checking &in'
      TabOrder = 1
      OnClick = cbKWExpCheckInClick
    end
    object cbKWExpCheckOut: TCheckBox
      Left = 8
      Top = 44
      Width = 209
      Height = 17
      Caption = 'Keyword expansion when checking &out'
      TabOrder = 2
      OnClick = cbKWExpCheckOutClick
    end
    object edKWExp: TEdit
      Left = 8
      Top = 139
      Width = 245
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 6
      OnChange = edArchLimitChange
    end
    object cbKWExpAdd: TCheckBox
      Left = 8
      Top = 8
      Width = 249
      Height = 17
      Caption = 'Keyword expansion when adding &new modules'
      TabOrder = 0
      OnClick = cbKWExpAddClick
    end
    object cbKWCreateBackup: TCheckBox
      Left = 8
      Top = 84
      Width = 260
      Height = 17
      Caption = 'Backup the file (.~kw) before &expanding keywords'
      TabOrder = 4
      OnClick = edArchLimitChange
    end
    object cbKWExCheckBinary: TCheckBox
      Left = 8
      Top = 102
      Width = 257
      Height = 17
      Caption = 'Check for &binary files before expanding keywords'
      TabOrder = 5
      OnClick = edArchLimitChange
    end
    object cbKWIgnorewoSKW: TCheckBox
      Left = 8
      Top = 66
      Width = 262
      Height = 17
      Caption = '&Skip files without "$Keywords" in the first two lines'
      TabOrder = 3
    end
  end
  object PanelFolders: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
    Visible = False
    DesignSize = (
      290
      250)
    object Label17: TLabel
      Left = 0
      Top = 8
      Width = 143
      Height = 13
      Caption = '&JEDI VCS temporary directory'
      FocusControl = edTempDir
    end
    object Label18: TLabel
      Left = 0
      Top = 48
      Width = 168
      Height = 13
      Caption = 'JEDI VCS &base registry key (HKCU)'
      FocusControl = edBaseRegKey
    end
    object Label20: TLabel
      Left = 0
      Top = 112
      Width = 137
      Height = 13
      Caption = '&Local application server path'
      FocusControl = edLocalServer
    end
    object spBtnLocalServer: TSpeedButton
      Left = 260
      Top = 127
      Width = 23
      Height = 22
      Hint = 'Browse/ Find'
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
      OnClick = spBtnLocalServerClick
    end
    object spBtnTempDir: TSpeedButton
      Left = 260
      Top = 23
      Width = 23
      Height = 22
      Hint = 'Browse'
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
      OnClick = spBtnTempDirClick
    end
    object Label50: TLabel
      Left = 0
      Top = 159
      Width = 131
      Height = 13
      Caption = 'Show "Parent folders" as...'
    end
    object edLocalServer: TEdit
      Left = 0
      Top = 128
      Width = 255
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      Text = 'edLocalServer'
      OnChange = edArchLimitChange
    end
    object edBaseRegKey: TEdit
      Left = 0
      Top = 64
      Width = 255
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = 'edBaseRegKey'
      OnChange = edArchLimitChange
    end
    object edTempDir: TEdit
      Left = 0
      Top = 24
      Width = 255
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'edTempDir'
      OnChange = edArchLimitChange
    end
    object rbPFSingle: TRadioButton
      Left = 8
      Top = 178
      Width = 113
      Height = 17
      Caption = '&Single pane view'
      TabOrder = 4
      OnClick = edArchLimitChange
    end
    object rbPFExplorer: TRadioButton
      Left = 128
      Top = 178
      Width = 89
      Height = 17
      Caption = 'Explorer view'
      TabOrder = 5
      OnClick = edArchLimitChange
    end
    object cbUseFileStorage: TCheckBox
      Left = 0
      Top = 88
      Width = 238
      Height = 17
      Caption = '&Use file storage (JVCS.INI) instead of Registry'
      TabOrder = 2
      OnClick = cbUseFileStorageClick
    end
  end
  object PanelComments: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 17
    object Label55: TLabel
      Left = 27
      Top = 186
      Width = 240
      Height = 41
      AutoSize = False
      Caption = 
        'This feature may cause problems when working with Data Module fo' +
        'rms. See the help file for more information.'
      WordWrap = True
    end
    object Image3: TImage
      Left = 8
      Top = 186
      Width = 16
      Height = 16
      AutoSize = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        0000100000000100040000000000800000000000000000000000100000001000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFF0BBBBBBBBBB
        BB0FF0BBBBB00BBBBB0FFF0BBBB00BBBB0FFFF0BBBBBBBBBB0FFFFF0BBB00BBB
        0FFFFFF0BBB00BBB0FFFFFFF0BB00BB0FFFFFFFF0BB00BB0FFFFFFFFF0B00B0F
        FFFFFFFFF0BBBB0FFFFFFFFFFF0BB0FFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object cbpromptfMemo: TCheckBox
      Left = 8
      Top = 8
      Width = 219
      Height = 17
      HelpContext = 111
      Caption = '&Confirm empty Check In comment'
      TabOrder = 0
      OnClick = cbpromptfMemoClick
    end
    object cbMemoRequired: TCheckBox
      Left = 16
      Top = 26
      Width = 273
      Height = 17
      Caption = 'Check In comment required'
      TabOrder = 1
      OnClick = edArchLimitChange
    end
    object cbpromptfMemoOut: TCheckBox
      Left = 8
      Top = 51
      Width = 225
      Height = 17
      HelpContext = 111
      Caption = 'C&onfirm empty Check Out comment'
      TabOrder = 2
      OnClick = edArchLimitChange
    end
    object cbCommInOut: TCheckBox
      Left = 8
      Top = 69
      Width = 273
      Height = 17
      Caption = '&Default Check In description = last Check Out descr.'
      TabOrder = 3
      OnClick = edArchLimitChange
    end
    object cbIncludeIPComment: TCheckBox
      Left = 8
      Top = 87
      Width = 273
      Height = 17
      Caption = 'Include client IP &numbers in Check In/Out comments'
      TabOrder = 4
      OnClick = cbIncludeIPCommentClick
    end
    object cbMarkSource: TCheckBox
      Left = 8
      Top = 112
      Width = 255
      Height = 17
      HelpContext = 115
      Caption = 'Include &version history/ timestamps in source files'
      TabOrder = 5
      OnClick = cbMarkSourceClick
    end
    object cbMSIn: TCheckBox
      Left = 16
      Top = 130
      Width = 157
      Height = 17
      Caption = 'Include Check &In information'
      TabOrder = 6
      OnClick = edArchLimitChange
    end
    object cbMSOut: TCheckBox
      Left = 16
      Top = 148
      Width = 165
      Height = 17
      Caption = 'Include Check &Out information'
      TabOrder = 7
      OnClick = edArchLimitChange
    end
    object cbBreakCIITo80: TCheckBox
      Left = 16
      Top = 166
      Width = 145
      Height = 17
      Caption = '&Break lines after 80 chars'
      TabOrder = 8
    end
  end
  object PanelOptions: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object min: TLabel
      Left = 220
      Top = 17
      Width = 16
      Height = 13
      Caption = '&min'
      FocusControl = speAutoRefresh
    end
    object Label9: TLabel
      Left = 8
      Top = 141
      Width = 135
      Height = 13
      Caption = 'Add automatic to project list'
    end
    object cbAddDSK: TCheckBox
      Left = 16
      Top = 193
      Width = 153
      Height = 17
      HelpContext = 114
      Caption = 'IDE'#39's d&esktop file (*.dsk)'
      TabOrder = 8
      OnClick = edArchLimitChange
    end
    object cbAddCFG: TCheckBox
      Left = 16
      Top = 175
      Width = 177
      Height = 17
      HelpContext = 113
      Caption = 'IDE'#39's co&nfiguration file (*.cfg)'
      TabOrder = 7
      OnClick = edArchLimitChange
    end
    object cbAddCList: TCheckBox
      Left = 16
      Top = 157
      Width = 243
      Height = 17
      HelpContext = 112
      Caption = 'IDE package/c&omponent list (CompList.jvcs)'
      TabOrder = 6
      OnClick = edArchLimitChange
    end
    object cbAutoSync: TCheckBox
      Left = 8
      Top = 64
      Width = 242
      Height = 17
      Caption = 'A&uto synchronize when opening a new project '
      TabOrder = 3
      OnClick = cbAutoSyncClick
    end
    object cbAutoRefresh: TCheckBox
      Left = 8
      Top = 16
      Width = 143
      Height = 17
      Caption = 'Auto refresh archive &view'
      TabOrder = 0
      OnClick = cbAutoRefreshClick
    end
    object cbShowLoad: TCheckBox
      Left = 8
      Top = 46
      Width = 223
      Height = 17
      HelpContext = 110
      Caption = 'Auto connect &server when starting the IDE'
      TabOrder = 2
      OnClick = cbShowLoadClick
    end
    object speAutoRefresh: TJvSpinEdit
      Left = 160
      Top = 13
      Width = 49
      Height = 21
      ButtonKind = bkStandard
      MaxValue = 60.000000000000000000
      MinValue = 1.000000000000000000
      Value = 1.000000000000000000
      TabOrder = 1
      OnChange = edArchLimitChange
    end
    object cbUnlockUnchanged: TCheckBox
      Left = 8
      Top = 82
      Width = 265
      Height = 17
      Caption = 'Undo C&heck Out unchanged files when checking in'
      TabOrder = 4
      OnClick = cbUnlockUnchangedClick
    end
    object cbNoROCheck: TCheckBox
      Left = 8
      Top = 100
      Width = 277
      Height = 17
      Caption = 'Don'#39't perform &RO flag checks on Check In/Out/Sync...'
      TabOrder = 5
      OnClick = cbNoROCheckClick
    end
    object cbCheckModuleState: TCheckBox
      Left = 8
      Top = 118
      Width = 281
      Height = 17
      Caption = 'Check module state automatic on menu pull down'
      TabOrder = 9
      OnClick = cbCheckModuleStateClick
    end
  end
  object PanelDialogs: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    DesignSize = (
      290
      250)
    object lvDSADlg: TListView
      Left = 8
      Top = 8
      Width = 268
      Height = 204
      HelpContext = 119
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Don'#39't show again dialog'
          Width = 235
        end
        item
          Caption = 'RegEntry'
          Width = 0
        end>
      ColumnClick = False
      ReadOnly = True
      SmallImages = TypeImageList
      StateImages = StateImageList
      TabOrder = 0
      ViewStyle = vsReport
      OnKeyDown = lvDSADlgKeyDown
      OnMouseDown = lvDSADlgMouseDown
    end
    object btnHideDSA: TButton
      Left = 115
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Disable All'
      TabOrder = 1
      OnClick = btnSetAllDSAClick
    end
    object btnShowDSA: TButton
      Left = 203
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Enable All'
      TabOrder = 2
      OnClick = btnResetDSAMClick
    end
  end
  object PanelTimeStamp: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 4
    Visible = False
    object Label4: TLabel
      Left = 19
      Top = 31
      Width = 122
      Height = 13
      Caption = '...&when Check In a file to'
      FocusControl = cbxChkInDate
    end
    object Label5: TLabel
      Left = 12
      Top = 55
      Width = 130
      Height = 13
      Caption = '...w&hen Check Out a file to'
      FocusControl = cbxChkOutDate
    end
    object Label33: TLabel
      Left = 8
      Top = 8
      Width = 133
      Height = 13
      Caption = 'Set file'#39's date/time stamp...'
    end
    object Label56: TLabel
      Left = 27
      Top = 82
      Width = 243
      Height = 40
      AutoSize = False
      Caption = 
        'Be very careful with this option. Usually it is *not* recommende' +
        'd to change the date/time stamps of source files!'
      WordWrap = True
    end
    object Image2: TImage
      Left = 8
      Top = 82
      Width = 16
      Height = 16
      AutoSize = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        0000100000000100040000000000800000000000000000000000100000001000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFF0BBBBBBBBBB
        BB0FF0BBBBB00BBBBB0FFF0BBBB00BBBB0FFFF0BBBBBBBBBB0FFFFF0BBB00BBB
        0FFFFFF0BBB00BBB0FFFFFFF0BB00BB0FFFFFFFF0BB00BB0FFFFFFFFF0B00B0F
        FFFFFFFFF0BBBB0FFFFFFFFFFF0BB0FFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object cbxChkInDate: TComboBox
      Left = 146
      Top = 26
      Width = 115
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbxChkInDateChange
      Items.Strings = (
        'Original date/time'
        'Current date/time')
    end
    object cbxChkOutDate: TComboBox
      Left = 146
      Top = 51
      Width = 115
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbxChkOutDateChange
      Items.Strings = (
        'Original date/time'
        'Current date/time')
    end
  end
  object PanelBackup: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 5
    Visible = False
    DesignSize = (
      290
      250)
    object Label35: TLabel
      Left = 8
      Top = 68
      Width = 98
      Height = 13
      Caption = '&Backup target folder'
      FocusControl = edBckupPath
    end
    object spbtnBckUpPath: TSpeedButton
      Left = 253
      Top = 83
      Width = 23
      Height = 22
      Hint = 'Browse'
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
      OnClick = spbtnBckUpPathClick
    end
    object Label3: TLabel
      Left = 8
      Top = 119
      Width = 138
      Height = 13
      Caption = 'Backup file compression level'
    end
    object lOlderthan: TLabel
      Left = 71
      Top = 216
      Width = 123
      Height = 13
      Caption = 'days &old (keep the latest)'
      FocusControl = spEraseDays
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object cbDoBckUp: TCheckBox
      Left = 8
      Top = 8
      Width = 253
      Height = 17
      HelpContext = 129
      Caption = 'Show backup &dialog automatic (Recommended)'
      TabOrder = 0
      OnClick = cbDoBckUpClick
    end
    object cbBckupProj: TCheckBox
      Left = 8
      Top = 26
      Width = 252
      Height = 17
      HelpContext = 131
      Caption = 'Select changed &files automatic (Recommended)'
      TabOrder = 1
      OnClick = edArchLimitChange
    end
    object cbShProgr: TCheckBox
      Left = 8
      Top = 44
      Width = 129
      Height = 17
      HelpContext = 132
      Caption = 'S&how progress sheet'
      TabOrder = 2
      OnClick = edArchLimitChange
    end
    object edBckupPath: TEdit
      Left = 8
      Top = 84
      Width = 240
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      Text = 'edBckupPath'
      OnChange = edArchLimitChange
    end
    object rbBkupLevel9: TRadioButton
      Left = 16
      Top = 137
      Width = 83
      Height = 17
      Caption = '&Slow/tightest'
      TabOrder = 4
      OnClick = edArchLimitChange
    end
    object rbBkupLevel5: TRadioButton
      Left = 104
      Top = 137
      Width = 83
      Height = 17
      Caption = 'Fast/medium'
      TabOrder = 5
      OnClick = edArchLimitChange
    end
    object rbBkupLevel2: TRadioButton
      Left = 192
      Top = 137
      Width = 84
      Height = 17
      Caption = 'Very fast/low'
      TabOrder = 6
      OnClick = edArchLimitChange
    end
    object spEraseDays: TJvSpinEdit
      Left = 16
      Top = 212
      Width = 51
      Height = 21
      ButtonKind = bkStandard
      MaxValue = 360.000000000000000000
      MinValue = 1.000000000000000000
      Value = 30.000000000000000000
      TabOrder = 9
      OnChange = edArchLimitChange
    end
    object cbSeqBackup: TCheckBox
      Left = 8
      Top = 169
      Width = 240
      Height = 17
      Caption = 'Cr&eate sequential backups (..000.zip-..999.zip)'
      TabOrder = 7
      OnClick = cbSeqBackupClick
    end
    object cbEraseSeq: TCheckBox
      Left = 8
      Top = 187
      Width = 209
      Height = 17
      Caption = 'Auto&matically erase backups more than:'
      TabOrder = 8
      OnClick = edArchLimitChange
    end
    object btnShowBackups: TButton
      Left = 203
      Top = 212
      Width = 75
      Height = 25
      Caption = 'Sho&w/ Clean'
      TabOrder = 10
      OnClick = btnShowBackupsClick
    end
  end
  object PanelEncryption: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 15
    DesignSize = (
      290
      250)
    object Label2: TLabel
      Left = 8
      Top = 32
      Width = 180
      Height = 13
      Caption = '&Key 128bit - 448bit (16byte - 56byte)'
    end
    object Label6: TLabel
      Left = 8
      Top = 134
      Width = 268
      Height = 29
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'JEDI VCS uses a sixteen round Blowfish implementation with at le' +
        'ast 128bit key length to encrypt your data.'
      WordWrap = True
    end
    object Label57: TLabel
      Left = 8
      Top = 161
      Width = 270
      Height = 53
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'Don'#39't forget the key you'#39've entered above. Don'#39't rely on the int' +
        'ernal "store key" procedure. You (and every other person out the' +
        're, including me) will be unable to decrypt the data without thi' +
        's key. Your data will be lost forever!'
      WordWrap = True
    end
    object Image1: TImage
      Left = 8
      Top = 116
      Width = 16
      Height = 16
      AutoSize = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        0000100000000100040000000000800000000000000000000000100000001000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFF0BBBBBBBBBB
        BB0FF0BBBBB00BBBBB0FFF0BBBB00BBBB0FFFF0BBBBBBBBBB0FFFFF0BBB00BBB
        0FFFFFF0BBB00BBB0FFFFFFF0BB00BB0FFFFFFFF0BB00BB0FFFFFFFFF0B00B0F
        FFFFFFFFF0BBBB0FFFFFFFFFFF0BB0FFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object Label58: TLabel
      Left = 8
      Top = 219
      Width = 248
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Please read the related help topic before using this.'
    end
    object Label59: TLabel
      Left = 29
      Top = 118
      Width = 90
      Height = 13
      Caption = 'Strong encryption.'
    end
    object Label60: TLabel
      Left = 8
      Top = 71
      Width = 37
      Height = 13
      Caption = 'Con&firm'
    end
    object cbEncryptData: TCheckBox
      Left = 8
      Top = 8
      Width = 209
      Height = 17
      Caption = '&Store/transmitt source files encrypted'
      TabOrder = 0
      OnClick = cbEncryptDataClick
    end
    object pwedBFKey: TJvEdit
      Left = 8
      Top = 48
      Width = 265
      Height = 21
      PasswordChar = #207
      ProtectPassword = True
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object pwedBFKeyConfirm: TJvEdit
      Left = 8
      Top = 86
      Width = 265
      Height = 21
      PasswordChar = #207
      ProtectPassword = True
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
  end
  object PanelDebug: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 16
    object Bevel1: TBevel
      Left = 8
      Top = 143
      Width = 271
      Height = 2
    end
    object Label62: TLabel
      Left = 8
      Top = 18
      Width = 151
      Height = 13
      Caption = '&Wait until request timeout error'
      FocusControl = speSrvTimeOut
    end
    object Label63: TLabel
      Left = 217
      Top = 18
      Width = 16
      Height = 13
      Caption = 'sec'
    end
    object Label64: TLabel
      Left = 8
      Top = 196
      Width = 124
      Height = 13
      Caption = 'Clean Up min. delay value'
      FocusControl = edCleanUpVal
    end
    object Label65: TLabel
      Left = 8
      Top = 222
      Width = 111
      Height = 13
      Caption = 'DataModule sync delay'
      Enabled = False
      FocusControl = Edit1
    end
    object cbOutPutDbgStr: TCheckBox
      Left = 8
      Top = 152
      Width = 153
      Height = 17
      Caption = 'OutputDebugString active'
      TabOrder = 2
      OnClick = edArchLimitChange
    end
    object speSrvTimeOut: TJvSpinEdit
      Left = 160
      Top = 13
      Width = 49
      Height = 21
      ButtonKind = bkStandard
      MaxValue = 900.000000000000000000
      MinValue = 30.000000000000000000
      Value = 120.000000000000000000
      TabOrder = 0
      OnChange = edArchLimitChange
    end
    object edCleanUpVal: TEdit
      Left = 160
      Top = 192
      Width = 49
      Height = 21
      TabOrder = 3
      OnChange = edArchLimitChange
    end
    object cbGEX: TCheckBox
      Left = 8
      Top = 44
      Width = 129
      Height = 17
      Caption = 'GE&xperts Workaround'
      TabOrder = 1
      OnClick = edArchLimitChange
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 170
      Width = 169
      Height = 17
      Caption = 'Remote Debug settings active'
      Enabled = False
      TabOrder = 4
    end
    object Edit1: TEdit
      Left = 160
      Top = 218
      Width = 49
      Height = 21
      Enabled = False
      TabOrder = 5
      Text = '100'
      OnChange = edArchLimitChange
    end
  end
  object PanelIntPrinter: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 13
    object Label41: TLabel
      Left = 8
      Top = 40
      Width = 53
      Height = 13
      Caption = '&Top margin'
      FocusControl = spePrintTM
    end
    object Label42: TLabel
      Left = 8
      Top = 68
      Width = 54
      Height = 13
      Caption = '&Left margin'
      FocusControl = spePrintLM
    end
    object Label43: TLabel
      Left = 8
      Top = 96
      Width = 242
      Height = 13
      Caption = 'Printer font (fixed character length recommended)'
    end
    object spBtSelectPrnFont: TSpeedButton
      Left = 248
      Top = 112
      Width = 25
      Height = 25
      Hint = 'Select font'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777447777777777777744777777777777774477777777731377444777777777
        1777447777777777173744777777777711174444775577771737777777735777
        1773777777775773111177777777577777777777777555777777777777775777
        7777777777775377777777777777755777777777777777777777}
      OnClick = spBtSelectPrnFontClick
    end
    object Label44: TLabel
      Left = 8
      Top = 150
      Width = 256
      Height = 28
      AutoSize = False
      Caption = 
        'These settings are only valid for internal print routines, not f' +
        'or reports based on QuickReport.'
      WordWrap = True
    end
    object Label45: TLabel
      Left = 136
      Top = 40
      Width = 21
      Height = 13
      Caption = 'lines'
    end
    object Label46: TLabel
      Left = 136
      Top = 68
      Width = 51
      Height = 13
      Caption = 'characters'
    end
    object cbPrintHeader: TCheckBox
      Left = 8
      Top = 8
      Width = 81
      Height = 17
      Caption = '&Print header'
      Enabled = False
      TabOrder = 0
      OnClick = edArchLimitChange
    end
    object spePrintTM: TJvSpinEdit
      Left = 74
      Top = 35
      Width = 56
      Height = 21
      ButtonKind = bkStandard
      TabOrder = 1
      OnChange = edArchLimitChange
    end
    object spePrintLM: TJvSpinEdit
      Left = 74
      Top = 64
      Width = 56
      Height = 21
      ButtonKind = bkStandard
      TabOrder = 2
      OnChange = edArchLimitChange
    end
    object paPrinterfont: TPanel
      Left = 8
      Top = 112
      Width = 233
      Height = 25
      BevelOuter = bvLowered
      Caption = 'paPrinterfont'
      TabOrder = 3
    end
  end
  object PanelEditors: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 6
    Visible = False
    DesignSize = (
      290
      250)
    object Label40: TLabel
      Left = 8
      Top = 222
      Width = 266
      Height = 15
      AutoSize = False
      Caption = 'Define corresponding file extensions via "Filter Values".'
      WordWrap = True
    end
    object Label10: TLabel
      Left = 8
      Top = 50
      Width = 76
      Height = 13
      Caption = '&Resource editor'
      FocusControl = edRWS
    end
    object Label13: TLabel
      Left = 8
      Top = 178
      Width = 92
      Height = 13
      Caption = '&User defined editor'
      FocusControl = edUserEdit
    end
    object Label12: TLabel
      Left = 8
      Top = 130
      Width = 53
      Height = 13
      Caption = '&Text editor'
      FocusControl = edTxt
    end
    object Label11: TLabel
      Left = 8
      Top = 90
      Width = 61
      Height = 13
      Caption = '&Image editor'
      FocusControl = edBMP
    end
    object edBMP: TJvFilenameEdit
      Left = 8
      Top = 106
      Width = 270
      Height = 21
      HelpContext = 138
      OnButtonClick = edBMPButtonClick
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'edBMP'
      OnChange = edArchLimitChange
    end
    object edTxt: TJvFilenameEdit
      Left = 8
      Top = 146
      Width = 270
      Height = 21
      HelpContext = 139
      OnButtonClick = edTxtButtonClick
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Text = 'edTxt'
      OnChange = edArchLimitChange
    end
    object edUserEdit: TJvFilenameEdit
      Left = 8
      Top = 194
      Width = 270
      Height = 21
      HelpContext = 140
      OnButtonClick = edUserEditButtonClick
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      Text = 'edUserEdit'
      OnChange = edArchLimitChange
    end
    object cbUseOnlyShellExt: TCheckBox
      Left = 8
      Top = 8
      Width = 222
      Height = 17
      Caption = 'Use always &Shell'#39's namespace extension'
      TabOrder = 0
      OnClick = cbUseOnlyShellExtClick
    end
    object cbSend8and3: TCheckBox
      Left = 8
      Top = 26
      Width = 153
      Height = 17
      Caption = 'Use short (&8+3) file names'
      TabOrder = 1
    end
    object edRWS: TJvFilenameEdit
      Left = 8
      Top = 65
      Width = 270
      Height = 21
      OnButtonClick = edRWSButtonClick
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      Text = 'edRWS'
    end
  end
  object PanelExtCompare: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 12
    Visible = False
    DesignSize = (
      290
      250)
    object Label15: TLabel
      Left = 8
      Top = 197
      Width = 183
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = '%1 = file to compare, %2 = base file '
    end
    object Label23: TLabel
      Left = 8
      Top = 143
      Width = 257
      Height = 54
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 
        'Insert at least the two placeholders below in the parameter stri' +
        'ng. JEDI VCS will replace them with the corresponding file names' +
        ' before passing the string to the compare utility.'
      WordWrap = True
    end
    object lvCompareTools: TListView
      Left = 8
      Top = 8
      Width = 268
      Height = 110
      HelpContext = 141
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Name'
          Width = 80
        end
        item
          Caption = 'Path'
          Width = 100
        end
        item
          Caption = 'Param'
          Width = 60
        end
        item
          Caption = 'Custom'
          Width = 0
        end>
      ColumnClick = False
      HideSelection = False
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lvCompareToolsChange
      OnEditing = lvCompareToolsEditing
    end
    object btnCTEdit: TButton
      Left = 8
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Edit'
      TabOrder = 2
      OnClick = btnCTEditClick
    end
    object btnCTAdd: TButton
      Left = 115
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'A&dd Custom'
      TabOrder = 3
      OnClick = btnCTAddClick
    end
    object btnCTRmv: TButton
      Left = 203
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Rmv Custom'
      Enabled = False
      TabOrder = 4
      OnClick = btnCTRmvClick
    end
    object cbIgnoreBinary_Text: TCheckBox
      Left = 8
      Top = 124
      Width = 233
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Don'#39't perform &Binary check before Compare'
      TabOrder = 1
      OnClick = edArchLimitChange
    end
  end
  object PanelFilter: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 7
    Visible = False
    DesignSize = (
      290
      250)
    object btnEditFilter: TButton
      Left = 8
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Edit'
      TabOrder = 1
      OnClick = pmiFilterEditClick
    end
    object btnRestFilt: TButton
      Left = 203
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Rmv Custom'
      Enabled = False
      TabOrder = 3
      OnClick = RemoveCustomFileFilter1Click
    end
    object lvFilters: TListView
      Left = 8
      Top = 8
      Width = 268
      Height = 204
      HelpContext = 141
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Item'
          Width = 110
        end
        item
          Caption = 'Filter'
          Width = 130
        end
        item
          Caption = 'User'
          Width = 0
        end>
      ColumnClick = False
      HideSelection = False
      PopupMenu = PopupMenu2
      SmallImages = TypeImageList
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lvFiltersChange
      OnDblClick = lvFiltersDblClick
      OnEditing = lvFiltersEditing
    end
    object btnAddCustFilter: TButton
      Left = 123
      Top = 218
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'A&dd Custom'
      TabOrder = 2
      OnClick = AddCustomFileFilter1Click
    end
  end
  object PanelNotify: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 8
    Visible = False
    object Label19: TLabel
      Left = 237
      Top = 34
      Width = 18
      Height = 13
      Caption = 'if...'
    end
    object Label38: TLabel
      Left = 8
      Top = 213
      Width = 78
      Height = 13
      Caption = '&Notify text color'
      FocusControl = NtfyColorCombo
    end
    object edMailSlot: TEdit
      Left = 165
      Top = 30
      Width = 66
      Height = 21
      HelpContext = 146
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 2
      Text = 'FVCSMail'
    end
    object cbMessChkIn: TCheckBox
      Left = 146
      Top = 78
      Width = 129
      Height = 17
      HelpContext = 144
      Caption = '...Ch&eck In a module'
      TabOrder = 6
      OnClick = edArchLimitChange
    end
    object cbMessChkOut: TCheckBox
      Left = 16
      Top = 78
      Width = 129
      Height = 17
      HelpContext = 144
      Caption = '...C&heck Out a module'
      TabOrder = 5
      OnClick = edArchLimitChange
    end
    object cbMessDisConnect: TCheckBox
      Left = 146
      Top = 58
      Width = 153
      Height = 17
      HelpContext = 144
      Caption = '...&disconnecting a project'
      TabOrder = 4
      OnClick = edArchLimitChange
    end
    object cbMessConnect: TCheckBox
      Left = 16
      Top = 58
      Width = 128
      Height = 17
      HelpContext = 144
      Caption = '...c&onnecting a project'
      TabOrder = 3
      OnClick = edArchLimitChange
    end
    object cbNotifyActive: TCheckBox
      Left = 8
      Top = 33
      Width = 154
      Height = 17
      HelpContext = 143
      Caption = '&Send messages via mailslot'
      TabOrder = 1
      OnClick = cbNotifyActiveClick
    end
    object cbBeep: TCheckBox
      Left = 8
      Top = 112
      Width = 175
      Height = 17
      Caption = '&Beep if a message was received'
      TabOrder = 7
      OnClick = edArchLimitChange
    end
    object cbOnlyCurrent: TCheckBox
      Left = 8
      Top = 130
      Width = 257
      Height = 17
      Caption = '&Filter out messages not related to current project'
      TabOrder = 8
      OnClick = edArchLimitChange
    end
    object cbNtfyFOConnect: TCheckBox
      Left = 8
      Top = 148
      Width = 241
      Height = 17
      Caption = 'Filter out Connecting/Disconnecting a &project'
      TabOrder = 9
      OnClick = edArchLimitChange
    end
    object cbNtfyFOCheckOut: TCheckBox
      Left = 8
      Top = 166
      Width = 169
      Height = 17
      Caption = 'Filte&r out Check Out a module'
      TabOrder = 10
      OnClick = edArchLimitChange
    end
    object cbNtfyFOCheckIn: TCheckBox
      Left = 8
      Top = 184
      Width = 161
      Height = 17
      Caption = 'Filter out Check &In a module'
      TabOrder = 11
      OnClick = edArchLimitChange
    end
    object NtfyColorCombo: TJvColorComboBox
      Left = 100
      Top = 209
      Width = 170
      Height = 20
      ColorDialogText = '(Other...)'
      DroppedDownWidth = 170
      NewColorText = 'Custom'
      TabOrder = 12
      OnChange = edArchLimitChange
    end
    object cbSMTP: TCheckBox
      Left = 8
      Top = 8
      Width = 197
      Height = 17
      Caption = 'Se&nd messages via SMTP forwarder'
      TabOrder = 0
      OnClick = cbSMTPClick
    end
  end
  object PanelShortcut: TPanel
    Left = 130
    Top = 10
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 9
    Visible = False
    object Label21: TLabel
      Left = 8
      Top = 17
      Width = 103
      Height = 13
      Caption = 'IDE &menu accelerator'
    end
    object Label25: TLabel
      Left = 16
      Top = 70
      Width = 79
      Height = 13
      Caption = '&Project Manager'
      FocusControl = edSCProjAdmin
    end
    object Label7: TLabel
      Left = 16
      Top = 94
      Width = 17
      Height = 13
      Caption = '&Get'
      FocusControl = edSCGet
    end
    object Label26: TLabel
      Left = 16
      Top = 118
      Width = 42
      Height = 13
      Caption = 'C&heck In'
      FocusControl = edSCChkIn
    end
    object Label27: TLabel
      Left = 16
      Top = 142
      Width = 50
      Height = 13
      Caption = 'Ch&eck Out'
      FocusControl = edSCChkOut
    end
    object Label32: TLabel
      Left = 16
      Top = 191
      Width = 79
      Height = 13
      Caption = '&Backup/ Restore'
      FocusControl = edSCBckUp
    end
    object Label34: TLabel
      Left = 8
      Top = 48
      Width = 46
      Height = 13
      Caption = 'Shortcuts'
    end
    object Label24: TLabel
      Left = 16
      Top = 167
      Width = 58
      Height = 13
      Caption = '&Synchronize'
      FocusControl = edSCSync
    end
    object lblAccel: TLabel
      Left = 128
      Top = 33
      Width = 153
      Height = 14
      AutoSize = False
      Caption = 'J e d i - V C S 1 . x'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
    object edSCProjAdmin: THotKey
      Left = 112
      Top = 67
      Width = 169
      Height = 21
      HelpContext = 148
      HotKey = 0
      Modifiers = []
      TabOrder = 0
      OnChange = edArchLimitChange
    end
    object edSCGet: THotKey
      Left = 112
      Top = 91
      Width = 169
      Height = 21
      HelpContext = 148
      HotKey = 0
      Modifiers = []
      TabOrder = 1
      OnChange = edArchLimitChange
    end
    object edSCChkIn: THotKey
      Left = 112
      Top = 115
      Width = 169
      Height = 21
      HelpContext = 148
      HotKey = 0
      Modifiers = []
      TabOrder = 2
      OnChange = edArchLimitChange
    end
    object edSCChkOut: THotKey
      Left = 112
      Top = 139
      Width = 169
      Height = 21
      HelpContext = 148
      HotKey = 0
      Modifiers = []
      TabOrder = 3
      OnChange = edArchLimitChange
    end
    object edSCBckUp: THotKey
      Left = 112
      Top = 187
      Width = 169
      Height = 21
      HelpContext = 148
      HotKey = 0
      Modifiers = []
      TabOrder = 5
      OnChange = edArchLimitChange
    end
    object cbDisableGraphDC: TCheckBox
      Left = 8
      Top = 218
      Width = 217
      Height = 17
      Caption = '&Disable all graphic button'#39's Ctrl+ shortcuts'
      TabOrder = 6
    end
    object edSCSync: THotKey
      Left = 112
      Top = 163
      Width = 169
      Height = 21
      HelpContext = 148
      HotKey = 0
      Modifiers = []
      TabOrder = 4
      OnChange = edArchLimitChange
    end
    object JvxAccel: TJvxSlider
      Left = 120
      Top = -4
      Width = 137
      Height = 37
      Increment = 1
      MinValue = 1
      MaxValue = 9
      TabOrder = 7
      Value = 1
      OnChange = JvxAccelChange
    end
  end
  object lbSelectSheet: TListBox
    Left = 2
    Top = 18
    Width = 121
    Height = 233
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Items.Strings = (
      'User Interface'
      'Common Options'
      'Comments'
      'Folders'
      'Time Stamps'
      'Keyword Expansion'
      'Project Backup'
      'Internal Editors'
      'Filter Values'
      'Compare Tools'
      'Notify'
      'Shortcut Keys'
      'DSA Dialogs'
      'Internal Printer'
      'MRU Lists'
      'Data Encryption'
      'Special/Debug'
      'External Bugtracker'
      'Save WIP')
    TabOrder = 0
    OnClick = lbSelectSheetClick
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 267
    Width = 422
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 18
    DesignSize = (
      422
      31)
    object Help: TSpeedButton
      Left = 5
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
    object btnOK: TButton
      Left = 172
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnApply: TButton
      Left = 252
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Apply'
      TabOrder = 1
      OnClick = btnApplyClick
    end
    object btnCancel: TButton
      Left = 328
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object PanelExtBugTrack: TPanel
    Left = 132
    Top = 18
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 19
    Visible = False
    DesignSize = (
      290
      250)
    object Label16: TLabel
      Left = 0
      Top = 48
      Width = 92
      Height = 13
      Caption = 'Regular Expression'
      FocusControl = edBugtrackerRegEx
    end
    object Label8: TLabel
      Left = 0
      Top = 8
      Width = 77
      Height = 13
      Caption = 'Bugtracker URL '
      FocusControl = edBugtrackerURL
    end
    object Label28: TLabel
      Left = 0
      Top = 144
      Width = 255
      Height = 33
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 'Use ?<bug> to mark bug reference in regular expression.'
      WordWrap = True
    end
    object Label29: TLabel
      Left = 0
      Top = 184
      Width = 255
      Height = 33
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        '{bug} in URL will be replaced with match from regular expression' +
        '.'
      WordWrap = True
    end
    object edBugtrackerURL: TEdit
      Left = 0
      Top = 24
      Width = 255
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edArchLimitChange
    end
    object edBugtrackerRegEx: TEdit
      Left = 0
      Top = 64
      Width = 255
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnChange = edArchLimitChange
    end
  end
  object PanelSaveWIP: TPanel
    Left = 132
    Top = 18
    Width = 290
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 20
    Visible = False
    DesignSize = (
      290
      250)
    object Label31: TLabel
      Left = 0
      Top = 8
      Width = 82
      Height = 13
      Caption = 'Backup command'
      FocusControl = edBugtrackerURL
    end
    object Label61: TLabel
      Left = 0
      Top = 80
      Width = 255
      Height = 33
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        'Save checked out modules (work in progress aka WIP) with a file ' +
        'archiver.'
      WordWrap = True
    end
    object Label30: TLabel
      Left = 0
      Top = 120
      Width = 255
      Height = 62
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        'Environment variables can be used (like %TEMP%). Additional vari' +
        'ables are #y# (4 digit year), #m#, #d#, #h#, #n#, #s# (two digit' +
        ' month, day, hour, minute, second) and #vcsusername#, #vcslistfi' +
        'le#.'
      WordWrap = True
    end
    object Label66: TLabel
      Left = 0
      Top = 192
      Width = 255
      Height = 25
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        '#vcslistfile# contains all checked out modules (respecting file ' +
        'family setting) one at a line.'
      WordWrap = True
    end
    object edSaveWIPcommand: TEdit
      Left = 0
      Top = 24
      Width = 255
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edArchLimitChange
    end
    object cbSaveWIPauto: TCheckBox
      Left = 0
      Top = 56
      Width = 120
      Height = 17
      Caption = 'Execute on close'
      TabOrder = 1
    end
  end
  object PopupMenu2: TPopupMenu
    Images = TypeImageList
    Left = 82
    Top = 219
    object pmiFilterEdit: TMenuItem
      Caption = '&Edit...'
      OnClick = pmiFilterEditClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object AddCustomFileFilter1: TMenuItem
      Caption = '&Add custom File Filter...'
      OnClick = AddCustomFileFilter1Click
    end
    object Renamecustomfilefilter1: TMenuItem
      Caption = 'Re&name custom File Filter...'
      OnClick = Renamecustomfilefilter1Click
    end
    object RemoveCustomFileFilter1: TMenuItem
      Caption = '&Remove custom File Filter'
      OnClick = RemoveCustomFileFilter1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object IncPosition1: TMenuItem
      Caption = '&Increment Position'
      ImageIndex = 6
      OnClick = IncPosition1Click
    end
    object DecrementPosition1: TMenuItem
      Caption = '&Decrement Position'
      ImageIndex = 7
      OnClick = DecrementPosition1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Restore1: TMenuItem
      Caption = 'Restore default &Values'
      OnClick = btnRestDefaultFiltClick
    end
  end
  object StateImageList: TImageList
    Left = 82
    Top = 96
    Bitmap = {
      494C010102000400140010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FFFFFFFF00000000
      FFFFFFFF00000000E007E00700000000E007E00700000000E007E00700000000
      E007E00700000000E007E00700000000E007E00700000000E007E00700000000
      E007E00700000000E007E00700000000E007E00700000000FFFFFFFF00000000
      FFFFFFFF00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
  object TypeImageList: TImageList
    Left = 82
    Top = 127
    Bitmap = {
      494C010108000900140010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
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
      000000000000000000000000000084848400C6C6C60084848400848484008484
      84008484840084848400C6C6C600848484000000000000000000000000000000
      000000000000000000000000000084848400000000008484840000000000FFFF
      FF00000000008484840000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C60084848400848484008484
      84008484840084848400C6C6C600848484000000000000000000000000000000
      00000000000000000000C6C6C60000000000FFFFFF008484840000000000FFFF
      FF000000000084848400FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840084848400C6C6C600C6C6C60000000000848484008484
      8400848484000000000084848400848484000000000000000000000000000000
      00000000000000848400000000008484840084848400FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C60084848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      00000084840000FFFF00848484000000000000000000FFFFFF00848484000000
      000084848400FFFFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      840084848400C6C6C60084848400848484008484840084848400848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      000000FFFF000084840000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF0000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF000000FF000000FF0000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60084848400C6C6C6008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF008484840000000000000000000000000000FF
      FF000084840000FFFF00848484000000000000000000FFFFFF00848484000000
      000084848400FFFFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60084848400848484000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000000
      00000000000000000000000000008484840084848400FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084848400848484000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000000000000000000000000000000000000000000000000000C6C6
      C60084848400848484008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000084
      840000FFFF000084840000FFFF0000000000FFFFFF008484840000000000FFFF
      FF000000000084848400FFFFFF00000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      840000000000848484008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF008484840000000000000000000000000000FF
      FF000084840000FFFF000084840084848400000000008484840000000000FFFF
      FF00000000008484840000000000848484000000000000000000000000000000
      00000000000000000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      84008484840084848400C6C6C600000000008484840084848400848484008484
      8400848484008484840084848400000000000000000000000000000000000084
      840000FFFF000084840000FFFF000084840000000000FFFFFF00848484000000
      00008484840000FFFF000084840000FFFF000000000000000000000000000000
      0000000000000000000000000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      84008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008484840084848400848484000000000000000000000000000000
      000000FFFF0000FFFF000084840000FFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000848400000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400C6C6C6000000000084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000084840000FFFF000084840000000000FFFFFF00000000000000
      0000FFFFFF000000000000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484
      8400848484008484840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008484840084848400848484008484840084848400848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000FFFF000084840000FFFF000084840000FFFF000084
      840000FFFF000084840000FFFF00000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000000000000000000000000000000000000000
      00000084840000FFFF000084840000FFFF000084840000FFFF000084840000FF
      FF000084840000FFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000000000000000000000000000000000000000
      000000FFFF000084840000FFFF000084840000FFFF000084840000FFFF000084
      840000FFFF0000FFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000000000000000000000000000000000000000000000000000FF
      FF000084840000FFFF000084840000FFFF000084840000FFFF000084840000FF
      FF0000FFFF000000000000FFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000848400000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000000000FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000FFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF000000000000000000000000000000000000000000000000000000000000FF
      FF000084840000000000FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000848400000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00000000000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000084
      840000FFFF0000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000FFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FF000000FF000000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00000000000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000084840000FFFF000084840000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000084840000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FF000000FF000000FF000000FF000000FF000000FF000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00000000000000000000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000084840000FFFF0000000000FFFFFF00000000000000
      0000FFFFFF000000000000FFFF00000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FF000000FF000000FF000000FF000000FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF0000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
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
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FC00FE00FFFFFFFFF800F000FFFFFFFF
      F000F000FE1FFF3FE000E000FE1FFE1FC000E000FE1FFC0FC000C000FE1FF807
      C000C000F003F003C000C000F003F003C000C000F807FE1FC000C000FC0FFE1F
      C000E000FE1FFE1FC001F000FF3FFE1FC003F801FFFFFFFFC007FF03FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF81FF81FFFFFF000
      F00FF00FC003F000E007E0078001E000C003C0038001E00080038003C003C000
      80018001C003C00080018001E007C00080018001E007C00080018001F00FC000
      80038003F00FE000C003C003F81FF000E007E007F81FF801F00FF00FFC3FFF03
      F81FF81FFE7FFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object PopupMenuServerInst: TPopupMenu
    Left = 82
    Top = 188
    object ServerInstBrowse: TMenuItem
      Caption = '&Browse...'
      OnClick = ServerInstBrowseClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ServerInstFind: TMenuItem
      Caption = '&Find'
      OnClick = ServerInstFindClick
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 82
    Top = 65
  end
  object JvSearchFiles: TJvSearchFiles
    FileParams.SearchTypes = [stFileMask]
    OnFindFile = JvSearchFilesFindFile
    Left = 82
    Top = 35
  end
end
