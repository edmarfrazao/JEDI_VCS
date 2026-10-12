{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Buffer handling
Creation:     February 17, 1998
Version:      1.47
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
Support:      Use the mailing list midware@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1998-2007 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty. In no event will the author be held liable
              for any damages arising from the use of this software.

              Permission is granted to anyone to use this software and or any
              derived or altered versions for any purpose, excluding commercial
              applications. You can use this software for personal use only.
              You may distribute it freely untouched.
              The following restrictions applies:

              1. The origin of this software must not be misrepresented, you
                 must not claim that you wrote the original software.

              2. If you use this software in a product, an acknowledgment in
                 the product documentation and displayed on screen is required.
                 The text must be: "This product is based on MidWare. Freeware
                 source code is available at http://www.overbyte.be."

              3. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              4. This notice may not be removed or altered from any source
                 distribution and must be added to the product documentation.

Updates:
Mar 11, 1998  V1.01 Corrected bug in Prior method which had old code related
              a no more existant header.
Mar 13, 1998  V1.02 Implemented GetBookmark, FreeBookmark, GotoBookmark and
              Delete methods to make it similar to TTable component.
              Revised logic for Eof, Bof, First, Last, Next, Prior, Delete
              to make it works exactly as a TTable works.
Mar 19, 1998  V1.03 Added a HeaderSize property to reserve space for any
              header. The component does nothing with this header space, it
              is just reserved for whatever purpose is needed by the user.
              This property default to 0 (no header space).
Mar 24, 1998  V1.04 AppendFields did'nt adjust the buffer size correctly
              resulting in a buffer overflow !
Mar 25, 1998  V1.05 Changed RecordToString to double the quotes inside the
              fields (like you do in pascal when a string constant has embedded
              quotes).
Apr 24, 1998  V1.06 Added a third delimiter in front of the buffer to allow
              blob fields. This make the new format incompatible with
              previous one !
              Added functions to handle blobs (from TStream objects).
              Introduced the notion of field type.
              String fields can now contains any data byte except nul bytes but
              including any control characters, even those used for delimiter.
              (Nul bytes are prohibed because they are used as a string
              terminator). You can use the new mwBlob field type to send binary
              data such as images or exe files.
Apr 28, 1998  V1.07 Corected a buffer overflow when a field is writen and if
              the buffer is too small for the new field length.
May 02, 1998  V1.08 Corrected field type extraction in GetStreamField. Thanks
              to Miha Remec <miha.remec@k2.net> for finding this bug.
Jun 01, 1998  V1.09 Removed beta status. Changed "legal stuff" to prohibe
              commercial application without agreement.
Jun 20, 1998  V1.10 Added functions to handle date and time.
Jun 28, 1998  V1.11 Added StringToRecord and StringToRecords function.
Jul 08, 1998  V1.12 Adadpted for Delphi 4
              Added support for TField in WriteRecord, WriteFields and
              AppendFields.
Jul 10, 1998  V1.13 Added FieldSize[] property.
Jul 12, 1998  V1.14 Added SaveToStream, LoadFromStream, SaveToFile,
              LoadFromFile.
Aug 17, 1998  V1.15 Added more explicit "invalid escape sequence" message.
Aug 18, 1998  V1.16 Corrected a bug in StringToRecord which badly handled
              doublequote mechanism.
Aug 19, 1998  V1.17 Added support for short strings in AppendFields
Sep 03, 1998  V1.18 Added Sort function
Sep 08, 1998  V1.19 Added support for vtExtended in AppendFields
Sep 16, 1998  V1.20 Corrected an overflow in AppendRecord
Nov 26, 1998  V1.21 Added ftBlob and ftMemo in AppendFields
Dec 23, 1998  V1.22 Handled vtAnsiString as strings in AppendFields.
Jan 29, 1999  V1.23 Replaced FloatToStr by FloatToStrEx.
Feb 28, 1999  V1.24 Moved ExpandBuffer and WriteDataBuffer to public section.
                    Added AppendBinaryField function.
May 10, 1999  V1.25 Cleared stream in GetStreamField
                    Set FHasAllocated in ExpandBuffer
May 20, 1999  V1.25a Correctly count records in WriteRecord and WriteFields
May 28, 1999  V1.25b Corrected an index in Locate. Thanks to Fred.
Jun 06, 1999  V1.25c Revised LoadFromStream and SaveToStream
Aug 18, 1999  V1.25d Corrected a BCB bug in AppendFields for AnsiString.
Nov 11, 2001  V1.30 Skipped to next decade in version number.
                    Generalized metadata handling. Now all metadata start by
                    ESC marker, an uppercase letter and stop by ESC marker and
                    the corresponding lower case letter. Metadata can be
                    anything. Letter 'M' is used for field layout metadata which
                    if formatted by keyword 'LAYOUT:' followed by suitable
                    string for TMWTable field layout. Later I will implement
                    other related metadata such a constrains by appending a
                    CR/LF pair and new keywords.
                    Added Assign method.
                    Added support for one dimentional variant array in
                    WriteFields.
                    Corrected a BCB bug in AppendFields for AnsiString.
                    Added SetMetaDataLayout method to make easier handling for
                    layout metadata. Layout metadata will be automatically
                    inserted when first field is written.
Dec 29, 2001  V1.31 Handle variant passed by reference (varByRef).
Feb 17, 2002  V1.32 Corrected a bug in AppendFields which caused metadata to
                    be inserted for each record.
Mar 30, 2002  V1.33 Added Delphi 6 Int64 support in AppendField
Jul 15, 2002  V1.34 Adapted for Delphi 7
May 06, 2003  V1.35 Added Delphi 7 int64 support in AppendField
May 31, 2003  V1.36 Frédéric SCHENCKEL <f_schenckel@cab-technologies.fr> added
                    support for null fields
Sep 21, 2003  V1.37 Uwe Schuster <jedivcs@bitcommander.de> added conditional
                    compilation for Delphi Personal Edition. He also added a
                    sort function using a function of object as comparison
                    method. He fixed a record count bug when using Assign.
Aug 26, 2004  V1.38 Added TMWBuffer.FieldInfoByName, FieldNumByName and
                    FieldByName. Those methods work using metadata layout
                    which _may_ be sent by the server.
Aug 28, 2004  V1.39 Use MWDefs.inc.
                    Fixed DateTimeFromMWFormat to handle nul datetime. Thanks
                    to Stefan Frank <stefan_frank@yahoo.com> for his fix.
Dec 14, 2004  V1.40 Added GetFieldByNameAsInteger.
Mar 03, 2005  V1.41 Fixed AppendMetaData to not append an end of field.
May 03, 2005  V1.42 Added MoveFieldData method.
                    Fixed GetUnEscapedLength to skip field type as well.
Jun 11, 2005  V1.43 Fixed GetFields to skip metadata in the middle of data
                    field.
                    Fixed SaveToStream/LoadFromStream to support more than
                    100MB buffer. Thanks to Filippov S V <s.fil@g23.relcom.ru>.
Sep 22, 2005  V1.44 Replaced DELPHI6_UP by COMPILE6_UP when related variants
                    unit which is present as well in BCB6.
Oct 23, 2005  V1.45 Updated for Delphi 2006 and BCB 2006
Mar 16, 2006  V1.46 Added a check for null variant in AppendFields. Thanks to
                    nouvakis <nouvakis@tellas.gr> for finding this bug.
Apr 11, 2006  V1.47 Pitko_Miroslav@teko.sk found a bug is Assign
Aug 08, 2006  V1.48 Save/restore current position in GetRecordCount
                    Fixed GetStreamField to skip metadata


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit RFormat;

interface

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$B-}              { Enable partial boolean evaluation   }
{$T-}              { Untyped pointers                    }
{$X+}              { Enable extended syntax              }
{$i MWDefs.inc}
{$DEFINE MAKECOMPONENT}

// USc 25/08/2003 moved the comma's into the IFDEF's - is a bit easier because
// the old solution (comma after unitname) will always need another unit before
// the semicolon.
uses
    Windows, SysUtils
{$IFDEF MAKECOMPONENT}
    ,Classes
{$ENDIF}
{$IFDEF COMPILER6_UP}
    ,Variants
{$ENDIF}
//USc 25/08/2003 exclude Db in Personal Edition
{$IFNDEF DelphiPersonalEdition}
    ,Db   // TBookmark, TLocateOption, TLocateOptions
{$ENDIF}
    ;

const
    MWBufferVersion    = 148;
    CopyRight : String = ' TMWBuffer (c) 1998-2006 F. Piette V1.48 ';

    { Default field and record separator in output data }
    FieldSeparator  = #18;   { Ascii DC2 }
    RecordSeparator = #20;   { Ascii DC4 }
    EscMarker       = #127;

