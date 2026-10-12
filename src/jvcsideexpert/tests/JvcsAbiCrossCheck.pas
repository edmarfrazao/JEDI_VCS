unit JvcsAbiCrossCheck;

{ F) Verificacao INDEPENDENTE da ABI do expert (a DLL falsa usa a mesma
  JVCSExpertABI do expert, entao os testes A/B nao pegariam um layout errado):

  - JVCSExpertABI x src\common\JVCSIDEInterfaceCommon.pas ORIGINAL (lado da
    JvcsExternalDll), compilada com os includes vazios de tests\abi-stub;
  - posicao de cada campo x tabela 3.4 de doc\client\Expert-IDE-Analise.md
    (record IDE: indice = coluna "#") e x a ordem dos records VCS, Notifier,
    History e Operation do fonte original. Cada campo recebe, PELO NOME, um
    marcador com o seu indice; o slot k do record tem de conter o marcador k;
  - assinatura de cada tipo procedural (convencao, tipos dos parametros e do
    retorno): atribuicao campo a campo entre os records das duas units, que
    so compila se as assinaturas forem identicas (os 4 tipos com enum/set na
    assinatura sao conferidos pelos enums/sets abaixo);
  - enums/sets: tamanho, ordinal maximo e ordinais usados pelo expert. }

interface

type
  TAbiCheckProc = procedure(Cond: Boolean; const What: string);

procedure RunAbiCrossCheck(ACheck: TAbiCheckProc);

implementation

uses
  System.SysUtils, JVCSIDEInterfaceCommon, JVCSExpertABI;

type
  TSlots = array[0..31] of Pointer;
  PSlots = ^TSlots;

var
  OIde: JVCSIDEInterfaceCommon.TExternalIDEFunctionRec;
  CIde: JVCSExpertABI.TExternalIDEFunctionRec;
  OVcs: JVCSIDEInterfaceCommon.TExternalVCSFunctionRec;
  CVcs: JVCSExpertABI.TExternalVCSFunctionRec;
  ONtf: JVCSIDEInterfaceCommon.TExternalNotifierFunctionRec;
  CNtf: JVCSExpertABI.TExternalNotifierFunctionRec;
  OHis: JVCSIDEInterfaceCommon.TExternalVCSModuleHistoryFunctionRec;
  CHis: JVCSExpertABI.TExternalVCSModuleHistoryFunctionRec;
  OOpr: JVCSIDEInterfaceCommon.TExternalVCSOperationFunctionRec;
  COpr: JVCSExpertABI.TExternalVCSOperationFunctionRec;

function M(AIndex: Integer): Pointer;
begin
  Result := Pointer(NativeUInt($7000 + AIndex));
end;

function SlotErrors(AOrig, ACopy: Pointer; ACount, AOrigSize, ACopySize: Integer): string;
var
  K: Integer;
begin
  Result := '';
  if (AOrigSize <> ACount * SizeOf(Pointer)) or (ACopySize <> AOrigSize) then
    Result := Format('tamanho original %d, copia %d, esperado %d; ',
      [AOrigSize, ACopySize, ACount * SizeOf(Pointer)]);
  for K := 0 to ACount - 1 do
  begin
    if PSlots(AOrig)^[K] <> M(K) then
      Result := Result + Format('original[%d]; ', [K]);
    if PSlots(ACopy)^[K] <> M(K) then
      Result := Result + Format('copia[%d]; ', [K]);
  end;
end;

