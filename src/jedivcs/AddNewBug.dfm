object VCSAddBug: TVCSAddBug
  Left = 348
  Top = 265
  AutoScroll = False
  Caption = 'Add new Bug'
  ClientHeight = 379
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbWorkaround: TGroupBox
    Left = 0
    Top = 245
    Width = 439
    Height = 105
    Align = alBottom
    Caption = '&Workaround'
    TabOrder = 2
    object meWorkaround: TJvMemo
      Left = 2
      Top = 15
      Width = 435
      Height = 88
      AutoSize = False
      MaxLines = 0
      HideCaret = False
      Align = alClient
      TabOrder = 0
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 350
    Width = 439
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      439
      29)
    object Help: TSpeedButton
      Left = 1
      Top = 3
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
      Left = 273
      Top = 3
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      Enabled = False
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 361
      Top = 3
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object gbDesription: TGroupBox
    Left = 0
    Top = 119
    Width = 439
    Height = 126
    Align = alClient
    Caption = '&Desription'
    TabOrder = 1
    object meDescription: TJvMemo
      Left = 2
      Top = 15
      Width = 435
      Height = 109
      AutoSize = False
      MaxLines = 0
      HideCaret = False
      Align = alClient
      MaxLength = 2000
      TabOrder = 0
    end
  end
  object pnlBugHead: TPanel
    Left = 0
    Top = 0
    Width = 439
    Height = 119
    Align = alTop
    TabOrder = 0
    DesignSize = (
      439
      119)
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 47
      Height = 13
      Caption = '&Bug name'
      FocusControl = edBug
    end
    object Label4: TLabel
      Left = 8
      Top = 37
      Width = 40
      Height = 13
      Caption = '&Severity'
      FocusControl = cbLevel
    end
    object Label7: TLabel
      Left = 312
      Top = 36
      Width = 26
      Height = 13
      Alignment = taRightJustify
      Anchors = [akRight, akBottom]
      Caption = 'S&tate'
      FocusControl = cbxStatus
    end
    object Label3: TLabel
      Left = 8
      Top = 63
      Width = 47
      Height = 13
      Caption = '&Keywords'
      FocusControl = edKeywords
    end
    object Label5: TLabel
      Left = 8
      Top = 92
      Width = 45
      Height = 13
      Caption = '&Reported'
      FocusControl = edReported
    end
    object edBug: TEdit
      Left = 66
      Top = 6
      Width = 363
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 250
      TabOrder = 0
      OnChange = edBugChange
    end
    object cbLevel: TComboBox
      Left = 66
      Top = 33
      Width = 242
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        'Minor'
        'Awkward'
        'Significant'
        'Serious'
        'Fatal')
    end
    object cbxStatus: TComboBox
      Left = 343
      Top = 33
      Width = 87
      Height = 21
      Style = csDropDownList
      Anchors = [akRight, akBottom]
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        'Unknown'
        'Open'
        'Sheduled'
        'Fixed'
        'Ignored')
    end
    object edKeywords: TEdit
      Left = 66
      Top = 60
      Width = 362
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 250
      TabOrder = 3
    end
    object edReported: TEdit
      Left = 66
      Top = 87
      Width = 362
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
    end
  end
end
