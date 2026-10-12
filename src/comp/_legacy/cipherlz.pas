{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Helper routines for the MidWare sample client/server demo.
              Use Adaptive Huffman Coding (LZH) for data compression.
              The LZH routines are from the SWAG and adapted by various
              peoples. See lzh.pas unit for details.
Creation:     Mar 24, 1999
Version:      1.01
EMail:        http://www.overbyte.be        http://www.rtfm.be/fpiette
              francois.piette@overbyte.be   francois.piette@rtfm.be
Support:      Unsupported code
Legal issues: Copyright (C) 1999-2005 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@pophost.eunet.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software and or any
              derived or altered versions for any purpose, excluding commercial
              applications. You can use this software for personal or internal
              use only. You may distribute it freely untouched.
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
Nov 10, 2001 V1.01 Paolo Lanzoni <paolol@salsan.com> adapted to use LongWORD

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit CipherLz;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

interface

uses
    Lzh, SysUtils;

procedure Encrypt(
    Src1        : PChar;
    Src1Len     : Integer;
    Src2        : PChar;
    Src2Len     : Integer;
    var aDst    : PChar;
    var aDstLen : Integer;
    Offset      : Integer);

procedure Decrypt(
    CmdBuf      : PChar;
    CmdLen      : Integer;
    var aDst    : PChar;
    var aDstLen : Integer);

implementation

type
    TLZObject = class(TObject)
    private
        FSrc1    : PChar;
        FSrc1Len : Integer;
        FSrc2    : PChar;
        FSrc2Len : Integer;
        FDst     : PChar;
        FDstLen  : Integer;
        FRdPtr   : Integer;
        FWrPtr   : Integer;
        procedure EncryptGetBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
        procedure EncryptPutBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
        procedure DecryptGetBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
        procedure DecryptPutBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
    end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLZObject.EncryptGetBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
var
    P : PChar;
begin
    // Data is split into two buffers, we must get data from the first
    // buffer and when exhausted, from the second buffer.
    // Buffers may be empty or not assigned
    if (FRdPtr < FSrc1Len) and (FSrc1Len > 0) and (FSrc1 <> nil) then begin
        P         := FSrc1 + FrdPtr;
        Bytes_Got := FSrc1Len - FRdPtr;
        if Bytes_Got > NBytes then
            Bytes_Got := NBytes;
    end
    else begin
        if (FSrc2 = nil) or (FSrc2Len = 0) then begin
            P         := nil;
            Bytes_Got := 0
        end
        else begin
            P         := FSrc2 + FRdPtr - FSrc1Len;
            Bytes_Got := FSrc2Len - (FRdPtr - FSrc1Len);
        end;
        if Bytes_Got > NBytes then
            Bytes_Got := NBytes;
    end;
    if Bytes_Got > 0 then
        Move(P^, DTA, Bytes_Got);
    Inc(FRdPtr, Bytes_Got);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLZObject.EncryptPutBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
var
    Src : PChar;
    Dst : PChar;
    I   : Integer;
begin
    if NBytes <= 0 then
        Exit;
    Bytes_Got := NBytes;
    Src       := @DTA;
    Dst       := FDst + FWrPtr;
    for I := 0 to NBytes - 1 do begin
        Dst^ := Src^;
        Inc(Src);
        { We must escape some characters because they are used as }
        { delimiters in MidWare protocol                          }
        case Dst^ of
        #0:  begin
                 Dst^ := #4;
                 Inc(Dst);
                 Inc(FWrPtr);
                 Dst^ := #7;
             end;
        #4:  begin
                 Dst^ := #4;
                 Inc(Dst);
                 Inc(FWrPtr);
                 Dst^ := #4;
             end;
        #10: begin
                 Dst^ := #4;
                 Inc(Dst);
                 Inc(FWrPtr);
                 Dst^ := #6;
             end;
        #13: begin
                 Dst^ := #4;
                 Inc(Dst);
                 Inc(FWrPtr);
                 Dst^ := #5;
             end;
        end;
        Inc(Dst);
        Inc(FWrPtr);
        if FWrPtr > (FDstLen - 3) then begin
            // We need to enlarge the buffer. Add 1KB
            Inc(FDstLen, 1024);
            ReallocMem(FDst, FDstLen);
            Dst := FDst + FWrPtr;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Encrypt(
    Src1        : PChar;
    Src1Len     : Integer;
    Src2        : PChar;
    Src2Len     : Integer;
    var aDst    : PChar;
    var aDstLen : Integer;
    Offset      : Integer);
var
    Lzh           : TLZH;
    LzObject      : TLZObject;
    Bytes_Written : LongInt;
    Buf           : String;
begin
    Lzh := TLzh.Create;
    try
        LzObject := TLZObject.Create;
        try
            LzObject.FSrc1    := Src1;
            LzObject.FSrc1Len := Src1Len;
            LzObject.FSrc2    := Src2;
            LzObject.FSrc2Len := Src2Len;
            // Create an output buffer
            LzObject.FDstLen := (((Src1Len + Src2Len) div 1024) + 1) * 1024;
            GetMem(LzObject.FDst, LzObject.FDstLen);
            // Reset pointers
            LzObject.FRdPtr := 0;
            LzObject.FWrPtr := Offset + 8;
            // Save length in destination
            Buf := IntToHex(Src1Len + Src2Len, 8);
            Move(Buf[1], LzObject.FDst[Offset], 8);
            Bytes_Written   := 0;
            Lzh.LZHPack(Bytes_Written,
                        LzObject.EncryptGetBytes,
                        LzObject.EncryptPutBytes);
            aDst    := LzObject.FDst;
            aDstLen := LzObject.FWrPtr;
            // Adjust buffer size
            ReallocMem(aDst, aDstLen);
        finally
            LzObject.Destroy;
        end;
    finally
        Lzh.Destroy;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLzObject.DecryptGetBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
var
    Src : PChar;
    Dst : PChar;
begin
    Bytes_Got := 0;
    Dst       := @DTA;
    Src       := FSrc1 + FRdPtr;
    while Bytes_Got < NBytes do begin
        if FRdPtr >= FSrc1Len then   // No more data
            break;
        if Src^ <> #4 then
            Dst^ := Src^
        else begin
            Inc(Src);
            Inc(FRdPtr);
            case Src^ of
            #4 : Dst^ := #4;
            #5 : Dst^ := #13;
            #6 : Dst^ := #10;
            #7 : Dst^ := #0;
            end;
        end;
        Inc(Dst);
        Inc(Src);
        Inc(FRdPtr);
        Inc(Bytes_Got);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLzObject.DecryptPutBytes(var DTA; NBytes : WORD; var Bytes_Got : Longword);
begin
    Bytes_Got := NBytes;
    if NBytes <= 0 then
        Exit;
    Move(DTA, FDst[FWrPtr], NBytes);
    Inc(FWrPtr, NBytes);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Decrypt(
    CmdBuf      : PChar;
    CmdLen      : Integer;
    var aDst    : PChar;
    var aDstLen : Integer);
var
    Lzh           : TLZH;
    LzObject      : TLZObject;
    I             : Integer;
    Len           : Integer;
begin
    Lzh := TLzh.Create;
    try
        LzObject := TLZObject.Create;
        try
            // First 8 bytes are original data size in ascii-hex
            Len := 0;
            for I := 0 to 7 do begin
                if CmdBuf[I] in ['0'..'9'] then
                    Len := (Len * 16) + Ord(Cmdbuf[I]) - Ord('0')
                else
                    Len := (Len * 16) + (Ord(Cmdbuf[I]) and 15) + 9;
            end;
            LzObject.FSrc1    := CmdBuf + 8;
            LzObject.FSrc1Len := CmdLen - 8;
            LzObject.FDstLen  := Len;
            LzObject.FRdPtr   := 0;
            LzObject.FWrPtr   := 0;
            GetMem(LzObject.FDst, LzObject.FDstLen);
            Lzh.LZHUnpack(LzObject.FDstLen,
                          LzObject.DecryptGetBytes,
                          LzObject.DecryptPutBytes);
            aDst    := LzObject.FDst;
            aDstLen := LzObject.FDstLen;
        finally
            LzObject.Destroy;
        end;
    finally
        Lzh.Destroy;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

