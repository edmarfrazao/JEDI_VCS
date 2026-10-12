object VCSVerSet: TVCSVerSet
  Left = 297
  Top = 207
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Version Settings'
  ClientHeight = 333
  ClientWidth = 321
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
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Help: TSpeedButton
    Left = 8
    Top = 304
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
  object tabVersionInfo: TPageControl
    Left = 3
    Top = 30
    Width = 317
    Height = 265
    ActivePage = TabSheet1
    TabIndex = 0
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = '&Version'
      object lblFileVersion: TLabel
        Left = 36
        Top = 37
        Width = 58
        Height = 13
        Alignment = taRightJustify
        Caption = 'File version:'
      end
      object lblProductVersion: TLabel
        Left = 16
        Top = 93
        Width = 79
        Height = 13
        Alignment = taRightJustify
        Caption = 'Product version:'
      end
      object spiFBuild: TJvSpinEdit
        Left = 250
        Top = 33
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 4
      end
      object spiFRelease: TJvSpinEdit
        Left = 199
        Top = 33
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 3
      end
      object spiPBuild: TJvSpinEdit
        Left = 250
        Top = 89
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 9
      end
      object spiPRelease: TJvSpinEdit
        Left = 199
        Top = 89
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 8
      end
      object cbAssFVersion: TCheckBox
        Left = 10
        Top = 11
        Width = 314
        Height = 17
        Caption = 'F&ile version corresponding to JEDI VCS *.dpr version'
        TabOrder = 0
        OnClick = cbAssFVersionClick
      end
      object cbAssPVersion: TCheckBox
        Left = 8
        Top = 64
        Width = 316
        Height = 17
        Caption = 'P&roduct version corresponding to JEDI VCS *.dpr version'
        TabOrder = 5
        OnClick = cbAssFVersionClick
      end
      object spiMinPVer: TJvSpinEdit
        Left = 149
        Top = 89
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 7
      end
      object spiMajPVer: TJvSpinEdit
        Left = 99
        Top = 89
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 6
      end
      object spiMinFVer: TJvSpinEdit
        Left = 149
        Top = 33
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 2
      end
      object spiMajFVer: TJvSpinEdit
        Left = 99
        Top = 33
        Width = 49
        Height = 21
        ButtonKind = bkStandard
        MaxValue = 9999
        MaxLength = 3
        TabOrder = 1
      end
      object chkIncludeDateStamp: TCheckBox
        Left = 8
        Top = 150
        Width = 215
        Height = 17
        Caption = 'In&clude compile time stamp'
        Checked = True
        State = cbChecked
        TabOrder = 11
      end
      object cbIncBuildNr: TCheckBox
        Left = 8
        Top = 176
        Width = 287
        Height = 17
        Caption = 'Incre&ment Build Nr (File version) on compile'
        TabOrder = 12
      end
      object cbIncPBuildNr: TCheckBox
        Left = 8
        Top = 202
        Width = 314
        Height = 17
        Caption = 'Incremen&t Build Nr (Product version) on compile'
        TabOrder = 13
      end
      object cbIncStringVerInfo: TCheckBox
        Left = 8
        Top = 124
        Width = 316
        Height = 17
        Caption = 'J&EDI VCS *.dpr version as StringFileInfo "InternalVersion"'
        TabOrder = 10
      end
    end
    object TabSheet2: TTabSheet
      Caption = '&Product'
      object lblCompanyName: TLabel
        Left = 10
        Top = 144
        Width = 78
        Height = 13
        Alignment = taRightJustify
        Caption = '&Company name:'
        FocusControl = txtCompanyName
      end
      object lblCopyright: TLabel
        Left = 38
        Top = 167
        Width = 51
        Height = 13
        Alignment = taRightJustify
        Caption = 'Co&pyright:'
        FocusControl = txtCopyright
      end
      object lblTradeMark: TLabel
        Left = 34
        Top = 190
        Width = 55
        Height = 13
        Alignment = taRightJustify
        Caption = 'Tr&ademark:'
        FocusControl = txtTradeMark
      end
      object lblAuthor: TLabel
        Left = 51
        Top = 213
        Width = 37
        Height = 13
        Alignment = taRightJustify
        Caption = 'A&uthor:'
        FocusControl = txtAuthor
      end
      object lblFileType: TLabel
        Left = 44
        Top = 5
        Width = 45
        Height = 13
        Alignment = taRightJustify
        Caption = 'F&ile type:'
        FocusControl = cmbFileType
      end
      object lblFileFlags: TLabel
        Left = 44
        Top = 29
        Width = 46
        Height = 13
        Alignment = taRightJustify
        Caption = 'Fi&le flags:'
        FocusControl = txtFileFlags
      end
      object lblOriginalName: TLabel
        Left = 20
        Top = 52
        Width = 69
        Height = 13
        Alignment = taRightJustify
        Caption = '&Original name:'
        FocusControl = txtOriginalName
      end
      object lblInternalName: TLabel
        Left = 19
        Top = 76
        Width = 71
        Height = 13
        Alignment = taRightJustify
        Caption = 'In&ternal name:'
        FocusControl = txtInternalName
      end
      object lblDescription: TLabel
        Left = 31
        Top = 98
        Width = 57
        Height = 13
        Alignment = taRightJustify
        Caption = 'D&escription:'
        FocusControl = txtDescription
      end
      object lblProductName: TLabel
        Left = 18
        Top = 121
        Width = 70
        Height = 13
        Alignment = taRightJustify
        Caption = 'P&roduct name:'
        FocusControl = txtProductName
      end
      object txtCompanyName: TEdit
        Left = 93
        Top = 142
        Width = 208
        Height = 21
        TabOrder = 6
      end
      object txtCopyright: TEdit
        Left = 93
        Top = 165
        Width = 208
        Height = 21
        TabOrder = 7
      end
      object txtTradeMark: TEdit
        Left = 93
        Top = 188
        Width = 208
        Height = 21
        TabOrder = 8
      end
      object txtAuthor: TEdit
        Left = 93
        Top = 211
        Width = 208
        Height = 21
        TabOrder = 9
      end
      object cmbFileType: TComboBox
        Left = 93
        Top = 2
        Width = 207
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'VFT_APP'
          'VFT_DLL'
          'VFT_DRV'
          'VFT_FONT'
          'VFT_VXD'
          'VFT_STATIC_LIB'
          'VFT_UNKNOWN')
      end
      object txtFileFlags: TEdit
        Left = 93
        Top = 25
        Width = 207
        Height = 21
        TabOrder = 1
      end
      object txtOriginalName: TEdit
        Left = 93
        Top = 49
        Width = 207
        Height = 21
        TabOrder = 2
      end
      object txtInternalName: TEdit
        Left = 93
        Top = 72
        Width = 207
        Height = 21
        TabOrder = 3
      end
      object txtDescription: TEdit
        Left = 93
        Top = 95
        Width = 207
        Height = 21
        TabOrder = 4
      end
      object txtProductName: TEdit
        Left = 93
        Top = 118
        Width = 207
        Height = 21
        TabOrder = 5
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&Special'
      object lblComments: TLabel
        Left = 26
        Top = 88
        Width = 54
        Height = 13
        Alignment = taRightJustify
        Caption = '&Comments:'
        FocusControl = txtComments
      end
      object lblOS: TLabel
        Left = 37
        Top = 119
        Width = 43
        Height = 13
        Alignment = taRightJustify
        Caption = '&OS type:'
        FocusControl = cmbOSType
      end
      object lblLanguage: TLabel
        Left = 30
        Top = 142
        Width = 51
        Height = 13
        Alignment = taRightJustify
        Caption = '&Language:'
        FocusControl = cmbLanguage
      end
      object lblCharSet: TLabel
        Left = 11
        Top = 166
        Width = 70
        Height = 13
        Alignment = taRightJustify
        Caption = 'C&haracter set:'
        FocusControl = cmbCharSet
      end
      object Label1: TLabel
        Left = 6
        Top = 194
        Width = 187
        Height = 13
        Caption = '&Resource compiler (full path required): '
        FocusControl = edRCComp
      end
      object spBtnBrowse: TSpeedButton
        Left = 278
        Top = 211
        Width = 23
        Height = 22
        Hint = 'Browse'
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
      object radDebugBuild: TRadioButton
        Left = 10
        Top = 12
        Width = 95
        Height = 17
        Caption = '&Debug Build'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object radReleaseBuild: TRadioButton
        Left = 114
        Top = 12
        Width = 97
        Height = 17
        Caption = 'Release Build'
        TabOrder = 1
      end
      object chkSpecialBuild: TCheckBox
        Left = 10
        Top = 35
        Width = 289
        Height = 17
        Caption = 'Sp&ecial Build'
        TabOrder = 2
      end
      object chkInternalBuild: TCheckBox
        Left = 10
        Top = 59
        Width = 289
        Height = 17
        Caption = '&Internal Build (add corresponding message)'
        TabOrder = 3
      end
      object txtComments: TEdit
        Left = 86
        Top = 84
        Width = 217
        Height = 21
        TabOrder = 4
      end
      object cmbOSType: TComboBox
        Left = 86
        Top = 115
        Width = 217
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        Items.Strings = (
          'VOS__WINDOWS32'
          'VOS__WINDOWS16'
          'VOS_NT'
          'VOS_DOS'
          'VOS_UNKNOWN'
          'VOS_DOS_WINDOWS16'
          'VOS_DOS_WINDOWS32'
          'VOS_NT_WINDOWS32'
          '')
      end
      object cmbLanguage: TComboBox
        Left = 86
        Top = 139
        Width = 217
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 6
        Items.Strings = (
          '0000: Language Neutral'
          '0400: Process Default Language'
          '0801: Arabic (Iraq)'
          '0c01: Arabic (Egypt)'
          '1001: Arabic (Libya)'
          '1401: Arabic (Algeria)'
          '1801: Arabic (Morocco)'
          '1c01: Arabic (Tunisia)'
          '2001: Arabic (Oman)'
          '2401: Arabic (Yemen)'
          '2801: Arabic (Syria)'
          '2c01: Arabic (Jordan)'
          '3001: Arabic (Lebanon)'
          '3401: Arabic (Kuwait)'
          '3801: Arabic (U.A.E.)'
          '3c01: Arabic (Bahrain)'
          '4001: Arabic (Qatar)'
          '0402: Bulgarian'
          '0403: Catalan'
          '0404: Chinese (Taiwan)'
          '0804: Chinese (PRC)'
          '0c04: Chinese (Hong Kong)'
          '1004: Chinese (Singapore)'
          '0405: Czech'
          '0406: Danish'
          '0407: German (Standard)'
          '0807: German (Swiss)'
          '0c07: German (Austrian)'
          '1007: German (Luxembourg)'
          '1407: German (Liechtenstein)'
          '0408: Greek'
          '0409: English (United States)'
          '0809: English (United Kingdom)'
          '0c09: English (Australian)'
          '1009: English (Canadian)'
          '1409: English (New Zealand)'
          '1809: English (Ireland)'
          '1c09: English (South Africa)'
          '2009: English (Jamaica)'
          '2409: English (Caribbean)'
          '2809: English (Belize)'
          '2c09: English (Trinidad)'
          '040a: Spanish (Traditional Sort)'
          '080a: Spanish (Mexican)'
          '0c0a: Spanish (Modern Sort)'
          '100a: Spanish (Guatemala)'
          '140a: Spanish (Costa Rica)'
          '180a: Spanish (Panama)'
          '1c0a: Spanish (Dominican Republic)'
          '200a: Spanish (Venezuela)'
          '240a: Spanish (Colombia)'
          '280a: Spanish (Peru)'
          '2c0a: Spanish (Argentina)'
          '300a: Spanish (Ecuador)'
          '340a: Spanish (Chile)'
          '380a: Spanish (Uruguay)'
          '3c0a: Spanish (Paraguay)'
          '400a: Spanish (Bolivia)'
          '440a: Spanish (El Salvador)'
          '480a: Spanish (Honduras)'
          '4c0a: Spanish (Nicaragua)'
          '500a: Spanish (Puerto Rico)'
          '040b: Finnish'
          '040c: French (Standard)'
          '080c: French (Belgian)'
          '0c0c: French (Canadian)'
          '100c: French (Swiss)'
          '140c: French (Luxembourg)'
          '040d: Hebrew'
          '040e: Hungarian'
          '040f: Icelandic'
          '0410: Italian (Standard)'
          '0810: Italian (Swiss)'
          '0411: Japanese'
          '0412: Korean'
          '0812: Korean (JoHab)'
          '0413: Dutch (Standard)'
          '0813: Dutch (Belgian)'
          '0414: Norwegian (Bokmal)'
          '0814: Norwegian (Nynorsk)'
          '0415: Polish'
          '0416: Portuguese (Brazilian)'
          '0816: Portuguese (Standard)'
          '0418: Romanian'
          '0419: Russian'
          '041a: Croatian'
          '0c1a: Serbian'
          '041b: Slovak'
          '041c: Albanian'
          '041d: Swedish'
          '081d: Swedish (Finland)'
          '041e: Thai'
          '041f: Turkish'
          '0421: Indonesian'
          '0422: Ukrainian'
          '0423: Belarusian'
          '0424: Slovenian'
          '0425: Estonian'
          '0426: Latvian'
          '0427: Lithuanian'
          '081a: Serbian'
          '0429: Farsi'
          '042d: Basque'
          '0436: Afrikaans'
          '0438: Faeroese')
      end
      object cmbCharSet: TComboBox
        Left = 86
        Top = 163
        Width = 217
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 7
        Items.Strings = (
          '0: 7-bit ASCII'
          '932: Windows, Japan'
          '949: Windows, Korea'
          '950: Windows, Taiwan'
          '1200: Unicode'
          '1250: Windows, Latin-2'
          '1251: Windows, Cyrillic'
          '1252: Windows, Multilangual'
          '1253: Windows, Greek'
          '1254: Windows, Turkish'
          '1255: Windows, Hebrew'
          '1256: Windows, Arabic')
      end
      object edRCComp: TEdit
        Left = 6
        Top = 211
        Width = 264
        Height = 21
        TabOrder = 8
      end
    end
  end
  object rbHandlebyD: TRadioButton
    Left = 8
    Top = 8
    Width = 110
    Height = 17
    Caption = 'Handle by &Delphi'
    TabOrder = 0
    OnClick = rbHandlebyDClick
  end
  object rbHandlebyFVCS: TRadioButton
    Left = 120
    Top = 8
    Width = 121
    Height = 17
    Caption = 'Handle by &JEDI VCS'
    TabOrder = 1
    OnClick = rbHandlebyDClick
  end
  object btnOK: TButton
    Left = 153
    Top = 304
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 241
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object btnCreate: TButton
    Left = 56
    Top = 304
    Width = 83
    Height = 25
    Caption = 'Create &Now'
    TabOrder = 3
    OnClick = btnCreateClick
  end
end
