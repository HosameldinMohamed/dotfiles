# dotfiles
My dotfiles for some applications.

## Applications

1. Qtile.
2. Xdotool.
3. LazyGit.
4. Tmux.
5. Picom.

## Create symbolic links to the `.config` location

Run the following commands:

```sh
ln -s <repo-location>/dotfiles/qtile/ ~/.config/qtile
ln -s <repo-location>/dotfiles/fusuma/ ~/.config/fusuma # Xdotool
ln -s <repo-location>/dotfiles/lazygit/ ~/.config/lazygit
ln -s <repo-location>/dotfiles/tmux/ ~/.config/tmux
ln -s <repo-location>/dotfiles/picom/ ~/.config/picom
ln -s <repo-location>/dotfiles/hypr/ ~/.config/hypr
ln -s <repo-location>/dotfiles/waybar/ ~/.config/waybar
ln -s <repo-location>/dotfiles/eww/ ~/.config/eww
```

## Add the `bin` location to the `PATH`

```sh
export PATH=$PATH:<repo-location>/dotfiles/bin
```

## Repeat the step above also for Plasma

To the file `.config/plasma-workspace/env/path.sh`:

Add the following lines:

```sh
#!/bin/bash
export PATH=$PATH:"/home/$USER/.local/bin/"
export PATH=$PATH:"/home/$USER/code/dotfiles/bin/"
```

