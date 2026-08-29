<p align="center">
  <img src="art/XelaNotPu-LogoTransparent-GithubSocial.png" alt="ZN-2 MiSTer banner" width="220">
</p>

# ZN-2 for MiSTer — First Public Release (2026-08-28)

This is the **first public release** of the **ZN2-Capcom** core: an FPGA
re-implementation of Sony's second-generation PlayStation-based arcade board,
Capcom variant (`coh3002c`, QSound), for the
[MiSTer platform](https://github.com/MiSTer-devel/Main_MiSTer/wiki).

The ZN-2 is Sony's 1997 successor to the ZN-1: an R3000A-compatible MIPS CPU at
33.8688 MHz, a PSX-type GPU with **2 MB of VRAM** (double the retail console),
and ZN-specific hardware with no consumer-PlayStation equivalent — the
`coh3002c` arcade boot ROM in place of the PS1 kernel, large banked game ROM in
place of a CD drive, **CAT702** challenge/response security chips with per-game
keys, and Capcom's **QSound** sound board (Z80 + Lucent DL-1425 DSP + 4 MB of
PCM samples). The core is an independent re-implementation of that board built on
the **PSX_MiSTer** PlayStation core by Robert Peip (FPGAzumSpass).

> **Provenance note:** the shipped bitstream is tagged/dated `20260825`
> (`Arcade-ZN2Capcom_20260825.rbf`, md5 `ec5b86f2b05ec731462db1200993de76`); this
> README publishes it on **2026-08-28**. See `BUILD_INFO.txt` for full build
> provenance, timing, and verification, and `ZN2-Capcom/README.md` for the
> complete per-core documentation.

---

## Supported games

Complete MAME `coh3002c` catalog coverage — **11 titles across 28 sets** (one
primary MRA per title; other regions/revisions live in
`releases/_Arcade/_alternatives/_<Title>/`). Merged MAME romsets are supported:
clone sets load from the parent zip's subdirectories.

| Title (primary set) | State |
|---|---|
| Street Fighter EX2 (USA 980526) | Boots + plays; Japan clone-set load also verified |
| Street Fighter EX2 Plus (USA) | Boots + plays, user-played, full speed |
| Rival Schools: United By Fate (USA) | Boots to attract |
| Shiritsu Justice Gakuen (Japan 971216) | MRA CRC-verified (shares the Rival Schools engine) |
| Plasma Sword (USA) | Boots + plays |
| Star Gladiator 2 (Japan) | MRA CRC-verified (shares the Plasma Sword engine) |
| Strider 2 (USA) | Boots + plays, user-played |
| Strider Hiryu 2 (Japan) | MRA CRC-verified (shares the Strider 2 engine) |
| Tech Romancer (USA) | Boots to attract |
| Choukou Senki Kikaioh (Japan) | MRA CRC-verified (shares the Tech Romancer engine) |
| Tetris: The Grand Master (Japan) | Boots to attract demo |

All 8 parent titles are hardware-verified booting; SF EX2, SF EX2 Plus, Plasma
Sword, and Strider 2 have been played on real hardware.

## What this release supports

- **Video** — the full PSX-type GPU with the ZN-2's 2 MB VRAM. **FMV playback**
  works (the PSX MDEC movie decoder is implemented, so attract movies play).
  **480i interlaced modes are field-correct** — the GPU field-status bit games
  poll to pace per-field rendering is returned correctly through vblank, so
  interlaced titles (e.g. Rival Schools) no longer ghost, flash under Bob
  deinterlacing, or comb on static scenes.
- **Audio** — **QSound music and SFX both work.** The DL-1425 DSP microcode is
  loaded at runtime from your own `qsound_hle.zip` (no copyrighted firmware ships
  in the core). 
- **Game speed** — a coherent 128 KB data cache with full-line fill, plus a
  ZN-2-appropriate memory-pacing default, keep the catalog running at speed; the
  heaviest fighters (SF EX2 / EX2 Plus) play at full speed in normal play (see
  *Known limitations* for the worst-case caveat).
- **NVRAM saving** — game settings, rankings, and bookkeeping written to the
  mainboard EEPROM persist across core reloads (`config/nvram/<game>.nvm`).
