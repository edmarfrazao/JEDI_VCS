object VCSLoad: TVCSLoad
  Left = 353
  Top = 232
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Server Login'
  ClientHeight = 252
  ClientWidth = 356
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
  OldCreateOrder = True
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Help: TSpeedButton
    Left = 11
    Top = 221
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
  object spBtnPing: TSpeedButton
    Left = 44
    Top = 221
    Width = 25
    Height = 25
    Hint = 'Ping (Ctrl+P)'
    Glyph.Data = {
      E6000000424DE60000000000000076000000280000000E0000000E0000000100
      0400000000007000000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
      FF00FFFFFFFFF0FFFF00FFFFFF0FFF0FFF00FFFFFFF0FFF0FF00FFFF0FFF0FF0
      FF00FFFFF0FF0FF0FF00F00FF0FF0FF0FF00F00FF0FF0FF0FF00FFFFF0FF0FF0
      FF00FFFF0FFF0FF0FF00FFFFFFF0FFF0FF00FFFFFF0FFF0FFF00FFFFFFFFF0FF
      FF00FFFFFFFFFFFFFF00}
    OnClick = spBtnPingClick
  end
  object btnCancel: TButton
    Left = 270
    Top = 221
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnOpen: TButton
    Left = 183
    Top = 221
    Width = 75
    Height = 25
    Caption = '&Connect'
    Default = True
    TabOrder = 1
    OnClick = btnOpenClick
  end
  object Panel1: TPanel
    Left = 5
    Top = 5
    Width = 344
    Height = 53
    BevelOuter = bvLowered
    BevelWidth = 2
    Color = clWindow
    TabOrder = 3
    object Label2: TLabel
      Left = 4
      Top = 5
      Width = 136
      Height = 13
      Caption = 'JEDI Version Control System'
    end
    object lblVersion: TLabel
      Left = 145
      Top = 5
      Width = 45
      Height = 13
      Caption = 'lblVersion'
    end
    object lblOs: TLabel
      Left = 4
      Top = 21
      Width = 334
      Height = 13
      AutoSize = False
      Caption = 'lblOs'
    end
    object lblSrvMsg: TLabel
      Left = 4
      Top = 37
      Width = 334
      Height = 13
      AutoSize = False
      Caption = 'lblSrvMsg'
    end
  end
  object PageControl1: TPageControl
    Left = 3
    Top = 65
    Width = 350
    Height = 150
    ActivePage = SheetAppServer
    TabIndex = 0
    TabOrder = 0
    object SheetAppServer: TTabSheet
      Caption = '&Application server'
      object GroupBox1: TGroupBox
        Left = 3
        Top = 3
        Width = 335
        Height = 114
        TabOrder = 0
        object Label3: TLabel
          Left = 13
          Top = 19
          Width = 42
          Height = 13
          Caption = 'I&dentity:'
          FocusControl = cbxIdentity
        end
        object spBtnAddID: TSpeedButton
          Left = 258
          Top = 14
          Width = 23
          Height = 22
          Hint = 'Add/ Update Identity (Ctrl+A)'
          Glyph.Data = {
            42010000424D4201000000000000760000002800000011000000110000000100
            040000000000CC00000000000000000000001000000000000000000000000000
            8000008000000080800080000000800080008080000080808000C0C0C0000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
            8888800000008888888888888888800000008888888008888888800000008888
            887AA0888888800000008888887AA0888888800000008888887AA08888888000
            00008888887AA0888888800000008800000AA00000888000000087AAAAAAAAAA
            AA088000000087AAAAAAAAAAAA08800000008877777AA0777788800000008888
            887AA0888888800000008888887AA0888888800000008888887AA08888888000
            00008888887AA088888880000000888888877888888880000000888888888888
            888880000000}
          OnClick = spBtnAddIDClick
        end
        object spBtnRmvID: TSpeedButton
          Left = 288
          Top = 14
          Width = 23
          Height = 22
          Hint = 'Remove Identity (Ctrl+R)'
          Glyph.Data = {
            42010000424D4201000000000000760000002800000011000000110000000100
            040000000000CC00000000000000000000001000000000000000000000000000
            8000008000000080800080000000800080008080000080808000C0C0C0000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
            8888800000008888888888888888800000008888888888888888800000008888
            8888888888888000000088888888888888888000000088888888888888888000
            0000888888888888888880000000880000000000008880000000879999999999
            9908800000008799999999999908800000008877777777777788800000008888
            8888888888888000000088888888888888888000000088888888888888888000
            0000888888888888888880000000888888888888888880000000888888888888
            888880000000}
          OnClick = spBtnRmvIDClick
        end
        object Label6: TLabel
          Left = 161
          Top = 57
          Width = 24
          Height = 13
          Caption = '&Port:'
          FocusControl = PortEdit
        end
        object Label4: TLabel
          Left = 13
          Top = 57
          Width = 26
          Height = 13
          Caption = '&Host:'
          FocusControl = ServerEdit
        end
        object Label1: TLabel
          Left = 13
          Top = 85
          Width = 26
          Height = 13
          Caption = '&User:'
          FocusControl = UserEdit
        end
        object Label12: TLabel
          Left = 161
          Top = 85
          Width = 50
          Height = 13
          Caption = 'Pass&word:'
        end
        object cbxIdentity: TComboBox
          Left = 55
          Top = 15
          Width = 186
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbxIdentityChange
          OnKeyPress = cbxIdentityKeyPress
        end
        object PortEdit: TEdit
          Left = 219
          Top = 53
          Width = 94
          Height = 21
          TabOrder = 2
          OnChange = IDChanged
        end
        object ServerEdit: TEdit
          Left = 55
          Top = 53
          Width = 94
          Height = 21
          TabOrder = 1
          OnChange = IDChanged
        end
        object pwUserPasswordEdit: TJvEdit
          Left = 219
          Top = 81
          Width = 94
          Height = 21
          PasswordChar = '*'
          ProtectPassword = True
          ClipboardCommands = [caPaste, caUndo]
          Modified = False
          TabOrder = 4
          OnChange = UserPasswordEditChange
        end
        object UserEdit: TEdit
          Left = 55
          Top = 81
          Width = 94
          Height = 21
          TabOrder = 3
          OnChange = IDChanged
        end
      end
    end
    object SheetSocks: TTabSheet
      Caption = '&Socks server'
      ImageIndex = 1
      TabVisible = False
      object GroupBox3: TGroupBox
        Left = 5
        Top = 2
        Width = 327
        Height = 108
        TabOrder = 0
        object Label7: TLabel
          Left = 8
          Top = 21
          Width = 36
          Height = 13
          Caption = 'Server:'
          Enabled = False
        end
        object Label8: TLabel
          Left = 198
          Top = 21
          Width = 24
          Height = 13
          Caption = 'Port:'
          Enabled = False
        end
        object Label9: TLabel
          Left = 8
          Top = 64
          Width = 49
          Height = 13
          Caption = 'Usercode:'
          Enabled = False
        end
        object Label10: TLabel
          Left = 170
          Top = 64
          Width = 50
          Height = 13
          Caption = 'Password:'
          Enabled = False
        end
        object SocksServerEdit: TEdit
          Left = 60
          Top = 16
          Width = 101
          Height = 21
          Color = clBtnFace
          Enabled = False
          TabOrder = 0
        end
        object SocksPortEdit: TEdit
          Left = 227
          Top = 17
          Width = 91
          Height = 21
          Color = clBtnFace
          Enabled = False
          TabOrder = 1
        end
        object SocksUsercodeEdit: TEdit
          Left = 60
          Top = 60
          Width = 101
          Height = 21
          Color = clBtnFace
          Enabled = False
          TabOrder = 2
        end
        object SocksPasswordEdit: TEdit
          Left = 227
          Top = 60
          Width = 92
          Height = 21
          Color = clBtnFace
          Enabled = False
          PasswordChar = '*'
          TabOrder = 3
        end
        object SocksAuthCheckBox: TCheckBox
          Left = 60
          Top = 86
          Width = 85
          Height = 17
          Caption = 'Authenticate'
          Enabled = False
          TabOrder = 4
        end
      end
    end
    object SheetOptions: TTabSheet
      Caption = '&Options'
      ImageIndex = 2
      object GroupBox2: TGroupBox
        Left = 3
        Top = 3
        Width = 335
        Height = 114
        TabOrder = 0
        object cbUseCurrentIP: TCheckBox
          Left = 8
          Top = 51
          Width = 321
          Height = 17
          Caption = 'Use always current local &IP as host name'
          TabOrder = 2
          OnClick = cbUseCurrentIPClick
        end
        object cbAutologin: TCheckBox
          Left = 8
          Top = 32
          Width = 321
          Height = 17
          Caption = 'Auto &login local clients (Host = local IP)'
          TabOrder = 1
        end
        object cbSavePW: TCheckBox
          Left = 8
          Top = 13
          Width = 321
          Height = 17
          Caption = 'St&ore Password with identity'
          TabOrder = 0
          OnClick = cbSavePWClick
        end
        object cbSyncServerTime: TCheckBox
          Left = 8
          Top = 70
          Width = 321
          Height = 17
          Caption = 'Sync local time with server &time'
          TabOrder = 3
          OnClick = cbSyncServerTimeClick
        end
      end
    end
  end
  object LoginTimer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = LoginTimerTimer
    Left = 317
    Top = 10
  end
  object ReConnectTimer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = ReConnectTimerTimer
    Left = 258
    Top = 10
  end
end
