{ config, lib, pkgs, ... }:

let
  username = "dylan"; # Adjust this if necessary
in
{
  options.settings.plasma.extra = {
    enable = lib.mkEnableOption "Enable extra Plasma settings";
  };

  #FIXME:
  #tiling not work promerly it doenst auto tile
  # navigation shortcuts neither
  # move all the others shortcuts
  # theme ? 
  #
  config = lib.mkIf config.settings.plasma.extra.enable {
    home.packages = with pkgs; [
      libsForQt5.kconfig
      libsForQt5.kcmutils
      libsForQt5.krohnkite
        kde-cli-tools
  # Add oth
    ];
   programs.zsh.shellAliases = {
 kde = "kcmshell6 $(kcmshell6 --list | fzf | awk '{print $1}')";
   };
      programs.plasma = {
    enable = true;
    shortcuts = {
      "ActivityManager"."switch-to-activity-3c56a3a7-5462-4f27-becc-57201f64cbd1" = [ ];
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "\\, Meta+Alt+K,Meta+Alt+K,Passer à la disposition de clavier suivante";
      "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
      "kcm_touchpad"."Toggle Touchpad" = ["Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku,Touchpad Toggle,Basculer le pavé tactile"];
      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."decrease_volume_small" = "Shift+Volume Down";
      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."increase_volume_small" = "Shift+Volume Up";
      "kmix"."mic_mute" = ["Microphone Mute" "Meta+Volume Mute,Microphone Mute" "Meta+Volume Mute,Couper le son du microphone"];
      "kmix"."mute" = "Volume Mute";
      "ksmserver"."Halt Without Confirmation" = "none,,Éteindre sans confirmation";
      "ksmserver"."Lock Session" = ["Meta+L" "Screensaver,Meta+L" "Screensaver,Lock Session"];
      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
      "ksmserver"."Log Out Without Confirmation" = "none,,Se déconnecter sans confirmation";
      "ksmserver"."LogOut" = "none,,Se déconnecter";
      "ksmserver"."Reboot" = "none,,Redémarrer";
      "ksmserver"."Reboot Without Confirmation" = "none,,Redémarrer sans confirmation";
      "ksmserver"."Shut Down" = "none,,Éteindre";
      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "kwin"."Cycle Overview" = [ ];
      "kwin"."Cycle Overview Opposite" = [ ];
      "kwin"."Decrease Opacity" = "none,,Diminuer l'opacité de la fenêtre active de 5 %";
      "kwin"."Edit Tiles" = "Meta+T";
      "kwin"."Expose" = "Ctrl+F9";
      "kwin"."ExposeAll" = ["Ctrl+F10" "Launch (C),Ctrl+F10" "Launch (C),Naviguer entre les fenêtres présentes (Tous les bureaux)"];
      "kwin"."ExposeClass" = "Ctrl+F7";
      "kwin"."ExposeClassCurrentDesktop" = [ ];
      "kwin"."Grid View" = "Meta+G";
      "kwin"."Increase Opacity" = "none,,Augmenter l'opacité de la fenêtre active de 5 %";
      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
      "kwin"."KrohnkiteBTreeLayout" = [ ];
      "kwin"."KrohnkiteDecrease" = [ ];
      "kwin"."KrohnkiteFloatAll" = [ ];
      "kwin"."KrohnkiteFloatingLayout" = [ ];
      "kwin"."KrohnkiteFocusDown" = [ ];
      "kwin"."KrohnkiteFocusLeft" = [ ];
      "kwin"."KrohnkiteFocusNext" = [ ];
      "kwin"."KrohnkiteFocusRight" = [ ];
      "kwin"."KrohnkiteFocusUp" = [ ];
      "kwin"."KrohnkiteGrowHeight" = [ ];
      "kwin"."KrohnkiteIncrease" = [ ];
      "kwin"."KrohnkiteMonocleLayout" = [ ];
      "kwin"."KrohnkiteNextLayout" = [ ];
      "kwin"."KrohnkitePreviousLayout" = [ ];
      "kwin"."KrohnkiteQuarterLayout" = [ ];
      "kwin"."KrohnkiteRotate" = [ ];
      "kwin"."KrohnkiteRotatePart" = [ ];
      "kwin"."KrohnkiteSetMaster" = [ ];
      "kwin"."KrohnkiteShiftDown" = [ ];
      "kwin"."KrohnkiteShiftLeft" = [ ];
      "kwin"."KrohnkiteShiftRight" = [ ];
      "kwin"."KrohnkiteShiftUp" = [ ];
      "kwin"."KrohnkiteShrinkHeight" = [ ];
      "kwin"."KrohnkiteShrinkWidth" = [ ];
      "kwin"."KrohnkiteSpiralLayout" = [ ];
      "kwin"."KrohnkiteSpreadLayout" = [ ];
      "kwin"."KrohnkiteStackedLayout" = [ ];
      "kwin"."KrohnkiteStairLayout" = [ ];
      "kwin"."KrohnkiteTileLayout" = [ ];
      "kwin"."KrohnkiteToggleFloat" = [ ];
      "kwin"."KrohnkiteTreeColumnLayout" = [ ];
      "kwin"."KrohnkitegrowWidth" = [ ];
      "kwin"."MinimizeAll" = [ ];
      "kwin"."Move Tablet to Next Output" = [ ];
      "kwin"."MoveMouseToCenter" = "Meta+F6";
      "kwin"."MoveMouseToFocus" = "Meta+F5";
      "kwin"."MoveZoomDown" = [ ];
      "kwin"."MoveZoomLeft" = [ ];
      "kwin"."MoveZoomRight" = [ ];
      "kwin"."MoveZoomUp" = [ ];
      "kwin"."Overview" = "Meta+W";
      "kwin"."PoloniumCycleEngine" = [ ];
      "kwin"."PoloniumFocusAbove" = "Alt+K,none,Polonium: Focus Above";
      "kwin"."PoloniumFocusBelow" = "Alt+J,none,Polonium: Focus Below";
      "kwin"."PoloniumFocusLeft" = "Alt+H,none,Polonium: Focus Left";
      "kwin"."PoloniumFocusRight" = "Alt+L,none,Polonium: Focus Right";
      "kwin"."PoloniumInsertAbove" = [ ];
      "kwin"."PoloniumInsertBelow" = [ ];
      "kwin"."PoloniumInsertLeft" = [ ];
      "kwin"."PoloniumInsertRight" = [ ];
      "kwin"."PoloniumOpenSettings" = [ ];
      "kwin"."PoloniumResizeAbove" = [ ];
      "kwin"."PoloniumResizeBelow" = [ ];
      "kwin"."PoloniumResizeLeft" = [ ];
      "kwin"."PoloniumResizeRight" = [ ];
      "kwin"."PoloniumRetileWindow" = [ ];
      "kwin"."PoloniumSwitchBTree" = [ ];
      "kwin"."PoloniumSwitchHalf" = [ ];
      "kwin"."PoloniumSwitchKwin" = [ ];
      "kwin"."PoloniumSwitchMonocle" = [ ];
      "kwin"."PoloniumSwitchThreeColumn" = [ ];
      "kwin"."Setup Window Shortcut" = "none,,Raccourci de configuration pour une fenêtre";
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."Suspend Compositing" = "Alt+Shift+F12";
      "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
      "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
      "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
      "kwin"."Switch Window Down" = "Meta+Alt+Down";
      "kwin"."Switch Window Left" = "Meta+Alt+Left";
      "kwin"."Switch Window Right" = "Meta+Alt+Right";
      "kwin"."Switch Window Up" = "Meta+Alt+Up";
      "kwin"."Switch to Desktop 1" = "Alt+1,Ctrl+F1,Passer au bureau 1";
      "kwin"."Switch to Desktop 10" = "Alt+0,,Passer au bureau 10";
      "kwin"."Switch to Desktop 11" = "none,,Passer au bureau 11";
      "kwin"."Switch to Desktop 12" = "Alt+N,,Passer au bureau 12";
      "kwin"."Switch to Desktop 13" = "none,,Passer au bureau 13";
      "kwin"."Switch to Desktop 14" = "none,,Passer au bureau 14";
      "kwin"."Switch to Desktop 15" = "none,,Passer au bureau 15";
      "kwin"."Switch to Desktop 16" = "none,,Passer au bureau 16";
      "kwin"."Switch to Desktop 17" = "none,,Passer au bureau 17";
      "kwin"."Switch to Desktop 18" = "none,,Passer au bureau 18";
      "kwin"."Switch to Desktop 19" = "none,,Passer au bureau 19";
      "kwin"."Switch to Desktop 2" = "Alt+2,Ctrl+F2,Passer au bureau 2";
      "kwin"."Switch to Desktop 20" = "none,,Passer au bureau 20";
      "kwin"."Switch to Desktop 3" = "Alt+3,Ctrl+F3,Passer au bureau 3";
      "kwin"."Switch to Desktop 4" = "Alt+4,Ctrl+F4,Passer au bureau 4";
      "kwin"."Switch to Desktop 5" = "Alt+5,,Passer au bureau 5";
      "kwin"."Switch to Desktop 6" = "Alt+6,,Passer au bureau 6";
      "kwin"."Switch to Desktop 7" = "Alt+7,,Passer au bureau 7";
      "kwin"."Switch to Desktop 8" = "Alt+8,,Passer au bureau 8";
      "kwin"."Switch to Desktop 9" = "Alt+9,,Passer au bureau 9";
      "kwin"."Switch to Next Desktop" = "none,,Passer au bureau suivant";
      "kwin"."Switch to Next Screen" = "none,,Passer sur l'écran suivant";
      "kwin"."Switch to Previous Desktop" = "none,,Passer au bureau précédent";
      "kwin"."Switch to Previous Screen" = "none,,Passer sur l'écran précédent";
      "kwin"."Switch to Screen 0" = "none,,Passer sur l'écran 0";
      "kwin"."Switch to Screen 1" = "none,,Passer sur l'écran 1";
      "kwin"."Switch to Screen 2" = "none,,Passer sur l'écran 2";
      "kwin"."Switch to Screen 3" = "none,,Passer sur l'écran 3";
      "kwin"."Switch to Screen 4" = "none,,Passer sur l'écran 4";
      "kwin"."Switch to Screen 5" = "none,,Passer sur l'écran 5";
      "kwin"."Switch to Screen 6" = "none,,Passer sur l'écran 6";
      "kwin"."Switch to Screen 7" = "none,,Passer sur l'écran 7";
      "kwin"."Switch to Screen Above" = "none,,Basculer vers l'écran ci-dessus";
      "kwin"."Switch to Screen Below" = "none,,Basculer vers l'écran ci-dessous";
      "kwin"."Switch to Screen to the Left" = "none,,Basculer vers l'écran sur la gauche";
      "kwin"."Switch to Screen to the Right" = "none,,Basculer vers l'écran sur la droite";
      "kwin"."Toggle Night Color" = [ ];
      "kwin"."Toggle Window Raise/Lower" = "none,,Passer une fenêtre au-dessus / en dessous";
      "kwin"."Walk Through Windows" = "\\, Alt+Tab,Alt+Tab,Naviguer parmi les fenêtres";
      "kwin"."Walk Through Windows (Reverse)" = "\\, Alt+Shift+Tab,Alt+Shift+Tab,Naviguer parmi les fenêtres (en ordre inverse)";
      "kwin"."Walk Through Windows Alternative" = "none,,Naviguer parmi les alternatives de fenêtres";
      "kwin"."Walk Through Windows Alternative (Reverse)" = "none,,Naviguer parmi les alternatives de fenêtres (en ordre inverse)";
      "kwin"."Walk Through Windows of Current Application" = "\\, Alt+`,Alt+`,Naviguer parmi les fenêtres de l'application courante";
      "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
      "kwin"."Walk Through Windows of Current Application Alternative" = "none,,Naviguer parmi les fenêtres de l'application alternative courante";
      "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = "none,,Naviguer parmi les fenêtres de l'application alternative courante (en ordre inverse)";
      "kwin"."Window Above Other Windows" = "none,,Conserver une fenêtre au-dessus des autres";
      "kwin"."Window Below Other Windows" = "none,,Conserver une fenêtre au-dessous des autres";
      "kwin"."Window Close" = ["Alt+Shift+Q" "Alt+F4\\, Alt+F4,Alt+F4,Fermer une fenêtre"];
      "kwin"."Window Fullscreen" = "none,,Mettre une fenêtre en plein écran";
      "kwin"."Window Grow Horizontal" = "none,,Maximiser horizontalement une fenêtre";
      "kwin"."Window Grow Vertical" = "none,,Maximiser verticalement une fenêtre";
      "kwin"."Window Lower" = "none,,Enrouler une fenêtre";
      "kwin"."Window Maximize" = "Meta+PgUp";
      "kwin"."Window Maximize Horizontal" = "none,,Maximiser horizontalement une fenêtre";
      "kwin"."Window Maximize Vertical" = "none,,Maximiser verticalement une fenêtre";
      "kwin"."Window Minimize" = "Meta+PgDown";
      "kwin"."Window Move" = "none,,Déplacer une fenêtre";
      "kwin"."Window Move Center" = "none,,Déplacer la fenêtre au centre";
      "kwin"."Window No Border" = "none,,Afficher / Masquer la barre de titre et la bordure";
      "kwin"."Window On All Desktops" = "none,,Conserver une fenêtre sur tous les bureaux";
      "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      "kwin"."Window One Screen Down" = "none,,Déplacer une fenêtre d'un écran vers le bas";
      "kwin"."Window One Screen Up" = "none,,Déplacer une fenêtre d'un écran vers le haut";
      "kwin"."Window One Screen to the Left" = "none,,Déplacer une fenêtre d'un écran vers la gauche";
      "kwin"."Window One Screen to the Right" = "none,,Déplacer une fenêtre d'un écran vers la droite";
      "kwin"."Window Operations Menu" = "Alt+F3";
      "kwin"."Window Pack Down" = "none,,Déplacer une fenêtre vers le bas";
      "kwin"."Window Pack Left" = "none,,Déplacer une fenêtre vers la gauche";
      "kwin"."Window Pack Right" = "none,,Déplacer une fenêtre vers la droite";
      "kwin"."Window Pack Up" = "none,,Déplacer une fenêtre vers le haut";
      "kwin"."Window Quick Tile Bottom" = "Meta+Down";
      "kwin"."Window Quick Tile Bottom Left" = "none,,Mettre rapidement en mosaïque une fenêtre en bas et à gauche";
      "kwin"."Window Quick Tile Bottom Right" = "none,,Mettre rapidement en mosaïque une fenêtre en bas et à droite";
      "kwin"."Window Quick Tile Left" = "Meta+Left";
      "kwin"."Window Quick Tile Right" = "Meta+Right";
      "kwin"."Window Quick Tile Top" = "Meta+Up";
      "kwin"."Window Quick Tile Top Left" = "none,,Mettre rapidement en mosaïque une fenêtre en haut et à gauche";
      "kwin"."Window Quick Tile Top Right" = "none,,Mettre rapidement en mosaïque une fenêtre en haut et à droite";
      "kwin"."Window Raise" = "none,,Dérouler une fenêtre";
      "kwin"."Window Resize" = "none,,Redimensionner une fenêtre";
      "kwin"."Window Shade" = "none,,Enrouler une fenêtre";
      "kwin"."Window Shrink Horizontal" = "none,,Réduire horizontalement une fenêtre";
      "kwin"."Window Shrink Vertical" = "none,,Réduire verticalement une fenêtre";
      "kwin"."Window to Desktop 1" = "Alt+!,,Envoyer une fenêtre sur le bureau 1";
      "kwin"."Window to Desktop 10" = "Alt+),,Envoyer une fenêtre sur le bureau 10";
      "kwin"."Window to Desktop 11" = "none,,Envoyer une fenêtre sur le bureau 11";
      "kwin"."Window to Desktop 12" = "none,,Envoyer une fenêtre sur le bureau 12";
      "kwin"."Window to Desktop 13" = "none,,Envoyer une fenêtre sur le bureau 13";
      "kwin"."Window to Desktop 14" = "none,,Envoyer une fenêtre sur le bureau 14";
      "kwin"."Window to Desktop 15" = "none,,Envoyer une fenêtre sur le bureau 15";
      "kwin"."Window to Desktop 16" = "none,,Envoyer une fenêtre sur le bureau 16";
      "kwin"."Window to Desktop 17" = "none,,Envoyer une fenêtre sur le bureau 17";
      "kwin"."Window to Desktop 18" = "none,,Envoyer une fenêtre sur le bureau 18";
      "kwin"."Window to Desktop 19" = "none,,Envoyer une fenêtre sur le bureau 19";
      "kwin"."Window to Desktop 2" = "Alt+@,,Envoyer une fenêtre sur le bureau 2";
      "kwin"."Window to Desktop 20" = "none,,Envoyer une fenêtre sur le bureau 20";
      "kwin"."Window to Desktop 3" = "Alt+#,,Envoyer une fenêtre sur le bureau 3";
      "kwin"."Window to Desktop 4" = "Alt+$,,Envoyer une fenêtre sur le bureau 4";
      "kwin"."Window to Desktop 5" = "Alt+%,,Envoyer une fenêtre sur le bureau 5";
      "kwin"."Window to Desktop 6" = "Alt+^,,Envoyer une fenêtre sur le bureau 6";
      "kwin"."Window to Desktop 7" = "Alt+&,,Envoyer une fenêtre sur le bureau 7";
      "kwin"."Window to Desktop 8" = "Alt+*,,Envoyer une fenêtre sur le bureau 8";
      "kwin"."Window to Desktop 9" = "Alt+(,,Envoyer une fenêtre sur le bureau 9";
      "kwin"."Window to Next Desktop" = "none,,Envoyer une fenêtre sur le bureau suivant";
      "kwin"."Window to Next Screen" = "Meta+Shift+Right";
      "kwin"."Window to Previous Desktop" = "none,,Envoyer une fenêtre sur le bureau précédent";
      "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
      "kwin"."Window to Screen 0" = "none,,Déplacer une fenêtre sur l'écran 0";
      "kwin"."Window to Screen 1" = "none,,Déplacer une fenêtre sur l'écran 1";
      "kwin"."Window to Screen 2" = "none,,Déplacer une fenêtre sur l'écran 2";
      "kwin"."Window to Screen 3" = "none,,Déplacer une fenêtre sur l'écran 3";
      "kwin"."Window to Screen 4" = "none,,Déplacer une fenêtre sur l'écran 4";
      "kwin"."Window to Screen 5" = "none,,Déplacer une fenêtre sur l'écran 5";
      "kwin"."Window to Screen 6" = "none,,Déplacer une fenêtre sur l'écran 6";
      "kwin"."Window to Screen 7" = "none,,Déplacer une fenêtre sur l'écran 7";
      "kwin"."view_actual_size" = "none,Meta+0,Zoomer jusqu'à la taille actuelle";
      "kwin"."view_zoom_in" = ["Meta++" "Meta+=,Meta++" "Meta+=,Zoom avant"];
      "kwin"."view_zoom_out" = "Meta+-";
      "mediacontrol"."mediavolumedown" = "none,,Diminution du volume pour le média";
      "mediacontrol"."mediavolumeup" = "none,,Augmentation du volume pour le média";
      "mediacontrol"."nextmedia" = "Media Next";
      "mediacontrol"."pausemedia" = "Media Pause";
      "mediacontrol"."playmedia" = "none,,Démarrer la lecture du média";
      "mediacontrol"."playpausemedia" = "Media Play";
      "mediacontrol"."previousmedia" = "Media Previous";
      "mediacontrol"."stopmedia" = "Media Stop";
      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      "org_kde_powerdevil"."Hibernate" = "Hibernate";
      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      "org_kde_powerdevil"."PowerDown" = "Power Down";
      "org_kde_powerdevil"."PowerOff" = "Power Off";
      "org_kde_powerdevil"."Sleep" = "Sleep";
      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "org_kde_powerdevil"."Turn Off Screen" = [ ];
      "org_kde_powerdevil"."powerProfile" = ["Battery" "Meta+B,Battery" "Meta+B,Changer de profil de gestion d'énergie"];
      "plasmashell"."activate application launcher" = ["Meta" "Alt+F1,Meta" "Alt+F1,Activer le lanceur d'applications"];
      "plasmashell"."activate task manager entry 1" = "Meta+1";
      "plasmashell"."activate task manager entry 10" = "\\, Meta+0,Meta+0,Activer l'entrée du gestionnaire de tâches 10";
      "plasmashell"."activate task manager entry 2" = "Meta+2";
      "plasmashell"."activate task manager entry 3" = "Meta+3";
      "plasmashell"."activate task manager entry 4" = "Meta+4";
      "plasmashell"."activate task manager entry 5" = "Meta+5";
      "plasmashell"."activate task manager entry 6" = "Meta+6";
      "plasmashell"."activate task manager entry 7" = "Meta+7";
      "plasmashell"."activate task manager entry 8" = "Meta+8";
      "plasmashell"."activate task manager entry 9" = "Meta+9";
      "plasmashell"."clear-history" = "none,,Effacer l'historique du presse-papier";
      "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
      "plasmashell"."cycle-panels" = "Meta+Alt+P";
      "plasmashell"."cycleNextAction" = "none,,Élément suivant de l'historique";
      "plasmashell"."cyclePrevAction" = "none,,Élément précédent de l'historique";
      "plasmashell"."manage activities" = "Meta+Q";
      "plasmashell"."next activity" = [ ];
      "plasmashell"."previous activity" = [ ];
      "plasmashell"."repeat_action" = "\\, Meta+Ctrl+R,Meta+Ctrl+R,Démarrer manuellement une action concernant le presse-papier actuel";
      "plasmashell"."show dashboard" = "Ctrl+F12";
      "plasmashell"."show-barcode" = "none,,Afficher le code barre...";
      "plasmashell"."show-on-mouse-pos" = "Meta+V";
      "plasmashell"."stop current activity" = "Meta+S";
      "plasmashell"."switch to next activity" = "none,,Basculer vers l'activité suivante";
      "plasmashell"."switch to previous activity" = "none,,Basculer vers l'activité précédente";
      "plasmashell"."toggle do not disturb" = "none,,Basculer « Ne pas déranger »";
      "services/org.kde.krunner.desktop"."_launch" = ["Search" "Alt+F" "Alt+Space" "Alt+F2"];
      "services/org.kde.spectacle.desktop"."RecordWindow" = [ ];
    };
    configFile = {
      "baloofilerc"."General"."dbVersion" = 2;
      "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
      "baloofilerc"."General"."exclude filters version" = 9;
      "dolphinrc"."General"."ViewPropsTimestamp" = "2024,8,21,13,31,52.094";
      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
      "kactivitymanagerdrc"."activities"."3c56a3a7-5462-4f27-becc-57201f64cbd1" = "Défaut";
      "kactivitymanagerdrc"."main"."currentActivity" = "3c56a3a7-5462-4f27-becc-57201f64cbd1";
      "kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat" = true;
      "kcminputrc"."Mouse"."cursorTheme" = "Sweet-cursors";
      "kded5rc"."Module-browserintegrationreminder"."autoload" = false;
      "kded5rc"."Module-device_automounter"."autoload" = false;
      "kdeglobals"."General"."TerminalApplication" = "wezterm start --cwd .";
      "kdeglobals"."General"."TerminalService" = "org.wezfurlong.wezterm.desktop";
      "kdeglobals"."General"."XftHintStyle" = "hintslight";
      "kdeglobals"."General"."XftSubPixel" = "rgb";
      "kdeglobals"."KDE"."widgetStyle" = "Breeze";
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
      "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Date";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = true;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 175;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."Sounds"."Theme" = "freedesktop";
      "kdeglobals"."WM"."activeBackground" = "28,32,47";
      "kdeglobals"."WM"."activeBlend" = "28,32,47";
      "kdeglobals"."WM"."activeForeground" = "211,218,227";
      "kdeglobals"."WM"."inactiveBackground" = "34,39,57";
      "kdeglobals"."WM"."inactiveBlend" = "28,32,47";
      "kdeglobals"."WM"."inactiveForeground" = "141,147,159";
      "kiorc"."Executable scripts"."behaviourOnLaunch" = "open";
      "krunnerrc"."General"."FreeFloating" = true;
      "kscreenlockerrc"."Daemon"."LockGrace" = 1800;
      "kscreenlockerrc"."Daemon"."Timeout" = 30;
      "kwalletrc"."Wallet"."First Use" = false;
      "kwinrc"."Desktops"."Id_1" = "709462f1-07ca-4748-9462-a90cedefe3b0";
      "kwinrc"."Desktops"."Id_10" = "81521a32-ca41-4563-91ff-661c2e1ad329";
      "kwinrc"."Desktops"."Id_11" = "b1f19c61-607b-4a7c-a3c5-834af37ed295";
      "kwinrc"."Desktops"."Id_12" = "ef2d4d7e-47f6-4f3a-90e4-38911a123da5";
      "kwinrc"."Desktops"."Id_2" = "ded1f22f-9fac-41c5-9dd0-0b3955f270aa";
      "kwinrc"."Desktops"."Id_3" = "dbfbbd06-e191-4f76-b4d8-fb71b6ce3086";
      "kwinrc"."Desktops"."Id_4" = "6f34b102-4bbf-4116-aec7-ef0f1b0b9407";
      "kwinrc"."Desktops"."Id_5" = "b79b1e38-8064-40e7-9c91-f8f0996fcb45";
      "kwinrc"."Desktops"."Id_6" = "e4af9e7a-db02-4002-bce9-df8e062b3d96";
      "kwinrc"."Desktops"."Id_7" = "b850eb52-2721-4504-933a-593f74415db6";
      "kwinrc"."Desktops"."Id_8" = "55023eda-af68-439a-a044-16a769621aa7";
      "kwinrc"."Desktops"."Id_9" = "e2ab4d62-a1be-4a62-8170-b8c486207637";
      "kwinrc"."Desktops"."Name_1" = "\n";
      "kwinrc"."Desktops"."Name_10" = "󰚌|\n";
      "kwinrc"."Desktops"."Name_11" = "󱚄\n";
      "kwinrc"."Desktops"."Name_12" = "\n";
      "kwinrc"."Desktops"."Name_2" = "\n";
      "kwinrc"."Desktops"."Name_3" = "󰎚\n";
      "kwinrc"."Desktops"."Name_4" = "\n";
      "kwinrc"."Desktops"."Name_5" = "\n";
      "kwinrc"."Desktops"."Name_6" = "󰙯\n";
      "kwinrc"."Desktops"."Name_7" = "󰌆\n";
      "kwinrc"."Desktops"."Name_8" = "󰏲\n";
      "kwinrc"."Desktops"."Name_9" = "\n";
      "kwinrc"."Desktops"."Number" = 12;
      "kwinrc"."Desktops"."Rows" = 1;
      "kwinrc"."Effect-blur"."BlurStrength" = 9;
      "kwinrc"."Effect-translucency"."ComboboxPopups" = 92;
      "kwinrc"."Effect-translucency"."Dialogs" = 92;
      "kwinrc"."Effect-translucency"."DropdownMenus" = 88;
      "kwinrc"."Effect-translucency"."Inactive" = 80;
      "kwinrc"."Effect-translucency"."IndividualMenuConfig" = true;
      "kwinrc"."Effect-translucency"."Menus" = 89;
      "kwinrc"."Effect-translucency"."MoveResize" = 92;
      "kwinrc"."Effect-translucency"."PopupMenus" = 90;
      "kwinrc"."Effect-translucency"."TornOffMenus" = 89;
      "kwinrc"."Plugins"."contrastEnabled" = true;
      "kwinrc"."Plugins"."frozenappEnabled" = false;
      "kwinrc"."Plugins"."krohnkiteEnabled" = false;
      "kwinrc"."Plugins"."minimizeallEnabled" = false;
      "kwinrc"."Plugins"."poloniumEnabled" = true;
      "kwinrc"."Plugins"."synchronizeskipswitcherEnabled" = false;
      "kwinrc"."Plugins"."translucencyEnabled" = true;
      "kwinrc"."Plugins"."videowallEnabled" = false;
      "kwinrc"."Script-krohnkite"."enableFloatingLayout" = true;
      "kwinrc"."Script-krohnkite"."enableMonocleLayout" = false;
      "kwinrc"."Script-krohnkite"."enableSpiralLayout" = false;
      "kwinrc"."Script-krohnkite"."enableSpreadLayout" = false;
      "kwinrc"."Script-krohnkite"."enableStairLayout" = false;
      "kwinrc"."Script-krohnkite"."enableThreeColumnLayout" = false;
      "kwinrc"."Script-krohnkite"."layoutPerActivity" = false;
      "kwinrc"."Script-krohnkite"."layoutPerDesktop" = false;
      "kwinrc"."Script-krohnkite"."limitTileWidth" = true;
      "kwinrc"."Script-krohnkite"."monocleMaximize" = false;
      "kwinrc"."Script-krohnkite"."noTileBorder" = true;
      "kwinrc"."Script-krohnkite"."screenDefaultLayout" = ":0";
      "kwinrc"."Script-krohnkite"."screenGapBottom" = 2;
      "kwinrc"."Script-krohnkite"."screenGapLeft" = 2;
      "kwinrc"."Script-krohnkite"."screenGapRight" = 2;
      "kwinrc"."Script-krohnkite"."screenGapTop" = 2;
      "kwinrc"."Script-krohnkite"."tileLayoutGap" = 5;
      "kwinrc"."Script-polonium"."Borders" = 2;
      "kwinrc"."Script-polonium"."EngineType" = 3;
      "kwinrc"."Script-polonium"."InsertionPoint" = 1;
      "kwinrc"."Script-polonium"."MaximizeSingle" = true;
      "kwinrc"."Script-polonium"."SaveOnTileEdit" = true;
      "kwinrc"."TabBox"."ActivitiesMode" = 2;
      "kwinrc"."TabBox"."DesktopMode" = 2;
      "kwinrc"."Tiling"."padding" = 4;
      "kwinrc"."Tiling/0709846f-e20d-5704-99cc-9a784f94e177"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/6c106da6-deee-5505-844d-e1e7f0382113"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[]}";
      "kwinrc"."Tiling/8f2e9e5e-5964-5e19-a7f2-450604977e3c"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[]}";
      "kwinrc"."Xwayland"."Scale" = 1.05;
      "kwinrc"."org.kde.kdecoration2"."BorderSize" = "None";
      "kwinrc"."org.kde.kdecoration2"."BorderSizeAuto" = false;
      "kwinrc"."org.kde.kdecoration2"."theme" = "__aurorae__svg__Otto";
      "plasma-localerc"."Formats"."LANG" = "fr_FR.UTF-8";
      "plasma-localerc"."Translations"."LANGUAGE" = "fr_FR:en_US";
      "plasmanotifyrc"."Applications/com.nextcloud.desktopclient.nextcloud"."Seen" = true;
      "plasmarc"."Theme"."name" = "Colorful-Dark-Plasma";
      "plasmarc"."Wallpapers"."usersWallpapers" = "/nix/store/fxk2whvvslad5crf7z9p26skg66vfpzw-breeze-6.1.4/share/wallpapers/Next/,/home/dylan/Images/Wallpaper/wallhaven-yx6e9l.jpg";
      "systemsettingsrc"."systemsettings_sidebar_mode"."HighlightNonDefaultSettings" = true;
    };
  };
};
}
