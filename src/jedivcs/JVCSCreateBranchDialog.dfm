object JVCSCreateBranchForm: TJVCSCreateBranchForm
  Left = 381
  Top = 286
  ActiveControl = wipBranchCreation
  BorderStyle = bsDialog
  Caption = 'Create new branch'
  ClientHeight = 339
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object CreateBranchWizard: TJvWizard
    Left = 0
    Top = 0
    Width = 537
    Height = 339
    ActivePage = wipBranchCreation
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Back'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&Next >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Finish'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = 'Abbrechen'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Hilfe'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = True
    OnActivePageChanged = CreateBranchWizardActivePageChanged
    OnActivePageChanging = CreateBranchWizardActivePageChanging
    DesignSize = (
      537
      339)
    object wipParentBranch: TJvWizardInteriorPage
      Header.Height = 50
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Parent Branch'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Select the parent branch'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'Parent Branch'
      object rbCurrentBranch: TRadioButton
        Left = 16
        Top = 136
        Width = 209
        Height = 17
        Caption = 'Current Branch'
        TabOrder = 0
        OnClick = rbSelectBranchClick
      end
      object rbSelectBranch: TRadioButton
        Left = 16
        Top = 184
        Width = 113
        Height = 17
        Caption = 'Select Branch'
        TabOrder = 1
        OnClick = rbSelectBranchClick
      end
    end
    object wipParentBranchSelection: TJvWizardInteriorPage
      Header.Height = 50
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Parent Branch Selection'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Select the parent branch'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'Parent Branch Selection'
    end
    object wipNameAndDescription: TJvWizardInteriorPage
      Header.Height = 50
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Name and Description'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Enter the name and a description'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'Name and Description'
      object Label1: TLabel
        Left = 4
        Top = 60
        Width = 27
        Height = 13
        Caption = 'Name'
      end
      object gbDescription: TGroupBox
        Left = 0
        Top = 80
        Width = 392
        Height = 217
        Align = alBottom
        Caption = '&Description'
        TabOrder = 0
        object memDescription: TJvMemo
          Left = 2
          Top = 15
          Width = 388
          Height = 200
          AutoSize = False
          MaxLines = 0
          HideCaret = False
          Align = alClient
          MaxLength = 2000
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object edBranchName: TEdit
        Left = 40
        Top = 56
        Width = 345
        Height = 21
        TabOrder = 1
        OnChange = edBranchNameChange
      end
    end
    object wipOptions: TJvWizardInteriorPage
      Header.Height = 50
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Options'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Set some additional options'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'Options'
      DesignSize = (
        392
        297)
      object lbOldRootPath: TLabel
        Left = 3
        Top = 162
        Width = 67
        Height = 13
        Caption = 'Old Root Path'
      end
      object lbNewRootPath: TLabel
        Left = 3
        Top = 189
        Width = 72
        Height = 13
        Caption = 'New Root Path'
      end
      object spBtnBrowseOld: TSpeedButton
        Left = 366
        Top = 158
        Width = 23
        Height = 22
        Hint = 'Browse'
        Anchors = [akTop, akRight]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00303333333333
          333337F3333333333333303333333333333337F33FFFFF3FF3FF303300000300
          300337FF77777F77377330000BBB0333333337777F337F33333330330BB00333
          333337F373F773333333303330033333333337F3377333333333303333333333
          333337F33FFFFF3FF3FF303300000300300337FF77777F77377330000BBB0333
          333337777F337F33333330330BB00333333337F373F773333333303330033333
          333337F3377333333333303333333333333337FFFF3FF3FFF333000003003000
          333377777F77377733330BBB0333333333337F337F33333333330BB003333333
          333373F773333333333330033333333333333773333333333333}
        NumGlyphs = 2
        OnClick = spBtnBrowseOldClick
      end
      object spBtnBrowseNew: TSpeedButton
        Left = 366
        Top = 185
        Width = 23
        Height = 22
        Hint = 'Browse'
        Anchors = [akTop, akRight]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00303333333333
          333337F3333333333333303333333333333337F33FFFFF3FF3FF303300000300
          300337FF77777F77377330000BBB0333333337777F337F33333330330BB00333
          333337F373F773333333303330033333333337F3377333333333303333333333
          333337F33FFFFF3FF3FF303300000300300337FF77777F77377330000BBB0333
          333337777F337F33333330330BB00333333337F373F773333333303330033333
          333337F3377333333333303333333333333337FFFF3FF3FFF333000003003000
          333377777F77377733330BBB0333333333337F337F33333333330BB003333333
          333373F773333333333330033333333333333773333333333333}
        NumGlyphs = 2
        OnClick = spBtnBrowseOldClick
      end
      object cbTagOnly: TCheckBox
        Left = 3
        Top = 105
        Width = 386
        Height = 17
        Caption = 'Tag Only (add only the latest revision to the branch)'
        TabOrder = 0
      end
      object cbSubstituteRootPath: TCheckBox
        Left = 3
        Top = 136
        Width = 126
        Height = 17
        Caption = 'Substitute Root Path'
        TabOrder = 1
        OnClick = cbSubstituteRootPathClick
      end
      object edOldRootPath: TEdit
        Left = 80
        Top = 159
        Width = 281
        Height = 21
        TabOrder = 2
        OnChange = edOldRootPathChange
      end
      object edNewRootPath: TEdit
        Left = 80
        Top = 186
        Width = 281
        Height = 21
        TabOrder = 3
        OnChange = edOldRootPathChange
      end
    end
    object wipSummary: TJvWizardInteriorPage
      Header.Height = 50
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Summary'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'The next step will create a branch with this options'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Caption = 'Summary'
      object memSummary: TMemo
        Left = 0
        Top = 50
        Width = 392
        Height = 247
        Align = alClient
        Color = clBtnFace
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object wipBranchCreation: TJvWizardInteriorPage
      Header.Height = 50
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Branch Creation'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Text = 'Subtitle'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkStart, bkLast, bkNext, bkCancel, bkHelp]
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'Branch Creation'
      OnFinishButtonClick = wipBranchCreationFinishButtonClick
      object lbCreateBranch: TLabel
        Left = 0
        Top = 160
        Width = 393
        Height = 19
        Alignment = taCenter
        AutoSize = False
        Caption = 'Create Branch - Please wait!'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object CreateBranchWizardSteps: TJvWizardRouteMapSteps
      Left = 0
      Top = 0
      Width = 145
      Height = 297
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
  end
end
