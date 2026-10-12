object VCSAssignLabels: TVCSAssignLabels
  Left = 353
  Top = 250
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Assign Labels'
  ClientHeight = 433
  ClientWidth = 462
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010002002020100000000000E80200002600000010101000000000002801
    00000E0300002800000020000000400000000100040000000000800200000000
    0000000000000000000000000000000000000000800000800000008080008000
    00008000800080800000C0C0C000808080000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000003B3B3B3B3B3B3B3B3B3B3B3B3B00000
    3B3B3B3B3B3B3B3B3B3B3B3B3B000000B3B3B3B3B3B3B3B3B3B3B3B3B300000B
    3B3B3B3B3B3B3B3B3B3B3B3B30B00003B3B3B3B3B3B3B3B3B3B3B3B3B0F0003B
    3B3B3B3B3B3B3B3B3B3B3B3B00B000B3B3B3B3B3B3B3B3B3B3B3B3B300F00B3B
    3B3B3B3B3B3B3B3B3B3B3B30F0B00000000000000000000000000000F0F00000
    0B0FFFF00FFFFFFFFFFFFFFFF0B000000F0FFFF00FFFFFFFFFFFFFFFF0F00000
    0B0FFFF00FFFFFFFFFFFFFFFF0B000000F0FFFF00FF000000000000FF0F00000
    0B0FFFF00FFFFFFFFFFFFFFFF0B000000F0FFFF00FFFFFFFFFFFFFFFF0F00000
    0B0FFFFF0FFFFFFFFFFFFFFFF0B000000F0FFFFF0FF000000000000FF0F00000
    0B0000000FFFFFFFFFFFFFFFF0B000000FFBFFFB0FFFFFFFFFFFFFFFF0F00000
    00FFFBFF0FFFFFFFFFFFFFFFF0000000000BFFFB0FF000000000000FF0000000
    000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000
    000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000F000
    0000E0000000E0000000C0000000C00000008000000080000000000000000000
    0000F0000000F0000000F0000000F0000000F0000000F0000000F0000000F000
    0000F0000000F0000000F0000000FC000003FE000003FFF00003FFF00003FFF0
    0003FFF00003FFFFFFFFFFFFFFFF280000001000000020000000010004000000
    0000C00000000000000000000000000000000000000000000000000080000080
    000000808000800000008000800080800000C0C0C000808080000000FF0000FF
    000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000000000000000
    000000000000000000000000000000003B3B3B3B3B000003B3B3B3B3B000000B
    3B3B3B3BB00000B3B3B3B3BB0B00000000000000030000BB0FF0FFFF0B0000B3
    0FF0FFFF0300003B0000F00F0B00000B3B30FFFF03000000B3B0F00F0B000000
    0000FFFF000000000000000000000000000000000000FFFF0000FFFF0000E001
    0000E0010000C0010000C0010000800100008001000080010000800100008001
    0000C0010000E0010000F0030000FE070000FFFF0000}
  KeyPreview = True
  OldCreateOrder = False
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object JvSplitterTop: TJvSplitter
    Left = 0
    Top = 137
    Width = 462
    Height = 4
    Cursor = crVSplit
    Align = alTop
  end
  object lvAssignedLabels: TListView
    Left = 0
    Top = 0
    Width = 462
    Height = 137
    Align = alTop
    Columns = <
      item
        Caption = 'Label assigned to'
        Width = 200
      end
      item
        Alignment = taRightJustify
        Caption = 'ID'
      end
      item
        Caption = 'Description'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'Changed'
        MaxWidth = 1
        Width = 0
      end>
    ColumnClick = False
    Constraints.MinHeight = 35
    HideSelection = False
    ReadOnly = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvAssignedLabelsChange
    OnDblClick = spBtnRemoveClick
  end
  object pnlMiddle: TPanel
    Left = 0
    Top = 141
    Width = 462
    Height = 254
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinHeight = 125
    TabOrder = 1
    object JvSplitterDesc: TJvSplitter
      Left = 0
      Top = 196
      Width = 462
      Height = 4
      Cursor = crVSplit
      Align = alBottom
    end
    object meLabelDescr: TMemo
      Left = 0
      Top = 200
      Width = 462
      Height = 54
      TabStop = False
      Align = alBottom
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 0
    end
    object pnlSearchFind: TPanel
      Left = 0
      Top = 0
      Width = 462
      Height = 196
      Align = alClient
      Caption = 'pnlSearchFind'
      Constraints.MinHeight = 65
      TabOrder = 1
      object lvLabels: TListView
        Left = 1
        Top = 56
        Width = 460
        Height = 139
        Align = alClient
        Columns = <
          item
            Caption = 'Available labels'
            Width = 200
          end
          item
            Alignment = taRightJustify
            Caption = 'ID'
          end
          item
            Caption = 'Description'
            MaxWidth = 1
            Width = 0
          end
          item
            Caption = 'Changed'
            MaxWidth = 1
            Width = 0
          end>
        ColumnClick = False
        HideSelection = False
        ReadOnly = True
        PopupMenu = PopupMenu2
        TabOrder = 1
        ViewStyle = vsReport
        OnChange = lvLabelsChange
        OnDblClick = spBtnAddClick
      end
      object Panel3: TPanel
        Left = 1
        Top = 1
        Width = 460
        Height = 55
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 0
        DesignSize = (
          460
          55)
        object Label1: TLabel
          Left = 9
          Top = 8
          Width = 49
          Height = 13
          Alignment = taRightJustify
          Caption = '&Find label:'
          FocusControl = edSearch
        end
        object spBtnGetLLabel: TSpeedButton
          Left = 428
          Top = 3
          Width = 23
          Height = 22
          Action = acGetLLabel
          Anchors = [akTop, akRight]
          Glyph.Data = {
            EE000000424DEE0000000000000076000000280000000F0000000F0000000100
            0400000000007800000000000000000000001000000010000000000000000000
            BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7770777777777777777077777777777777707777707777707770777700777700
            7770777000777000777077000077000077707000007000007770770000770000
            7770777000777000777077770077770077707777707777707770777777777777
            777077777777777777707777777777777770}
        end
        object spBtnApply: TSpeedButton
          Left = 428
          Top = 28
          Width = 23
          Height = 22
          Hint = 'Apply mask'
          Anchors = [akTop, akRight]
          Glyph.Data = {
            DE000000424DDE0000000000000076000000280000000D0000000D0000000100
            0400000000006800000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7000777777777777700077777777777770007777007777777000777000077777
            7000770000007777700077007000077770007707770000777000777777700077
            7000777777770077700077777777707770007777777777777000777777777777
            7000}
          OnClick = spBtnApplyClick
        end
        object edSearch: TEdit
          Left = 65
          Top = 4
          Width = 352
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edSearchChange
          OnEnter = edSearchEnter
        end
        object cbMask: TCheckBox
          Left = 10
          Top = 30
          Width = 49
          Height = 17
          Caption = '&Mask'
          TabOrder = 1
          OnClick = cbMaskClick
        end
        object rcbLabelMask: TJvComboBox
          Left = 65
          Top = 28
          Width = 352
          Height = 21
          AutoComplete = False
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          TabOrder = 2
          Text = '*'
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 395
    Width = 462
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      462
      38)
    object spBtnAdd: TSpeedButton
      Left = 40
      Top = 8
      Width = 25
      Height = 25
      Action = acAdd
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
    end
    object spBtnRemove: TSpeedButton
      Left = 72
      Top = 8
      Width = 25
      Height = 25
      Action = acRemove
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
    end
    object spBtnMaintain: TSpeedButton
      Left = 104
      Top = 8
      Width = 25
      Height = 25
      Hint = 'Label manager'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333033
        33333333333338F33333333333330F0333333333333F8F8F333333333330FBF0
        3333333333F83338F3333333330FB0BF033333333F8338338F33333330FB0F0B
        F0333333F8338383383333330FB0FBF00333333F8338333883333330FB0FBFBF
        033333F8338333338F33330FB0FB0B0BF033338F38338383F83333000FB0B0BF
        033333888338383F83333330FB0B0BF033333FF8F38383F83333300FBFB0BF03
        3333F88F33383F833333030B00FBF0333333838F8833F8333333330F00BF0333
        3333338F883F833333333330FBF03333333333F8FFF833333333330300033333
        33333F8388833333333330333333333333333833333333333333}
      NumGlyphs = 2
      OnClick = spBtnMaintainClick
    end
    object Help: TSpeedButton
      Left = 8
      Top = 8
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
    object btnCancel: TButton
      Left = 381
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Done'
      Default = True
      TabOrder = 0
      OnClick = btnCancelClick
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 248
    Top = 24
    object RemoveLabel1: TMenuItem
      Caption = 'Remove Label'
      OnClick = spBtnRemoveClick
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 216
    Top = 24
    object Addlabel1: TMenuItem
      Caption = 'Add label'
      OnClick = spBtnAddClick
    end
  end
  object ActionList1: TActionList
    Left = 144
    Top = 400
    object acAdd: TAction
      Hint = 'Add label to revision'
      OnExecute = spBtnAddClick
    end
    object acRemove: TAction
      Hint = 'Remove label from revision'
      OnExecute = spBtnRemoveClick
    end
    object acGetLLabel: TAction
      Hint = 'Find last used label'
      OnExecute = spBtnGetLLabelClick
    end
  end
end
