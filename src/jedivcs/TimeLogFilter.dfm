object VCSTLFilter: TVCSTLFilter
  Left = 335
  Top = 253
  BorderStyle = bsDialog
  Caption = 'Time Log Filter'
  ClientHeight = 127
  ClientWidth = 212
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 3
    Top = 12
    Width = 59
    Height = 13
    Alignment = taRightJustify
    Caption = '&Include user'
    FocusControl = cbxUser
  end
  object Label3: TLabel
    Left = 14
    Top = 48
    Width = 49
    Height = 13
    Alignment = taRightJustify
    Caption = '&From date'
    FocusControl = dtpStart
  end
  object Label4: TLabel
    Left = 23
    Top = 68
    Width = 37
    Height = 13
    Alignment = taRightJustify
    Caption = '&To date'
    FocusControl = dtpStop
  end
  object cbxUser: TComboBox
    Left = 68
    Top = 8
    Width = 137
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    Items.Strings = (
      'All Users')
  end
  object dtpStart: TDateTimePicker
    Left = 68
    Top = 40
    Width = 137
    Height = 21
    CalAlignment = dtaLeft
    Date = 36631.6305821644
    Time = 36631.6305821644
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 1
  end
  object dtpStop: TDateTimePicker
    Left = 68
    Top = 64
    Width = 137
    Height = 21
    CalAlignment = dtaLeft
    Date = 36631.6307595023
    Time = 36631.6307595023
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 44
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 132
    Top = 96
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
