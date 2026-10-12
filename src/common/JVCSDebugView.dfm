object fmClientDebugView: TfmClientDebugView
  Left = 14
  Top = 248
  Width = 982
  Height = 247
  Caption = 'Client Debug View'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object memRunList: TMemo
    Left = 0
    Top = 41
    Width = 974
    Height = 179
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 974
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object JvTransLED1: TJvLED
      Left = 8
      Top = 11
    end
    object lbRunCount: TLabel
      Left = 32
      Top = 13
      Width = 8
      Height = 13
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label1: TLabel
      Left = 288
      Top = 13
      Width = 31
      Height = 13
      Caption = 'sort by'
    end
    object btnShowRunning: TButton
      Left = 56
      Top = 8
      Width = 129
      Height = 25
      Caption = 'Show Running Functions'
      TabOrder = 0
      OnClick = btnShowRunningClick
    end
    object btnShowStatistics: TButton
      Left = 192
      Top = 8
      Width = 89
      Height = 25
      Caption = 'Show Statistics'
      TabOrder = 1
      OnClick = btnShowStatisticsClick
    end
    object cboxStatisticSort: TComboBox
      Left = 328
      Top = 10
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = 'Functioncode'
      Items.Strings = (
        'Functioncode'
        'Min. Avg. RunTime'
        'Max. Avg. RunTime'
        'Max. Runs'
        '')
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 464
    Top = 8
  end
end
