# Nightmare Ned on Batocera — Setup Guide

How to add **Nightmare Ned** (Disney Interactive, 1997) to a Batocera Linux box so that
selecting it from the menu boots straight into the game, fullscreen — using a **lean Windows 98
SE virtual machine** in the **86Box** emulator.

Nightmare Ned is a Windows 95/98 program that relies on the Intel RDX/DINO 3D middleware and
Smacker FMV; it will not run on a modern OS or under Wine. The reliable approach is full-machine
emulation of a period PC. This guide builds the smallest VM that still plays smoothly.

## You provide (not included here — copyright)

- A **Windows 98 SE** install CD image (`.iso`). Bring your own licensed copy.
- Your **Nightmare Ned** disc as a `.cue` + `.bin` pair (e.g. `Nightmare.Ned.cue` / `Nightmare.Ned.BIN`).
  - On Batocera's case-sensitive filesystem, make sure the `FILE "..."` line in the `.cue`
    matches the `.bin`'s exact case.
- A **Batocera** box with the **86Box** Flatpak installed (`net._86box._86Box` + its `.ROMs`
  companion, via the Batocera Content Downloader / `batocera-flatpak-update`).
- A **Win98 SE OEM product key**. A known-working one: `R3TQR-PQTKG-HBVQ9-YBFH3-CGCRT`
  (Win98 FE and retail keys are rejected by the SE OEM installer).

## The lean VM (what and why)

| Spec | Value | Why |
|---|---|---|
| Machine | ASUS P/I-P55T2P4 (Intel 430HX) | Stable, well-supported Win98-era board |
| CPU | Pentium P54C **133 MHz** | Above the game's 90 MHz min; smooth, period-correct |
| RAM | **64 MB** | Comfortable (game min is 16 MB); costs host RAM, not disk |
| Video | Cirrus Logic **GD5446** | Reliable Win98 driver; does 640×480×256 |
| Sound | Sound Blaster 16 | Game min requirement |
| Mouse | PS/2 | — |
| Disk | **700 MB** raw, `speed = ramdisk` | Only ~332 MB used (Win98 Compact + game); rest is swap headroom |
| Display | **640×480, 256 colors** | The mode the game's manual requires |

Copy the ready-made [`vm/86box.cfg`](vm/86box.cfg) and [`vm/86Box.sh`](vm/86Box.sh) from this repo.

---

## Steps

### 1. Create the VM

On the box, in the 86Box **Virtual Machines** directory
(`.../data/.var/app/net._86box._86Box/data/86Box/Virtual Machines/`):

```sh
mkdir -p "Nightmare Ned" && cd "Nightmare Ned"
# 700 MB disk matching the CHS geometry in the config:
sh /path/to/vm/create-disk.sh            # creates ./win98
cp /path/to/vm/86box.cfg ./86box.cfg     # then edit cdrom_01_image_path to your game .cue
```

For the **install only**, temporarily point the CD at your Win98 ISO — set
`cdrom_01_image_path` to the `.iso`. You'll switch it to the game `.cue` in step 5.

### 2. Install Windows 98 SE (minimal)

Launch the VM. The BIOS boot order is already `CDROM,C,A`.

1. At the **"Microsoft Windows 98 CD-ROM Startup Menu"**, choose **`2` — Boot from CD-ROM**.
   (It defaults to "Boot from Hard Disk", which on a blank disk just goes black.)
2. Setup runs. On the blank disk it offers **"Configure unallocated disk space"** → accept, and
   choose **"Yes, enable large disk support"** (FAT32 — smaller clusters). It reboots.
3. On reboot, at the CD menu pick **`1` — Boot from Hard Disk** to continue Setup. **From here on,
   always pick "1 — Boot from Hard Disk"** at that menu.
4. In the graphical Setup Wizard: keep **C:\WINDOWS**; choose **Compact** setup type (smallest);
   keep "Install the most common components"; enter a name; enter the **product key**.
5. Let it copy files and run hardware detection (a couple of auto-reboots — always "1 — Hard Disk").
6. At the login/password box, **leave it blank** (no password).