procedure MarkIde;
begin
  FillChar(OIde, SizeOf(OIde), 0);
  FillChar(CIde, SizeOf(CIde), 0);
  // indices = coluna "#" da tabela 3.4
  @OIde.CloseProject := M(0);            @CIde.CloseProject := M(0);
  @OIde.CloseFile := M(1);               @CIde.CloseFile := M(1);
  @OIde.SaveFile := M(2);                @CIde.SaveFile := M(2);
  @OIde.OpenFile := M(3);                @CIde.OpenFile := M(3);
  @OIde.GetParentHandle := M(4);         @CIde.GetParentHandle := M(4);
  @OIde.GetProjectName := M(5);          @CIde.GetProjectName := M(5);
  @OIde.GetUnitCount := M(6);            @CIde.GetUnitCount := M(6);
  @OIde.GetUnitName := M(7);             @CIde.GetUnitName := M(7);
  @OIde.GetFormCount := M(8);            @CIde.GetFormCount := M(8);
  @OIde.GetFormName := M(9);             @CIde.GetFormName := M(9);
  @OIde.GetCurrentFile := M(10);         @CIde.GetCurrentFile := M(10);
  @OIde.IsFileOpen := M(11);             @CIde.IsFileOpen := M(11);
  @OIde.GetModuleCount := M(12);         @CIde.GetModuleCount := M(12);
  @OIde.GetModuleName := M(13);          @CIde.GetModuleName := M(13);
  @OIde.GetComponentCount := M(14);      @CIde.GetComponentCount := M(14);
  @OIde.GetComponentName := M(15);       @CIde.GetComponentName := M(15);
  @OIde.RaiseException := M(16);         @CIde.RaiseException := M(16);
  @OIde.GetBaseRegistryKey := M(17);     @CIde.GetBaseRegistryKey := M(17);
  @OIde.GetModuleComponentCount := M(18); @CIde.GetModuleComponentCount := M(18);
  @OIde.GetModuleComponent := M(19);     @CIde.GetModuleComponent := M(19);
  @OIde.SourceWriteString := M(20);      @CIde.SourceWriteString := M(20);
  @OIde.SourceReadString := M(21);       @CIde.SourceReadString := M(21);
  @OIde.GetOptions := M(22);             @CIde.GetOptions := M(22);
  @OIde.IsFileOpenAndWriteable := M(23); @CIde.IsFileOpenAndWriteable := M(23);
end;

procedure MarkOthers;
begin
  FillChar(OVcs, SizeOf(OVcs), 0);
  FillChar(CVcs, SizeOf(CVcs), 0);
  @OVcs.GetIDString := M(0);             @CVcs.GetIDString := M(0);
  @OVcs.ExecuteVerb := M(1);             @CVcs.ExecuteVerb := M(1);
  @OVcs.GetMenuName := M(2);             @CVcs.GetMenuName := M(2);
  @OVcs.GetVerb := M(3);                 @CVcs.GetVerb := M(3);
  @OVcs.GetVerbCount := M(4);            @CVcs.GetVerbCount := M(4);
  @OVcs.GetVerbState := M(5);            @CVcs.GetVerbState := M(5);
  @OVcs.ProjectChange := M(6);           @CVcs.ProjectChange := M(6);
  @OVcs.GetVerbImages := M(7);           @CVcs.GetVerbImages := M(7);
  @OVcs.GetVerbImageIndex := M(8);       @CVcs.GetVerbImageIndex := M(8);
  @OVcs.GetVerbShortCut := M(9);         @CVcs.GetVerbShortCut := M(9);

  FillChar(ONtf, SizeOf(ONtf), 0);
  FillChar(CNtf, SizeOf(CNtf), 0);
  @ONtf.FileNotification := M(0);        @CNtf.FileNotification := M(0);
  @ONtf.EventNotification := M(1);       @CNtf.EventNotification := M(1);

  FillChar(OHis, SizeOf(OHis), 0);
  FillChar(CHis, SizeOf(CHis), 0);
  @OHis.GetModuleHistoryCount := M(0);              @CHis.GetModuleHistoryCount := M(0);
  @OHis.GetModuleHistoryAuthor := M(1);             @CHis.GetModuleHistoryAuthor := M(1);
  @OHis.GetModuleHistoryVersionRevisionStr := M(2); @CHis.GetModuleHistoryVersionRevisionStr := M(2);
  @OHis.GetModuleHistoryLabelCount := M(3);         @CHis.GetModuleHistoryLabelCount := M(3);
  @OHis.GetModuleHistoryLabel := M(4);              @CHis.GetModuleHistoryLabel := M(4);
  @OHis.GetModuleHistoryDate := M(5);               @CHis.GetModuleHistoryDate := M(5);
  @OHis.GetModuleHistoryComment := M(6);            @CHis.GetModuleHistoryComment := M(6);
  @OHis.GetModuleHistoryContentSize := M(7);        @CHis.GetModuleHistoryContentSize := M(7);
  @OHis.GetModuleHistoryContent := M(8);            @CHis.GetModuleHistoryContent := M(8);

  FillChar(OOpr, SizeOf(OOpr), 0);
  FillChar(COpr, SizeOf(COpr), 0);
  @OOpr.GetProjectID := M(0);            @COpr.GetProjectID := M(0);
  @OOpr.CheckInModule := M(1);           @COpr.CheckInModule := M(1);
  @OOpr.CheckOutModule := M(2);          @COpr.CheckOutModule := M(2);
  @OOpr.GetModule := M(3);               @COpr.GetModule := M(3);
  @OOpr.CompareModule := M(4);           @COpr.CompareModule := M(4);
  @OOpr.ShowModuleHistory := M(5);       @COpr.ShowModuleHistory := M(5);
  @OOpr.ShowProjectManager := M(6);      @COpr.ShowProjectManager := M(6);
  @OOpr.ShowProjectHistory := M(7);      @COpr.ShowProjectHistory := M(7);
  @OOpr.SyncProject := M(8);             @COpr.SyncProject := M(8);
  @OOpr.DiffModule := M(9);              @COpr.DiffModule := M(9);
