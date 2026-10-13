object fm_EditorProp: Tfm_EditorProp
  Left = 342
  Top = 235
  BorderStyle = bsDialog
  Caption = 'Editor'
  ClientHeight = 414
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
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 48
    Height = 13
    Caption = 'Max &Undo'
    FocusControl = speMaxUndo
  end
  object Label4: TLabel
    Left = 8
    Top = 43
    Width = 59
    Height = 13
    Caption = 'Line &Spacing'
    FocusControl = speLineSpacing
  end
  object Label3: TLabel
    Left = 8
    Top = 71
    Width = 52
    Height = 13
    Caption = 'Right &Edge'
    FocusControl = speRightEdge
  end
  object Label2: TLabel
    Left = 8
    Top = 103
    Width = 53
    Height = 13
    Caption = 'Editor &Font'
  end
  object speFont: TSpeedButton
    Left = 272
    Top = 97
    Width = 26
    Height = 26
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777447777777777777744777777777777774477777777731377444777777777
      1777447777777777173744777777777711174444775577771737777777735777
      1773777777775773111177777777577777777777777555777777777777775777
      7777777777775377777777777777755777777777777777777777}
    OnClick = speFontClick
  end
  object Label5: TLabel
    Left = 8
    Top = 163
    Width = 97
    Height = 13
    Caption = '&Window background'
    FocusControl = cocbxWinBack
  end
  object Label6: TLabel
    Left = 156
    Top = 203
    Width = 98
    Height = 13
    Caption = 'Selected f&oreground'
    FocusControl = cocbxSelFore
  end
  object Label7: TLabel
    Left = 8
    Top = 203
    Width = 100
    Height = 13
    Caption = 'Selected &background'
    FocusControl = cocbxSelBack
  end
  object Label8: TLabel
    Left = 156
    Top = 163
    Width = 48
    Height = 13
    Caption = 'Fo&nt color'
    FocusControl = cocbxText
  end
  object Label9: TLabel
    Left = 8
    Top = 132
    Width = 286
    Height = 26
    AutoSize = False
    Caption = 
      'Remember that the color settings below may be overwritten by Hig' +
      'hlighter settings.'
    WordWrap = True
  end
  object Label10: TLabel
    Left = 144
    Top = 71
    Width = 49
    Height = 13
    Caption = '&Tab Width'
    FocusControl = speRightEdge
  end
  object speMaxUndo: TSpinEdit
    Left = 75
    Top = 12
    Width = 57
    Height = 22
    TabOrder = 0
    MaxValue = 0
    MinValue = 0
    Value = 0
  end
  object speLineSpacing: TSpinEdit
    Left = 75
    Top = 39
    Width = 57
    Height = 22
    TabOrder = 1
    MaxValue = 0
    MinValue = 0
    Value = 0
  end
  object speRightEdge: TSpinEdit
    Left = 75
    Top = 67
    Width = 57
    Height = 22
    TabOrder = 2
    MaxValue = 0
    MinValue = 0
    Value = 0
  end
  object pnEditorFont: TPanel
    Left = 75
    Top = 96
    Width = 190
    Height = 28
    BevelOuter = bvLowered
    Caption = 'pnEditorFont'
    TabOrder = 5
  end
  object btnOK: TButton
    Left = 136
    Top = 382
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 10
  end
  object btnCancel: TButton
    Left = 224
    Top = 382
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 11
    OnClick = btnCancelClick
  end
  object cbEnableLeftEditor: TCheckBox
    Left = 144
    Top = 16
    Width = 153
    Height = 17
    Caption = '&Left editor always enabled'
    TabOrder = 3
  end
  object cbEnableRightEditor: TCheckBox
    Left = 144
    Top = 40
    Width = 161
    Height = 17
    Caption = '&Right editor always enabled'
    TabOrder = 4
  end
  object cocbxWinBack: TColorBox
    Left = 8
    Top = 177
    Width = 133
    Height = 20
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    Selected = clWhite
    TabOrder = 6
    OnChange = cocbxWinBackChange
  end
  object cocbxSelFore: TColorBox
    Left = 156
    Top = 217
    Width = 133
    Height = 20
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    Selected = clYellow
    TabOrder = 9
    OnChange = cocbxSelForeChange
  end
  object cocbxSelBack: TColorBox
    Left = 8
    Top = 217
    Width = 133
    Height = 20
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    Selected = clNavy
    TabOrder = 8
    OnChange = cocbxSelBackChange
  end
  object cocbxText: TColorBox
    Left = 156
    Top = 177
    Width = 133
    Height = 20
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    TabOrder = 7
    OnChange = cocbxTextChange
  end
  object speTabWidth: TSpinEdit
    Left = 203
    Top = 67
    Width = 57
    Height = 22
    TabOrder = 12
    MaxValue = 0
    MinValue = 0
    Value = 0
  end
  object grbUI: TGroupBox
    Left = 8
    Top = 246
    Width = 289
    Height = 128
    Caption = ' User interface (all JEDI VCS windows) '
    TabOrder = 13
    object lblUIScale: TLabel
      Left = 8
      Top = 22
      Width = 95
      Height = 13
      Caption = 'Interface font si&ze'
      FocusControl = cbUIScale
    end
    object lblUIFont: TLabel
      Left = 8
      Top = 50
      Width = 69
      Height = 13
      Caption = 'Interface f&ont'
    end
    object lblTheme: TLabel
      Left = 8
      Top = 102
      Width = 33
      Height = 13
      Caption = 'T&heme'
      FocusControl = cbTheme
    end
    object cbUIScale: TComboBox
      Left = 120
      Top = 18
      Width = 81
      Height = 21
      TabOrder = 0
      Items.Strings = (
        '100%'
        '125%'
        '150%'
        '175%'
        '200%')
    end
    object pnUIFont: TPanel
      Left = 120
      Top = 45
      Width = 137
      Height = 24
      BevelOuter = bvLowered
      Caption = 'pnUIFont'
      TabOrder = 1
    end
    object btnUIFont: TButton
      Left = 260
      Top = 45
      Width = 24
      Height = 24
      Caption = '...'
      TabOrder = 2
      OnClick = btnUIFontClick
    end
    object btnUIFontDefault: TButton
      Left = 120
      Top = 72
      Width = 137
      Height = 22
      Caption = '&System default font'
      TabOrder = 3
      OnClick = btnUIFontDefaultClick
    end
    object cbTheme: TComboBox
      Left = 120
      Top = 98
      Width = 137
      Height = 21
      Style = csDropDownList
      TabOrder = 4
      Items.Strings = (
        'Follow Windows'
        'Light'
        'Dark')
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Options = [fdEffects, fdFixedPitchOnly]
    Left = 8
    Top = 245
  end
  object FontDialog2: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [fdForceFontExist]
    Left = 40
    Top = 380
  end
end