### 3. Fix the display size (important)

On this HiDPI laptop panel, 86Box's **HiDPI scaling** shrinks the render into a corner.
In 86Box: **View → uncheck "HiDPI scaling"** (equivalently `dpi_scale = 0` in the config — already
set in the repo's `86box.cfg`). Display should already be **640×480 / 256 Colors** (the Cirrus
driver defaults there); confirm via Display Properties → Settings.

### 4. Clean up first-boot nags

- Close the **"Welcome to Windows 98"** dialog; **uncheck** "Show this screen each time…".
- **Control Panel → Network → Primary Network Logon → "Windows Logon"** — so a blank password
  boots straight through with no prompt.

### 5. Install the game

Shut down Windows, change `cdrom_01_image_path` to your **Nightmare Ned `.cue`**, relaunch.
Because the game disc isn't bootable, it now boots **straight to the desktop, no CD menu**.
Open **My Computer → the CD-ROM drive** → the InstallShield installer runs → accept the
recommended install → **restart** when prompted (needed to activate DirectX/RDX/Smacker).

### 6. Auto-launch on boot

Copy the game's Start Menu shortcut into the StartUp folder so Windows launches it automatically:

- Right-click **Start → Open** → `Programs\Disney Interactive` → copy **Nightmare Ned** →
  paste into `Programs\StartUp`.
- (Equivalent DOS copy: `copy "C:\WINDOWS\Start Menu\Programs\Disney Interactive\Nightmare Ned.lnk" "C:\WINDOWS\Start Menu\Programs\StartUp"`)

### 7. Fullscreen + Batocera menu integration

- Fullscreen that fills the screen at 4:3: in `86box.cfg`, `start_in_fullscreen = 1` and
  **`video_fullscreen_scale = 1`** (both already in the repo config). Without the latter,
  fullscreen renders 1:1 in a corner.
  - **Gotcha:** 86Box *drops* `video_fullscreen_scale` when it rewrites the config on exit, so
    it reverts on the next cold boot. Lock it: after the config is final, make it read-only —
    `chmod 444 86box.cfg`. 86Box reads it fine on launch but can no longer overwrite it. (To
    change settings later, `chmod 644`, edit, then `chmod 444` again.)
- Make the Batocera menu entry launch the VM: install the patched [`vm/86Box.sh`](vm/86Box.sh)
  over the flatpak's `bin/86Box.sh` (keep a `.orig` backup). With no arguments (how Batocera
  launches it) it boots the "Nightmare Ned" VM fullscreen.
- For renaming the entry, art, video, and the custom "Windows 98" system, see [README.md](README.md).

## Result

Select **Nightmare Ned** in Batocera → the VM boots (no CD menu, no password) → the game
**auto-launches fullscreen**. ~700 MB on disk, ~332 MB actually used.

## Exiting the game

Both quit *all* of 86Box and return you to the Batocera menu (no need to shut Windows down —
it's a CD game that barely writes to disk):

- **Controller:** **Hotkey + Start** (on a DualSense, the **PS** button + **Options**) — Batocera's
  standard exit-game combo; runs `flatpak kill`.
- **Mouse/keyboard:** **middle-click** (or `Ctrl+End`) to release 86Box's mouse grab, then
  **`Alt+F4`** to quit. Instant, since `confirm_exit = 0` in `86box_global.cfg`.

## Gotchas (learned the hard way)

- **`.cue` case-sensitivity** on Linux — match the `.bin` filename case exactly.
- **CD-ROM Startup Menu** defaults to Hard Disk — pick CD-ROM (2) only to *start* the installer;
  Hard Disk (1) every time after.
- **HiDPI scaling** shrinks the render → `dpi_scale = 0`.
- **`video_fullscreen_scale = 1`** is required or fullscreen is a tiny 1:1 image in the corner —
  and 86Box drops it on exit, so `chmod 444` the config to lock it in.
- The bootable Win98 install CD keeps showing the boot menu; swapping to the (non-bootable)
  game `.cue` makes it boot straight to Windows.