type
    MWBufferException     = class(Exception);
    PInteger              = ^Integer;
    TPosition             = LongInt;
    {:Describe the type of a field.
      @enum mwString The field is a string field.
      @enum mwBlob   The field is a binary large object such a memo or image. }
    TMWFieldType          = (mwString, mwBlob);
    TMWBuffer             = class;
    TMWBufferSortBuildKey = function (MWBuffer : TMWBuffer) : String;
    // USc 25/08/2003 new typedefinition TMWBufferSortBuildKeyObject
    TMWBufferSortBuildKeyObject = function (MWBuffer : TMWBuffer) : String of object;
    TMWBufferSortList     = class(TList)
    public
        destructor Destroy; override;
        procedure ClearList;
        procedure AddKey(const Key : String; const Offset : LongInt);
    end;
    TMWBufferSortRec = record
        Key    : String;
        Offset : TPosition;
    end;
    PMWBufferSortRec = ^TMWBufferSortRec;
    // USc 25/08/2003 defined the missing types for the Personal Edition
    // these types are no secrets because the can be recovered from the code
    // here the other way were to exclude TMWBuffer.GetBookmark, GotoBookmark,
    // FreeBookmark and Locate
{$IFDEF DelphiPersonalEdition}
    TBookmark = TPosition;
    TLocateOption = (loCaseInsensitive, loPartialKey);
    TLocateOptions = set of TLocateOption;
{$ENDIF}

    {::TMWBuffer is the component responsible for holding data to be transmitted
      between the client and the server (both directions). The buffer has a
      special format allowing to store records made of fields. Each record can
      have a variable number of fields of variable length. There are two types
      of fields: mwString (default) and mwBlob (also called stream fields
      because of the way they are read/written). }
{$IFDEF MAKECOMPONENT}
    TMWBuffer = class(TComponent)
{$ELSE}
    TMWBuffer = class(TObject)
{$ENDIF}
    private
        FDataBuffer      : PChar;            { Buffer start                    }
        FDataBufferSize  : LongInt;          { Total buffer size               }
        FDataBufferCount : LongInt;          { How many characters used        }
        FHeaderSize      : LongInt;          { Reserved space for a header     }
        FFieldCount      : Integer;          { How many fileds in current rec  }
        FRecordCount     : Integer;          { Total number of records         }
        FFldSep          : Char;             { Field separator                 }
        FRecSep          : Char;             { Record separator                }
        FEscSep          : Char;             { Special character marker        }
        FRecordPointer   : PChar;            { Current record pointer          }
        FHitEof          : Boolean;          { We hit the end of file          }
        FHitBof          : Boolean;          { We hit the begin of file        }
        FHasData         : Boolean;          { Is there any data in the buffer }
        FHasAllocated    : Boolean;          { Do we have allocated memory     }
        FAutoExpand      : LongInt;          { How many we can realloc         }
        FMetaDataLayout  : String;           { MetaData 'M'                    }
        FPSessionID      : PChar;            { Used for MetaData 'I'           }
    protected
        procedure RaiseException(const Where: String);
        function  GetFields(nIndex : Integer) : String;
        function  GetFieldType(nIndex : Integer) : TMWFieldType;
        function  GetFieldCount : Integer;
        function  GetRecordCount : Integer;
        function  GetEof : Boolean;
        function  GetBof : Boolean;
        procedure SetFields(nIndex : Integer; newValue : String);
        procedure SetDataBufferSize(newValue : LongInt);
        procedure SetDataBuffer(newValue : PChar);
        procedure SetHasData(newValue : Boolean);
        function  GetFieldPtr(nIndex : Integer) : PChar;
        function  GetFieldSize(nIndex : Integer) : Integer;
        function  GetNextFieldPtr(Cur : PChar) : PChar;
        function  GetEscapedLength(Src : PChar; Len : Integer) : Integer;
        function  GetUnEscapedLength(p : PChar; q : PChar) : Integer;
        procedure MoveEscaped(const Source; var Dest; Count : Integer);
        function  GetMetaData(nIndex : Integer; Delim : Char) : String;
        function  SkipMetaData(P : PChar;            // From where to scan
                               Q : PChar) : PChar;   // Up to that address
        // USc 25/08/2003 new function InternalSort(it's basicly the old public
        // Sort function)
        procedure InternalSort(BuildKey       : TMWBufferSortBuildKey;
                               BuildKeyObject : TMWBufferSortBuildKeyObject;
                               Ascending      : Boolean);
    public
{$IFDEF MAKECOMPONENT}
        constructor Create(AOwner : TComponent); override;
{$ELSE}
        constructor Create(AOwner : TObject); virtual;
{$ENDIF}
        destructor  Destroy; override;
        {:Position the pointer to current position on the first record. }
        procedure   First;
        {:Position the pointer to current position on the next record. }
        procedure   Next;
        {:Position the pointer to current position on the previous record. }
        procedure   Prior;
        {:Position the pointer to current position on the last record. }
        procedure   Last;
        {:Return the internal position for the current record. The returned
          value can be used with the Seek method. }
        function    Tell : TPosition;
        {:Position the current record to some arbitrary position. The argument
          must be a value returned by the Tell method. }
        procedure   Seek(nPos : TPosition);
        {:Get a bookmark on current record. Use the value with GotoBookmark.
          When no more used, call FreeBookmark to release used resources. }
        function    GetBookmark: TBookmark; virtual;
        {:Return the current position to the bookmark setup by GetBookmark. }
        procedure   GotoBookmark(Bookmark: TBookmark);
        {:Free resources used for bookmark keeping. }
        procedure   FreeBookmark(Bookmark: TBookmark); virtual;
        {:Transform the current record to a convenient string representation. }
        function    RecordToString : String;
        {:Reverse operation for RecordToString. Append a new record.
          Start parsing the string from a given index. Update this position.
          Return the number of fields copied.
          Accept fields delimited by single or double quotes.
          See also StringToRecords for several records. }
        function StringToRecord(Src       : String;
                                var Start : Integer) : integer;
        {:Same as StringToRecord, but applied for several records.
          Use semicolon as record delimiter. }
        procedure StringToRecords(Src : String);
        {:Clear the buffer content and prepare for wrting new data. }
        procedure   Rewrite;
        {:Write a complete record with field values given by the argument. }
        procedure   WriteRecord(Args : array of const);
        {:Write a new record or append to current record some fields passed in
          argument in the array of const. }
        procedure   WriteFields(NewRec : Boolean; Args : array of const);
        {:Append fields to the current record. }
        procedure   AppendFields(Args : array of const);
        {:Append a single record from another TMWBuffer. }
        procedure   AppendRecord(From : TMWBuffer);
        {:Write a single stream (blob) field. This function can be used to place
          a complete file (for example a BMP file) into a single field. }
        procedure   WriteStreamField(NewRec : Boolean; FldType : TMWFieldType;
                                     Data : TStream);
        {:Same as WriteStreamField, but append the field to the current record.}
        procedure   AppendStreamField(Data : TStream; FldType : TMWFieldType);
        procedure   AppendBinaryField(Data    : Pointer;
                                      Len     : Integer;
                                      FldType : TMWFieldType);
        {:Get a stream (blob) field value from the buffer. Same as the Fields[]
          property but works with blob fields. }
        function    GetStreamField(FieldNb : Integer;
                                   Data : TStream;
                                   var FieldType : TMWFieldType) : integer;
        function    MoveFieldData(FieldNb  : Integer;
                                  Data     : Pointer;
                                  DataSize : Integer;
                                  var FieldType : TMWFieldType) : integer;
        {:Delete the current record. }
        procedure   Delete;
        {:Locate a record by sequential search. }
        function    Locate(const KeyFields: String;
                           const KeyValues: Variant;
                           Options: TLocateOptions): Boolean;
        {:Terminate the current record (can makes an empty record) }
        procedure   WriteRecordMarker;
        {:Write the content buffer to a stream at the current position. }
        procedure   SaveToStream(Stream : TStream);
        {:Load data from a stream at the current position. Several buffer can
          be written and reread sequentially, for example to save in a single
          stream the content of several TMWBuffer. }
        procedure   LoadFromStream(Stream : TStream);
        {:Write data buffer to a file for later read using LoadFromFile. }
        procedure   SaveToFile(FileName : String);
        {:Load data from a file. }
        procedure   LoadFromFile(FileName : String);
        {:Sort }
        procedure   Sort(BuildKey : TMWBufferSortBuildKey; Ascending : Boolean);
        // USc 25/08/2003 new function SortObject
        {:Sort using a function of object }
        procedure   SortObject(BuildKeyObject : TMWBufferSortBuildKeyObject;
                               Ascending : Boolean);
        {:Check if a field number is valid }
        function    IsValidFields(nIndex : Integer) : Boolean;
        function    ExpandBuffer(pSize : PInteger; Requested : LongInt) : Boolean;
        procedure   WriteDataBuffer(Src : PChar; Len : LongInt);
        {:Inject metadata into the buffer. Normally it is done before writing
          any data field. But it is allowed to insert metadata anywhere in the
          buffer provided the user know what to do with it. This is for example
          used when a result set is made out of several DB result sets. Each
          one having his own metadata. }
        procedure   AppendMetaData(Delim : Char; Src : PChar; Len : LongInt);
        {:SetMetaDataLayout initialize MetaData for later use by method
          GetFieldByNameAsString or to be inserted into the buffer before any
          data. Normally you call SetMetaDataLayout at server side to inject
          metadata from the DB to the buffer, and at client side to be able
          to access fields by name. }
        procedure   SetMetaDataLayout(const Layout : String);
        {:Extract field informations from metadata layout. Returns field
          number as result. Returns -1 if field not found. Also returns
          field type and field size.}
        function    FieldInfoByName(const MetaData  : String;
                                    const FieldName : String;
                                    out   FieldType : String;
                                    out   FieldSize : Integer) : Integer;
        {:Extract field informations from metadata layout. Returns field
          number as result. Returns -1 if field not found. }
        function    FieldNumByName(const MetaData  : String;
                                   const FieldName : String) : Integer;
        {:Use metadata layout to get a field by name as a string value }
        function    GetFieldByNameAsString(const FieldName : String) : String;
        {:Use metadata layout to get a field by name as an integer value }
        function    GetFieldByNameAsInteger(const FieldName : String) : Integer;
        {:Get a field by number. If number is not a field number, return an
          empty string. }
        function    GetFieldByNumAsString(nIndex : Integer) : String;
        {:Get a field by number. If number is not a field number, return an
          nul value. If field content is not a number, return a nul value. }
        function    GetFieldByNumAsInteger(nIndex : Integer) : Integer;
        {:Get a field by number. If number is not a field number, return an
          nul date. }
        function    GetFieldByNumAsDateTime(nIndex : Integer) : TDateTime;
        procedure   Assign(Source: TPersistent); override;
        procedure   SetPSessionID(const Value : PChar);
        property PSessionID : PChar                read   FPSessionID
                                                   write  SetPSessionID;
        {:The indexed Fields[] property gives access to the current record's
          fields. Works with string type field only. For blobs, use
          GetStreamField method. }
        property Fields[nIndex : Integer] : String  read  GetFields
                                                    write SetFields;
        {:The indexed property FieldByNameAsString[] gives access to the current
          record's fields. Works only after SetMetaDataLayout has been called
          to define the fields names. Value passed to SetMetaDataLayout can
          be obtained by using MetaData[] property. }
        property FieldByNameAsString[const FieldName : String] : String
                                                   read  GetFieldByNameAsString;
        property FieldByNameAsInteger[const FieldName : String] : Integer
                                                   read  GetFieldByNameAsInteger;
        {:The indexed MetaData property gives access to the current record's
          meta data (application defined). Normally a server send MetaData in
          front of all fields, with an 'M' delimiter. To get this MetaData back,
          use MetData[0, 'M']. If you then call SetMetaDataLayout with thise
          value, you'll be able to use FieldByNameAsString[]. }
        property MetaData[nIndex : Integer; Delim : Char] : String
                                                    read  GetMetaData;
        {:Returns the field type. This is not related to MetaData but a layer
          below. Use FieldInfoByName() to get field type extracted from
          metadata. }
        property FieldType[nIndex : Integer] : TMWFieldType
                                                    read  GetFieldType;
        {:Return field size in bytes. This is not related to MetaData but a
          layer below. Use FieldInfoByName() to get field type extracted from
          metadata. }
        property FieldSize[nIndex : Integer] : Integer
                                                    read  GetFieldSize;
        {:Returns the number of fields in the current record. }
        property FieldCount : Integer               read  GetFieldCount;
        {:Returns the number of records by sequentially counting them. The
          value is cached because counting if CPU expensive. }
        property RecordCount : Integer              read  GetRecordCount;
        {:Returns the End Of File status. Usefull with First, Next, Prior
          and Last methods. }
        property Eof : Boolean                      read  GetEof;
        {:Returns the Begin Of File status. Usefull with First, Next, Prior
          and Last methods. }
        property Bof : Boolean                      read  GetBof;
        {:Indicates if some data is in the buffer. Usefull when using the
          back door and copying data directly in the underlaying buffer. }
        property HasData : Boolean                  read  FHasData
                                                    write SetHasData;
        {:Gives access to the underlaying data buffer. Writing this value
          allows to allocate a buffer for data storage. If the buffer is forced
          then the component cannot expand it as needed to write fields. }
        property DataBuffer : PChar                 read  FDataBuffer
                                                    write SetDataBuffer;
        {:The size in bytes of the data present in the buffer. }
        property DataBufferCount : LongInt          read  FDataBufferCount
                                                    write FDataBufferCount;
        {:The EscSep property set or get the character used to escape data
          in the buffer.}
        property EscSep          : Char             read  FEscSep
                                                    write FEscSep;
    published
        {:The size in bytes of the current buffer. Assigning a value to this
          property will allocate or reallocate the buffer. }
        property DataBufferSize : LongInt           read  FDataBufferSize
                                                    write SetDataBufferSize;
        {:Size in byte of the header in the data buffer. Default to 0. }
        property HeaderSize : LongInt               read  FHeaderSize
                                                    write FHeaderSize;
        {:This property tells the component if the data buffer can be expanded
          if it is too short for the data that needs to be written to it. }
        property AutoExpand : LongInt               read  FAutoExpand
                                                    write FAutoExpand;
    end;

{ MWFormat for DateTime is the same as the TimeStamp record structure.      }
{ It is expressed as two ascii formatted integers separated by a semicolon. }
{ TimeStamp handling definition are in SysUtils.                            }
function  DateTimeFromMWFormat(Src : String) : TDateTime;
function  DateTimeToMWFormat(DateTime : TDateTime) : String;
function  TimeStampFromMWFormat(Src : String) : TTimeStamp;
function  TimeStampToMWFormat(TimeStamp : TTimeStamp) : String;
function  FloatToStrEx(Value : Extended) : String;

{$IFDEF MAKECOMPONENT}
procedure Register;
{$ENDIF}

implementation

const
    CR = #13;
    LF = #10;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF MAKECOMPONENT}
procedure Register;
begin
    RegisterComponents('FPiette', [TMWBuffer]);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF MAKECOMPONENT}
