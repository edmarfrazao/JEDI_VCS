object VCSChangeUserPW: TVCSChangeUserPW
  Left = 318
  Top = 269
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 179
  ClientWidth = 199
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
    Top = 22
    Width = 65
    Height = 13
    Caption = '&Old password'
  end
  object Label3: TLabel
    Left = 8
    Top = 62
    Width = 70
    Height = 13
    Caption = '&New password'
  end
  object Label5: TLabel
    Left = 8
    Top = 103
    Width = 109
    Height = 13
    Caption = '&Confirm new password'
  end
  object lblUser: TLabel
    Left = 8
    Top = 4
    Width = 32
    Height = 13
    Caption = 'lblUser'
  end
  object Help: TSpeedButton
    Left = 8
    Top = 151
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
    Left = 41
    Top = 151
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Enabled = False
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 121
    Top = 151
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object pwedOldPW: TJvEdit
    Left = 8
    Top = 38
    Width = 185
    Height = 21
    PasswordChar = '*'
    ProtectPassword = True
    Modified = False
    TabOrder = 0
    OnChange = edOldPWChange
  end
  object pwedPW: TJvEdit
    Left = 8
    Top = 78
    Width = 185
    Height = 21
    PasswordChar = '*'
    ProtectPassword = True
    Modified = False
    TabOrder = 1
    OnChange = edOldPWChange
  end
  object pwedPW2: TJvEdit
    Left = 8
    Top = 119
    Width = 185
    Height = 21
    PasswordChar = '*'
    ProtectPassword = True
    Modified = False
    TabOrder = 2
    OnChange = edOldPWChange
  end
end
