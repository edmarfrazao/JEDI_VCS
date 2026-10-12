object VCSPassword: TVCSPassword
  Left = 272
  Top = 230
  ActiveControl = edPW
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'VCS Backup'
  ClientHeight = 110
  ClientWidth = 190
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 12
    Top = 80
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 104
    Top = 80
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 177
    Height = 70
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 30
      Height = 13
      Caption = '&Enter:'
      FocusControl = edPW
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 32
      Height = 13
      Caption = '&Verify:'
      FocusControl = edVerify
    end
    object edPW: TEdit
      Left = 44
      Top = 16
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 0
    end
    object edVerify: TEdit
      Left = 44
      Top = 40
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
  end
end
