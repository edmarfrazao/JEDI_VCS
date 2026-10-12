object VCSAddFamily: TVCSAddFamily
  Left = 318
  Top = 269
  AutoScroll = False
  Caption = 'Add Family'
  ClientHeight = 222
  ClientWidth = 487
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
  object pnlButton: TPanel
    Left = 0
    Top = 190
    Width = 487
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      487
      32)
    object Help: TSpeedButton
      Left = 8
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
      Left = 319
      Top = 5
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
      Left = 407
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object gbDescription: TGroupBox
    Left = 0
    Top = 63
    Width = 487
    Height = 127
    Align = alClient
    Caption = '&Description'
    TabOrder = 1
    object meDescription: TMemo
      Left = 2
      Top = 15
      Width = 483
      Height = 110
      Align = alClient
      MaxLength = 2000
      TabOrder = 0
    end
  end
  object pnlHead: TPanel
    Left = 0
    Top = 0
    Width = 487
    Height = 63
    Align = alTop
    TabOrder = 0
    DesignSize = (
      487
      63)
    object Label1: TLabel
      Left = 10
      Top = 10
      Width = 59
      Height = 13
      Caption = '&Family name'
      FocusControl = edFamily
    end
    object Label3: TLabel
      Left = 8
      Top = 35
      Width = 55
      Height = 13
      Caption = '&Parent ext.'
      FocusControl = edParent
    end
    object Label4: TLabel
      Left = 201
      Top = 35
      Width = 78
      Height = 13
      Caption = '&Child extensions'
      FocusControl = edChild
    end
    object spBtnEditChild: TSpeedButton
      Left = 458
      Top = 32
      Width = 23
      Height = 22
      Hint = 'Edit child extensions'
      Anchors = [akTop, akRight]
      Caption = '...'
      OnClick = spBtnEditChildClick
    end
    object edFamily: TEdit
      Left = 85
      Top = 6
      Width = 396
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      MaxLength = 50
      TabOrder = 0
      OnChange = edFamilyChange
    end
    object edParent: TEdit
      Left = 85
      Top = 32
      Width = 108
      Height = 21
      MaxLength = 10
      TabOrder = 1
      OnChange = edFamilyChange
    end
    object edChild: TEdit
      Left = 280
      Top = 32
      Width = 174
      Height = 21
      Hint = 'seperate with semikolons ;.ext1;.ext2...'
      Anchors = [akLeft, akRight, akBottom]
      MaxLength = 250
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnChange = edFamilyChange
    end
  end
end
