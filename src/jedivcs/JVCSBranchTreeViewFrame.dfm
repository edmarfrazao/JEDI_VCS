object JVCSBranchTreeViewFrm: TJVCSBranchTreeViewFrm
  Left = 0
  Top = 0
  Width = 346
  Height = 223
  TabOrder = 0
  object vtBranch: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 346
    Height = 223
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    Header.Style = hsFlatButtons
    TabOrder = 0
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnFocusChanged = vtBranchFocusChanged
    OnGetText = vtBranchGetText
    OnInitChildren = vtBranchInitChildren
    OnInitNode = vtBranchInitNode
    Columns = <
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 170
        WideText = 'Name'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 100
        WideText = 'Created By'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Width = 120
        WideText = 'Created In'
      end>
  end
end
