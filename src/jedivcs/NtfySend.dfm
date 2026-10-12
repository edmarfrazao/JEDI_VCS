object NtfySendForm: TNtfySendForm
  Left = 355
  Top = 222
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Send Message'
  ClientHeight = 286
  ClientWidth = 330
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
    0000800080008080000080808000C0C0C0000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000003B3B3B3B3B3B3B3B3B3B3B3B3B00000
    3B3B3B3B3B3B3B3B3B3B3B3B3B000000B3B3B3B3B3B3B3B3B3B3B3B3B300000B
    3B3B3B3B3B3B3B3B3B3B3B3B30B00003B3B3B3B3B3B3B3B3B3B3B3B3B0F0003B
    3B3B3B3B3B3B3B3B3B3B3B3B00B000B3B3B3B3B3B3B3B3B3B3B3B3B300F00B3B
    3B3B3B3B3B3B3B3B3B3B3B30F0B00000000000000000000000000000F0F00000
    0B0FFFFFFFFFFFFFFFFFFFFFF0B000000F0FFFFFFCCCCCCCCCCCCCFFF0F00000
    0B0FFFFFFFFFFFFFFFFFFFFFF0B000000F0FFFFFFCCCCCCCCCCCCCFFF0F00000
    0B0FFFFFFFFFFFFFFFFFFFFFF0B000000F0FFFFFFCCCCCCCCCCCCCFFF0F00000
    0B0FFFFFFFFFFFFFFFFFFFFFF0B000000F0FFFFFFFFFFFFFFFFFFFFFF0F00000
    0B0FFFFFFFFFFFFFFFFFFFFFF0B000000F0FCCCCFFFFFFFFFFFF9999F0F00000
    000FFFFFFFFFFFFFFFFF9999F0000000000FFFFFFFFFFFFFFFFFFFFFF0000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000F000
    0000E0000000E0000000C0000000C00000008000000080000000000000000000
    0000F0000000F0000000F0000000F0000000F0000000F0000000F0000000F000
    0000F0000000F0000000F0000000FC000003FE000003FFFFFFFFFFFFFFFFFFFF
    FFFFFFFFFFFFFFFFFFFFFFFFFFFF280000001000000020000000010004000000
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
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButton: TPanel
    Left = 0
    Top = 254
    Width = 330
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      330
      32)
    object Help: TSpeedButton
      Left = 8
      Top = 5
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
    object btnSendM: TButton
      Left = 164
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Send'
      Default = True
      Enabled = False
      TabOrder = 0
      OnClick = btnSendMClick
    end
    object Button1: TButton
      Left = 252
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object gbMessage: TGroupBox
    Left = 0
    Top = 110
    Width = 330
    Height = 144
    Align = alClient
    Caption = '&Message:'
    TabOrder = 1
    object meMessage: TJvMemo
      Left = 2
      Top = 15
      Width = 326
      Height = 127
      AutoSize = False
      MaxLines = 0
      HideCaret = False
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 0
      OnChange = meMessageChange
    end
  end
  object pnlHead: TPanel
    Left = 0
    Top = 0
    Width = 330
    Height = 110
    Align = alTop
    TabOrder = 0
    DesignSize = (
      330
      110)
    object spBtnRecipient: TSpeedButton
      Left = 298
      Top = 80
      Width = 23
      Height = 22
      Hint = 'Select recipients'
      Anchors = [akRight]
      Caption = '...'
      Enabled = False
      OnClick = spBtnRecipientClick
    end
    object plFrom: TPanel
      Left = 8
      Top = 8
      Width = 315
      Height = 21
      Alignment = taLeftJustify
      Anchors = [akLeft, akRight]
      BevelOuter = bvLowered
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 8
      Top = 36
      Width = 315
      Height = 21
      Alignment = taLeftJustify
      Anchors = [akLeft, akRight]
      BevelOuter = bvLowered
      Caption = 'To: Domain [*] via mailslot [FVCSMail]'
      TabOrder = 1
    end
    object cbSMTPForward: TCheckBox
      Left = 8
      Top = 62
      Width = 105
      Height = 17
      Caption = 'SMTP &forwarding'
      TabOrder = 2
      OnClick = cbSMTPForwardClick
    end
    object rbToAll: TRadioButton
      Left = 16
      Top = 83
      Width = 49
      Height = 17
      Caption = '&To All'
      Checked = True
      TabOrder = 3
      TabStop = True
      OnClick = rbToAllClick
    end
    object rbSingle: TRadioButton
      Left = 72
      Top = 83
      Width = 33
      Height = 17
      Caption = 'To'
      TabOrder = 4
      OnClick = rbToAllClick
    end
    object edRecipient: TEdit
      Left = 112
      Top = 80
      Width = 178
      Height = 21
      Anchors = [akLeft, akRight]
      Color = clBtnFace
      Enabled = False
      TabOrder = 5
    end
  end
end
