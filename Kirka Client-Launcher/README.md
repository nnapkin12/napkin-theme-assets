<p align="center">
  <img src="../misc/NapIcon.png" alt="NAP Client" width="96">
</p>

# NAP Client + Launcher

Unofficial [kirka.io](https://kirka.io) desktop client (Electron) with a separate launcher.

> [!NOTE]
> Not affiliated with kirka.io in any way. This client just opens the game kirka.io in a modified chromium window.

**Linux:** Client **1.7.3** · Launcher **1.1.3**  
**Windows:** same client, a buggy WPF launcher.

User data lives in **`Documents/NAP Client/`** (config, themes, scripts, swaps, clips).

AppImages are too large for the git repo (GitHub’s limit is 100 MB). Download them from **[Releases](https://github.com/nnapkin12/napkin-theme-assets/releases)**.

---

## Credits

[kirka.io](https://kirka.io)  
Inspired by **Coke / Juice Client**, **Dawn Client**, and **BKC**.

- Kirka Badges: [OBS-Akuma/KirkaBadges](https://github.com/OBS-Akuma/KirkaBadges)
- Player counts: [kirka.lukeskywalk.com](https://kirka.lukeskywalk.com/api.html)

## Features

- **Launcher** — live player counts, performance toggles, folder shortcuts, and Launch into Kirka
- **Unlimited FPS / In-Process GPU** — Chromium flags, control from the launcher. On Linux, Electron 10 cannot cap FPS to the monitor without freezing the picture, so the client stays uncapped
- **Custom resolution** — width/height instead of native display size (stretched res without stretching the whole desktop)
- **Right Shift menu** — in-game panel for themes, scripts, sounds, weapon skins, media, and more
- **Weapon / texture swap** — swap any skin you own (including defaults) using a [Kirka skin database](https://github.com/nnapkin12/napkin-theme-assets/blob/main/misc/skins.json) (updated sept 2026). Client-side only
- **Sound swap** — drop in an mp3 for any swappable sound; volume slider included (re-encoding the same file over and over can hurt quality)
- **Custom CSS** — community themes in a dropdown, plus a Quick CSS editor
- **User scripts** — JS in `Documents/NAP Client/scripts` is preloaded
- **Kill icon & hitmarkers** — override with a URL or local image, and scale them
- **Hide game chat** — toggle chat visibility

---

## Linux (AppImages)

Download **NAP Client-1.7.3.AppImage** and **NAP Launcher-1.1.3.AppImage** from [Releases](https://github.com/nnapkin12/napkin-theme-assets/releases), then:

```bash
chmod +x "NAP Client-1.7.3.AppImage" "NAP Launcher-1.1.3.AppImage"
mkdir -p ~/.local/bin
cp "NAP Client-1.7.3.AppImage" ~/.local/bin/nap-client.AppImage
chmod +x ~/.local/bin/nap-client.AppImage
./"NAP Launcher-1.1.3.AppImage"
```

The launcher looks for the client at `~/.local/bin/nap-client` or `~/.local/bin/nap-client.AppImage`.
