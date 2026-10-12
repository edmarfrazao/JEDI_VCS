inherited JVCSDiffAbout: TJVCSDiffAbout
  Caption = 'About JEDI Version Control System Diff/Merge Utility'
  PixelsPerInch = 96
  TextHeight = 14
  inherited PageControl1: TPageControl
    inherited tsAbout: TTabSheet
      inherited Panel2: TPanel
        inherited Label6: TLabel
          Width = 343
          Caption = 'Source codes based on Thomas Hensle'#39's FreeVCS Diff/Merge.'
        end
      end
    end
    inherited tsCredits: TTabSheet
      inherited Memo3: TMemo
        Lines.Strings = (
          '')
      end
    end
  end
end