- **Controls** — the Capcom CPS-style split panel: 3 punches on the P1 register +
  3 kicks on the kick harness. 6-button (SF EX2 / EX2 Plus) and 4-button
  (Plasma Sword, Tech Romancer, Rival Schools, Strider 2, Tetris TGM) layouts;
  per-game button labels come from each MRA.
- **CRT Adjust (analog)** — optional H-Size / H-Position / V-Shift for analog
  CRTs (OSD → Video & Audio; default Off).
- **DB9 / DB15 controllers (UserIO)** — native Mega Drive (DB9) and Neo-Geo-style
  (DB15) pads/sticks on the USER port for Antonio Villena-style DB9/SNAC8
  splitter hardware, OR-merged with USB input.
- **Merged romsets** and a MiSTer-standard pause overlay.

## Known limitations / not yet supported

Stated plainly so expectations are accurate:

- **CPU is not yet clocked at the true ZN-2 rate.** The real ZN-2 CPU has a
  ~1.48× larger execution budget than the ZN-1's. This release runs the CPU at
  the ZN-1 rate — a calibrated stand-in that reaches full speed in normal play — but the very
  heaviest SF EX2 Plus scenes can still dip (roughly 40 fps worst case). A true
  CPU-domain reclock is the planned follow-up; when it lands, base mode stays
  authentic to the board and the current pacing becomes an opt-in **Turbo**
  option. There is deliberately **no** slower-than-stock speed option.
- **SF EX2 Plus intro audio glitch.** A brief audio glitch occurs at the end of
  the intro, just after the spoken voice line. It is pre-existing and cosmetic —
  it does not affect gameplay — and is tracked for a later fix.
- **Saturn controllers via DB9-Pro are locked.** The Saturn pad path is part of
  the key-gated MiSTer-DB9-Pro program; this open-source build carries no key, so
  Saturn mode stays disabled. DB9 (Mega Drive) and DB15 (Neo Geo) work.
- **No ZN-2 boards other than the Capcom (`coh3002c`) variant** are covered — the
  ZN-2 was a Capcom-dominated platform, and this core targets that catalog.
- **No copyrighted data is included.** You must supply your own ROMs, the
  `coh3002c` boot ROM, and the QSound DL-1425 microcode (see *Requirements*).

## Requirements

- A MiSTer (DE10-Nano) setup.
- Your own legally-obtained **game romsets** (merged MAME sets recommended).
- The **`coh3002c` boot ROM** (loads at runtime; not included).
- **`qsound_hle.zip`** containing the DL-1425 microcode (`dl-1425.bin`), for
  QSound audio (loads at runtime; not included).

## Install

Copy the contents of `ZN2-Capcom/releases/_Arcade/` onto your SD card's
`_Arcade/` folder: this places the `.mra` files (and `_alternatives/`) directly
in `_Arcade/`, and `cores/Arcade-ZN2Capcom_20260825.rbf` in `_Arcade/cores/`.
Provide your own romsets as above. Core name **ZN2Capcom** — every MRA references
`<rbf>ZN2Capcom</rbf>`.

---

## Credits & attribution

This core stands on the work of others, gratefully acknowledged. Where a
component is used, its own authors and license govern that component.

- **PSX_MiSTer** by **Robert Peip (FPGAzumSpass)** — the PlayStation core this
  ZN-2 core derives from, providing the R3000A CPU, GPU, GTE, DMA, MDEC, SPU, and
  memory subsystem.
- **The MiSTer project** and its framework (`sys/`) — **Alexey Melnikov
  (Sorgelig)** and the MiSTer-devel contributors.
- **QSound DSP — JTDSP16** by **Jose Tejada (Jotego)**: `jtdsp16`
  (`rtl/sound/jt_qsound/`, GPLv3) is Jotego's implementation of the Lucent DSP16A
  at the heart of Capcom's DL-1425 QSound chip, originally developed for his
  CPS1.5/CPS2 cores and used here essentially intact. The ZN-2 work is the
  integration around it: runtime microcode loading (so no firmware ships in the
  bitstream), sample-ROM service through this core's shared multi-channel SDRAM
  controller with a latency-tolerant dual-clock fetch handshake, serial-DAC audio
  recovery, and clock-enable generation. Without JTDSP16 there would be no QSound
  music on this core.
