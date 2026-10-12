object VCSAddCompareTool: TVCSAddCompareTool
  Left = 371
  Top = 303
  AutoScroll = False
  Caption = 'Edit Compare Tool'
  ClientHeight = 168
  ClientWidth = 212
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
  DesignSize = (
    212
    168)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 46
    Width = 89
    Height = 13
    Caption = '&File compare utility'
    FocusControl = edPath
  end
  object Label6: TLabel
    Left = 8
    Top = 91
    Width = 149
    Height = 13
    Caption = 'C&ommand line parameter string'
    FocusControl = edParam
  end
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 76
    Height = 13
    Caption = '(Internal) &Name'
    FocusControl = edName
  end
  object Help: TSpeedButton
    Left = 8
    Top = 137
    Width = 25
    Height = 25
    Hint = 'Help (F1)'
    Anchors = [akLeft, akBottom]
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
  object edPath: TJvFilenameEdit
    Left = 8
    Top = 63
    Width = 195
    Height = 21
    AddQuotes = False
    Filter = 
      'Programs (*.exe;*.com;*.bat)|*.exe;*.com;*.bat|All files (*.*)|*' +
      '.*'
    DialogOptions = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnChange = edNameChange
  end
  object edName: TEdit
    Left = 8
    Top = 20
    Width = 195
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = edNameChange
  end
  object edParam: TEdit
    Left = 8
    Top = 108
    Width = 195
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnChange = edNameChange
  end
  object btnCancel: TButton
    Left = 129
    Top = 137
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnOK: TButton
    Left = 49
    Top = 137
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    Enabled = False
    TabOrder = 3
    OnClick = btnOKClick
  end
end