constructor TMWBuffer.Create(AOwner : TComponent);
begin
    inherited Create(AOwner);
{$ELSE}
constructor TMWBuffer.Create(AOwner : TObject);
begin
    inherited Create;
{$ENDIF}
    FFldSep      := FieldSeparator;
    FRecSep      := RecordSeparator;
    FEscSep      := EscMarker;
    FFieldCount  := -1;
    FRecordCount := -1;
    FAutoExpand  := 256;
    FHeaderSize  := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TMWBuffer.Destroy;
begin
    if FHasAllocated and (FDataBuffer <> nil) then begin
        try
            FreeMem(FDataBuffer);
            FDataBuffer   := nil;
            FHasAllocated := FALSE;
        except
        end;
    end;

    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SetDataBufferSize(newValue : LongInt);
begin
    if newValue < 0 then
        RaiseException('Invalid buffer size');

    FDataBufferSize := newValue;
    FFieldCount     := -1;
    FRecordCount    := -1;
    FRecordPointer  := nil;
    FHasData        := FALSE;

    if FDataBuffer = nil then begin
        FHasAllocated := TRUE;
        GetMem(FDataBuffer, FDataBufferSize);
        Rewrite;
    end
    else if FHasAllocated then begin
        ReallocMem(FDataBuffer, FDataBufferSize);
        Rewrite;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SetDataBuffer(newValue : PChar);
begin
    if FHasAllocated then begin
        FHasAllocated := FALSE;
        FreeMem(FDataBuffer);
        FDataBuffer   := nil;
    end;
    FDataBuffer := newValue;
    if newValue = nil then         // FP 10/04/2006
        FDataBufferCount := 0;     // FP 10/04/2006
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.RaiseException(const Where: String);
begin
    raise MWBufferException.Create(Where);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Get the pointer on the given field in the current record.                 }
{ If empty field, then the returned value point to the field separator,     }
{ if non existant field, then returned value point to the record separator. }
function TMWBuffer.GetFieldPtr(nIndex : Integer) : PChar;
var
    p      : PChar;                { Data pointer        }
    q      : PChar;                { End of data pointer }
    nCount : Integer;
begin
    if FRecordPointer = nil then begin     { 24/12/98 }
        Result := nil;
        Exit;
    end;

    { 15/02/99 There was a missing call to First, do it automatically }
    if FRecordPointer < @FDataBuffer[FHeaderSize + 3] then
        First;

    p := FRecordPointer;                   { Start of current record }
    q := @FDataBuffer[FDataBufferCount];   { End of all records      }

    { Scan data to find requested field }
    for nCount := 0 to nIndex - 1 do begin
        { Stop at next separator or end of data }
        while (p < q) and (p^ <> FFldSep) and (p^ <> FRecSep) do
            Inc(p);
        { If end of record, can't go further }
        if (p >= q) or (p^ = FRecSep) then
            Break;
        { Skip field separator and proceed with next field }
        Inc(p);
    end;
    Result := p;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Given a field pointer, return the pointer to the next field               }
{ If last field is passed, then the pointer point to the record separator.  }
function TMWBuffer.GetNextFieldPtr(Cur : PChar) : PChar;
var
    q : PChar;
