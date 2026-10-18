# Credits, creators' rights and FVCSCrypt.dll

**JEDI VCS 2.5 Beta 2026** is a port of the JEDI VCS 2.5 client to modern Delphi. It is **not** a new product:
almost all of the code and the whole project come from the original creators and maintainers listed here. Their rights
and licenses still apply, and anyone who uses, modifies or redistributes this code must respect them.

## 1. Who created and maintained JEDI VCS

| Who | Role |
|---|---|
| **Thomas Hensle** | **Creator of FreeVCS**, the origin of JEDI VCS, and author ("Initial Developer") of the FreeVCS code. He opened the code and donated it to Project JEDI in 2003. He is also the author of the cipher DLLs `FVCSCrypt.dll` (client) and `ServerCrypt.dll` (server) |
| **Project JEDI** (Joint Endeavour of Delphi Innovators) | The community that received FreeVCS and published it as **JEDI VCS** (JVCS), with the code on SourceForge (`jedivcs`) |
| **Holger Dors** and **Thomas Huber** | Moved the FreeVCS code to JEDI VCS ("Code move to JEDI VCS") and maintained it |
| **Uwe Schuster** | Main maintainer of JEDI VCS 2.x: most of the changes recorded in the unit histories, the server ports and the Free Pascal port |
| **Fikret Hasovic**, **Marco Gosselink**, **Ondrej Kelle (TOndrej)** | JEDI VCS maintainers and contributors |
| Other contributors in the unit histories | CSchuette, AKroeber (2012 trunk features), FBouwmans, WKlein, KFitzner, PLauret, DBelanger, CSchiffler, LBrands and others |
| **F. Libaud** | Port of JEDI VCS to Lazarus/Free Pascal (Linux), published at `github.com/Libaud/JediVCS`; his clone (commit `f6a777d`) is the source base of this port |

The 2026 port (Delphi 11, 12 and 13) lives at [github.com/edmarfrazao/JEDI_VCS](https://github.com/edmarfrazao/JEDI_VCS).
It keeps the original headers, credits and history of every unit; the port changes are marked `JVCS 2026` in the code.

**How the 2026 port was made:** the analysis of the original code, the port changes and the tests were done with
**Claude Code** (model **Claude Opus 5.5**, by Anthropic), directed and validated by the repository maintainer. The
maintainer checked every beta on Delphi 11, 12 and 13 and on a second PC before publishing it. This work is only the
port: the project, its design and almost all of the code still belong to the creators and maintainers above.

## 2. License and rights

- **MPL 1.1:** most of the JEDI VCS code is published under the Mozilla Public License 1.1 (`doc/original/license.txt`).
  It applies to every file with the MPL header or with no other license note.
- **Parts under other licenses:** several parts are donations or derivations from other developers and libraries,
  with their own licenses and restrictions, marked in each file header. Anyone who distributes or reuses the code must
  check every unit header and respect them.
- **Commercial use:** the original license warns that several parts **may not** be used commercially (see Midware below).
- **What this port does to respect the rights:**
  - it keeps the MPL headers and credits;
  - it publishes the source of its changes;
  - it marks the changes;
  - it redistributes third-party binaries unchanged;
  - it keeps the Midware license notice in About and in the console.

## 3. Third-party components

The full component credits are in `doc/original/credits.txt`. The main ones:

| Component | License |
|---|---|
| Midware (François Piette) | freeware for **non-commercial use only**; company use needs a license |
| ICS (Overbyte) | freeware |
| JCL and JVCL (Project JEDI) | MPL 1.1 |
| SynEdit | MPL 1.1 / GPL 2 |
| Virtual-TreeView | MPL 1.1 / LGPL 2.1 |
| Password cipher base: TEncrypt © 1996, F. Millenaar (base of `FVCSCrypt.dll` and `ServerCrypt.dll`) | see `credits.txt` |

## 4. FVCSCrypt.dll: what it is and why it is required

- **What:** the password cipher DLL of the FreeVCS / JEDI VCS client. It exports `fvcs_Encrypt1` (password when a
  user is created or changed) and `fvcs_Encrypt2` (LOGIN password, with the server time).
- **Author:** FreeVCS (Thomas Hensle), based on F. Millenaar's TEncrypt.
- **Source:** **never published.** It was always shipped as a binary in the official installers; the public sources
  only have the interface unit `JVCSCrypt.pas`. Its server-side pair is `ServerCrypt.dll` (`fvcs_CryptCompare`), also
  closed.
- **Version used:** 1.0.0.19, **the same binary** as the official JVCS 2.50 Beta 3 installer, unchanged.
- **Why it is required:** **without it there is no login.** The standalone client, the IDE DLL and the console load it
  from their own folder to encrypt the password before sending it to the 2.5 server.
- **Consequences:** the client is **32-bit** (a 32-bit DLL cannot load into a 64-bit process); the 64-bit Delphi 13 IDE
  uses the standalone client. The installer always puts the DLL next to `Jedivcs.exe`, `jvcs.exe` and
  `JvcsExternalDll.dll`.
- **Rights:** the DLL belongs to its authors; it is redistributed as part of the JEDI VCS runtime, as in the official
  installers, without changes.

## 5. Why there is no 64-bit client

The reason is the `FVCSCrypt.dll` requirement:

1. **Without the DLL there is no login**, and the 2.5 server accepts no other cipher. `ServerCrypt.dll` only
   recognizes passwords encrypted by `FVCSCrypt.dll`.
2. **The DLL is 32-bit and has no source.** It is a PE32 binary with the `register` calling convention and
   `ShortString` parameters. Windows cannot load a 32-bit DLL into a 64-bit process, and there is no source to rebuild
   it for 64 bits.
3. **Rewriting the cipher is not worth it.** Without the source, the algorithm would have to be rebuilt from the
   binary and proven identical, byte for byte, to the original DLL. Moving the client core to 64 bits would also cost
   15 to 40 days, with a high risk of breaking LOGIN for existing servers.
4. **Changing the server is not an option.** The server's `SRVCRYPTINTERNALDUMMY` mode turns authentication off (any
   password is accepted), and replacing `ServerCrypt.dll` would break compatibility with existing clients.
5. **No published source was found:** not in JEDI VCS on SourceForge, not in JCL or JVCL, not in F. Libaud's port.

So the whole client (standalone, IDE DLL, Diff and console) stays **Win32**:

- the 32-bit IDE of Delphi 11, 12 and 13 uses the integrated expert;
- the 64-bit Delphi 13 IDE uses the **standalone client**.

If 64-bit IDE integration is ever resumed, the technical path is a thin Win64 expert that talks to a Win32 agent. The
agent would load the same `FVCSCrypt.dll`. See phase F7 of the port plan (Portuguese:
[Plano-de-Port.md](../pt/common/Plano-de-Port.md)).

Portuguese version, with sources for each item: [doc/pt/common/Creditos-e-Direitos.md](../pt/common/Creditos-e-Direitos.md).
