object VCSSelectDrive: TVCSSelectDrive
  Left = 400
  Top = 345
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Find'
  ClientHeight = 156
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 250
    Height = 13
    Caption = 'Select the drive that JEDI VCS should search for the'
  end
  object lblSearchFor: TLabel
    Left = 8
    Top = 22
    Width = 59
    Height = 13
    Caption = 'lblSearchFor'
  end
  object Label3: TLabel
    Left = 8
    Top = 70
    Width = 181
    Height = 29
    AutoSize = False
    Caption = 
      'Remember that the search may take some time and cannot be cancel' +
      'd.'
    WordWrap = True
  end
  object btnCancel: TButton
    Left = 205
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object JvDriveCombo: TJvDriveCombo
    Left = 8
    Top = 40
    Width = 257
    Height = 22
    DriveTypes = [dtFixed]
    Offset = 4
    ItemHeight = 16
    TabOrder = 1
  end
  object Button1: TButton
    Left = 128
    Top = 120
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
end