begin
    Result := Cur;
    q      := @FDataBuffer[FDataBufferCount];   { End of all records }
    { Stop at next separator or end of data }
    while (Result < q) and (Result^ <> FFldSep) and (Result^ <> FRecSep) do
        Inc(Result);
    { Skip field delimiter to point to start of next field }
    if (Result < q) and (Result^ = FFldSep) then
        Inc(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldType(nIndex : Integer) : TMWFieldType;
var
    p, q : PChar;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if (nIndex < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    { Find requested field pointer }
    p := GetFieldPtr(nIndex);
    { End of all records }
    q := @FDataBuffer[FDataBufferCount];

    { Default to string type }
    Result := mwString;

    { Skip all metadata and search for field type info }
    while (P[0] = FEscSep) and ((q - p) >= 2) do begin
        if p[1] = 'T' then begin
            { Field type information }
            if P[2] <> 'S' then
                Result := TMWFieldType(Ord(P[2]) - Ord('0'))
    else
        Result := mwString;
            break;
        end
        else if P[1] in ['C', 'F', 'L', 'N', 'R'] then
            { Escaped control characters }
            break
        else if (P[1] >= 'A') and (P[1] <= 'Z') then
        { Meta data in embedded between ESC-Uppercase Letter and }
        { ESC-Lowercase Letter                                   }
            P := SkipMetadata(P, Q)
        else
            { Now in data, so by default it is a string field }
            break;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.SkipMetaData(
    P : PChar;            // From where to scan (point to ESC marker)
    Q : PChar) : PChar;   // Up to that address
var
    C : Char;
begin
    C := Chr(Ord(P[1]) xor $20);
    Result := P + 2;     { Skip past delimiter }
    while Result < q do begin
        if Result^ = FEscSep then begin
            Inc(Result);
            if Result^ = c then begin
                Inc(Result);
                break;
            end;
        end;
        Inc(Result);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldByNumAsString(nIndex : Integer) : String;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if nIndex < 0 then
        Result := ''
    else
        Result := GetFields(nIndex);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldByNumAsInteger(nIndex : Integer) : Integer;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if nIndex < 0 then
        Result := 0
    else
        Result := StrToIntDef(GetFields(nIndex), 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldByNumAsDateTime(nIndex : Integer) : TDateTime;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if nIndex < 0 then
        Result := 0
    else
        Result := DateTimeFromMWFormat(GetFields(nIndex));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFields(nIndex : Integer) : String;
var
    p      : PChar;                { Data pointer        }
    q      : PChar;                { End of data pointer }
    c      : Char;
    I      : Integer;
    r      : PChar;
    Len    : Integer;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if (nIndex < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    { Check if missing call to method First }
    if FRecordPointer = nil then
        First;

    { Find requested field pointer }
    p := GetFieldPtr(nIndex);

    { End of all records }
    q := @FDataBuffer[FDataBufferCount];

    { Skip all metadata and field type. Also check field type }
    while (P[0] = FEscSep) and ((q - p) >= 2) do begin
        if p[1] = 'T' then begin
            { Field type information }
            if ((q - p) >= 3) and (p[2] <> 'S') then begin
                { We have a typed field and the field is not a string field }
                { this is an error since this function returns only strings }
                { Sould I raise an error ?                                  }
                Result := '** BLOB **';
                Exit;
            end;
            Inc(P, 3);     { Skip field type info }
        end
        else if P[1] in ['C', 'F', 'L', 'N', 'R'] then
            { Escaped control characters are part of data }
            break
        else if (P[1] >= 'A') and (P[1] <= 'Z') then
        { Meta data in embedded between ESC-Uppercase Letter and }
        { ESC-Lowercase Letter                                   }
            P := SkipMetadata(P, Q)
        else
            break;         { Seems to be part of data }
    end;

    // 24/12/98 Optimize for speed
    c      := #0;  // makes compiler happy about initialization
    r      := nil; // makes compiler happy about initialization
    Result := '';  // Empty the result string
    I      := 0;   // Index in Result string
    Len    := 0;   // Result string current length

    // Copy data until next separator or end of data
    while (p < q) and (p^ <> FFldSep) and (p^ <> FRecSep) do begin
        if p^ <> FEscSep then
            c := p^
        else begin
            Inc(p);
            if (p >= q) then begin
                { This condition should never occurs. There is an error }
                { int the format.                                       }
                RaiseException('Escape sequence truncated');
                break;
            end;
            if p^ = FEscSep then
                c := FEscSep
            else begin
                case p^ of
                'F': c := FFldSep;
                'R': c := FRecSep;
                'C': c := CR;
                'L': c := LF;
                'N': c := #0;
                else
                    if (P^ >= 'A') and (P^ <= 'Z') then begin  { 06/06/2005 }
                        { Meta data in embedded between ESC-Uppercase Letter and }
                        { ESC-Lowercase Letter                                   }
                        P := SkipMetadata(P - 1, Q);
                        continue;
                    end
                    else begin
                    c := #0; { makes compiler happy about initialization }
                    RaiseException('GetFields: Invalid escape sequence ''$' +
                                   IntToStr(Ord(p^)) + '''');
                    end;
                end;
            end;
        end;
        // 24/12/98
        // This strange code is to avoid long string computation as much as
        // possible because it is very slow because of memory allocation.
        // Here we do memory allocation only every 256 characters. We will
        // adjust string length at the end.
        Inc(I);
        if I > Len then begin
{$IFDEF NEVER}
            Len := I + 256;
{$ENDIF}
            if Len <= 0 then
                Len := 512
            else
                Len := Len + Len;
            SetLength(Result, Len);
            r := @Result[I];
        end;
        r^ := c;
        Inc(r);

        // Go to next char to be processed
        Inc(p);
    end;
    // Adjust the length to the exact computed value
    if I <> Len then
        SetLength(Result, I);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Metadata is assumed to be before data                                     }
function  TMWBuffer.GetMetaData(nIndex : Integer; Delim : Char) : String;
var
    p        : PChar;                { Data pointer        }
    q        : PChar;                { End of data pointer }
    DelimEnd : Char;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if (nIndex < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    { Check if missing call to method First }
    if FRecordPointer = nil then
        First;

    { Find requested field pointer }
    P := GetFieldPtr(nIndex);

    { End of all records }
    Q := @FDataBuffer[FDataBufferCount];

    { Default to empty metadata }
    Result   := '';

    { Compute ending delimiter }
    DelimEnd := Chr(Ord(Delim) xor $20);

    { Parse all metadata to find requested one and skip field type }
    while (P[0] = FEscSep) and ((Q - P) >= 2) do begin
        if P[1] = 'T' then
            { Field type information }
            Inc(P, 3)     { Skip field type info }
        else if P[1] in ['C', 'F', 'L', 'N', 'R'] then
            { Escaped control characters are part of data }
            break
        else if P[1] = Delim then begin
            { This is metadata we are looking for }
            P := P + 2;     { Skip delimiter }
            while P < Q do begin
                if P^ = FEscSep then begin
                    Inc(P);
                    if P^ = FEscSep then
                        Result := Result + P^
                    else if P^ = DelimEnd then
                        break
                    else
                        Result := Result + FEscSep + P^;
                end
                else
                    Result := Result + p^;
                Inc(p);
            end;
        end
        else if (P[1] >= 'A') and (P[1] <= 'Z') then
            { Other type of metadata, just skip it }
            P := SkipMetadata(P, Q)
        else
            break;         { Seems to be part of data }
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.MoveEscaped(const Source; var Dest; Count : Integer);
type
    TBytes = array[0..MaxInt - 1] of Char;
var
    I, J : Integer;
    Ch   : Char;
begin
    J := 0;
    for I := 0 to Count - 1 do begin
        Ch := TBytes(Source)[I];
        if Ch = FEscSep then begin
            TBytes(Dest)[J] := FEscSep;
            Inc(J);
            TBytes(Dest)[J] := FEscSep;
        end
        else if Ch = FFldSep then begin
            TBytes(Dest)[J] := FEscSep;
            Inc(J);
            TBytes(Dest)[J] := 'F';
        end
        else if Ch = FRecSep then begin
            TBytes(Dest)[J] := FEscSep;
            Inc(J);
            TBytes(Dest)[J] := 'R';
        end
        else if Ch = CR then begin
            TBytes(Dest)[J] := FEscSep;
            Inc(J);
            TBytes(Dest)[J] := 'C';
        end
        else if Ch = LF then  begin
            TBytes(Dest)[J] := FEscSep;
            Inc(J);
            TBytes(Dest)[J] := 'L';
        end
        else if Ch = #0 then begin
            TBytes(Dest)[J] := FEscSep;
            Inc(J);
            TBytes(Dest)[J] := 'N';
        end
        else
            TBytes(Dest)[J] := Ch;
        Inc(J);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Compute the required size for a buffer to hold some data once it has been }
{ "escaped" for special characters.                                         }
function TMWBuffer.GetEscapedLength(
    Src : PChar;             { Start of data }
    Len : integer)           { End of data   }
    : Integer;
begin
    Result := 0;
    if Src = nil then
        Exit;

    while Len > 0 do begin
        if (Src^ = FEscSep) or
           (Src^ = FFldSep) or
           (Src^ = FRecSep) or
           (Src^ = CR) or
           (Src^ = LF) or
           (Src^ = #0) then
           { Each special character count for two }
           Inc(Result);
        Inc(Result);
        Dec(Len);
        Inc(Src);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Compute the required size for a buffer to hold some data once it has been }
{ "unescaped" for special characters.                                       }
function TMWBuffer.GetUnEscapedLength(
    p : PChar;             { Start of data }
    q : PChar)             { End of data   }
    : Integer;
begin
    Result := 0;
    { Scan data until next separator or end of data }
    while (p < q) and (p^ <> FFldSep) and (p^ <> FRecSep) do begin
        if p^ <> FEscSep then
            Inc(Result)
        else begin
            Inc(p);
            if (p >= q) then
                { This condition should never occurs. There is an error }
                { int the format.                                       }
                RaiseException('GetUnEscapedLength: Escape sequence truncated');
            { The first byte of a field can be the EscMarker followed by a 'T' and  }
            { by another character giving some file type information ('S' = String) }
            if ((q - p) >= 2) and (p[0] = 'T') then begin
                 Inc(p, 2);
                 continue;
            end
            else if (p^ <> FEscSep) and (not (p^ in ['C', 'F', 'L', 'N', 'R'])) then
                RaiseException('GetUnEscapedLength: Invalid escape sequence ''$' +
                               IntToStr(Ord(p^)) + '''');
            Inc(Result);
        end;
        Inc(p);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Return the field size, in bytes                                           }
function TMWBuffer.GetFieldSize(nIndex : Integer) : Integer;
var
    p      : PChar;                { Data pointer        }
    q      : PChar;                { End of data pointer }
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if (nIndex < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    { Find requested field pointer }
    p := GetFieldPtr(nIndex);

    { End of all records }
    q := @FDataBuffer[FDataBufferCount];

    { The first byte of a field can be the EscMarker followed by a 'T' and  }
    { by another character giving some file type information ('S' = String) }
//    if (p[0] = FEscSep) and ((q - p) >= 3) and
//       (p[1] = 'T') and (p[2] <> 'S') then begin
//         { We have a typed field and the field is not a string field }
//         { this is an error since this function returns only strings }
//         { Sould I raise an error ?                                  }
//         Result := '** BLOB **';
//         Exit;
//    end;
    Result := GetUnEscapedLength(p, q);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.MoveFieldData(
    FieldNb  : Integer;
    Data     : Pointer;
    DataSize : Integer;
    var FieldType : TMWFieldType) : integer;
var
    p      : PChar;                { Data pointer        }
    q      : PChar;                { End of data pointer }
    c      : Char;
    Dst    : PChar;
    Cnt    : LongInt;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if (FieldNb < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    { Find requested field pointer }
    p := GetFieldPtr(FieldNb);

    { End of all records }
    q := @FDataBuffer[FDataBufferCount];

    { Get the field type }
    if (p[0] = FEscSep) and ((q - p) >= 3) and
       (p[1] = 'T') and (p[2] <> 'S') then begin
        FieldType := TMWFieldType(Ord(p[2]) - Ord('0'));
        p := p + 3;
    end
    else
        FieldType := mwString;

    { Copy data until next separator or end of data }
    Cnt := 0;
    Dst := PChar(Data);
    while (Cnt < DataSize) and
          (p < q) and (p^ <> FFldSep) and (p^ <> FRecSep) do begin
        if p^ <> FEscSep then
            Dst^ := p^
        else begin
            Inc(p);
            if (p >= q) then begin
                { This condition should never occurs. There is an error }
                { int the format.                                       }
                RaiseException('Escape sequence truncated');
                break;
            end;
            if p^ = FEscSep then
                c := FEscSep
            else begin
                case p^ of
                'F': c := FFldSep;
                'R': c := FRecSep;
                'C': c := CR;
                'L': c := LF;
                'N': c := #0;
                else
                    c := #0; { makes compiler happy about initialization }
                    RaiseException('MoveFieldData: Invalid escape sequence ''$' +
                                   IntToStr(Ord(p^)) + '');
                end;
            end;
            Dst^ := c;
        end;
        Inc(p);
        Inc(Dst);
        Inc(Cnt);
    end;
    Result := Cnt;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetStreamField(
    FieldNb       : Integer;
    Data          : TStream;
    var FieldType : TMWFieldType) : integer;
var
    p      : PChar;                { Data pointer        }
    q      : PChar;                { End of data pointer }
    c      : Char;
    Dst    : PChar;
    Buf    : array [0..1023] of char;
    Cnt    : LongInt;
begin
    if not FHasData then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('No data available');
    end;

    if (FieldNb < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    Result := 0;

    { Find requested field pointer }
    p := GetFieldPtr(FieldNb);

    { End of all records }
    q := @FDataBuffer[FDataBufferCount];

// 08/08/06 begin
//    { Get the field type }
//    if (p[0] = FEscSep) and ((q - p) >= 3) and
//       (p[1] = 'T') and (p[2] <> 'S') then begin
//        FieldType := TMWFieldType(Ord(p[2]) - Ord('0'));
//        p := p + 3;
//    end
//    else
//        FieldType := mwString;
    { Skip all metadata and field type. Also check field type }
    FieldType := mwString;
    while (P[0] = FEscSep) and ((q - p) >= 2) do begin
        if p[1] = 'T' then begin
            { Field type information }
            if ((q - p) >= 3) and (p[2] <> 'S') then
        FieldType := TMWFieldType(Ord(p[2]) - Ord('0'));
            Inc(P, 3);     { Skip field type info }
    end
        else if P[1] in ['C', 'F', 'L', 'N', 'R'] then
            { Escaped control characters are part of data }
            break
        else if (P[1] >= 'A') and (P[1] <= 'Z') then
        { Meta data in embedded between ESC-Uppercase Letter and }
        { ESC-Lowercase Letter                                   }
            P := SkipMetadata(P, Q)
    else
            break;         { Seems to be part of data }
    end;
// 08/08/06 end

    { Clear stream content }
    Data.Size := 0; { FP 10/05/99 }

    // USc 25/09/2005 Preset stream size when large data
    if FDataBufferCount > (128 * 1024) then begin
        Data.Size     := GetUnEscapedLength(p, q);
        Data.Position := 0;
    end;

    { Copy data until next separator or end of data }
    Cnt := 0;
    Dst := @Buf;
    while (p < q) and (p^ <> FFldSep) and (p^ <> FRecSep) do begin
        if p^ <> FEscSep then
            Dst^ := p^
        else begin
            Inc(p);
            if (p >= q) then begin
                { This condition should never occurs. There is an error }
                { int the format.                                       }
                RaiseException('Escape sequence truncated');
                break;
            end;
            if p^ = FEscSep then
                c := FEscSep
            else begin
                case p^ of
                'F': c := FFldSep;
                'R': c := FRecSep;
                'C': c := CR;
                'L': c := LF;
                'N': c := #0;
                else
                    c := #0; { makes compiler happy about initialization }
                    RaiseException('GetStreamField: Invalid escape sequence ''$' +
                                   IntToStr(Ord(p^)) + '');
                end;
            end;
            Dst^ := c;
        end;
        Inc(p);
        Inc(Dst);
        Inc(Cnt);
        if Cnt >= SizeOf(Buf) then begin
            Data.WriteBuffer(Buf, Cnt);
            Result := Result + Cnt;
            Cnt    := 0;
            Dst    := @Buf;
        end;
    end;
    if Cnt >0 then begin
        Data.WriteBuffer(Buf, Cnt);
        Result := Result + Cnt;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Check if a field exists in the current record  24/12/98                   }
function TMWBuffer.IsValidFields(nIndex : Integer) : Boolean;
var
    Start : PChar;
begin
    Result := FALSE;
    if nIndex < 0 then
        Exit;
    Start  := GetFieldPtr(nIndex);
    if Start = nil then
        Exit;
    if Start^ = FRecSep then
        Exit;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SetFields(nIndex : Integer; newValue : String);
var
    FldLen  : Integer;
    Start   : PChar;    { Requested field start }
    Stop    : PChar;    { Next field start      }
    SupLen  : Integer;  { Supplemental length   }
    aSize   : Integer;
    RqBytes : Integer;
begin
    if (nIndex < 0) then begin
        SetLastError(ERROR_INVALID_PARAMETER);
        RaiseException('Invalid field index');
    end;

    Start  := GetFieldPtr(nIndex);
    if Start^ = FRecSep then
        RaiseException('Invalid field index (non existant field)');
    Stop   := GetNextFieldPtr(Start);
    FldLen := Stop - Start - 1;
    SupLen := GetEscapedLength(PChar(newValue), Length(newValue)) - FldLen;
    if SupLen > 0 then begin
        { new value is longer than existing one }
        if (FDataBufferCount + SupLen) >= FDataBufferSize then begin
            { We need to expand our buffer, expand by a multiple of 512 bytes }
            RqBytes := ((SupLen div 512) + 1) * 512;
            if not ExpandBuffer(@aSize, RqBytes) then
                RaiseException('Can''t expand buffer to write data');
            { Buffer may have moved to a new address in the reallocation }
            Start := GetFieldPtr(nIndex);
        end;
        Move(Start[0], Start[SupLen], FDataBufferCount - (Start - FDataBuffer) + 1);
        FDataBufferCount := FDataBufferCount + SupLen;
    end
    else if SupLen < 0 then begin
        { New value is shorter than existing one, SupLen is NEGATIVE }
        Move(Start[-SupLen], Start[0], FDataBufferCount - (Start - FDataBuffer) + SupLen + 1);
        FDataBufferCount := FDataBufferCount + SupLen;
    end;

    { Move the new value above the old one }
    if Length(newValue) > 0 then
        MoveEscaped(newValue[1], Start^, Length(newValue));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldCount : Integer;
var
    p      : PChar;                { Data pointer        }
    q      : PChar;                { End of data pointer }
begin
    if not FHasData then begin
        Result := 0;
        Exit;
    end;

    if FFieldCount >= 0 then begin
        Result := FFieldCount;
        Exit;
    end;

    FFieldCount := 0;

    { Makes data pointers points to start and end of data }
    p := FRecordPointer;
    q := @FDataBuffer[FDataBufferCount];

    { No data at all }
    if p >= q then begin
        Result := 0;
        Exit;
    end;

    { Scan data to count fields }
    while p < q do begin
        { Count the field }
        Inc(FFieldCount);
        { Stop at next separator or end of data }
        while (p < q) and (p^ <> FFldSep) and (p^ <> FRecSep) do
            Inc(p);
        { Skip field separator }
        Inc(p);
        { If end of record, can't go further }
        if (p >= q) or (p^ = FRecSep) then
            Break;
    end;

    Result := FFieldCount;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetRecordCount : Integer;
var
    CurPos : TPosition;
begin
    if not FHasData then begin
        Result := 0;
        Exit;
    end;

    if FRecordCount >= 0 then begin
        Result := FRecordCount;
        Exit;
    end;

    // Save current position and restore it after
    CurPos := Tell;
    try
    FRecordCount := 0;
    First;
    while not GetEof do begin
        Inc(FRecordCount);
        Next;
    end;
    finally
        Seek(CurPos);
    end;

    Result := FRecordCount;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SetHasData(newValue : Boolean);
begin
    FHasData := newValue;
    if FHasData then begin
        { Retrieve separators wich are always first 3 characters after }
        { the reserved header space                                    }
        FEscSep := FDataBuffer[FHeaderSize + 0];
        FFldSep := FDataBuffer[FHeaderSize + 1];
        FRecSep := FDataBuffer[FHeaderSize + 2];

        { Set pointer to first record }
        First;
    end
    else begin
        FFieldCount    := -1;
        FRecordCount   := -1;
        FRecordPointer := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetBof : Boolean;
begin
    Result := (FRecordPointer = nil) or
//              (FRecordPointer^ = FRecSep) or   { Empty }
              (FHitBof); { or
              (FRecordPointer <= @FDataBuffer[3]);}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetEof : Boolean;
begin
    Result := (FRecordPointer = nil) or
              (FRecordPointer^ = FRecSep) or  { Empty }
              (FHitEof) {or
              (FRecordPointer >= @FDataBuffer[FDataBufferCount - 1])};
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.First;
begin
    if not FHasData then
        Exit;

    FFieldCount    := -1;
    FRecordPointer := @FDataBuffer[FHeaderSize + 3];
    FHitBof        := TRUE;
    FHitEof        := (FDataBufferCount <= (FHeaderSize + 5));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Next;
var
    q          : PChar;
    oldPointer : PChar;
begin
    if (not FHasData) or (FRecordPointer = nil) then
        Exit;

    FFieldCount := -1;
    oldPointer  := FRecordPointer;
    FHitEof     := FALSE;
    FHitBof     := FALSE;

    q := @FDataBuffer[FDataBufferCount];   { End of all records }

    { Search next record separator }
    while (FRecordPointer < q) and (FRecordPointer^ <> FRecSep) do
        Inc(FRecordPointer);

    if (FRecordPointer < q) and (FRecordPointer^ = FRecSep) then begin
        { We hit the record separator }
        Inc(FRecordPointer);
        if (FRecordPointer < q) and (FRecordPointer^ = FRecSep) then begin
            { We hit the end of all records }
            FHitEof        := TRUE;
            FRecordPointer := oldPointer;
            if FDataBufferCount <= (FHeaderSize + 5) then
                FHitBof    := TRUE; { No data at all }
        end;
    end
    else begin
        { We hit end of data and there is not record separator }
        { This is a format error !                             }
        FHitEof        := TRUE;
        FRecordPointer := oldPointer;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Prior;
begin
    if (not FHasData) or (FRecordPointer = nil) then
        Exit;

    FFieldCount := -1;
    FHitEof     := FALSE;
    FHitBof     := FALSE;

    { We are already at the start of data, can't go prior }
    if FRecordPointer <= @FDataBuffer[FHeaderSize + 3] then begin
        FHitBof := TRUE;
        FHitEof := (FDataBufferCount <= (FHeaderSize + 5));
        Exit;
    end;

    { Search the previous record delimiter }
    Dec(FRecordPointer);
    repeat
        Dec(FRecordPointer);
    until (FRecordPointer^ = FRecSep) or
          (FRecordPointer <= @FDataBuffer[FHeaderSize + 3]);

    { Stay on the first char for the first field }
    if FRecordPointer > @FDataBuffer[FHeaderSize + 3] then
        Inc(FRecordPointer);
    { 24/12/98 }
    if FRecordPointer < @FDataBuffer[FHeaderSize + 3] then
        FRecordPointer := @FDataBuffer[FHeaderSize + 3];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Last;
begin
    if not FHasData then
        Exit;

    FFieldCount    := -1;
    FRecordPointer := @FDataBuffer[FDataBufferCount - 1];
    Prior;
    FHitEof        := TRUE;
    FHitBof        := (FDataBufferCount <= (FHeaderSize + 5));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetBookmark: TBookmark;
begin
    { TODO -oFL : To be review for FPC port }
    //Result := TBookmark(Tell);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.FreeBookmark(Bookmark: TBookmark);
begin
    { Nothing to do as we did'nt allocate memory ! }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.GotoBookmark(Bookmark: TBookmark);
begin
    { TODO -oFL : To be review for FPC port }
    //Seek(TPosition(Bookmark));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Returns the byte offset for the first character of the first field of the }
{ current record                                                            }
function TMWBuffer.Tell : TPosition;
begin
    Result := FRecordPointer - FDataBuffer;
//writeln('Tell = ' + IntToHex(LongInt(FRecordPointer), 8));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Seek(nPos : TPosition);
begin
    if nPos < (FHeaderSize + 2) then
        raise Exception.Create('TMWBuffer.Seek before first record');
    if nPos >= FDataBufferCount then
        raise Exception.Create('TMWBuffer.Seek after last record');
    FRecordPointer := FDataBuffer + nPos;
    FFieldCount    := -1;
    FHitEof        := FALSE;
    FHitBof        := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Not so good for blob fields...                                            }
function TMWBuffer.RecordToString : String;
var
    Count  : Integer;
    I      : Integer;
    N, M   : Integer;
    N1, N2 : Integer;
    Buf    : String;
begin
    Count  := FieldCount;
    Result := '';
    for I := 0 to Count - 1 do begin
        N1     := Length(Result) + 2;
        try
            Buf := Fields[I];
        except
            Buf := '';
        end;
        Result := Result + '''' + Buf + '''';
        N2     := Length(Result) - 1;
        { Check if any quote inside field. If yes, replace by double quote     }
        { This strange code is optimized for the case where there is not quote }
        for N := N1 to N2 do begin
            if Result[N] = '''' then begin
                Buf := Copy(Result, N, N2 - N + 1);
                SetLength(Result, N - 1);
                for M := 1 to Length(Buf) do begin
                    if Buf[M] = '''' then
                        Result := Result + ''''''
                    else
                        Result := Result + Buf[M];
                end;
                Result := Result + '''';
                break;
            end;
        end;
        if I < (Count - 1) then
            Result := Result + ',';
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Reverse operation for RecordToString. Append a new record.                }
{ Start parsing the string from a give index. Update this position          }
{ Return the number of fields copied.                                       }
{ Accept fields delimited by single or double quotes                        }
{ See also StringToRecords for several records.                             }
function TMWBuffer.StringToRecord(
    Src       : String;
    var Start : Integer) : integer;
var
    Delim : Char;
    I     : Integer;
    Fld   : String;
    FldNo : Integer;
begin
    if (Start < 1) or (Start > Length(Src)) then
        raise Exception.Create('StringToRecord: invalid start position');
    FldNo := 0;
    I     := Start;

    { Skip over white spaces }
    while (I <= Length(Src)) and (Src[I] in [' ', #9, #13, #10]) do
        Inc(I);

    while TRUE do begin
        Fld := '';
        if I > Length(Src) then
            break;

        { Get Delimiter }
        if Src[I] in ['''', '"'] then begin
            Delim := Src[I];
            Inc(I);
        end
        else
            Delim := ',';

        { Copy field value }
        while I <= Length(Src) do begin
            if Src[I] <> Delim then
                Fld := Fld + Src[I]
            else if Delim <> ',' then begin
                Inc(I);
                if (I < Length(Src)) and (Src[I] = Delim) then
                    Fld := Fld + Delim
                else
                    break;
            end
            else
                break;
            Inc(I);
        end;

        { Field is complete, add to record }
        WriteFields(FALSE {FldNo = 0}, [Fld]);
        Inc(FldNo);

        { Continue with next field }
        if Delim <> ',' then begin
            { Skip over white spaces }
            while (I <= Length(Src)) and (Src[I] in [' ', #9, #13, #10]) do
                Inc(I);
        end;
        if (I <= Length(Src)) and (Src[I] <> ',') then
            break;

        if I > Length(Src) then
            break;
        Inc(I);
        { Skip over white spaces }
        while (I <= Length(Src)) and (Src[I] in [' ', #9, #13, #10]) do
            Inc(I);
        if I > Length(Src) then
            break;
    end;

    Result := FldNo;
    Start  := I;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Same as StringToRecord, but applied for several records.                  }
{ Use semicolon as record delimiter.                                        }
procedure TMWBuffer.StringToRecords(Src : String);
var
    Start : Integer;
begin
    Start := 1;
    while Start <= Length(Src) do begin
        StringToRecord(Src, Start);
        if Start > Length(Src) then
            break;
        if Src[Start] <> ';' then
            raise Exception.Create('TMWTable.StringToRecords: ' +
                                   'Invalid record delimiter ''' +
                                   Src[Start] + ''' in ''' +
                                   Src + '''');
        Inc(Start);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SetPSessionID(const Value : PChar);
begin
    FPSessionID := Value;
    // Should add code to replace any existing SessionID already pushed in
    // the buffer by Rewrite.
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Rewrite;
var
    Dst : PChar;
begin
    FHitEof := TRUE;
    FHitBof := TRUE;

    // 15/02/99 Force buffer allocation
    if {(FDataBuffer = nil) or} (not ExpandBuffer(nil, 6)) then begin
        FDataBufferCount := 0;
        FRecordCount     := 0;
        FHasData         := FALSE;
        Exit;
    end;

    Dst              := FDataBuffer + FHeaderSize;
    Dst[0]           := FEscSep;
    Dst[1]           := FFldSep;
    Dst[2]           := FRecSep;
    Dst[3]           := FRecSep;
    Dst[4]           := FRecSep;
    Dst[5]           := #0;
    FDataBufferCount := FHeaderSize + 5;
    FRecordCount     := 0;
    FHasData         := TRUE;
    First;                          // 15/02/99
    if (FPSessionID <> nil) and (FPSessionID^ <> #0) then
        AppendMetaData('I', FPSessionID, StrLen(FPSessionID));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.ExpandBuffer(
    pSize     : PInteger;
    Requested : LongInt) : Boolean;
var
    nBytes : Integer;
    nOff   : LongInt;
begin
    if (FDataBufferSize - FDataBufferCount) >= Requested then begin
        { There is enough memory available, it's ok }
        if pSize <> nil then
            pSize^ := FDataBufferSize - FDataBufferCount;
        Result := TRUE;
        Exit;
    end;

    if FAutoExpand <= 0 then begin
        { Not enough memory, but cannot allocate, fail ! }
        Result := FALSE;
        if pSize <> nil then
            pSize^ := FDataBufferSize - FDataBufferCount;
        Exit;
    end;

    try
        { How much do we allocate ? }
        if FAutoExpand < Requested then
            nBytes := Requested
        else
            nBytes := FAutoExpand;

        { Resize the buffer, this can change the buffer address so we need to }
        { save the byte offset for the current record                         }
        nOff := FRecordPointer - FDataBuffer;
        ReallocMem(FDataBuffer, FDataBufferSize + nBytes);
        FDataBufferSize := FDataBufferSize + nBytes;
        FRecordPointer  := FDataBuffer + nOff;
        FHasAllocated   := TRUE;    { FP 10/05/99 }

        if pSize <> nil then
            pSize^ := FDataBufferSize - FDataBufferCount;
        Result := TRUE;
    except
        if pSize <> nil then
            pSize^ := FDataBufferSize - FDataBufferCount;
        Result := FALSE;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Append a record after the last one                                        }
procedure TMWBuffer.WriteRecord(Args : array of const);
begin
    if not ExpandBuffer(nil, 5) then
        raise MWBufferException.Create('Cannot append data, buffer full');
    if FDataBufferCount <= 0 then
        Rewrite
    else if FDataBufferCount > (FHeaderSize + 5) then
        Inc(FDataBufferCount);        { Skip a record marker }
    AppendFields(Args);
    if FRecordCount >= 0 then         { FP 20/05/99 }
        Inc(FRecordCount);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Terminate the current record (can makes an empty record)                  }
procedure TMWBuffer.WriteRecordMarker;
const
    ErrMsg = 'Buffer too small';
begin
    if not ExpandBuffer(nil, 2) then
        raise MWBufferException.Create(ErrMsg);
    FDataBuffer[FDataBufferCount] := FRecSep; // 21/08/98 RecordSeparator;
    Inc(FDataBufferCount);
    FDataBuffer[FDataBufferCount] := #0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Append fields to the last record                                          }
procedure TMWBuffer.WriteFields(
    NewRec : Boolean;             { Append to current record or start a new }
    Args   : array of const);
begin
    if not ExpandBuffer(nil, 6) then
        raise MWBufferException.Create('Cannot append data, buffer full');
    if FDataBufferCount <= 0 then
        Rewrite;
    if NewRec and (FDataBufferCount > (FHeaderSize + 5)) then begin
        Inc(FDataBufferCount);        { Skip a record marker }
        if FRecordCount >= 0 then     { FP 20/05/99 }
            Inc(FRecordCount);
    end
    else if FRecordCount = 0 then
        Inc(FRecordCount);
    AppendFields(Args);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Assign(Source: TPersistent);
var
    Src : TMWBuffer;
begin
    if not (Source is TMWBuffer) then begin
        inherited Assign(Source);
        Exit;
    end;
    Src            := TMWBuffer(Source);
    // USc 25/08/2003 EscSep, HeaderSize and AutoExpand should also assigned
    FEscSep        := Src.EscSep;
    FHeaderSize    := Src.HeaderSize;
    FAutoExpand    := Src.AutoExpand;
    DataBuffer     := nil;                         { Free current buffer }
    DataBufferSize := Src.DataBufferCount + 1;     { Allocate new buffer }
    { Copy data, including nul terminating character                     }
    { Do not use DataBufferSize as it may be enlarged because AutoExpand }
    Move(Src.DataBuffer^, DataBuffer^, Src.DataBufferCount + 1);  // FP 10/04/2006
    DataBufferCount := Src.DataBufferCount;
    // USc 25/08/2003 set FRecordCount to -1 to ensure a correct working
    // GetRecordCount because Rewrite which is called in SetDataBufferSize
    // set's FRecordCount to Zero and thatswhy the RecordCount won't be
    // "calculated" in GetRecordCount
    FRecordCount    := -1;
    // USc 25/08/2003 make sure that the BOF and EOF flags are correct and the
    // position is the first record
    First;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.AppendRecord(From : TMWBuffer);
var
    Src   : PChar;
    nDst  : LongInt;
    Len   : Integer;
    aSize : LongInt;
begin
    { Compute the length }
    Len := 1;
    Src := From.FRecordPointer;
    while Src^ <> FRecSep do begin
        Inc(Len);
        Inc(Src);
    end;

    if not ExpandBuffer(@aSize, Len + 5) then   { 16/09/98 }
        raise MWBufferException.Create('Cannot append data, buffer full');
    if FDataBufferCount <= 0 then begin
        Rewrite;
        First;
    end
    else if FDataBufferCount > (FHeaderSize + 5) then
        Inc(FDataBufferCount);        { Skip a record marker }

    { Copy data }
    Src  := From.FRecordPointer;
    nDst := FDataBufferCount - 2;
    Move(Src^, FDataBuffer[nDst], Len);
    FDataBufferCount := nDst + Len;

    { Install end of record }
    WriteRecordMarker;

    { Clear field count cache }
    FFieldCount       := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Append fields to the last record                                          }
procedure TMWBuffer.AppendFields(Args : array of const);
type
    PInteger = ^Integer;
const
    ErrMsg = 'Buffer too small';
var
    nArg      : Integer;
    V         : TVarRec;
    Src       : PChar;
    SrcSize   : Integer;
    Buf       : String;
    aSize     : LongInt;
{$IFNDEF DelphiPersonalEdition}
    aField    : TField;    //USc 25/08/2003 exclude TField in Personal Edition
{$ENDIF}
    Count     : Integer;
    HighBound : Integer;
    LowBound  : Integer;
    I         : Integer;
begin
    if FDataBuffer = nil then
        raise EAccessViolation.Create('No buffer');
    if FDataBufferCount < 2 then
        raise MWBufferException.Create('Can''t append data, malformed buffer');
    if not ExpandBuffer(@aSize, 2) then
        raise MWBufferException.Create('Can''t append data, buffer full');

    if (FieldCount = 1) and (FMetaDataLayout > '') then begin
        AppendMetaData('M', PChar(FMetaDataLayout), Length(FMetaDataLayout));
        FMetaDataLayout := '';        { 17/02/2002 }
    end;

    nArg := 0;
    Src  := nil;
    while nArg <= High(Args) do begin
        SrcSize := -1;   // FP 07/04/99
        V       := args[nArg];
        case (V.VType and varTypeMask) of
        vtString:
            begin
                Src     := @(V.VString^)[1];
                SrcSize := Length(V.VString^);
            end;
        vtAnsiString:    // FP 23/12/98
            begin
                Src     := PChar(V.VAnsiString);
                if Src = nil then
                    SrcSize := 0
                else begin
{$IFDEF BCB}
                    // BCB bug: when passing an empty string, data pointer
                    // is not null but point to a zero length string constant
                    // This bug will make impossible to use a string with a nul
                    // byte as first character...
                    if Src^ = #0 then
                        SrcSize := 0
                    else
                        SrcSize := PInteger(PChar(V.VAnsiString) - SizeOf(Integer))^;
{$ELSE}
                    // Not very legal code, there should be a better way to
                    // retrieve the string length !
                    SrcSize := PInteger(PChar(V.VAnsiString) - SizeOf(Integer))^;
{$ENDIF}
                end;
            end;
        vtPChar:
            begin
                if V.VPChar <> nil then
                    Src := V.VPchar
                else
                    Src := nil;
            end;
        vtBoolean:
            begin
                Buf := IntToStr(Ord(V.VBoolean));
                Src := PChar(Buf);
            end;
        vtInteger:
            begin
                Buf := IntToStr(V.VInteger);
                Src := PChar(Buf);
            end;
{$IFDEF VER140} { Delphi 6 }
        vtInt64:
            begin
                Buf := IntToStr(V.VInt64^);       // 30/03/02
                Src := PChar(Buf);
            end;
{$ENDIF}
{$IFDEF VER150} { Delphi 7 }
        vtInt64:
            begin
                Buf := IntToStr(V.VInt64^);       // 06/05/03
                Src := PChar(Buf);
            end;
{$ENDIF}
        vtExtended:
            begin
                Buf := FloatToStrEx(V.VExtended^); // 29/01/99
                Src := PChar(Buf);
            end;
        vtChar:
            begin
                Buf := V.VChar;
                Src := PChar(Buf);
            end;
        vtObject:
            begin
// USc 25/08/2003 exclude TField in Personal Edition
{$IFNDEF DelphiPersonalEdition}
                if V.VObject is TField then begin
                    aField := TField(V.VObject);
                    if V.VObject is TBlobField then begin
{$IFDEF VER90} // 26/11/98 added ftBlob and ftMemo
                        SrcSize := TBlobField(aField).Size;
{$ELSE}
{$IFDEF VER93}
                        SrcSize := TBlobField(aField).Size;
{$ELSE}
                        SrcSize := TBlobField(aField).BlobSize;
{$ENDIF}
{$ENDIF}
                        Src     := PChar(TBlobField(aField).Value);
                    end
                    else if aField.DataType in [ftDate, ftTime, ftDateTime] then
                        Src := PChar(DateTimeToMWFormat(aField.AsDateTime))
                    else
                        Src := PChar(aField.AsString);
                end
                else
{$ENDIF}
                    RaiseException('AppendFields: Unsupported object type ' +
                                   V.VObject.ClassName);
            end;
        vtVariant:
            begin
                Count := VarArrayDimCount(V.VVariant^);
                if Count = 0 then begin
                    if (TVarData(V.VVariant^).VType and varByRef) <> 0 then
                        Buf := PVariant(TVarData(V.VVariant^).VPointer)^
                    else if V.VVariant^ = Null then
                        Buf := ''
                    else
                        Buf := V.VVariant^;
                    Src     := PChar(Buf);
                    WriteDataBuffer(Src, -1);
                end
                else begin
                    if Count <> 1 then
                        RaiseException(
                           'AppendFields: Variant array is multidimensional (' +
                           IntToStr(Count) + ')');
                    LowBound  := VarArrayLowBound(V.VVariant^, 1);
                    HighBound := VarArrayHighBound(V.VVariant^, 1);
                    for I := LowBound to HighBound do begin
                        Buf     := V.VVariant^[I];
                        Src     := PChar(Buf);
                        WriteDataBuffer(Src, -1);
                    end;
                end;
                SrcSize := -2;
            end;
        else
            RaiseException('AppendFields: Unsupported data type ' +
                           IntToStr(V.VType));
        end;

        // Write field data to result set buffer
        if SrcSize <> -2 then
            WriteDataBuffer(Src, SrcSize);

        // Go to next argument
        Inc(nArg);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.AppendMetaData(Delim : Char; Src : PChar; Len : LongInt);
var
    aSize   : LongInt;
    Flag    : Boolean;                                      // 03/03/2005
begin
    if FDataBufferCount <= 0 then
        Rewrite;
    if not ExpandBuffer(@aSize, 6) then
        raise MWBufferException.Create('Cannot append data, buffer full');
    if (Delim in ['C', 'F', 'L', 'N', 'R', 'T']) or
       (Delim < 'A') or (Delim > 'Z') then
        raise MWBufferException.Create('Invalid metadata delimiter #' +
                                       IntToStr(Ord(Delim)));
    Flag := ((FDataBufferCount > 5) and                     // 03/03/2005
            (FDataBuffer[FDataBufferCount - 3] = FFldSep)); // 03/03/2005
    if Flag then                                            // 03/03/2005
        Dec(FDataBufferCount);                              // 03/03/2005
    FDataBuffer[FDataBufferCount - 2] := FEscSep;
    FDataBuffer[FDataBufferCount - 1] := Delim;
    FDataBufferCount := FDataBufferCount + 2;
    WriteDataBuffer(Src, Len);
    if not ExpandBuffer(@aSize, 3) then
        raise MWBufferException.Create('Cannot append data, buffer full');
    FDataBuffer[FDataBufferCount - 3] := FEscSep;
    FDataBuffer[FDataBufferCount - 2] := Chr(Ord(Delim) xor $20);
    //FDataBuffer[FDataBufferCount - 1] := FFldSep;      // 03/03/2005
    //FDataBuffer[FDataBufferCount]     := FRecSep;      // 03/03/2005
    //FDataBuffer[FDataBufferCount + 1] := FRecSep;      // 03/03/2005
    //FDataBuffer[FDataBufferCount + 2] := #0;           // 03/03/2005

    if Flag then begin                                   // 03/03/2005
        FDataBuffer[FDataBufferCount - 1] := FFldSep;    // 03/03/2005
        Inc(FDataBufferCount);                           // 03/03/2005
    end;                                                 // 03/03/2005
    FDataBuffer[FDataBufferCount - 1] := FRecSep;        // 03/03/2005
    FDataBuffer[FDataBufferCount]     := FRecSep;        // 03/03/2005
    FDataBuffer[FDataBufferCount + 1] := #0;             // 03/03/2005

    FDataBufferCount := FDataBufferCount + 1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SetMetaDataLayout(const Layout : String);
begin
    if FMetaDataLayout <> Layout then begin
        if FDataBufferCount <= 0 then
            Rewrite;
        FMetaDataLayout := Layout;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Append data from a buffer to the record buffer.                           }
{ Delimiter characters found in data are 'escaped'.                         }
{ Add ending field delimiter, two record delimiters (EOF) and a nul byte.   }
{ Update DataBufferCount.                                                   }
{ If Len argument is positive or nul, then copy the specified length        }
{ else if Len < 0 then copy until nul byte (nul terminated string).         }
procedure TMWBuffer.WriteDataBuffer(Src : PChar; Len : LongInt);
const
    ErrMsg = 'Buffer too small';
var
    nDst  : Integer;
    aSize : LongInt;
    Escaped : Boolean;
begin
    if Len < 0 then begin
        if Src = nil then
            Len := 0
        else
            Len := StrLen(Src);
    end;

    { Be sure to have enough room in data buffer }
        if not ExpandBuffer(@aSize, Len + 5) then
            raise MWBufferException.Create(ErrMsg);

    Escaped := FALSE;
    if (Src <> nil) and (Len <> 0) then begin
        { Data is to be added just before last field delimiter and record  }
        { delimiter.                                                       }
        nDst := FDataBufferCount - 2;
        while Len > 0 do begin
        { If any delimiter found in the data, replace by the EscMarker }
        { followed by a character telling which delimiter is there     }
        if Src^ = FEscSep then begin
            FDataBuffer[nDst] := FEscSep;
            Inc(nDst);
            Inc(FDataBufferCount);
            FDataBuffer[nDst] := FEscSep;
                Escaped           := TRUE;
        end
        else if Src^ = FFldSep then begin
            FDataBuffer[nDst] := FEscSep;
            Inc(nDst);
            Inc(FDataBufferCount);
            FDataBuffer[nDst] := 'F';
                Escaped           := TRUE;
        end
        else if Src^ = FRecSep then begin
            FDataBuffer[nDst] := FEscSep;
            Inc(nDst);
            Inc(FDataBufferCount);
            FDataBuffer[nDst] := 'R';
                Escaped           := TRUE;
        end
        else if Src^ = CR then begin
            FDataBuffer[nDst] := FEscSep;
            Inc(nDst);
            Inc(FDataBufferCount);
            FDataBuffer[nDst] := 'C';
                Escaped           := TRUE;
        end
        else if Src^ = LF then  begin
            FDataBuffer[nDst] := FEscSep;
            Inc(nDst);
            Inc(FDataBufferCount);
            FDataBuffer[nDst] := 'L';
                Escaped           := TRUE;
        end
        else if Src^ = #0 then begin
            FDataBuffer[nDst] := FEscSep;
            Inc(nDst);
            Inc(FDataBufferCount);
            FDataBuffer[nDst] := 'N';
                Escaped           := TRUE;
        end
        else
            FDataBuffer[nDst] := Src^;

            if Escaped then begin
                { We escaped a character, need to check for room again }
                if not ExpandBuffer(@aSize, Len + 5) then
                    raise MWBufferException.Create(ErrMsg);
                Escaped := FALSE;
            end;

        Inc(nDst);
        Inc(Src);
        Inc(FDataBufferCount);
        Dec(Len);
    end;
end;

    if not ExpandBuffer(@aSize, 4) then
        raise MWBufferException.Create(ErrMsg);
        
    // Add end of field marker
    FDataBuffer[FDataBufferCount - 2] := FieldSeparator;
    Inc(FDataBufferCount);
    // Terminate buffer with EOF marker (2 rec delim) and nul byte
    FDataBuffer[FDataBufferCount - 2] := FRecSep;
    FDataBuffer[FDataBufferCount - 1] := FRecSep;
    FDataBuffer[FDataBufferCount]     := #0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Write stream data as field content. The stream is writen starting from    }
{ current position to end of stream.                                        }
procedure TMWBuffer.WriteStreamField(
    NewRec  : Boolean;            { Append to current record or start a new }
    FldType : TMWFieldType;       { The kind of data field                  }
    Data    : TStream);
begin
    if not ExpandBuffer(nil, Data.Size + 6) then
        raise MWBufferException.Create('Cannot append data, buffer full');
    if FDataBufferCount <= 0 then
        Rewrite;
    if NewRec and (FDataBufferCount > (FHeaderSize + 5)) then
        Inc(FDataBufferCount);        { Skip a record marker }
    AppendStreamField(Data, FldType);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Write stream data as field content. The stream is writen starting from    }
{ current position to end of stream.                                        }
procedure TMWBuffer.AppendStreamField(
    Data    : TStream;
    FldType : TMWFieldType);      { The kind of data field                  }
const
    ErrMsg = 'Buffer too small';
var
    nDst  : Integer;
    Buf   : PChar;
    Len   : Integer;
    Cnt   : LongInt;
    aSize : LongInt;
begin
    if FDataBuffer = nil then
        raise EAccessViolation.Create('No buffer');

    if not ExpandBuffer(@aSize, Data.Size + 2) then
        raise MWBufferException.Create('Cannot append data, buffer full');

    { If field type is not string, then write the field type marker }
    if FldType <> mwString then begin
        if not ExpandBuffer(@aSize, 6) then
            raise MWBufferException.Create('Cannot append data, buffer full');
        nDst              := FDataBufferCount - 2;
        FDataBuffer[nDst] := FEscSep;
        Inc(nDst);
        FDataBuffer[nDst] := 'T';          { For field Type }
        Inc(nDst);
        FDataBuffer[nDst] := Chr(Ord('0') + Ord(FldType));
        Inc(FDataBufferCount, 3);
    end;

    if Data is TMemoryStream then begin
        { We can optimize for a TMemoryStream because we have direct }
        { access to data in memory                                   }
        WriteDataBuffer(PChar(TMemoryStream(Data).Memory) +
                        TMemoryStream(Data).Position,
                        Data.Size - TMemoryStream(Data).Position);
    end
    else begin
        { Other kind of TStream, must read data into memory }
        Len := Data.Size - Data.Position;
        if Len <= 0 then
            // Empty field
            WriteDataBuffer(nil, 0)
        else begin
            { Allocate memory to read entire stream }
            GetMem(Buf, Len);
            try
                { Read stream into memory buffer }
                Cnt := Data.Read(Buf^, Len);
                { Write buffer as field data }
                WriteDataBuffer(Buf, Cnt);
            finally
                FreeMem(Buf);
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Write binary data as field content.                                       }
procedure TMWBuffer.AppendBinaryField(
    Data    : Pointer;
    Len     : Integer;
    FldType : TMWFieldType);      { The kind of data field                  }
const
    ErrMsg = 'Buffer too small';
var
    nDst  : Integer;
    aSize : LongInt;
begin
    if FDataBuffer = nil then
        raise EAccessViolation.Create('No buffer');

    if not ExpandBuffer(@aSize, Len + 10) then
        raise MWBufferException.Create('Cannot append data, buffer full');

    { If field type is not string, then write the field type marker }
    if FldType <> mwString then begin
        nDst              := FDataBufferCount - 2;
        FDataBuffer[nDst] := FEscSep;
        Inc(nDst);
        FDataBuffer[nDst] := 'T';          { For field Type }
        Inc(nDst);
        FDataBuffer[nDst] := Chr(Ord('0') + Ord(FldType));
        Inc(FDataBufferCount, 3);
    end;

    WriteDataBuffer(Data, Len);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.Delete;
var
    Start : PChar;
    Len   : Integer;
    Len1  : Integer;
begin
    if FRecordPointer = nil then
        raise Exception.Create('No current record');
    FFieldCount := -1;
    Start       := FRecordPointer;
    Next;
    Len         := FRecordPointer - Start;
    if Len <= 0 then begin
        { We are on the last record }
        Prior;
        Len := Start - FRecordPointer;
        if Len <= 0 then begin
            { Only one record }
            Rewrite;
        end
        else begin
            Start[0]         := FRecSep;
            Start[1]         := #0;
            FDataBufferCount := Start - FDataBuffer + 1;
        end;
    end
    else begin
        Len1 := FDataBufferCount - (FRecordPointer - FDataBuffer);
        Move(FRecordPointer^, Start^, Len1);
        FRecordPointer   := Start;
        FDataBufferCount := FDataBufferCount - Len;
    end;

    FHitEof := (FDataBufferCount <= (FHeaderSize + 5));
    FHitBof := FHitEof;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.Locate(
    const KeyFields: String;           // Field list, byte values, 1 based
    const KeyValues: Variant;
    Options: TLocateOptions): Boolean;
var
    I                : Integer;
    FldNum           : Integer;
    FldVal           : String;
    KeyVal           : String;
    bCaseInsensitive : Boolean;
    bPartialKey      : Boolean;
    bVarArray        : Boolean;
begin
    bCaseInsensitive := (loCaseInsensitive in Options);
    bPartialKey      := (loPartialKey in Options);
    bVarArray        := ((VarType(KeyValues) and varArray) <> 0);
    Result           := FALSE;
    First;
    while not Eof do begin
        Result := TRUE;
        for I := 1 to Length(KeyFields) do begin
            FldNum := Ord(KeyFields[I]) - 1;
            FldVal := Fields[FldNum];
{
            if bVarArray then
                KeyVal := KeyValues[I - 1]  // Fred 28/05/99 [I - 1] was FldNum
            else
                KeyVal := KeyValues;
}
            if bVarArray then begin
                if KeyValues[I - 1] = null then   // FS 16/05/03
                    KeyVal := ''
                else
                    KeyVal := KeyValues[I - 1];  // Fred 28/05/99 [I - 1] was FldNum
            end
            else begin
                if KeyValues = null then
                    KeyVal := ''
                else
                    KeyVal := KeyValues;
            end;

            if bCaseInsensitive then begin
                FldVal := UpperCase(FldVal);
                KeyVal := UpperCase(KeyVal);
            end;
            if bPartialKey then
                Result := (Copy(FldVal, 1, Length(KeyVal)) = KeyVal)
            else
                Result := (FldVal = KeyVal);
            if not Result then
                break;
        end;
        if Result then
            break;
        Next;
    end;
    FHitBof := FALSE;
    FHitEof := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function DateTimeToMWFormat(DateTime : TDateTime) : String;
var
    TimeStamp : TTimeStamp;
begin
    TimeStamp := DateTimeToTimeStamp(DateTime);
    Result    := IntToStr(TimeStamp.Time) + ';' + IntToStr(TimeStamp.Date);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function DateTimeFromMWFormat(Src : String) : TDateTime;
var
    TimeStamp : TTimeStamp;
begin
    TimeStamp := TimeStampFromMWFormat(Src);
    if (TimeStamp.Date = 0) and (TimeStamp.Time = 0) then
        Result := 0
    else
        Result := TimeStampToDateTime(TimeStamp);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TimeStampToMWFormat(TimeStamp : TTimeStamp) : String;
begin
    Result := IntToStr(TimeStamp.Time) + ';' + IntToStr(TimeStamp.Date);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TimeStampFromMWFormat(Src : String) : TTimeStamp;
var
    I : Integer;
begin
    Result.Date := 0;
    Result.Time := 0;
    I := 1;
    { Skip leading spaces }
    while (I <= Length(Src)) and (Src[I] = ' ') do
        Inc(I);
    { Convert first integer as time field }
    while (I <= Length(Src)) and (Src[I] in ['0'..'9']) do begin
        Result.Time := Result.Time * 10 + Ord(Src[I]) - Ord('0');
        Inc(I);
    end;
    { skip delimiters }
    while (I <= Length(Src)) and (not (Src[I] in ['0'..'9'])) do
        Inc(I);
    { convert second integer as date field }
    while (I <= Length(Src)) and (Src[I] in ['0'..'9']) do begin
        Result.Date := Result.Date * 10 + Ord(Src[I]) - Ord('0');
        Inc(I);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function FloatToStrEx(Value : Extended) : String;
begin
    Result := FloatToStrF(Value, ffGeneral, 18, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SaveToStream(Stream : TStream);
var
    Buffer : String;
begin
    // Check if TMWBuffer is correctly constructed
    if (DataBufferCount < 0) or
       ((DataBufferCount > 0) and (DataBufferCount < 5)) or
       ((DataBufferCount > 0) and (DataBuffer = nil))  then
        raise MWBufferException.Create('Data corrupted');
    if DataBufferCount < 100000000 then
        Buffer := 'MWBUFFER1' + Format('%8.8d', [DataBufferCount])
    else
        Buffer := 'MWBUFFER2' + Format('%10.10d', [DataBufferCount]);
    Stream.WriteBuffer(Buffer[1], Length(Buffer));
    if DataBuffer <> nil then
        Stream.WriteBuffer(DataBuffer^, DataBufferCount);
    Buffer := #13#10;
    Stream.WriteBuffer(Buffer[1], Length(Buffer));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.LoadFromStream(Stream : TStream);
var
    Buffer : String;
    Count  : LongInt;
    Len    : Integer;
begin
    // Read the header
    SetLength(Buffer, 10);
    Count := Stream.Read(Buffer[1], 9);
    if (Count <> 9) or (Copy(Buffer, 1, 8) <> 'MWBUFFER') then begin
        Rewrite;
        raise MWBufferException.Create('Invalid format');
    end;

    // Get the length from hedaer, depending on version number
    case Buffer[9] of
    '1' : Len := 8;
    '2' : Len := 10;
    else
        raise MWBufferException.Create('Unsupported version');
    end;

    FillChar(Buffer[1], 10, 0);
    Count := Stream.Read(Buffer[1], Len);
    if Count <> Len then begin
        Rewrite;
        raise MWBufferException.Create('Invalid format');
    end;

    Len := StrToIntDef(Buffer, -1);
    if Len < 0 then begin
        Rewrite;
        raise MWBufferException.Create('Data corrupted');
    end;

    // Check special case of an empty TMWBuffer written to the stream
    if Len = 0 then begin
        DataBuffer      := nil;
        DataBufferSize  := 0;    // Warning: implicit allocation and Rewrite
        DataBufferCount := 0;    // We insist on no data
        HasData         := FALSE;
    end
    else begin
        // (re)allocate memory to exact needed size
        DataBufferSize := Len;

        // Read data from stream
        Count := Stream.Read(DataBuffer^, Len);
        if Count <> Len then begin
            // Not the right count !
            DataBufferSize := 6;
            Rewrite;
            raise MWBufferException.Create('Data corrupted');
        end;
        DataBufferCount := Len;
        HasData         := TRUE;
    end;

    // Data is followed by CR/LF pair
    SetLength(Buffer, 2);
    Count := Stream.Read(Buffer[1], 2);
    if (Count <> 2) or (Buffer <> #13#10) then begin
        DataBufferSize := 6;
        Rewrite;
        raise MWBufferException.Create('Data corrupted');
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.SaveToFile(FileName : String);
var
    Stream : TFileStream;
begin
    Stream := TFileStream.Create(FileName, fmCreate);
    try
        SaveToStream(Stream);
    finally
        Stream.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBuffer.LoadFromFile(FileName : String);
var
    Stream : TFileStream;
begin
    Stream := TFileStream.Create(FileName, fmOpenRead);
    try
        LoadFromStream(Stream);
    finally
        Stream.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function DefaultBuildKey(MWBuffer : TMWBuffer) : String;
begin
    Result := MWBuffer.Fields[0];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function SortIndexCompare(Item1, Item2 : Pointer) : Integer;
var
    p1, p2 : PChar;
const
    Ch : Char = #0;
begin
    try
        p1 := PChar(PMWBufferSortRec(Item1).Key);
        if p1 = nil then
            p1 := @Ch;
        p2 := PChar(PMWBufferSortRec(Item2).Key);
        if p2 = nil then
            p2 := @Ch;
        Result := StrComp(p1, p2);
    except
        Result := 0;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// USc 25/08/2003 renamed the old Sort to InternalSort
// I didn't moved the position in the file because this would make comparing
// a bit complicated
procedure TMWBuffer.InternalSort(
    BuildKey       : TMWBufferSortBuildKey;
    BuildKeyObject : TMWBufferSortBuildKeyObject;
    Ascending      : Boolean);
var
    BuildKeyFct : TMWBufferSortBuildKey;
    I           : LongInt;
    SortResult  : TMWBuffer;
    SortIndex   : TMWBufferSortList;
begin
    // If not data at all, then nothing to do
    if not FHasData then
        Exit;

    // If empty record set then nothing to do
    First;
    if Eof then
        Exit;

    // Create a list with all keys and positions
    SortIndex := TMWBufferSortList.Create;
    try
        // USc 25/08/2003 when BuildKeyObject is not Assigned then use the non
        // object procedure
        if not Assigned(BuildKeyObject) then begin
        // Use default function if none provided
        if @BuildKey = nil then
            BuildKeyFct := DefaultBuildKey
        else
            BuildKeyFct := BuildKey;

        // Build the key list
        while not Eof do begin
            SortIndex.AddKey(BuildKeyFct(Self), Tell);
            Next;
        end;
        end
        else begin //USc 25/08/2003 else use the object procedure for sorting
            while not Eof do begin
                SortIndex.AddKey(BuildKeyObject(Self), Tell);
                Next;
            end;
        end;

        // Sort the key list
        SortIndex.Sort(SortIndexCompare);

        SortResult := TMWBuffer.Create(nil);
        try
            SortResult.SetDataBufferSize(DataBufferCount);
            if Ascending then begin
                for I := 0 to SortIndex.Count - 1 do begin
                    Seek(PMWBufferSortRec(SortIndex.Items[I]).Offset);
                    SortResult.AppendRecord(Self);
                end;
            end
            else begin
                for I := SortIndex.Count - 1 downto 0 do begin
                    Seek(PMWBufferSortRec(SortIndex.Items[I]).Offset);
                    SortResult.AppendRecord(Self);
                end;
            end;

            FreeMem(FDataBuffer);
            FDataBuffer      := SortResult.FDataBuffer;
            FDataBufferSize  := SortResult.FDataBufferSize;
            FDataBufferCount := SortResult.FDataBufferCount;
            FRecordPointer   := SortResult.FRecordPointer;
            FHasData         := SortResult.FHasData;          { 16/09/98 }
            FHasAllocated    := SortResult.FHasAllocated;     { 16/09/98 }
            SortResult.FDataBuffer      := nil;
            SortResult.FDataBufferSize  := 0;
            SortResult.FDataBufferCount := 0;
            SortResult.HasData          := FALSE;
            SortResult.FHasAllocated    := FALSE;

            First;
        finally
            SortResult.Destroy;
        end;
    finally
        SortIndex.Destroy;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// USc 25/08/2003 new Sort procedure use InternalSort with non object procedure
// which behaves like the old Sort
procedure TMWBuffer.Sort(BuildKey : TMWBufferSortBuildKey; Ascending : Boolean);
begin
    InternalSort(BuildKey, nil, Ascending);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
//USc 25/08/2003 new SortObject procedure use InternalSort with object procedure
procedure TMWBuffer.SortObject(
    BuildKeyObject : TMWBufferSortBuildKeyObject;
    Ascending      : Boolean);
begin
    InternalSort(nil, BuildKeyObject, Ascending);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBufferSortList.AddKey(const Key : String; const Offset : LongInt);
var
    P : PMWBufferSortRec;
begin
    P := AllocMem(Sizeof(P^));
    Add(P);
    P^.Key    := Key;
    P^.Offset := Offset;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMWBufferSortList.ClearList;
var
    I : Integer;
    P : PMWBufferSortRec;
begin
    for I := 0 to Count - 1 do begin
        P := Items[I];
        FreeMem(P);
    end;
    Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TMWBufferSortList.Destroy;
begin
    ClearList;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function stpblk(PValue : PChar) : PChar;
begin
    Result := PValue;
    while Result^ in [' ', #9, #10, #13] do
        Inc(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function atoi(Value : String) : Integer;
var
    i    : Integer;
    Sign : Char;
begin
    Result := 0;
    Sign   := '+';
    i      := 1;
    while (i <= Length(Value)) and (Value[i] = ' ') do
        i := i + 1;
    if (i <= Length(Value)) and (Value[i] in ['+', '-']) then begin
        Sign := Value[i];
        Inc(i);
    end;
    while (i <= Length(Value)) and (Value[i] >= '0') and (Value[i] <= '9')do begin
        Result := Result * 10 + ord(Value[i]) - ord('0');
        i := i + 1;
    end;
    if Sign = '-' then
        Result := -Result;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetToken(Src : PChar; var Dst : String; var Delim : Char) : PChar;
begin
    Result := StpBlk(Src);
    Dst    := '';
    while TRUE do begin
        Delim := Result^;
        if Delim in [';', #0] then
            break;
        Dst := Dst + UpperCase(Result^);
        Inc(Result);
    end;
    if Delim <> #0 then
        Inc(Result);
    Result := stpblk(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldByNameAsString(const FieldName : String) : String;
var
    FieldType  : String;
    FieldSize  : Integer;
    FieldNum   : Integer;
begin
    FieldNum := FieldInfoByName(FMetaDataLayout,
                                FieldName, FieldType, FieldSize);
    if FieldNum < 0 then
        raise MWBufferException.Create('Unknown FieldName "' + FieldName + '"');

    { Should probably test FieldType }
    Result := Fields[FieldNum];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TMWBuffer.GetFieldByNameAsInteger(const FieldName : String) : Integer;
var
    FieldType  : String;
    FieldSize  : Integer;
    FieldNum   : Integer;
begin
    FieldNum := FieldInfoByName(FMetaDataLayout,
                                FieldName, FieldType, FieldSize);
    if FieldNum < 0 then
        raise MWBufferException.Create('Unknown FieldName "' + FieldName + '"');

    { Should probably test FieldType }
    Result := Atoi(Fields[FieldNum]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Returns field number as result
function TMWBuffer.FieldNumByName(
    const MetaData  : String;            { MetaData with field layout       }
    const FieldName : String) : Integer;
var
    FieldType  : String;
    FieldSize  : Integer;
begin
    Result := FieldInfoByName(MetaData, FieldName, FieldType, FieldSize);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Returns field number as result
function TMWBuffer.FieldInfoByName(
    const MetaData  : String;            { MetaData with field layout       }
    const FieldName : String;
    out   FieldType : String;
    out   FieldSize : Integer) : Integer;
type
    fdState = (fdName, fdType, fdSize);
var
    FldNo   : Integer;
    p       : PChar;
    Token   : String;
    Delim   : Char;
    State   : fdState;
    FldName : String;
    FldType : String;
    FldSize : Integer;
begin
    if CompareText(Copy(MetaData, 1, 7), 'LAYOUT:') <> 0 then
        raise MWBufferException.Create('Invalid metadata layout');

    Result      := -1;
    FieldType   := '';
    FieldSize   := -1;
    State       := fdName;
    FldNo       := 0;
    FldType     := '';
    p           := @MetaData[8];
    while (p <> nil) and (p^ <> #0) do begin
        p := GetToken(p, Token, Delim);
        case State of
        fdName:
            begin
                if Token = '' then
                    FldName := 'FIELD' + IntToStr(FldNo)
                else
                    FldName := UpperCase(Token);
                State   := fdType;
            end;
        fdType:
            begin
                FldType := UpperCase(Token);
                State   := fdSize;
            end;
        fdSize:
            begin
                // We need a field length
                FldSize := atoi(Token);
                if CompareText(FieldName, FldName) = 0 then begin
                    Result    := FldNo;
                    FieldType := FldType;
                    FieldSize := FldSize;
                    Exit;
                end;
                Inc(FldNo);
                State := fdName;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

