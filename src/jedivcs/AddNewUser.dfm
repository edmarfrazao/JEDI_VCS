object VCSAddUser: TVCSAddUser
  Left = 318
  Top = 269
  AutoScroll = False
  Caption = 'Add new User'
  ClientHeight = 261
  ClientWidth = 274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButton: TPanel
    Left = 0
    Top = 229
    Width = 274
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      274
      32)
    object Help: TSpeedButton
      Left = 10
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
    object btnOK: TButton
      Left = 103
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      Enabled = False
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 191
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object gbDescription: TGroupBox
    Left = 0
    Top = 126
    Width = 274
    Height = 103
    Align = alClient
    Caption = '&Description'
    TabOrder = 1
    object meDescription: TMemo
      Left = 2
      Top = 15
      Width = 270
      Height = 86
      Align = alClient
      MaxLength = 2000
      TabOrder = 0
    end
  end
  object pnlHead: TPanel
    Left = 0
    Top = 0
    Width = 274
    Height = 126
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 2
      Width = 51
      Height = 13
      Caption = '&User name'
      FocusControl = edUser
    end
    object Label4: TLabel
      Left = 146
      Top = 2
      Width = 58
      Height = 13
      Caption = '&Access level'
      FocusControl = cbLevel
    end
    object Label3: TLabel
      Left = 8
      Top = 42
      Width = 46
      Height = 13
      Caption = '&Password'
      FocusControl = edPW
    end
    object Label5: TLabel
      Left = 144
      Top = 42
      Width = 86
      Height = 13
      Caption = '&Confirm password'
      FocusControl = edPW2
    end
    object Label6: TLabel
      Left = 8
      Top = 82
      Width = 228
      Height = 13
      Caption = 'Client &IP address (optional, see documentation)'
      FocusControl = edIP
    end
    object spBtnEditIP: TSpeedButton
      Left = 241
      Top = 96
      Width = 23
      Height = 22
      Hint = 'Edit IP'
      Caption = '&...'
      OnClick = spBtnEditIPClick
    end
    object edUser: TEdit
      Left = 8
      Top = 18
      Width = 121
      Height = 21
      MaxLength = 50
      TabOrder = 0
      OnChange = edUserChange
    end
    object cbLevel: TComboBox
      Left = 144
      Top = 18
      Width = 122
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        'Guest account'
        'Read only access'
        'Read write access'
        'Project administrator'
        'Archive administrator')
    end
    object edPW: TEdit
      Left = 8
      Top = 58
      Width = 121
      Height = 21
      MaxLength = 50
      PasswordChar = '*'
      TabOrder = 2
      OnChange = edUserChange
    end
    object edPW2: TEdit
      Left = 144
      Top = 58
      Width = 121
      Height = 21
      MaxLength = 50
      PasswordChar = '*'
      TabOrder = 3
      OnChange = edUserChange
    end
    object edIP: TEdit
      Left = 9
      Top = 97
      Width = 223
      Height = 21
      Color = clBtnFace
      MaxLength = 50
      ReadOnly = True
      TabOrder = 4
    end
  end
end