end;

// So compila se cada tipo procedural tiver a MESMA assinatura nas duas units
// (convencao de chamada, quantidade/tipos/modificadores dos parametros e
// retorno). Executada no fim (copia os marcadores, sem efeito).
procedure SignatureCheck;
begin
  CIde.CloseProject := OIde.CloseProject;
  CIde.CloseFile := OIde.CloseFile;
  CIde.SaveFile := OIde.SaveFile;
  CIde.OpenFile := OIde.OpenFile;
  CIde.GetParentHandle := OIde.GetParentHandle;
  CIde.GetProjectName := OIde.GetProjectName;
  CIde.GetUnitCount := OIde.GetUnitCount;
  CIde.GetUnitName := OIde.GetUnitName;
  CIde.GetFormCount := OIde.GetFormCount;
  CIde.GetFormName := OIde.GetFormName;
  CIde.GetCurrentFile := OIde.GetCurrentFile;
  CIde.IsFileOpen := OIde.IsFileOpen;
  CIde.GetModuleCount := OIde.GetModuleCount;
  CIde.GetModuleName := OIde.GetModuleName;
  CIde.GetComponentCount := OIde.GetComponentCount;
  CIde.GetComponentName := OIde.GetComponentName;
  CIde.RaiseException := OIde.RaiseException;
  CIde.GetBaseRegistryKey := OIde.GetBaseRegistryKey;
  CIde.GetModuleComponentCount := OIde.GetModuleComponentCount;
  CIde.GetModuleComponent := OIde.GetModuleComponent;
  CIde.SourceWriteString := OIde.SourceWriteString;
  CIde.SourceReadString := OIde.SourceReadString;
  // GetOptions: retorno TIDEInterfaceOptions (set) - conferido nos sets
  CIde.IsFileOpenAndWriteable := OIde.IsFileOpenAndWriteable;

  CVcs.GetIDString := OVcs.GetIDString;
  CVcs.ExecuteVerb := OVcs.ExecuteVerb;
  CVcs.GetMenuName := OVcs.GetMenuName;
  CVcs.GetVerb := OVcs.GetVerb;
  CVcs.GetVerbCount := OVcs.GetVerbCount;
  CVcs.GetVerbState := OVcs.GetVerbState;
  CVcs.ProjectChange := OVcs.ProjectChange;
  // GetVerbImages: retorno TGetVerbImagesResult (enum) - conferido nos enums
  CVcs.GetVerbImageIndex := OVcs.GetVerbImageIndex;
  CVcs.GetVerbShortCut := OVcs.GetVerbShortCut;

  // Notifier: parametros enum - conferidos nos enums

  CHis.GetModuleHistoryCount := OHis.GetModuleHistoryCount;
  CHis.GetModuleHistoryAuthor := OHis.GetModuleHistoryAuthor;
  CHis.GetModuleHistoryVersionRevisionStr := OHis.GetModuleHistoryVersionRevisionStr;
  CHis.GetModuleHistoryLabelCount := OHis.GetModuleHistoryLabelCount;
  CHis.GetModuleHistoryLabel := OHis.GetModuleHistoryLabel;
  CHis.GetModuleHistoryDate := OHis.GetModuleHistoryDate;
  CHis.GetModuleHistoryComment := OHis.GetModuleHistoryComment;
  CHis.GetModuleHistoryContentSize := OHis.GetModuleHistoryContentSize;
  CHis.GetModuleHistoryContent := OHis.GetModuleHistoryContent;

  COpr.GetProjectID := OOpr.GetProjectID;
  COpr.CheckInModule := OOpr.CheckInModule;
  COpr.CheckOutModule := OOpr.CheckOutModule;
  COpr.GetModule := OOpr.GetModule;
  COpr.CompareModule := OOpr.CompareModule;
  COpr.ShowModuleHistory := OOpr.ShowModuleHistory;
  COpr.ShowProjectManager := OOpr.ShowProjectManager;
  COpr.ShowProjectHistory := OOpr.ShowProjectHistory;
  COpr.SyncProject := OOpr.SyncProject;
  COpr.DiffModule := OOpr.DiffModule;