- **Z80 (T80) CPU core** — **Daniel Wallner** and contributors, used for the
  QSound program CPU.
- **MiSTer-CRT-Adjust** — the core-side analog CRT geometry module
  (`crt_adjust.sv`).
- **MiSTer-DB9 / DB9-Pro** — DB9/DB15/Saturn splitter support for **Antonio
  Villena**'s DB9/SNAC8 splitter hardware; control modules by **Aitor Pelaez
  (NeuroRulez)**, based on work by **Victor Trucco** and **Fernando Mosquera**;
  Saturn protocol adaptation by **Timothy Redaelli**.
- **The MAME project** — used solely as hardware documentation and behavioral
  reference for developing the ZN-2 board support as an independent
  re-implementation. No MAME source code is included in this core.
- **ZN-2 board support & original chip re-implementations** — **XelaNotPu**:
  `coh3002c` boot integration, CAT702 security, 4-bit ROM banking, NVRAM/EEPROM,
  the QSound board wrapper and fetch/handshake work, the MDEC/480i and
  data-cache/pacing work, and the pause-overlay artwork and README banner.

## Legal & licensing

**No affiliation.** This project is unofficial and is not affiliated with,
endorsed by, or sponsored by Sony Interactive Entertainment, Capcom, Arika,
QSound Labs, or any other rights holder.

**Trademarks.** Sony, PlayStation, and ZN-2 are trademarks of Sony Interactive
Entertainment. QSound is a trademark of QSound Labs. Capcom, Street Fighter,
Rival Schools, Strider, Plasma Sword, Star Gladiator, Tech Romancer, and all
associated game titles, characters, and logos are trademarks or registered
trademarks of their respective owners (including Capcom Co., Ltd., Arika Co.,
Ltd., and The Tetris Company). Sega, Mega Drive, and Saturn are trademarks of
SEGA Corporation; Neo Geo is a trademark of SNK Corporation — referenced solely
to identify the third-party controllers the DB9/DB15 feature supports. All such
names are used in a purely nominative and descriptive manner, solely to identify
the hardware and games being re-implemented or referenced.

**No ROMs or copyrighted data.** This release contains and distributes **no**
copyrighted ROMs, BIOS images, game data, or manufacturer firmware. The bitstream
embeds no boot ROM, game ROMs, or QSound microcode; the `coh3002c` boot ROM and
the DL-1425 microcode load at runtime from files you supply, and on-board
EEPROM/FRAM initialise blank. MRA files reference romsets by name only. You must
supply your own legally-obtained ROM dumps, made from original hardware or media
you legally own, where and to the extent your local law permits.

**Security-chip emulation.** ZN-2 boards use CAT702 challenge/response security
chips. This core re-implements that algorithm for interoperability and
preservation, in the same manner as MAME and other preservation projects; no
manufacturer key material is embedded in the bitstream (per-game keys travel in
your MRA files). You are responsible for the legal status of security-chip
emulation in your jurisdiction, including any applicable anti-circumvention laws
(e.g., DMCA §1201 and its interoperability exemptions).

**Purpose.** This is a preservation and interoperability project. The hardware
behavior was re-implemented independently, using MAME purely as behavioral
reference documentation; no proprietary source code was used.

**User responsibility.** You are solely responsible for ensuring that your use of
this core — including the acquisition and use of any ROM images, boot ROMs, or
firmware — complies with copyright law and all other applicable laws in your
jurisdiction.

**No warranty.** This program is provided "AS IS", without warranty of any kind,
express or implied, including but not limited to the implied warranties of
merchantability and fitness for a particular purpose. The entire risk as to
quality and performance is with the user. No copyright holder or contributor
shall be liable for any damages arising from the use of this program.

**License.** The FPGA source is released under the **GNU General Public License,
version 3 or later** (see `LICENSE`, `COPYING.GPL2`, `COPYING.GPL3` at the core
root). The source tree mixes GPLv2-or-later and GPLv3-or-later files, so the
combined work and its synthesized bitstream are GPLv3-or-later; every file
remains available under the terms in its own header, and upstream components
(PSX_MiSTer, the MiSTer framework, jtdsp16, T80, MiSTer-CRT-Adjust,
MiSTer-DB9/DB9-Pro) retain their respective licenses.
