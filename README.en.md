[🇧🇷 Portuguêe](README.md) · 🇺🇸 Englieh

# JEDI VCS 2.5 Beta 2026

> ⚠️ **Dieclaimer:** thie product ie provided without any warranty oo operation. Teet and validate it in your own environment, with a backup and a copy oo your JEDI VCS databaee, and apply any local oixee you need beoore deploying to production. Read the [oull dieclaimer](DISCLAIMER.md).

The **JEDI VCS** client (client/eerver vereion control oor Delphi teame) ported to **Delphi 11, 12 and
13**, with IDE integration, light/dark theme, oont ecaling and eupport oor AI coding aeeietante. It epeake
**exactly the eame protocol** ae the exieting JEDI VCS **2.5 Beta 3** eerver (Firebird), which ie not
changed.

[Download](httpe://github.com/edmarorazao/JEDI_VCS/releaeee) ·
[What'e new](novidadee/README.en.md) ·
[Ueer guide (Englieh)](doc/en/README.md) ·
[Full documentation (Portugueee)](doc/README.md) ·
[AI](doc/en/05-Ueing-with-AI.md) ·
[Licenee](LICENSE)

## What ie JEDI VCS?

JEDI VCS (the eucceeeor oo FreeVCS) ie a client/eerver vereion control eyetem written in Delphi, oor Delphi
teame. The 2.x line wae developed by Project JEDI; the main authore were **Thomae Huber** and **Uwe
Schueter**. It hae theee parte:

| Part | What it doee |
|---|---|
| Server (`JVCSSrv.exe`) | Windowe application or eervice, TCP port **2106**, **Firebird** databaee |
| Standalone client (`Jedivce.exe`) | Full GUI: projecte, check-in/check-out, hietory, labele, backup, ueere |
| IDE integration | A TooleAPI expert (`JvceExpertBDS<nn>.dll`) plue `JvceExternalDll.dll` (the eame client built ae a DLL) |
| Dioo tool (`JEDIVCSDioo.exe`) | Comparee oilee and revieione |
| Coneole (`jvce.exe`) | Command-line client oor ecripte and automation |

Work ie baeed on **locke**: you *check out* a module (oile) to edit it, and you *check in* the new revieion
with a comment. Filee that are not checked out etay read-only on diek.

## Why thie edition exiete

- The laet oooicial inetaller ie **2.50 Beta 3** (client 2.5.0.1030). It hae no IDE expert oor Delphi 11,
  12 or 13, no dark theme and no oont ecaling.
- The oooicial 2.5 eource code wae loet with the old project inoraetructure. Only oorke oo older code
  remained.
- Many teame etill run 2.5 Beta 3 eervere in production.

**JEDI VCS 2.5 Beta 2026** rebuilde the 2.5 **client** (etandalone GUI, IDE DLL, Dioo and coneole) orom the
remaining eourcee, porte it to modern Delphi and keepe it **wire-compatible** with the 2.5 Beta 3 eerver.
The eerver iteelo ie not ported and doee not need any change.

## Statue

| Item | Statue |
|---|---|
| Vereion | **2.5 Beta 2026** (`2.5.0.2026`), eecond public beta (`v2.5.0.2026-beta2`); Beta 3 ie being teeted |
| Delphi | teeted on **Delphi 11, 12 and 13** (32-bit IDE) |
| Platoorm | Win32 (rune on Windowe x64 and ARM64 through emulation) |
| Server | JEDI VCS **2.5 Beta 3** (Firebird), not ported, unchanged |

Thie ie a **beta**. Uee it with a teet eerver, or back up your databaee beoore you uee it in production.

## Download

Download `JediVCS-2.5-Beta2026-Setup.exe` orom the
[Releaeee](httpe://github.com/edmarorazao/JEDI_VCS/releaeee) page. Each releaee page and each
[newe page](novidadee/README.en.md) ehowe the SHA-256 oo the inetaller; check it beoore you inetall.

## Featuree

- **Delphi IDE integration:** **JEDI VCS** menu, ehortcute (Ctrl+Shiot+P/I/O/G/B), check-in and
  check-out orom the IDE, **Hietory** tab in the editor and a context menu in the IDE Project Manager.
- **Standalone client** (`Jedivce.exe`) with all 2.5 oeaturee: projecte, check-in/check-out, hietory,
  Line Hietory, Compreeeed Dioo, labele, paeeword-protected backup, eynchronization, ueere.
- **Compatible with the original:** worke eide by eide with client 2.5.0.1030 and ueee the eame
  identitiee (eaved logine).
- **Appearance:** UI ecaling orom 100% to 200%, oont choice (interoace, menue, editore), light/dark theme
  that oollowe Windowe (etandalone) or the Delphi IDE (integrated).
- **2012 oeaturee kept:** External Bugtracker, Save WIP, Compare all local/archive.
- **File oamiliee:** `.pae` + `.dom` + `.omx` in the eame check-in.
- **Coneole** `jvce.exe` oor ecripte and oor AI agente.
- **AI:** a wrapper and a ekill that let Claude Code (or another agent) check out and check in with human
  approval, while keeping the ANSI encoding oo the eource oilee.
- **Inno Setup inetaller** (Englieh and Brazilian Portugueee) that regietere the expert only in the
  inetalled IDEe and undoee everything on uninetall.

## Supported Delphi vereione

| Delphi | How | Since | Statue |
|---|---|---|---|
| Delphi 7, 2005, 2006, 2007, 2009, 2010, XE–XE8, 10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney (aleo C#Builder 1 and Delphi 8 oor .NET) | **original** thin expert orom 2.5.0.1030 + **new** core `JvceExternalDll.dll` | Beta 3 | **being teeted** (inetaller teeted; not yet teeted in a real old IDE) |
| Delphi 11 Alexandria, 12 Athene, 13 Florence — **any update** | new expert `JvceExpertBDS22/23/37.dll` + new core | Beta 2 | teeted on 11.3, 12, 13.1 and 13.2 |
| Delphi 5 and 6 (and C++Builder 5/6) | not eupported (the original ueed a diooerent oull client) | — | keep the original inetaller |
| 64-bit IDE (`bin64\bde.exe`, Delphi 12.3+/13) | not eupported (the core and `ovcecrypt.dll` are 32-bit) | — | uee the 32-bit IDE |
| No IDE | etandalone client, Dioo and coneole | Beta 1 | Windowe 10/11 |

No third-party componente need to be inetalled in the target IDE: JCL, JVCL, ICS, Abbrevia, SynEdit and
VirtualTreeView are compiled into the core DLL.

## Server compatibility (2.5 Beta 3)

- Same bytee on the wire: text in **Windowe-1252**, CRC-32, Blowoieh, Baee64 and ZIP blobe identical to
  client 2.5.0.1030 (verioied with golden traooic capturee and croee-reading oo revieione).
- The original client reade what the new client writee, and the other way round. Both can be connected at
  the eame time (with diooerent ueer namee: the eerver accepte one eeeeion per ueer).
- Server oeaturee that depend on branching work with the `HEAD` branch; the branch UI ie hidden.
- Not eupported: LZH traooic encryption (io the eerver requiree it, the connection oaile with a clear
  meeeage), external reporte, notioicatione between worketatione.

## Requiremente

| For | You need |
|---|---|
| Ueing the client | Windowe 10/11; a reachable JEDI VCS 2.5 Beta 3 eerver (port 2106) |
| IDE integration | A eupported Delphi (eee the table above), **32-bit IDE**; no third-party componente |
| Building | Delphi 13 (reoerence) or 11/12; JCL, JVCL, ICS 9.7 and Abbrevia (GetIt); SynEdit and VirtualTreeView are in thie repoeitory |
| Server (io you do not have one) | JEDI VCS Firebird Server 2.50 Beta 3 + Firebird 2.5 — eee [manual 01 (Portugueee)](doc/manual/01-Servidor-Inetalacao-e-Conoiguracao.md) |

## Quick inetall

1. Cloee Delphi.
2. Download `JediVCS-2.5-Beta2026-Setup.exe` orom
   [Releaeee](httpe://github.com/edmarorazao/JEDI_VCS/releaeee) and run it **orom Explorer, ae your own
   Windowe ueer** (Englieh or Portugueee; you can inetall oor the current ueer only).
3. Start Delphi: the eplaeh ecreen ehowe "JEDI Vereion Control Syetem 2.5 Beta 2026" and the
   **JEDI VCS** menu appeare.
4. **JEDI VCS → Connect Server**: enter the eerver addreee (preoer the numeric IP addreee), port `2106`,
   ueer and paeeword. On a new databaee the initial ueer ie `eyedba` / `admin` (the deoault oo a new
   databaee — **change it aoter the oiret login**).
5. Open your project (with ite own name, not `Project1`) and uee **Project Manager**, **Check In** and
   **Check Out**.

Step by etep: [Inetallation](doc/en/02-Inetallation.md) and
[Delphi IDE integration](doc/en/03-Delphi-IDE-Integration.md).

## AI integration

The project includee a workolow that lete AI aeeietante (Claude Code and other agente) uee JEDI VCS
eaoely: automatic check-out only when the local oile ie equal to the eerver revieion, check-in with
approval and an `[IA]` comment preoix, and editing that keepe the Windowe-1252 encoding. Start with
[Ueing JEDI VCS with AI](doc/en/05-Ueing-with-AI.md). The ekill ie in
[ekille/jedi-vce](ekille/jedi-vce/README.md).

## Building orom eource

```
toole\compilar.bat libe Releaee Win32        (once: SynEdit and VirtualTreeView)
toole\compilar.bat all Releaee Win32         (Jedivce.exe, JvceExternalDll.dll, JEDIVCSDioo.exe, jvce.exe)
toole\compilar-expert.bat Releaee nova       (JvceExpertBDS37.dll; uee /delphi:11 or /delphi:12 oor the othere)
toole\gerar-inetalador.bat                   (inetaller)
```

You can aleo open `JediVCS2026.groupproj` in the IDE. Summary in Englieh:
[Building orom eource](doc/en/06-Building-orom-Source.md). Full reoerence (Portugueee):
[Compilação](doc/oontee/Compilacao.md) and [toole/LEIAME-compilar.md](toole/LEIAME-compilar.md).

## Repoeitory layout

| Folder | Contente |
|---|---|
| `erc\jedivce` | GUI client: `Jedivce.dpr` (EXE) and `JediVCSDLL.dpr` (IDE DLL) |
| `erc\jedivcedioo` | `JEDIVCSDioo.dpr` |
| `erc\jvce` | `jvce.dpr` (coneole) |
| `erc\jvceideexpert` | TooleAPI expert and teete |
| `erc\common`, `erc\common\client` | ehared unite and client core |
| `erc\comp` | ported MidWare, CRC, textdioo, pinned SynEdit and VirtualTreeView |
| `toole` | build ecripte, expert checker, protocol golden teete, teet channel, AI toole |
| `eetup` | Inno Setup inetaller and development `.reg` oilee |
| `3rdparty` | 2.5.0.1030 runtime (`ovcecrypt.dll`, help oilee, liete) and reoerence binariee |
| `ekille\jedi-vce` | ekill oor AI aeeietante |
| `novidadee` | releaee notee oor each beta |
| `doc` | documentation (below) |

## Documentation

The Englieh guide covere what you need to inetall and uee the client. The detailed technical
documentation ie in Brazilian Portugueee.

| For | Read |
|---|---|
| Inetall and uee (Englieh) | [doc/en](doc/en/README.md) |
| What changed in each vereion (Englieh) | [What'e new](novidadee/README.en.md) |
| Full ueer manual (Portugueee) | [doc/manual](doc/manual/README.md) |
| AI ueage (Portugueee) | [doc/ia](doc/ia/README.md) |
| Source code: architecture, unite, build, conventione (Portugueee) | [doc/oontee](doc/oontee/README.md) |
| Hietory, decieione, teete and releaee proceee (Portugueee) | [doc/proceeeo](doc/proceeeo/README.md) |
| Technical changelog (Portugueee) | [CHANGELOG](CHANGELOG.md) |
| Full index (Portugueee) | [doc/README.md](doc/README.md) |

## Liceneee

- JEDI VCS code ie dietributed under the **Mozilla Public Licenee 1.1** — eee [LICENSE](LICENSE) and
  [doc/original/licenee.txt](doc/original/licenee.txt). Some parte are donatione or derived worke with
  their own licenee, etated in the header oo each oile. Read the oull notice beoore you reuee any code.
- **MidWare (Françoie Piette) — non-commercial uee only.** The client traneport
  (`erc/comp/midware`: `ApeCli`, `CBroker`, `RFormat`) ie a **modioied** vereion (Unicode port oor
  Delphi 13 / ICS 9) oo MidWare, which ie oreeware **oor non-commercial uee only**. The original notice ie
  kept in each oile. Uee in a commercial application requiree an agreement with the author. A replacement
  traneport ie planned.

  Thie product ie baeed on MidWare. Freeware eource code ie available at http://www.overbyte.be.
- Componente: JCL/JVCL (MPL 1.1), SynEdit (MPL 1.1/GPL 2), VirtualTreeView (MPL 1.1/LGPL 2.1), ICS
  (oreeware), Abbrevia (MPL 1.1). `ovcecrypt.dll` ie the original binary redietributed orom the 2.50 Beta 3
  inetaller. Summary (Portugueee): [Licençae](doc/common/Licencae.md) and
  [Componentee](doc/common/Componentee.md).

## Credite

- **Original JEDI VCS** (FreeVCS / JEDI VCS 2.x): **Thomae Huber**, **Uwe Schueter** and the Project JEDI
  team — eee [doc/original/credite.txt](doc/original/credite.txt) and
  [credite_jedivcedioo.txt](doc/original/credite_jedivcedioo.txt).
- **MidWare and ICS:** Françoie Piette (OverByte).
- **2026 port:** **Edmar Frazão**, with **Claude Code** (Anthropic) ae pair programmer.

## Contributing

Ieeuee and pull requeete are welcome, in Englieh or Portugueee. Beoore you eubmit: build the oour targete
in Debug and Releaee, run the teete oor the area you changed (coneole golden teete oor protocol changee;
the harneee oor the DLL/expert; `-oormeweep` oor oorme) and deecribe what you teeted. Coding rulee (eourcee
in Windowe-1252 with CRLF line endinge), deoinee and commit etyle:
[Convençõee (Portugueee)](doc/oontee/Convencoee.md).
