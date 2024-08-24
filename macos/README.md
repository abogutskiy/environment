It is a good idea to configure os X before installing scripts and configs from
the repository. This paper includes different tips for os X Catalina.

## Configure TrackPad (touchpad)
First of all, it's a good idea, to configure tap to click, double-tap, zooming,
scrolling and switching between screens. You can configure all this things
in ***System Preferences -> Trackpad***

Another usefull thing is draging with 3 fingers. You can enable it in ***System
Preferences -> Accessebility -> Pointer Contoll (mouse/trackpad icon on the
left menu) -> Trackpad Options***

## Configure Dock and menu panels
There is only one problem with doc – sometimes closed apps stay in dock.
You can disable this option in ***System Preferences -> Dock -> Show recent
applications in dock***. It's not obvious how you can configure the menu panel. The
simple answer is – You can't. To remove the app from the menu pane – you should go to
this app's settings, and maybe there will be an option.

## Ports or brew
One of the most important points in this list. There is no default package
manager in os X, but there are two great open-source alternatives: [brew](https://brew.sh/)
и [ports](https://www.macports.org/). To Install both of them you need to
install XCode, but there are good official tutorials for both managers.

`NB: my personal choise is brew`



## Hammerspoon
Hammerspoon is a powerful automation tool for mac os. It's a good tool to
operate with windows, screens, hotkeys for anything, etc.

To install and prepare hammerspoon on you machine (mac)
- [Download](https://github.com/Hammerspoon/hammerspoon/releases/tag/0.9.78)
  and move it to application folder.
- run ```sudo ./install.py --configure hammerspoon``` or copy hammerspon files to
  home folder ```cp -r environment/hammerspoon ~/.hammerspoon```

## List of must-have applications
* [VLC](https://www.videolan.org/vlc/index.ru.html)
* [Gimp](https://www.gimp.org/downloads/)
* [Sublime](https://www.sublimetext.com/)

## Configure terminal
The default terminal in os X is awful. It is a good idea to use [ITerm2](https://www.iterm2.com/downloads.html) instead.
But even after installing iterm2 there is room for improvement. First of all,
it's a good idea to [configure](https://dev.to/clairecodes/making-the-alt-key-work-in-iterm2-1aa9) alt key behavior.
Sometime's there is a problem with loading bashrc/profile files in iterm, the
quick and stupid solution is to run source ~/.bashrc on term start. You can set
this command via ***Preferences -> Profile -> General -> Send Text as Start***.

Also, the default shell since Catalina is zsh, but os X doesn't set it as
default for new accounts, so to set zsh run ``chsh -s /bin/zsh``.

If you use zsh as your default shell, you might like the open-source [Oh My Zsh](https://ohmyz.sh) framework for zsh
configuration (.zshrc script from this repo uses it as well).

## Other things to do
Don't forget to move keys, and .ssh/config file and start the ssh agent.