end;

procedure RunAbiCrossCheck(ACheck: TAbiCheckProc);

  procedure CheckSlots(const AName: string; AOrig, ACopy: Pointer;
    ACount, AOrigSize, ACopySize: Integer);
  var
    Err: string;
  begin
    Err := SlotErrors(AOrig, ACopy, ACount, AOrigSize, ACopySize);
    if Err <> '' then
      Err := ' - ' + Err;
    ACheck(Err = '', Format('%s: %d campos na mesma posicao no original, na copia e na tabela%s',
      [AName, ACount, Err]));
  end;

var
  OSet: JVCSIDEInterfaceCommon.TIDEInterfaceOptions;
  CSet: JVCSExpertABI.TIDEInterfaceOptions;
begin
  MarkIde;
  MarkOthers;
  CheckSlots('TExternalIDEFunctionRec (tabela 3.4)', @OIde, @CIde, 24, SizeOf(OIde), SizeOf(CIde));
  CheckSlots('TExternalVCSFunctionRec', @OVcs, @CVcs, 10, SizeOf(OVcs), SizeOf(CVcs));
  CheckSlots('TExternalNotifierFunctionRec', @ONtf, @CNtf, 2, SizeOf(ONtf), SizeOf(CNtf));
  CheckSlots('TExternalVCSModuleHistoryFunctionRec', @OHis, @CHis, 9, SizeOf(OHis), SizeOf(CHis));
  CheckSlots('TExternalVCSOperationFunctionRec', @OOpr, @COpr, 10, SizeOf(OOpr), SizeOf(COpr));

  ACheck((SizeOf(JVCSIDEInterfaceCommon.TIDEFileNotification) = SizeOf(JVCSExpertABI.TIDEFileNotification)) and
    (SizeOf(JVCSExpertABI.TIDEFileNotification) = 1) and
    (Ord(High(JVCSIDEInterfaceCommon.TIDEFileNotification)) = Ord(High(JVCSExpertABI.TIDEFileNotification))) and
    (Ord(JVCSIDEInterfaceCommon.ifnFileOpening) = Ord(JVCSExpertABI.ifnFileOpening)) and
    (Ord(JVCSIDEInterfaceCommon.ifnFileOpened) = Ord(JVCSExpertABI.ifnFileOpened)) and
    (Ord(JVCSIDEInterfaceCommon.ifnFileClosing) = Ord(JVCSExpertABI.ifnFileClosing)) and
    (Ord(JVCSIDEInterfaceCommon.ifnProjectOpening) = Ord(JVCSExpertABI.ifnProjectOpening)) and
    (Ord(JVCSIDEInterfaceCommon.ifnProjectOpened) = Ord(JVCSExpertABI.ifnProjectOpened)) and
    (Ord(JVCSIDEInterfaceCommon.ifnProjectClosing) = Ord(JVCSExpertABI.ifnProjectClosing)) and
    (Ord(JVCSIDEInterfaceCommon.ifnProjectDesktopLoad) = Ord(JVCSExpertABI.ifnProjectDesktopLoad)),
    'TIDEFileNotification: 1 byte e mesmos ordinais do original');
  ACheck((SizeOf(JVCSIDEInterfaceCommon.TIDEEventNotification) = SizeOf(JVCSExpertABI.TIDEEventNotification)) and
    (Ord(JVCSIDEInterfaceCommon.ienBeforeCompile) = Ord(JVCSExpertABI.ienBeforeCompile)) and
    (Ord(JVCSIDEInterfaceCommon.ienAfterCompile) = Ord(JVCSExpertABI.ienAfterCompile)),
    'TIDEEventNotification: mesmo tamanho e ordinais do original');
  ACheck((SizeOf(JVCSIDEInterfaceCommon.TGetVerbImagesResult) = SizeOf(JVCSExpertABI.TGetVerbImagesResult)) and
    (Ord(High(JVCSIDEInterfaceCommon.TGetVerbImagesResult)) = Ord(High(JVCSExpertABI.TGetVerbImagesResult))) and
    (Ord(JVCSIDEInterfaceCommon.gvirOkay) = Ord(JVCSExpertABI.gvirOkay)) and
    (Ord(JVCSIDEInterfaceCommon.gvirContainsNoImages) = Ord(JVCSExpertABI.gvirContainsNoImages)),
    'TGetVerbImagesResult: mesmo tamanho e ordinais do original');
  OSet := [JVCSIDEInterfaceCommon.ioSupportsShortCuts];
  CSet := [JVCSExpertABI.ioSupportsShortCuts];
  ACheck((SizeOf(OSet) = SizeOf(CSet)) and (SizeOf(CSet) = 1) and
    (PByte(@OSet)^ = PByte(@CSet)^) and (PByte(@CSet)^ = 1),
    'TIDEInterfaceOptions: 1 byte, [ioSupportsShortCuts] = 1 (GetOptions)');
  ACheck((JVCSIDEInterfaceCommon.ivsEnabled = JVCSExpertABI.ivsEnabled) and
    (JVCSIDEInterfaceCommon.ivsChecked = JVCSExpertABI.ivsChecked) and
    (JVCSIDEInterfaceCommon.cJediVCSDLLInitFuncName = JVCSExpertABI.cJediVCSDLLInitFuncName) and
    (JVCSIDEInterfaceCommon.cJediVCSDLLFinalizeFuncName = JVCSExpertABI.cJediVCSDLLFinalizeFuncName) and
    (JVCSIDEInterfaceCommon.cJediVCSDLLInitHistoryFuncName = JVCSExpertABI.cJediVCSDLLInitHistoryFuncName) and
    (JVCSIDEInterfaceCommon.cJediVCSDLLInitOperationFuncName = JVCSExpertABI.cJediVCSDLLInitOperationFuncName),
    'constantes ivs* e nomes dos exports iguais ao original');

  SignatureCheck;
  ACheck(SlotErrors(@OIde, @CIde, 24, SizeOf(OIde), SizeOf(CIde)) = '',
    'assinaturas dos tipos procedurais identicas ao original (verificado na compilacao)');
end;

end.
