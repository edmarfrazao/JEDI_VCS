object VCSProgress: TVCSProgress
  Left = 319
  Top = 212
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Progress'
  ClientHeight = 49
  ClientWidth = 216
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 216
    Height = 49
    Align = alClient
    BevelWidth = 2
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 9
      Width = 31
      Height = 13
      Alignment = taCenter
      Caption = 'Label1'
    end
    object ProgressBar1: TProgressBar
      Left = 8
      Top = 28
      Width = 201
      Height = 11
      Min = 0
      Max = 100
      Step = 1
      TabOrder = 0
    end
  end
end
