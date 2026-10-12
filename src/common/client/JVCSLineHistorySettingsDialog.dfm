object JVCSLineHistorySettingsDlg: TJVCSLineHistorySettingsDlg
  Left = 415
  Top = 329
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Color and User Settings'
  ClientHeight = 230
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 199
    Width = 311
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      311
      31)
    object btnOK: TButton
      Left = 61
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnApply: TButton
      Left = 141
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Apply'
      TabOrder = 1
      OnClick = btnApplyClick
    end
    object btnCancel: TButton
      Left = 217
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object VSTUserColors: TVirtualStringTree
    Left = 0
    Top = 113
    Width = 311
    Height = 86
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    Header.Style = hsFlatButtons
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnAfterCellPaint = VSTUserColorsAfterCellPaint
    OnDblClick = VSTUserColorsDblClick
    OnFocusChanged = VSTUserColorsFocusChanged
    OnGetText = VSTUserColorsGetText
    Columns = <
      item
        Position = 0
        Width = 150
        WideText = 'User'
      end
      item
        Position = 1
        WideText = 'Color'
      end
      item
        Position = 2
        Width = 80
        WideText = 'Visible Name'
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 311
    Height = 113
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 0
      Top = 20
      Width = 51
      Height = 13
      Caption = 'Date Color'
    end
    object Label2: TLabel
      Left = 72
      Top = 0
      Width = 24
      Height = 13
      Caption = 'From'
    end
    object Label3: TLabel
      Left = 272
      Top = 0
      Width = 12
      Height = 13
      Caption = 'To'
    end
    object Label4: TLabel
      Left = 0
      Top = 52
      Width = 71
      Height = 13
      Caption = 'Revision Color '
    end
    object Label5: TLabel
      Left = 0
      Top = 84
      Width = 27
      Height = 13
      Caption = 'Users'
    end
    object JvGradient1: TJvGradient
      Left = 113
      Top = 16
      Width = 152
      Height = 22
      Align = alNone
    end
    object JvGradient2: TJvGradient
      Left = 112
      Top = 48
      Width = 153
      Height = 22
      Align = alNone
    end
    object spBtnClear: TSpeedButton
      Left = 104
      Top = 80
      Width = 25
      Height = 25
      Hint = 'Remove User'
      Glyph.Data = {
        42010000424D4201000000000000760000002800000011000000110000000100
        040000000000CC00000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888800000008888888888888888800000008888888888888888800000008888
        8888888888888000000088888888888888888000000088888888888888888000
        0000888888888888888880000000880000000000008880000000879999999999
        9908800000008799999999999908800000008877777777777788800000008888
        8888888888888000000088888888888888888000000088888888888888888000
        0000888888888888888880000000888888888888888880000000888888888888
        888880000000}
      OnClick = spBtnClearClick
    end
    object spBtnAdd: TSpeedButton
      Left = 72
      Top = 80
      Width = 25
      Height = 25
      Hint = 'Add User'
      Glyph.Data = {
        42010000424D4201000000000000760000002800000011000000110000000100
        040000000000CC00000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888800000008888888888888888800000008888888008888888800000008888
        887AA0888888800000008888887AA0888888800000008888887AA08888888000
        00008888887AA0888888800000008800000AA00000888000000087AAAAAAAAAA
        AA088000000087AAAAAAAAAAAA08800000008877777AA0777788800000008888
        887AA0888888800000008888887AA0888888800000008888887AA08888888000
        00008888887AA088888880000000888888877888888880000000888888888888
        888880000000}
      OnClick = spBtnAddClick
    end
    object cbtnDateTo: TJvOfficeColorButton
      Left = 272
      Top = 16
      Width = 35
      Height = 22
      TabOrder = 0
      SelectedColor = clNone
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      Properties.ShowDefaultColor = False
      Properties.NoneColorCaption = 'No Color'
      Properties.DefaultColorCaption = 'Automatic'
      Properties.CustomColorCaption = 'Other Colors...'
      Properties.NoneColorHint = 'No Color'
      Properties.DefaultColorHint = 'Automatic'
      Properties.CustomColorHint = 'Other Colors...'
      Properties.NoneColorFont.Charset = DEFAULT_CHARSET
      Properties.NoneColorFont.Color = clWindowText
      Properties.NoneColorFont.Height = -11
      Properties.NoneColorFont.Name = 'Tahoma'
      Properties.NoneColorFont.Style = []
      Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
      Properties.DefaultColorFont.Color = clWindowText
      Properties.DefaultColorFont.Height = -11
      Properties.DefaultColorFont.Name = 'Tahoma'
      Properties.DefaultColorFont.Style = []
      Properties.CustomColorFont.Charset = DEFAULT_CHARSET
      Properties.CustomColorFont.Color = clWindowText
      Properties.CustomColorFont.Height = -11
      Properties.CustomColorFont.Name = 'Tahoma'
      Properties.CustomColorFont.Style = []
      Properties.FloatWindowCaption = 'Color Window'
      Properties.DragBarHint = 'Drag to float'
      OnColorChange = cbtnDateFromColorChange
    end
    object cbtnRevisionFrom: TJvOfficeColorButton
      Left = 72
      Top = 48
      Width = 35
      Height = 22
      TabOrder = 1
      SelectedColor = clNone
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      Properties.ShowDefaultColor = False
      Properties.NoneColorCaption = 'No Color'
      Properties.DefaultColorCaption = 'Automatic'
      Properties.CustomColorCaption = 'Other Colors...'
      Properties.NoneColorHint = 'No Color'
      Properties.DefaultColorHint = 'Automatic'
      Properties.CustomColorHint = 'Other Colors...'
      Properties.NoneColorFont.Charset = DEFAULT_CHARSET
      Properties.NoneColorFont.Color = clWindowText
      Properties.NoneColorFont.Height = -11
      Properties.NoneColorFont.Name = 'Tahoma'
      Properties.NoneColorFont.Style = []
      Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
      Properties.DefaultColorFont.Color = clWindowText
      Properties.DefaultColorFont.Height = -11
      Properties.DefaultColorFont.Name = 'Tahoma'
      Properties.DefaultColorFont.Style = []
      Properties.CustomColorFont.Charset = DEFAULT_CHARSET
      Properties.CustomColorFont.Color = clWindowText
      Properties.CustomColorFont.Height = -11
      Properties.CustomColorFont.Name = 'Tahoma'
      Properties.CustomColorFont.Style = []
      Properties.FloatWindowCaption = 'Color Window'
      Properties.DragBarHint = 'Drag to float'
      OnColorChange = cbtnRevisionFromColorChange
    end
    object cbtnRevisionTo: TJvOfficeColorButton
      Left = 272
      Top = 48
      Width = 35
      Height = 22
      TabOrder = 2
      SelectedColor = clNone
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      Properties.ShowDefaultColor = False
      Properties.NoneColorCaption = 'No Color'
      Properties.DefaultColorCaption = 'Automatic'
      Properties.CustomColorCaption = 'Other Colors...'
      Properties.NoneColorHint = 'No Color'
      Properties.DefaultColorHint = 'Automatic'
      Properties.CustomColorHint = 'Other Colors...'
      Properties.NoneColorFont.Charset = DEFAULT_CHARSET
      Properties.NoneColorFont.Color = clWindowText
      Properties.NoneColorFont.Height = -11
      Properties.NoneColorFont.Name = 'Tahoma'
      Properties.NoneColorFont.Style = []
      Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
      Properties.DefaultColorFont.Color = clWindowText
      Properties.DefaultColorFont.Height = -11
      Properties.DefaultColorFont.Name = 'Tahoma'
      Properties.DefaultColorFont.Style = []
      Properties.CustomColorFont.Charset = DEFAULT_CHARSET
      Properties.CustomColorFont.Color = clWindowText
      Properties.CustomColorFont.Height = -11
      Properties.CustomColorFont.Name = 'Tahoma'
      Properties.CustomColorFont.Style = []
      Properties.FloatWindowCaption = 'Color Window'
      Properties.DragBarHint = 'Drag to float'
      OnColorChange = cbtnRevisionFromColorChange
    end
    object cbtnDateFrom: TJvOfficeColorButton
      Left = 72
      Top = 16
      Width = 35
      Height = 22
      TabOrder = 3
      SelectedColor = clNone
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      Properties.ShowDefaultColor = False
      Properties.NoneColorCaption = 'No Color'
      Properties.DefaultColorCaption = 'Automatic'
      Properties.CustomColorCaption = 'Other Colors...'
      Properties.NoneColorHint = 'No Color'
      Properties.DefaultColorHint = 'Automatic'
      Properties.CustomColorHint = 'Other Colors...'
      Properties.NoneColorFont.Charset = DEFAULT_CHARSET
      Properties.NoneColorFont.Color = clWindowText
      Properties.NoneColorFont.Height = -11
      Properties.NoneColorFont.Name = 'Tahoma'
      Properties.NoneColorFont.Style = []
      Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
      Properties.DefaultColorFont.Color = clWindowText
      Properties.DefaultColorFont.Height = -11
      Properties.DefaultColorFont.Name = 'Tahoma'
      Properties.DefaultColorFont.Style = []
      Properties.CustomColorFont.Charset = DEFAULT_CHARSET
      Properties.CustomColorFont.Color = clWindowText
      Properties.CustomColorFont.Height = -11
      Properties.CustomColorFont.Name = 'Tahoma'
      Properties.CustomColorFont.Style = []
      Properties.FloatWindowCaption = 'Color Window'
      Properties.DragBarHint = 'Drag to float'
      OnColorChange = cbtnDateFromColorChange
    end
    object cbtnUserColor: TJvOfficeColorButton
      Left = 136
      Top = 80
      Width = 35
      Height = 22
      TabOrder = 4
      SelectedColor = clNone
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      Properties.NoneColorCaption = 'No Color'
      Properties.DefaultColorCaption = 'Automatic'
      Properties.CustomColorCaption = 'Other Colors...'
      Properties.NoneColorHint = 'No Color'
      Properties.DefaultColorHint = 'Automatic'
      Properties.CustomColorHint = 'Other Colors...'
      Properties.NoneColorFont.Charset = DEFAULT_CHARSET
      Properties.NoneColorFont.Color = clWindowText
      Properties.NoneColorFont.Height = -11
      Properties.NoneColorFont.Name = 'Tahoma'
      Properties.NoneColorFont.Style = []
      Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
      Properties.DefaultColorFont.Color = clWindowText
      Properties.DefaultColorFont.Height = -11
      Properties.DefaultColorFont.Name = 'Tahoma'
      Properties.DefaultColorFont.Style = []
      Properties.CustomColorFont.Charset = DEFAULT_CHARSET
      Properties.CustomColorFont.Color = clWindowText
      Properties.CustomColorFont.Height = -11
      Properties.CustomColorFont.Name = 'Tahoma'
      Properties.CustomColorFont.Style = []
      Properties.FloatWindowCaption = 'Color Window'
      Properties.DragBarHint = 'Drag to float'
      OnColorChange = cbtnUserColorColorChange
    end
  end
  object JvColorDialog1: TJvColorDialog
    Ctl3D = True
    Left = 192
    Top = 80
  end
end
