# Install guide: play Mulle Meck bygger bilar on a modern computer

This guide is for people who just want to play. Pick your computer:

- [**Mac**](#mac): ready-made download, about 10 minutes, no typing needed.
- [**Windows**](#windows): you build the program yourself by pasting a few commands. About 30–60 minutes, mostly waiting.
- [**Linux**](#linux): you build the program yourself with a few commands. About 15–30 minutes, mostly waiting.

## What everyone needs

- **Your own copy of the game** *Mulle Meck bygger bilar* (Swedish, 1997), as the original CD or as a disc image
  file (`.iso`). The game itself is **not** included in any download here.
- About 1 GB of free disk space (2 GB on Windows, for the build tools).

---

## Mac

You need **a Mac with Apple Silicon** (M1, M2, M3, M4 or later). Not sure? Click the Apple menu → *About This Mac*.
If it says *Chip: Apple M…*, you're good. On an older Intel Mac there's no ready-made download yet; follow
*Build it yourself* in the [README](README.md#building-from-source) instead.

### Mac step 1: Download Buffas Bilverkstad

1. Open the [Releases page](https://github.com/Sighalong/BuffasBilverkstad/releases/latest).
2. Under **Assets**, click the file that ends in **`-macOS-arm64.zip`**.
   (You don't need the `.sha256` file or the "Source code" files.)
3. Open your **Downloads** folder. If you see a `.zip` file, double-click it to unpack it.
   You now have a folder called `BuffasBilverkstad-…-macOS-arm64`.
4. Drag that folder to somewhere you'll find it again, for example your **Documents** folder.

Inside the folder is **Buffas Bilverkstad.app**. That's the program that runs the game.

### Mac step 2: Copy the game from the CD

The game files only need to be copied once. After that, you can put the CD away.

1. **Insert the CD**, or **double-click the `.iso` file**. A disc icon appears on your desktop or in the
   Finder sidebar under *Locations*. Open it.
2. In your Documents folder, make a new folder called **`Mulle game`**
   (right-click an empty spot → *New Folder*).
3. From the disc, drag the folders **DATA**, **MOVIES** and **XTRAS** into `Mulle game`. This can take a minute.
4. One extra step the game needs: open `Mulle game` → **DATA**, find the file **`FILEIO.X32`**, and copy it into
   `Mulle game` → **XTRAS** as well. (Hold the **Option ⌥** key while dragging to copy it instead of moving it.)
5. Eject the disc (click the ⏏ button next to it in the Finder sidebar).

Your `Mulle game` folder should now look like [this](#the-game-folder).

### Mac step 3: Open the app the first time

The app is free and open source, but it isn't registered with Apple, so macOS is careful the first time you open it.

1. Double-click **Buffas Bilverkstad.app**. macOS will most likely say it *can't be opened* or *can't be verified*.
   Click **Done** or **OK** (not *Move to Bin*).
2. Open the **Apple menu → System Settings → Privacy & Security**.
3. Scroll down. You'll see a line about *Buffas Bilverkstad* being blocked. Click **Open Anyway**,
   and confirm with your password or Touch ID if asked.
4. The app opens. You only need to do this once.

(On some older macOS versions you can instead right-click the app → *Open* → *Open*.)

If macOS says the app **"is damaged and can't be opened"**: open **Terminal** (Applications → Utilities), type
`xattr -dr com.apple.quarantine ` (with a space at the end), drag **Buffas Bilverkstad.app** into the Terminal
window, press **Return**, then open the app again.

Then continue with [Add the game and play](#add-the-game-and-play).

---

## Windows

There's no ready-made Windows download yet, so you build the program yourself with a free tool called **MSYS2**.
You'll copy and paste a few commands; you don't need to understand them. The Windows build has not been tested
much yet, so if something goes wrong, please [tell us](#something-went-wrong).

### Windows step 1: Copy the game from the CD

1. **Insert the CD**, or right-click the `.iso` file → **Mount**. It shows up in File Explorer as a new drive
   (for example `D:`).
2. Make a new folder **`C:\Mulle\game`** (in File Explorer: open `C:`, right-click → *New* → *Folder*,
   name it `Mulle`; inside it make another folder called `game`).
3. From the disc, copy the folders **DATA**, **MOVIES** and **XTRAS** into `C:\Mulle\game`.
4. Open `C:\Mulle\game\DATA`, copy the file **`FILEIO.X32`** (right-click → *Copy*), open `C:\Mulle\game\XTRAS`
   and paste it there too.
5. Eject the disc (right-click the drive → *Eject*).

Your game folder should now look like [this](#the-game-folder).

### Windows step 2: Install MSYS2

1. Go to [msys2.org](https://www.msys2.org), download the installer (`msys2-x86_64-….exe`) and run it.
   Keep the suggested folder `C:\msys64`.
2. When it's done, open the Start menu and start **MSYS2 MINGW64** (the one with *MINGW64* in the name,
   with a blue icon). A black text window opens. All commands below go into this window.
   To paste in it, right-click → *Paste* (Ctrl+V doesn't work there).
3. Paste this line and press **Enter**. When it asks *Proceed with installation? [Y/n]*, press **Enter** again.
   ```bash
   pacman -S --needed base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-SDL2 curl unzip
   ```
   This downloads the build tools and takes a few minutes.

### Windows step 3: Build Buffas Bilverkstad

Still in the **MSYS2 MINGW64** window, paste these lines one at a time, pressing **Enter** after each:

```bash
cd /c/Mulle
```
```bash
curl -L -o buffas.zip https://github.com/Sighalong/BuffasBilverkstad/archive/refs/heads/main.zip && unzip -q buffas.zip
```
```bash
cd BuffasBilverkstad-main && bash build.sh
```

The last one takes a long time (often 20–40 minutes) and prints a lot of text. That's normal.
It's done when the last line starts with **`Built`**. If it stops with a red `error` message instead,
see [Something went wrong?](#something-went-wrong).

### Windows step 4: Start it

The program has to be started from the **MSYS2 MINGW64** window. Every time you want to play:

1. Start **MSYS2 MINGW64** from the Start menu.
2. Paste this and press **Enter**:
   ```bash
   /c/Mulle/BuffasBilverkstad-main/build/scummvm-2026.4.0/scummvm.exe
   ```

The ScummVM window opens. When it asks you to pick your game folder, choose **`C:\Mulle\game`**.
Then continue with [Add the game and play](#add-the-game-and-play).

---

## Linux

There's no ready-made Linux download yet, so you build the program yourself. You'll copy and paste a few
commands into a terminal. The Linux build has not been tested much yet, so if something goes wrong, please
[tell us](#something-went-wrong).

### Linux step 1: Copy the game from the CD

1. **Insert the CD**, or open the `.iso` file with your file manager (on most desktops, double-clicking an `.iso`
   or right-clicking → *Open With Disk Image Mounter* shows its contents).
2. In your home folder, make a new folder called **`Mulle`**, and inside it a folder called **`game`**.
3. From the disc, copy the folders **DATA**, **MOVIES** and **XTRAS** into `Mulle/game`.
   (On some systems their names show in lower case, like `data`. That's fine.)
4. Open `Mulle/game/DATA`, copy the file **`FILEIO.X32`**, and paste it into `Mulle/game/XTRAS` too.
5. Eject the disc.

Your game folder should now look like [this](#the-game-folder).

### Linux step 2: Install the build tools

Open a **Terminal**. Paste the line for your system and press **Enter**. Type your password if asked.
(Nothing appears on screen while you type the password. That's normal.)

| Your system | Command |
|---|---|
| Ubuntu, Debian, Linux Mint, Pop!_OS | `sudo apt install build-essential libsdl2-dev curl unzip` |
| Fedora | `sudo dnf install gcc-c++ make patch SDL2-devel curl unzip` |
| Arch, Manjaro, SteamOS (desktop mode) | `sudo pacman -S --needed base-devel sdl2 curl unzip` |

### Linux step 3: Build Buffas Bilverkstad

In the same terminal, paste these lines one at a time, pressing **Enter** after each:

```bash
cd ~/Mulle
```
```bash
curl -L -o buffas.zip https://github.com/Sighalong/BuffasBilverkstad/archive/refs/heads/main.zip && unzip -q buffas.zip
```
```bash
cd BuffasBilverkstad-main && bash build.sh
```

The last one takes a while (often 10–20 minutes) and prints a lot of text. That's normal.
It's done when the last line starts with **`Built`**.

### Linux step 4: Play

Every time you want to play, open a terminal and paste:

```bash
bash ~/Mulle/BuffasBilverkstad-main/run.sh ~/Mulle/game
```

The game starts directly. Your saved progress is kept in `~/Mulle/BuffasBilverkstad-main/saves`.
You can skip *Add the game* below; read [Playing](#playing) for tips.

---

## Add the game and play

### Add the game (Mac and Windows, first time only)

The program shows a window with an empty game list.

1. Click **Add Game…**.
2. Select your game folder (`Mulle game` on Mac, `C:\Mulle\game` on Windows), the one with DATA, MOVIES and XTRAS
   inside, and confirm (**Choose** on Mac, **Choose** or **OK** on Windows).
3. The program recognises *Mulle Meck bygger bilar*. If it shows a message that the game isn't fully supported,
   continue anyway. Then click **OK** on the settings window that appears. You don't need to change anything.

The game is now in the list. You only do this once.

### Playing

Select the game in the list and click **Start**. Have fun building cars with Mulle!

Next time, just open the program (on Mac: **Buffas Bilverkstad.app**; on Windows: see
[Windows step 4](#windows-step-4-start-it)), pick the game, and click **Start**.

- The screen can be **white for a few seconds** before the game starts. That's normal.
- **To quit**, close the game window. Mulle remembers your cars and your progress.
  If a scene is playing, the game may ask whether you really want to quit. Answer yes.
- **Settings** (sound volume, full screen and more): select the game in the list and click **Game Options…**.

## The game folder

On every computer, your game folder should look like this:

```
game folder
├── DATA      (lots of files, including FILEIO.X32)
├── MOVIES
└── XTRAS     (also contains a copy of FILEIO.X32)
```

## Something went wrong?

| Problem | What to do |
|---|---|
| **Add Game…** says *no game found* | You probably selected the wrong folder. Select the game folder itself, not DATA or a folder above it. Check that DATA, MOVIES and XTRAS are all inside. |
| The game starts but **gets stuck at the beginning**, or names aren't remembered | Check that `FILEIO.X32` is in the XTRAS folder too (step 1 or 2, point 4). |
| Windows or Linux: the build stops with an **error** | Check that step 2 (installing the tools) finished without errors, then paste the `bash build.sh` line again. If it still fails, report it (below) and include the last 20 lines of text. |
| Windows: **`scummvm.exe` is missing a DLL** when started by double-clicking | Start it from the **MSYS2 MINGW64** window as in [Windows step 4](#windows-step-4-start-it). |
| Mac: the app **"is damaged"** or **can't be opened** | See [Mac step 3](#mac-step-3-open-the-app-the-first-time). |
| Some **conversations end too early**, or a high-score name doesn't show | These are known issues in this early version. See [Status and known issues](README.md#status-and-known-issues). |
| **Printing the diploma** does nothing | Printing isn't supported yet. |

Found another problem? Report it on the [Issues page](https://github.com/Sighalong/BuffasBilverkstad/issues).
Please say which computer you use and what you did just before it happened.

## Removing it

- **Mac:** drag the `BuffasBilverkstad-…` folder and your `Mulle game` folder to the Bin. Settings are stored in
  your home folder under **Library → Preferences → Buffas Bilverkstad Preferences**; you can delete that file too.
- **Windows:** delete the `C:\Mulle` folder. To remove the build tools as well, uninstall **MSYS2** in
  *Settings → Apps*.
- **Linux:** delete the `Mulle` folder in your home folder.
