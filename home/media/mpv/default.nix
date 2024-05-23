{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
let
  cfg = config.licht.media.mpv;
in
{
  options = {
    licht.media.mpv = {
      enable = lib.mkEnableOption "my mpv configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mpv =
      let
        mpv-discord-version = "1.6.1";
        mpv-discord-src = pkgs.fetchFromGitHub {
          owner = "tnychn";
          repo = "mpv-discord";
          rev = "v${mpv-discord-version}";
          sha256 = "sha256-P1UaXGboOiqrXapfLzJI6IT3esNtflkQkcNXt4Umukc=";
        };
      in
      {
        enable = true;
        config = {
          border = true;
          cscale = "ewa_lanczossharp";
          deband = true;
          demuxer-max-bytes = "256m";
          fbo-format = "rgba16hf";
          geometry = "50%+50%+50%";
          gpu-api = "vulkan";
          interpolation = true;
          keep-open = true;
          osc = false;
          osd-bar = false;
          osd-duration = 2000;
          osd-font-size = 25;
          osd-font = "Gabarito";
          profile = "gpu-hq";
          scale = "ewa_lanczos";
          scale-blur = 0.981251;
          screenshot-directory = "~/Bilder/Screenshots"; # TODO
          screenshot-format = "webp";
          screenshot-template = "%tY-%tm/%tY-%tm-%td_%tH-%tM-%tS";
          screenshot-webp-compression = 6;
          screenshot-webp-lossless = true;
          sub-font = "Lexend";
          sub-font-size = 43;
          tscale = "oversample";
          video-sync = "display-resample";
          vo = "gpu-next";
          volume = 70;
        };
        package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { lua = pkgs.luajit; }) {
          scripts = with pkgs.mpvScripts; [
            (unstablePkgs.mpvScripts.uosc.overrideAttrs (finalAttrs: {
              version = "5.2.0";

              src = pkgs.fetchFromGitHub {
                owner = "tomasklaen";
                repo = "uosc";
                rev = finalAttrs.version;
                hash = "sha256-+4k8T1yX3IRXK3XkUShsuJSH9w1Zla7CaRENcIqX4iM=";
              };
            }))
            thumbfast
            (pkgs.stdenvNoCC.mkDerivation {
              name = "dynamic-crop";

              src = pkgs.fetchFromGitHub {
                owner = "Ashyni";
                repo = "mpv-scripts";
                rev = "master";
                sha256 = "sha256-W4Dj2tyJHeHLqAndrzllKs4iwMe3Tu8rfzEGBHuke6s=";
              };

              installPhase = ''
                runHook preInstall

                mkdir -p $out/share/mpv/scripts
                cp dynamic-crop.lua $out/share/mpv/scripts

                runHook postInstall
              '';

              passthru.scriptName = "dynamic-crop.lua";
            })
            (pkgs.stdenvNoCC.mkDerivation {
              name = "mpv-copyTime";

              src = pkgs.fetchFromGitHub {
                owner = "Arieleg";
                repo = "mpv-copyTime";
                rev = "master";
                sha256 = "sha256-7yYwHTpNo4UAaQdMVF5n//Hnk8+O+x1Q5MXG6rfFNpc=";
              };

              installPhase = ''
                runHook preInstall

                mkdir -p $out/share/mpv/scripts
                cp copyTime.lua $out/share/mpv/scripts

                runHook postInstall
              '';

              passthru.scriptName = "copyTime.lua";
            })
            (pkgs.stdenvNoCC.mkDerivation {
              name = "blur-edges";

              src = pkgs.fetchFromGitHub {
                owner = "occivink";
                repo = "mpv-scripts";
                rev = "master";
                sha256 = "sha256-pc2aaO7lZaoYMEXv5M0WI7PtmqgkNbdtNiLZZwVzppM=";
              };

              patches = [ ./blur-edges.patch ];

              installPhase = ''
                runHook preInstall

                mkdir -p $out/share/mpv/scripts
                cp scripts/blur-edges.lua $out/share/mpv/scripts

                runHook postInstall
              '';

              passthru.scriptName = "blur-edges.lua";
            })
            # (pkgs.stdenvNoCC.mkDerivation {
            #   name = "status-line";

            #   src = pkgs.fetchurl {
            #     url = "https://raw.githubusercontent.com/mpv-player/mpv/5ea390c07f166ad1186b409176dd4e27d93b6f92/TOOLS/lua/status-line.lua";
            #     sha256 = "sha256-f626+0y9H1V3GoOBXodOH6f6rRDSOeIL3ypE7Oyhic4=";
            #   };

            #   dontUnpack = true;

            #   installPhase = ''
            #     runHook preInstall

            #     mkdir -p $out/share/mpv/scripts
            #     cp $src $out/share/mpv/scripts/status-line.lua

            #     runHook postInstall
            #   '';

            #   passthru.scriptName = "status-line.lua";
            # })
            # (pkgs.stdenvNoCC.mkDerivation {
            #   name = "mpv-discordRPC";

            #   src = pkgs.fetchFromGitHub {
            #     owner = "cniw";
            #     repo = "mpv-discordRPC";
            #     rev = "9a060308fd05e6752981592d0a9e92b5e149fdc9";
            #     sha256 = "sha256-n6NMyaRtR7a/WvHKHCLxLxC8vdK1cAqvnkqhY0M83x4=";
            #   };

            #   propagatedBuildInputs = with pkgs; [ discord-rpc ];

            #   patches = [ ./mpv-discordRPC.patch ];

            #   postPatch = ''
            #     substituteInPlace mpv-discordRPC/lua-discordRPC.lua \
            #       --replace "ffi.load(\"discord-rpc\")" "ffi.load(\"${pkgs.discord-rpc}/lib/libdiscord-rpc.so\")"
            #   '';

            #   installPhase = ''
            #     runHook preInstall

            #     mkdir -p $out/share/mpv/scripts
            #     cp -r mpv-discordRPC $out/share/mpv/scripts/

            #     runHook postInstall
            #   '';

            #   passthru.scriptName = "mpv-discordRPC";
            # })
            (pkgs.stdenvNoCC.mkDerivation {
              pname = "mpv-discord";
              version = mpv-discord-version;

              src = mpv-discord-src;

              installPhase = ''
                runHook preInstall

                mkdir -p $out/share/mpv
                cp -r scripts $out/share/mpv

                runHook postInstall
              '';

              passthru.scriptName = "discord.lua";
            })
          ];
        };
        scriptOpts = {
          blur_edges = {
            active = true;
            mode = "all";
            blur_radius = 20;
            blur_power = 3;
            minimum_black_bar_size = 3;
            reapply_delay = 0.5;
            watch_later_fix = false;
            only_fullscreen = true;
            prepend_subs = true;
          };
          discord = {
            key = "D";
            active = false;
            client_id = 737663962677510245;
            binary_path =
              let
                mpv-discord-bin = pkgs.buildGoModule {
                  pname = "mpv-discord-bin";
                  version = mpv-discord-version;

                  src = "${mpv-discord-src}/mpv-discord";

                  vendorHash = "sha256-xe1jyWFQUD+Z4qBAVQ0SBY0gdxmi5XG9t29n3f/WKDs=";

                  patches = [ ./mpv-discord-bin.patch ];
                };
              in
              "${mpv-discord-bin}/bin/mpv-discord";
            socket_path = "/tmp/mpvsocket";
            use_static_socket_path = true;
            autohide_threshold = 0;
          };
          # mpv_discordRPC = {
          #   rpc_wrapper = "lua-discordRPC";ssssssssssssssssssss
          #   periodic_timer = 1;
          #   playlist_info = true;
          #   loop_info = true;
          #   cover_art = true;
          #   mpv_version = true;
          #   active = false;
          #   key_toggle = "D";
          # };
          uosc = {
            # Display style of current position. available: line, bar
            timeline_style = "line";
            # # Line display style config
            timeline_line_width = 2;
            # Timeline size when fully expanded, in pixels, 0 to disable
            timeline_size = 40;
            # Comma separated states when element should always be fully visible.
            # Available: paused, audio, image, video, idle, windowed, fullscreen
            timeline_persistency = "paused";
            # Top border of background color to help visually separate timeline from video
            timeline_border = 1;
            # When scrolling above timeline, wheel will seek by this amount of seconds
            timeline_step = 5;
            # Render cache indicators for streaming content
            timeline_cache = true;

            # When to display an always visible progress bar (minimized timeline). Can be: windowed, fullscreen, always, never
            # Can also be toggled on demand with `toggle-progress` command.
            progress = "windowed";
            progress_size = 2;
            progress_line_width = 20;

            # A comma delimited list of items to construct the controls bar above the timeline. Set to `never` to disable.
            # Parameter spec: enclosed in `{}` means value, enclosed in `[]` means optional
            # Full item syntax: `[<[!]{disposition1}[,[!]{dispositionN}]>]{element}[:{paramN}][#{badge}[>{limit}]][?{tooltip}]`
            # Common properties:
            #   `{icon}` - parameter used to specify an icon name (example: `face`)
            #            - you can pick one here: https://fonts.google.com/icons?selected=Material+Icons&icon.style=Rounded
            # `{element}`s and their parameters:
            #   `{usoc_command}` - preconfigured shorthands for uosc commands that make sense to have as buttons:
            #      - `menu`, `subtitles`, `audio`, `video`, `playlist`, `chapters`, `editions`, `stream-quality`,
            #        `open-file`, `items`, `next`, `prev`, `first`, `last`, `audio-device`
            #   `fullscreen` - toggle fullscreen
            #   `loop-playlist` - button to toggle playlist looping
            #   `loop-file` - button to toggle current file looping
            #   `shuffle` - toggle for uosc's shuffle mode
            #   `speed[:{scale}]` - display speed slider, [{scale}] - factor of controls_size, default: 1.3
            #   `command:{icon}:{command}` - button that executes a {command} when pressed
            #   `toggle:{icon}:{prop}[@{owner}]` - button that toggles mpv property
            #   `cycle:{default_icon}:{prop}[@{owner}]:{value1}[={icon1}][!]/{valueN}[={iconN}][!]`
            #     - button that cycles mpv property between values, each optionally having different icon and active flag
            #     - presence of `!` at the end will style the button as active
            #     - `{owner}` is the name of a script that manages this property if any
            #   `gap[:{scale}]` - display an empty gap, {scale} - factor of controls_size, default: 0.3
            #   `space` - fills all available space between previous and next item, useful to align items to the right
            #           - multiple spaces divide the available space among themselves, which can be used for centering
            # Item visibility control:
            #   `<[!]{disposition1}[,[!]{dispositionN}]>` - optional prefix to control element's visibility
            #   - `{disposition}` can be one of:
            #     - `idle` - true if mpv is in idle mode (no file loaded)
            #     - `image` - true if current file is a single image
            #     - `audio` - true for audio only files
            #     - `video` - true for files with a video track
            #     - `has_many_video` - true for files with more than one video track
            #     - `has_image` - true for files with a cover or other image track
            #     - `has_audio` - true for files with an audio track
            #     - `has_many_audio` - true for files with more than one audio track
            #     - `has_sub` - true for files with an subtitle track
            #     - `has_many_sub` - true for files with more than one subtitle track
            #     - `has_many_edition` - true for files with more than one edition
            #     - `has_chapter` - true for files with chapter list
            #     - `stream` - true if current file is read from a stream
            #     - `has_playlist` - true if current playlist has 2 or more items in it
            #   - prefix with `!` to negate the required disposition
            #   Examples:
            #     - `<stream>stream-quality` - show stream quality button only for streams
            #     - `<has_audio,!audio>audio` - show audio tracks button for all files that have
            #                                   an audio track, but are not exclusively audio only files
            # Place `#{badge}[>{limit}]` after the element params to give it a badge. Available badges:
            #   `sub`, `audio`, `video` - track type counters
            #   `{mpv_prop}` - any mpv prop that makes sense to you: https://mpv.io/manual/master/#property-list
            #                - if prop value is an array it'll display its size
            #   `>{limit}` will display the badge only if it's numerical value is above this threshold.
            #   Example: `#audio>1`
            # Place `?{tooltip}` after the element config to give it a tooltip.
            #   Example: `<stream>stream-quality?Stream quality`
            # Example implementations of some of the available shorthands:
            #   menu = command:menu:script-binding uosc/menu-blurred?Menu
            #   subtitles = command:subtitles:script-binding uosc/subtitles#sub?Subtitles
            #   fullscreen = cycle:crop_free:fullscreen:no/yes=fullscreen_exit!?Fullscreen
            #   loop-playlist = cycle:repeat:loop-playlist:no/inf!?Loop playlist
            #   toggle:{icon}:{prop} = cycle:{icon}:{prop}:no/yes!
            #controls=menu,gap,subtitles,<has_many_audio>audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality,gap,space,speed,space,shuffle,loop-playlist,loop-file,gap,prev,items,next,gap,fullscreen
            controls = "shuffle,loop-playlist,loop-file,space,menu,gap,subtitles,audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality,gap,space,prev,items,next,gap,fullscreen";
            controls_size = 32;
            controls_margin = 8;
            controls_spacing = 2;
            controls_persistency = "";

            # Where to display volume controls: none, left, right
            volume = "right";
            volume_size = 40;
            volume_border = 1;
            volume_step = 1;
            volume_persistency = "";

            # Playback speed widget: mouse drag or wheel to change, click to reset
            speed_step = 0.1;
            speed_step_is_factor = false;
            speed_persistency = "";

            # Controls all menus, such as context menu, subtitle loader/selector, etc
            menu_item_height = 36;
            menu_min_width = 260;
            # Determines if `/` or `ctrl+f` is required to activate the search, or if typing
            # any text is sufficient.
            # When enabled, you can no longer toggle a menu off with the same key that opened it, if the key is a unicode character.
            menu_type_to_search = true;

            # Top bar with window controls and media title
            # Can be: never, no-border, always
            top_bar = "no-border";
            top_bar_size = 40;
            top_bar_controls = true;
            # Can be: `no` (hide), `yes` (inherit title from mpv.conf), or a custom template string
            top_bar_title = true;
            # Template string to enable alternative top bar title. If alt title matches main title,
            # it'll be hidden. Tip: use `${media-title}` for main, and `${filename}` for alt title.
            top_bar_alt_title = "";
            # Can be:
            #   `below`  => display alt title below the main one
            #   `toggle` => toggle the top bar title text between main and alt by clicking
            #               the top bar, or calling `toggle-title` binding
            top_bar_alt_title_place = "below";
            # Flash top bar when any of these file types is loaded. Available: audio,image,video
            top_bar_flash_on = "video,audio";
            top_bar_persistency = "";

            # Window border drawn in no-border mode
            window_border_size = 1;

            # If there's no playlist and file ends, load next file in the directory
            # Requires `keep-open=yes` in `mpv.conf`.
            autoload = true;
            # What types to accept as next item when autoloading or requesting to play next file
            # Can be: video, audio, image, subtitle
            autoload_types = "video,audio,image";
            # Enable uosc's playlist/directory shuffle mode
            # This simply makes the next selected playlist or directory item be random, just
            # like any other player in the world. It also has an easily togglable control button.
            shuffle = false;

            # Scale the interface by this factor
            scale = 1;
            # Scale in fullscreen
            scale_fullscreen = 1.3;
            # Adjust the text scaling to fit your font
            font_scale = 1;
            # Border of text and icons when drawn directly on top of video
            text_border = 1.2;
            # Border radius of buttons, menus, and all other rectangles
            border_radius = 2;
            # A comma delimited list of color overrides in RGB HEX format.
            # Defaults: foreground=ffffff,foreground_text=000000,background=000000,background_text=ffffff,curtain=111111,
            #           success=a5e075,error=ff616e
            color =
              let
                palette =
                  (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").${config.catppuccin.flavor};

                colors = lib.mapAttrs (_: value: builtins.replaceStrings [ "#" ] [ "" ] value.hex) (
                  palette.colors // { accent = palette.colors.${config.catppuccin.accent}; }
                );
              in
              "foreground=${colors.accent},foreground_text=${colors.surface0},background=${colors.base},background_text=${colors.text},curtain=${colors.mantle},success=${colors.green},error=${colors.red}";
            # A comma delimited list of opacity overrides for various UI element backgrounds and shapes.
            # This does not affect any text, which is always rendered fully opaque.
            # Defaults: timeline=0.9,position=1,chapters=0.8,slider=0.9,slider_gauge=1,speed=0.6,menu=1,submenu=0.4,
            #           border=1,title=1,tooltip=1,thumbnail=1,curtain=0.8,idle_indicator=0.8,audio_indicator=0.5,
            #           buffering_indicator=0.3
            opacity = "";
            # Use a faster estimation method instead of accurate measurement
            # setting this to `no` might have a noticeable impact on performance, especially in large menus.
            text_width_estimation = true;
            # Duration of animations in milliseconds
            animation_duration = 100;
            # Execute command for background clicks shorter than this number of milliseconds, 0 to disable
            # Execution always waits for `input-doubleclick-time` to filter out double-clicks
            click_threshold = 0;
            click_command = ''
              cycle pause
              script-binding uosc/flash-pause-indicator
            '';
            # Flash duration in milliseconds used by `flash-{element}` commands
            flash_duration = 1000;
            # Distances in pixels below which elements are fully faded in/out
            proximity_in = 40;
            proximity_out = 120;
            # Use only bold font weight throughout the whole UI
            font_bold = false;
            # One of `total`, `playtime-remaining` (scaled by the current speed), `time-remaining` (remaining length of file)
            destination_time = "playtime-remaining";
            # Display sub second fraction in timestamps up to this precision
            time_precision = 0;
            # Display stream's buffered time in timeline if it's lower than this amount of seconds, 0 to disable
            buffered_time_threshold = 60;
            # Hide UI when mpv autohides the cursor
            autohide = false;
            # Can be: none, flash, static, manual (controlled by flash-pause-indicator and decide-pause-indicator commands)
            pause_indicator = "flash";
            # Sizes to list in stream quality menu
            stream_quality_options = "4320,2160,1440,1080,720,480,360,240,144";
            # Types to identify media files
            video_types = "3g2,3gp,asf,avi,f4v,flv,h264,h265,m2ts,m4v,mkv,mov,mp4,mp4v,mpeg,mpg,ogm,ogv,rm,rmvb,ts,vob,webm,wmv,y4m";
            audio_types = "aac,ac3,aiff,ape,au,cue,dsf,dts,flac,m4a,mid,midi,mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv";
            image_types = "apng,avif,bmp,gif,j2k,jp2,jfif,jpeg,jpg,jxl,mj2,png,svg,tga,tif,tiff,webp";
            subtitle_types = "aqt,ass,gsub,idx,jss,lrc,mks,pgs,pjs,psb,rt,sbv,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt";
            # Default open-file menu directory
            default_directory = "~/Videos"; # TODO
            # List hidden files when reading directories. Due to environment limitations, this currently only hides
            # files starting with a dot. Doesn't hide hidden files on windows (we have no way to tell they're hidden).
            show_hidden_files = false;
            # Move files to trash (recycle bin) when deleting files. Dependencies:
            # - Linux: `sudo apt install trash-cli`
            # - MacOS: `brew install trash`
            use_trash = false;
            # Adjusted osd margins based on the visibility of UI elements
            adjust_osd_margins = true;

            # Adds chapter range indicators to some common chapter types.
            # Additionally to displaying the start of the chapter as a diamond icon on top of the timeline,
            # the portion of the timeline of that chapter range is also colored based on the config below.
            #
            # The syntax is a comma-delimited list of `{type}:{color}` pairs, where:
            # `{type}` => range type. Currently supported ones are:
            #   - `openings`, `endings` => anime openings/endings
            #   - `intros`, `outros` => video intros/outros
            #   - `ads` => segments created by sponsor-block software like https://github.com/po5/mpv_sponsorblock
            # `{color}` => an RGB(A) HEX color code (`rrggbb`, or `rrggbbaa`)
            #
            # To exclude marking any of the range types, simply remove them from the list.
            chapter_ranges = "openings:30abf964,endings:30abf964,ads:c54e4e80";
            # Add alternative lua patterns to identify beginnings of simple chapter ranges (except for `ads`)
            # Syntax: `{type}:{pattern}[,{patternN}][;{type}:{pattern}[,{patternN}]]`
            chapter_range_patterns = ''
              openings:オープニング
              endings:エンディング
            '';

            # Localization language priority from highest to lowest.
            # Built in languages can be found in `uosc/intl`.
            # `slang` is a keyword to inherit values from `--slang` mpv config.
            # Supports paths to custom json files: `languages=~~/custom.json,slang,en`
            languages = "en";

            # A comma separated list of element IDs to disable. Available IDs:
            #   window_border, top_bar, timeline, controls, volume,
            #   idle_indicator, audio_indicator, buffering_indicator, pause_indicator
            disable_elements = "";
          };
        };
      };

    xdg.configFile = {
      "mpv/input.conf".source = ./input.conf;
      "mpv/shaders".source =
        let
          anime4k = pkgs.fetchzip {
            url = "https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip";
            sha256 = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
            stripRoot = false;
          };
          fsrcnnx-x2-16-0-4-1 = pkgs.fetchurl {
            url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_16-0-4-1.glsl";
            sha256 = "sha256-1aJKJx5dmj9/egU7FQxGCkTCWzz393CFfVfMOi4cmWU=";
          };
          fsrcnnx-x2-8-0-4-1 = pkgs.fetchurl {
            url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_8-0-4-1.glsl";
            sha256 = "sha256-6ADbxcHJUYXMgiFsWXckUz/18ogBefJW7vYA8D6Nwq4=";
          };
          fsrcnnx-checkpoint-params = pkgs.fetchurl {
            url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/checkpoints_params.7z";
            sha256 = "sha256-h5B7DU0W5B39rGaqC9pEqgTTza5dKvUHTFlEZM1mfqo=";
          };
          ssimdownscaler = pkgs.fetchurl {
            url = "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/575d13567bbe3caa778310bd3b2a4c516c445039/SSimDownscaler.glsl";
            sha256 = "sha256-AEq2wv/Nxo9g6Y5e4I9aIin0plTcMqBG43FuOxbnR1w=";
          };
          krigbilateral = pkgs.fetchurl {
            url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/038064821c5f768dfc6c00261535018d5932cdd5/KrigBilateral.glsl";
            sha256 = "sha256-ikeYq7d7g2Rvzg1xmF3f0UyYBuO+SG6Px/WlqL2UDLA=";
          };
        in
        pkgs.stdenvNoCC.mkDerivation {
          name = "mpv-shaders";

          dontUnpack = true;

          buildPhase = ''
            runHook preBuild

            mkdir -p $out
            cp -r ${anime4k}/* $out
            cp ${fsrcnnx-x2-16-0-4-1} $out/${fsrcnnx-x2-16-0-4-1.name}
            cp ${fsrcnnx-x2-8-0-4-1} $out/${fsrcnnx-x2-8-0-4-1.name}
            ${pkgs.p7zip}/bin/7z e -o$out ${fsrcnnx-checkpoint-params} FSRCNNX_x2_8-0-4-1_LineArt.glsl
            cp ${ssimdownscaler} $out/${ssimdownscaler.name}
            cp ${krigbilateral} $out/${krigbilateral.name}

            runHook postBuild
          '';
        };
    };
  };
}
