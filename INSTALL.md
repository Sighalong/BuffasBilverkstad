# Install guide: play Mulle Meck bygger bilar on a modern Mac

This guide is for people who just want to play. You don't need to know anything about programming,
and you don't need to type commands (except in one optional fix in *Something went wrong?*).

It takes about 10 minutes.

## What you need

- **A Mac with Apple Silicon** (M1, M2, M3, M4 or later). Not sure? Click the Apple menu → *About This Mac*.
  If it says *Chip: Apple M…*, you're good.
- **Your own copy of the game** *Mulle Meck bygger bilar* (Swedish, 1997), as the original CD or as a disc image
  file (`.iso`). The game itself is **not** included in this download.
- On an older Intel Mac, Windows or Linux there is no ready-made download yet. See the
  [README](README.md#2-get-the-engine) for how to build it yourself.

## Step 1: Download Buffas Bilverkstad

1. Open the [Releases page](https://github.com/Sighalong/BuffasBilverkstad/releases/latest).
2. Under **Assets**, click the file that ends in **`-macOS-arm64.zip`**.
   (You don't need the `.sha256` file or the "Source code" files.)
3. Open your **Downloads** folder. If you see a `.zip` file, double-click it to unpack it.
   You now have a folder called `BuffasBilverkstad-…-macOS-arm64`.
4. Drag that folder to somewhere you'll find it again, for example your **Documents** folder.

Inside the folder is **Buffas Bilverkstad.app**. That's the program that runs the game.

## Step 2: Copy the game from the CD

The game files only need to be copied once. After that, you can put the CD away.

1. **Insert the CD**, or **double-click the `.iso` file**. A disc icon appears on your desktop or in the
   Finder sidebar under *Locations*. Open it.
2. In your Documents folder, make a new folder called **`Mulle game`**
   (right-click an empty spot → *New Folder*).
3. From the disc, drag these three folders into `Mulle game`:
   - **DATA**
   - **MOVIES**
   - **XTRAS**

   This can take a minute.
4. One extra step the game needs: open `Mulle game` → **DATA**, find the file **`FILEIO.X32`**, and copy it into
   `Mulle game` → **XTRAS** as well. (Hold the **Option ⌥** key while dragging to copy it instead of moving it.)
5. Eject the disc (click the ⏏ button next to it in the Finder sidebar).

Your `Mulle game` folder should now look like this:

```
Mulle game
├── DATA      (lots of files, including FILEIO.X32)
├── MOVIES
└── XTRAS     (also contains a copy of FILEIO.X32)
```

## Step 3: Open the app the first time

The app is free and open source, but it isn't registered with Apple, so macOS is careful the first time you open it.

1. Double-click **Buffas Bilverkstad.app**. macOS will most likely say it *can't be opened* or *can't be verified*.
   Click **Done** or **OK** (not *Move to Bin*).
2. Open the **Apple menu → System Settings → Privacy & Security**.
3. Scroll down. You'll see a line about *Buffas Bilverkstad* being blocked. Click **Open Anyway**,
   and confirm with your password or Touch ID if asked.
4. The app opens. You only need to do this once.

(On some older macOS versions you can instead right-click the app → *Open* → *Open*.)

## Step 4: Add the game

The app shows a window with an empty game list.

1. Click **Add Game…**.
2. Select your **`Mulle game`** folder (the one that has DATA, MOVIES and XTRAS inside) and click **Choose**.
3. The app recognises *Mulle Meck bygger bilar*. If it shows a message that the game isn't fully supported,
   click to continue anyway. Then click **OK** on the settings window that appears. You don't need to change anything.

The game is now in the list. You only do this once.

## Step 5: Play!

Select the game in the list and click **Start**. Have fun building cars with Mulle!

Next time, just open **Buffas Bilverkstad.app**, pick the game, and click **Start**.

- The screen can be **white for a few seconds** before the game starts. That's normal.
- **To quit**, close the game window. Mulle remembers your cars and your progress.
  If a scene is playing, the game may ask whether you really want to quit. Answer yes.
- **Settings** (sound volume, full screen and more) are in the app's game list: select the game
  and click **Game Options…**.

## Something went wrong?

| Problem | What to do |
|---|---|
| macOS says the app **"is damaged and can't be opened"** | This is the same safety check as in Step 3, in a stricter form. Open **Terminal** (in Applications → Utilities), type `xattr -dr com.apple.quarantine ` (with a space at the end), drag **Buffas Bilverkstad.app** into the Terminal window, press **Return**, then open the app again. |
| **Add Game…** says *no game found* | You probably selected the wrong folder. Select the `Mulle game` folder itself, not DATA or a folder above it. Check that DATA, MOVIES and XTRAS are all inside. |
| The game starts but **gets stuck at the beginning**, or names aren't remembered | Check that `FILEIO.X32` is in the XTRAS folder (Step 2, point 4). |
| Some **conversations end too early**, or a high-score name doesn't show | These are known issues in this early version. See [Status and known issues](README.md#status-and-known-issues). |
| **Printing the diploma** does nothing | Printing isn't supported yet. |

Found another problem? You can report it on the
[Issues page](https://github.com/Sighalong/BuffasBilverkstad/issues). Please tell us what you did just before it happened.

## Removing it

Drag the `BuffasBilverkstad-…` folder and your `Mulle game` folder to the Bin.
Settings are stored in your home folder under **Library → Preferences → Buffas Bilverkstad Preferences**.
You can delete that file too.
