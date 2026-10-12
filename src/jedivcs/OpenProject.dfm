object VCSOpenProject: TVCSOpenProject
  Left = 433
  Top = 279
  BorderStyle = bsDialog
  Caption = 'New Project'
  ClientHeight = 115
  ClientWidth = 244
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
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 136
    Height = 26
    Caption = '&Enter the name for the new project:'
    FocusControl = edProjectName
    WordWrap = True
  end
  object Help: TSpeedButton
    Left = 8
    Top = 84
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
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 193
    Height = 13
    Caption = 'Project names are always in lower-case.'
  end
  object edProjectName: TEdit
    Left = 8
    Top = 24
    Width = 229
    Height = 21
    CharCase = ecLowerCase
    MaxLength = 50
    TabOrder = 0
    OnChange = edProjectNameChange
  end
  object btnOK: TButton
    Left = 72
    Top = 84
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    Enabled = False
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 160
    Top = 84
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
