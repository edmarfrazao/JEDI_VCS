object VCSAddLabel: TVCSAddLabel
  Left = 318
  Top = 269
  AutoScroll = False
  Caption = 'Add Label'
  ClientHeight = 193
  ClientWidth = 269
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
    Top = 161
    Width = 269
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      269
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
      Left = 101
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
      Left = 189
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
    Top = 38
    Width = 269
    Height = 123
    Align = alClient
    Caption = '&Description'
    TabOrder = 1
    object meDescription: TMemo
      Left = 2
      Top = 15
      Width = 265
      Height = 106
      Align = alClient
      MaxLength = 2000
      TabOrder = 0
    end
  end
  object pnlHead: TPanel
    Left = 0
    Top = 0
    Width = 269
    Height = 38
    Align = alTop
    TabOrder = 0
    DesignSize = (
      269
      38)
    object Label1: TLabel
      Left = 7
      Top = 12
      Width = 25
      Height = 13
      Caption = '&Label'
      FocusControl = edLabel
    end
    object edLabel: TEdit
      Left = 42
      Top = 7
      Width = 221
      Height = 21
      Anchors = [akLeft, akRight]
      MaxLength = 250
      TabOrder = 0
      OnChange = edLabelChange
    end
  end
end
