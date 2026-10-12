object VCSEditIP: TVCSEditIP
  Left = 309
  Top = 279
  BorderStyle = bsDialog
  Caption = 'IP Address'
  ClientHeight = 131
  ClientWidth = 236
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 57
    Top = 59
    Width = 11
    Height = 37
    Caption = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 113
    Top = 59
    Width = 11
    Height = 37
    Caption = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 169
    Top = 59
    Width = 11
    Height = 37
    Caption = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 20
    Top = 48
    Width = 110
    Height = 13
    Caption = '(Wildcards * ? allowed)'
  end
  object Help: TSpeedButton
    Left = 8
    Top = 100
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
  object rbFree: TRadioButton
    Left = 8
    Top = 8
    Width = 208
    Height = 17
    Caption = '&Allow this user login from any client'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbFreeClick
  end
  object rbRestricted: TRadioButton
    Left = 8
    Top = 28
    Width = 209
    Height = 17
    Caption = '&Restrict to IP address (IP mask)'
    TabOrder = 1
    OnClick = rbFreeClick
  end
  object Edit1: TEdit
    Left = 14
    Top = 68
    Width = 40
    Height = 21
    MaxLength = 3
    TabOrder = 2
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 70
    Top = 68
    Width = 40
    Height = 21
    MaxLength = 3
    TabOrder = 3
    OnChange = Edit2Change
  end
  object Edit3: TEdit
    Left = 126
    Top = 68
    Width = 40
    Height = 21
    MaxLength = 3
    TabOrder = 4
    OnChange = Edit3Change
  end
  object Edit4: TEdit
    Left = 182
    Top = 68
    Width = 40
    Height = 21
    MaxLength = 3
    TabOrder = 5
  end
  object btnOK: TButton
    Left = 68
    Top = 100
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 156
    Top = 100
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
end
