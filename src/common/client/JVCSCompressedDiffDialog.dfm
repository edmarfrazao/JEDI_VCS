object VCSCompressedDiff: TVCSCompressedDiff
  Left = 360
  Top = 315
  AutoScroll = False
  Caption = 'Compressed Diff'
  ClientHeight = 292
  ClientWidth = 459
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormShow
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  inline CompressedDiffFrame: TJVCSCompressedDiffFrm
    Left = 0
    Top = 0
    Width = 459
    Height = 253
    Align = alClient
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 253
    Width = 459
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      459
      39)
    object Button1: TButton
      Left = 379
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Close'
      Default = True
      ModalResult = 2
      TabOrder = 0
    end
    object PB: TProgressBar
      Left = 8
      Top = 12
      Width = 365
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
  end
end
