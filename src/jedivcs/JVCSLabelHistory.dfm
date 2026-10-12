object VCSLabelHistory: TVCSLabelHistory
  Left = 281
  Top = 163
  AutoScroll = False
  Caption = 'Label History'
  ClientHeight = 286
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 184
    Width = 634
    Height = 102
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      634
      102)
    object lbFromLabel: TLabel
      Left = 0
      Top = 56
      Width = 53
      Height = 13
      Caption = 'From-Label'
    end
    object lbToLabel: TLabel
      Left = 0
      Top = 80
      Width = 41
      Height = 13
      Caption = 'To-Label'
    end
    object Label3: TLabel
      Left = 0
      Top = 8
      Width = 34
      Height = 13
      Caption = 'Project'
    end
    object Label4: TLabel
      Left = 0
      Top = 32
      Width = 26
      Height = 13
      Caption = 'Mode'
    end
    object cbFromLabel: TComboBox
      Left = 56
      Top = 52
      Width = 177
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbFromLabelChange
    end
    object cbToLabel: TComboBox
      Left = 56
      Top = 76
      Width = 177
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = cbFromLabelChange
    end
    object cbProjects: TComboBox
      Left = 56
      Top = 4
      Width = 177
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbFromLabelChange
    end
    object btnGenerate: TButton
      Left = 385
      Top = 73
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Generate...'
      Enabled = False
      TabOrder = 4
      OnClick = btnGenerateClick
    end
    object btnReport: TButton
      Left = 468
      Top = 73
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Report...'
      TabOrder = 5
      OnClick = btnReportClick
    end
    object btnClose: TButton
      Left = 554
      Top = 73
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Close'
      Default = True
      TabOrder = 6
      OnClick = btnCloseClick
    end
    object cbMode: TComboBox
      Left = 56
      Top = 28
      Width = 177
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbFromLabelChange
      Items.Strings = (
        'Label to label'
        'Label to latest'
        'Branchpoint to latest')
    end
  end
  object elvHistory: TdfsEnhListView
    Left = 0
    Top = 0
    Width = 634
    Height = 184
    NoColumnResize = False
    Align = alClient
    Columns = <
      item
        Caption = 'Path'
        Width = 220
      end
      item
        Caption = 'Name'
        Width = 100
      end
      item
        Caption = 'Version.Revision'
      end
      item
        Caption = 'Comment'
        Width = 250
      end>
    TabOrder = 1
    ViewStyle = vsReport
  end
end
