# option list
# https://gitlab.com/Remmina/Remmina/-/wikis/Remmina-Config-File-Options
#
{
  config,
  pkgs,
  lib,
  ...
}:

let
  remminaPrefContent = ''
    [remmina_pref]
    datadir_path=/home/${config.home.username}/.local/share/remmina
    remmina_file_name=%G_%P_%N_%h
    screenshot_path=/home/${config.home.username}/Images
    screenshot_name=remmina_%p_%h_%Y%m%d-%H%M%S
    deny_screenshot_clipboard=true
    disablepasswordstoring=1
    save_view_mode=true
    confirm_close=true
    use_primary_password=false
    unlock_timeout=300
    lock_connect=false
    lock_edit=false
    lock_view_passwords=false
    enc_mode=1
    audit=false
    trust_all=false
    floating_toolbar_placement=0
    toolbar_placement=3
    prevent_snap_welcome_message=false
    fullscreen_on_auto=true
    always_show_tab=true
    always_show_notes=false
    hide_connection_toolbar=false
    hide_searchbar=false
    default_action=0
    scale_quality=3
    ssh_loglevel=1
    ssh_parseconfig=true
    hide_toolbar=false
    small_toolbutton=false
    view_file_mode=0
    resolutions=640x480,800x600,1024x768,1152x864,1280x960,1400x1050,1920x1080
    main_width=1904
    main_height=994
    main_maximize=false
    main_sort_column_id=1
    main_sort_order=0
    toolbar_pin_down=false
    sshtunnel_port=4732
    ssh_tcp_keepidle=20
    ssh_tcp_keepintvl=10
    ssh_tcp_keepcnt=3
    ssh_tcp_usrtimeout=60000
    applet_new_ontop=false
    applet_hide_count=false
    applet_enable_avahi=false
    disable_tray_icon=false
    dark_theme=false
    recent_maximum=10
    default_mode=0
    tab_mode=0
    fullscreen_toolbar_visibility=0
    auto_scroll_step=10
    hostkey=192
    #F14 serve as hostkey ( launch5 in gnome)
    # if i need to use mod combo later :
    # https://gitlab.com/Remmina/Remmina/-/merge_requests/2523 
    hostkey=269025093
    shortcutkey_grab=65367          # End key
    shortcutkey_fullscreen=65360    # Home key
    shortcutkey_autofit=114         # R key
    shortcutkey_nexttab=65363       # Right Arrow key
    shortcutkey_prevtab=65361       # Left Arrow key
    shortcutkey_scale=115           # S key
    shortcutkey_clipboard=98        # B key
    shortcutkey_multimon=65365      # Page Up key
    shortcutkey_viewonly=109        # M key
    shortcutkey_screenshot=65481    # F12 key
    shortcutkey_minimize=65478      # F9 key
    shortcutkey_disconnect=65473    # F4 key
    shortcutkey_toolbar=116         # T key

    vte_shortcutkey_copy=99
    vte_shortcutkey_paste=118
    vte_shortcutkey_select_all=97
    vte_shortcutkey_increase_font=65365
    vte_shortcutkey_decrease_font=65366
    vte_shortcutkey_search_text=103
    vte_allow_bold_text=true
    vte_lines=512
    rdp_use_client_keymap=0
    rdp_disable_smooth_scrolling=0
    grab_color=#00ff00
    grab_color_switch=false
    # audio forwarding
    rdp_audio=0  # 0 is "local", 1 is "remote", 2 is "disabled"
    rdp_audio_output=true  # Enable audio output redirection
    rdp_microphone=true    # Enable microphone redirection
    rdp_audio_output_path=sys:pulse
    rdp_microphone_path=format:1

    [remmina_info]
    periodic_news_permitted=false
    periodic_usage_stats_permitted=false
    disable_tip=true

    [remmina]
    name=
    ignore-tls-errors=1
  '';

in
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.remmina = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "Enable custom Remmina configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.remmina.enable {
    home.packages = [ pkgs.remmina ];

    home.file.".config/remmina/remmina.pref".text = remminaPrefContent;
  };
}
