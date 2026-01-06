# 𝕽𝖎𝖛𝖊𝖓𝖉𝖊𝖑𝖑

<img src="thumbnail.png" width="700">

Featuring two plugins I wrote (imgborders and ipc-closewindowv2).

Pretty much "everything" was written during the course of the competition. Tho I didn't have time to write the firmware, the bootloader, the kernel, the OS, the drivers, the filesystem, the shell, the coreutils, the terminal, the shell toolkit, and most other stuff. I'm also using hardware that someone else manufactured.

Many late nights and a lot of learning went into this. Hyprland-plugins was a really useful starting place for writing the plugins, and outfoxxed's Quickshell config was also a handy reference. Also thanks to the fellows in rice-discussion.

God bless you.

# Deps

- a cpu, gpu, motherboard, monitor, keyboard, probably a network adapter of some sort, etc.
- the LATEST version of hyprland-git
- hyprpolkitagent
- wireplumber, pipewire, pipewire-jack, pipewire-alsa, pipewire-pulse
- xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk
- zsh
- quickshell, qt6-5compat
- upower
- kitty
- ttf-bigblueterminal-nerd
- brightnessctl
- sox
- socat
- nvim
- grim
- hyprpicker
- mpd, mpd-mpris, mpc
- hypridle

## Plugins

Install and enable my plugins (see below).

```
hyprpm udpate

hyprpm add https://codeberg.org/zacoons/ipc-closewindowv2
hyprpm add https://codeberg.org/zacoons/imgborders

hyprpm enable ipc-closewindowv2
hyprpm enable imgborders
```

# Setup

Install the dependencies above.

Clone these dotfiles.

Go through all the config files and change `/home/tudor/thing` to `/home/yourhome/thing`.

Do `chsh -s /usr/bin/zsh $(whoami)`

Reboot.

# Attributions

Wallpaper: https://www.artstation.com/artwork/zOWqld\
Chest on lockscreen: https://franjatesa.itch.io/free-rpgmaker-chests\
I think everything else was drawn by me
