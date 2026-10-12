object fm_HighLightProp: Tfm_HighLightProp
  Left = 317
  Top = 206
  BorderStyle = bsDialog
  Caption = 'Highlighter'
  ClientHeight = 227
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 8
    Top = 232
    Width = 3
    Height = 13
  end
  object Label6: TLabel
    Left = 8
    Top = 1
    Width = 55
    Height = 13
    Caption = '&Highlighter:'
    FocusControl = cbxHighlighterSelect
  end
  object Label22: TLabel
    Left = 8
    Top = 39
    Width = 47
    Height = 13
    Caption = 'A&ttribute:'
    FocusControl = cbxAttrSelect
  end
  object Label23: TLabel
    Left = 8
    Top = 80
    Width = 86
    Height = 13
    Caption = '&Foreground color:'
  end
  object Label24: TLabel
    Left = 8
    Top = 117
    Width = 86
    Height = 13
    Caption = 'Bac&kground color:'
  end
  object Label5: TLabel
    Left = 8
    Top = 166
    Width = 41
    Height = 13
    Caption = 'File fil&ter'
    FocusControl = edDefaultFilter
  end
  object Button1: TButton
    Left = 132
    Top = 194
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 8
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 213
    Top = 194
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 9
  end
  object cbxHighlighterSelect: TComboBox
    Left = 8
    Top = 15
    Width = 121
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbxHighlighterSelectChange
  end
  object cbxAttrSelect: TComboBox
    Left = 8
    Top = 54
    Width = 121
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbxAttrSelectChange
    Items.Strings = (
      'Assembler'
      'Comment'
      'Identifier'
      'Number'
      'Operator'
      'Pragma'
      'Preprocessor'
      'Reserved word'
      'Symbol'
      'Space'
      'String'
      'Variable')
  end
  object cocbxAttrForeground: TJvColorComboBox
    Left = 8
    Top = 94
    Width = 121
    Height = 20
    ColorNameMap.Strings = (
      'clBlack=Black'
      'clMaroon=Maroon'
      'clGreen=Green'
      'clOlive=Olive'
      'clNavy=Navy'
      'clPurple=Purple'
      'clTeal=Teal'
      'clGray=Gray'
      'clSilver=Silver'
      'clRed=Red'
      'clLime=Lime'
      'clYellow=Yellow'
      'clBlue=Blue'
      'clFuchsia=Fuchsia'
      'clAqua=Aqua'
      'clLtGray=Light Gray'
      'clDkGray=Dark Gray'
      'clWhite=White'
      'clMoneyGreen=Money Green'
      'clSkyBlue=Sky Blue'
      'clCream=Cream'
      'clMedGray=Medium Gray'
      'clScrollBar=ScrollBar'
      'clBackground=Background'
      'clActiveCaption=Active Caption'
      'clInactiveCaption=Inactive Caption'
      'clMenu=Menu'
      'clWindow=Window'
      'clWindowFrame=Window Frame'
      'clMenuText=Menu Text'
      'clWindowText=Window Text'
      'clCaptionText=Caption Text'
      'clActiveBorder=Active Border'
      'clInactiveBorder=Inactive Border'
      'clAppWorkSpace=Application Workspace'
      'clHighlight=Highlight'
      'clHighlightText=Highlight Text'
      'clBtnFace=Button Face'
      'clBtnShadow=Button Shadow'
      'clGrayText=Gray Text'
      'clBtnText=Button Text'
      'clInactiveCaptionText=Inactive Caption Text'
      'clBtnHighlight=Button Highlight'
      'cl3DDkShadow=3D Dark Shadow'
      'cl3DLight=3D Light'
      'clInfoText=Info Text'
      'clInfoBk=Info Background'
      'clHotLight=Hot Light'
      'clGradientActiveCaption=Gradient Active Caption'
      'clGradientInactiveCaption=Gradient Inactive Caption'
      'clMenuHighlight=Menu Highlight'
      'clMenuBar=MenuBar'
      'clNone=None'
      'clDefault=Default')
    ColorDialogText = '(Other...)'
    DroppedDownWidth = 121
    NewColorText = 'Custom'
    TabOrder = 2
    OnChange = cocbxAttrForegroundChange
  end
  object cocbxAttrBackground: TJvColorComboBox
    Left = 8
    Top = 132
    Width = 121
    Height = 20
    ColorNameMap.Strings = (
      'clBlack=Black'
      'clMaroon=Maroon'
      'clGreen=Green'
      'clOlive=Olive'
      'clNavy=Navy'
      'clPurple=Purple'
      'clTeal=Teal'
      'clGray=Gray'
      'clSilver=Silver'
      'clRed=Red'
      'clLime=Lime'
      'clYellow=Yellow'
      'clBlue=Blue'
      'clFuchsia=Fuchsia'
      'clAqua=Aqua'
      'clLtGray=Light Gray'
      'clDkGray=Dark Gray'
      'clWhite=White'
      'clMoneyGreen=Money Green'
      'clSkyBlue=Sky Blue'
      'clCream=Cream'
      'clMedGray=Medium Gray'
      'clScrollBar=ScrollBar'
      'clBackground=Background'
      'clActiveCaption=Active Caption'
      'clInactiveCaption=Inactive Caption'
      'clMenu=Menu'
      'clWindow=Window'
      'clWindowFrame=Window Frame'
      'clMenuText=Menu Text'
      'clWindowText=Window Text'
      'clCaptionText=Caption Text'
      'clActiveBorder=Active Border'
      'clInactiveBorder=Inactive Border'
      'clAppWorkSpace=Application Workspace'
      'clHighlight=Highlight'
      'clHighlightText=Highlight Text'
      'clBtnFace=Button Face'
      'clBtnShadow=Button Shadow'
      'clGrayText=Gray Text'
      'clBtnText=Button Text'
      'clInactiveCaptionText=Inactive Caption Text'
      'clBtnHighlight=Button Highlight'
      'cl3DDkShadow=3D Dark Shadow'
      'cl3DLight=3D Light'
      'clInfoText=Info Text'
      'clInfoBk=Info Background'
      'clHotLight=Hot Light'
      'clGradientActiveCaption=Gradient Active Caption'
      'clGradientInactiveCaption=Gradient Inactive Caption'
      'clMenuHighlight=Menu Highlight'
      'clMenuBar=MenuBar'
      'clNone=None'
      'clDefault=Default')
    ColorValue = clWhite
    ColorDialogText = '(Other...)'
    DroppedDownWidth = 121
    NewColorText = 'Custom'
    TabOrder = 3
    OnClick = cocbxAttrForegroundChange
  end
  object btnKeywords: TButton
    Left = 164
    Top = 14
    Width = 100
    Height = 25
    Caption = '&Reserved Words'
    TabOrder = 4
    OnClick = btnKeywordsClick
  end
  object edDefaultFilter: TEdit
    Left = 56
    Top = 163
    Width = 241
    Height = 21
    TabOrder = 7
    OnChange = edDefaultFilterChange
  end
  object grbAttrComments: TGroupBox
    Left = 136
    Top = 94
    Width = 161
    Height = 58
    Caption = ' Comments'
    TabOrder = 6
    object cbCommentsBas: TCheckBox
      Left = 104
      Top = 16
      Width = 41
      Height = 17
      Caption = 'B&as'
      TabOrder = 4
      OnClick = cbCommentsAnsiClick
    end
    object cbCommentsAsm: TCheckBox
      Left = 56
      Top = 34
      Width = 41
      Height = 17
      Caption = 'As&m'
      TabOrder = 3
      OnClick = cbCommentsAnsiClick
    end
    object cbCommentsPas: TCheckBox
      Left = 8
      Top = 34
      Width = 41
      Height = 17
      Caption = '&Pas'
      TabOrder = 1
      OnClick = cbCommentsAnsiClick
    end
    object cbCommentsAnsi: TCheckBox
      Left = 8
      Top = 16
      Width = 41
      Height = 17
      Caption = 'A&nsi'
      TabOrder = 0
      OnClick = cbCommentsAnsiClick
    end
    object cbCommentsC: TCheckBox
      Left = 56
      Top = 16
      Width = 41
      Height = 17
      Caption = '&C'
      TabOrder = 2
      OnClick = cbCommentsAnsiClick
    end
  end
  object grbAttrStyle: TGroupBox
    Left = 136
    Top = 49
    Width = 161
    Height = 39
    Caption = ' Style '
    TabOrder = 5
    object cbStyleBold: TCheckBox
      Left = 8
      Top = 13
      Width = 33
      Height = 17
      Caption = '&B'
      TabOrder = 0
      OnClick = cocbxAttrForegroundChange
    end
    object cbStyleStrikeOut: TCheckBox
      Left = 110
      Top = 13
      Width = 33
      Height = 17
      Caption = '&S'
      TabOrder = 3
      OnClick = cocbxAttrForegroundChange
    end
    object cbStyleUnderline: TCheckBox
      Left = 76
      Top = 13
      Width = 31
      Height = 17
      Caption = '&U'
      TabOrder = 2
      OnClick = cocbxAttrForegroundChange
    end
    object cbStyleItalic: TCheckBox
      Left = 42
      Top = 13
      Width = 28
      Height = 17
      Caption = '&I'
      TabOrder = 1
      OnClick = cocbxAttrForegroundChange
    end
  end
end
