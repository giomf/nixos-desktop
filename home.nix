{ config, pkgs, ... }:

{
	home.stateVersion = "23.05";
	home.username = "giom";
	home.homeDirectory = "/home/giom";


	# Packages
	home.packages = with pkgs; [
		# Base
		vim
		alacritty
		dmenu
		ranger
		ssh-agents
		pavucontrol
		pulseaudio
		zellij

		# Coding
		git
		rustup

		# Office
		firefox-wayland
		google-chrome
		thunderbird
		libreoffice-qt
		keepassxc
		
		# Social
		telegram-desktop
		element-desktop
		spotify
		nextcloud-client
	];

	# Programs
	programs.bash.enable = true;

	programs.vscode = {
		enable = true;
		enableUpdateCheck = false;
		extensions = with pkgs.vscode-extensions; [
			jnoortheen.nix-ide
			rust-lang.rust-analyzer
			streetsidesoftware.code-spell-checker
		];
		userSettings = {
			"workbench.colorTheme" = "Visual Studio Dark";
			"window.zoomLevel" = "2";
			"editor.minimap.enabled" = "false";
		};
	};

	
	# Services
	services.ssh-agent.enable = true;
  

	# Window manager
	wayland.windowManager.sway = {
		enable = true;
		xwayland = true;
		config = rec {
			modifier = "Mod4";
			terminal = "alacritty";
			menu = "dmenu_run";
			defaultWorkspace = "workspace number 1";
			input = {
			"*" = {
				xkb_layout = "de";
			};
			};
				fonts = {
				names = [ "DejaVu Sans Mono" ];
				size = 11.0;
			};
				gaps = {
				smartBorders = "on";
			};
			startup = [
				{ command = "nextcloud"; }
			];
			keybindings = {
				"${modifier}+Return" = "exec --no-startup-id ${terminal} -e zellij attach -c TERMINAL";
				"${modifier}+Space" = "exec --no-startup-id ${menu}";
				"${modifier}+Shift+Return" = "exec --no-startup-id firefox";
				"${modifier}+f" = "exec --no-startup-id ${terminal} -e ranger";
				"${modifier}+k" = "exec --no-startup-id keepassxc";
				"${modifier}+m" = "exec --no-startup-id thunderbird";

				"XF86AudioMute" =  "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
				"XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
				"XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
				"XF86MonBrightnessUp" = "exec light -A 10";
				"XF86MonBrightnessDown" = "exec light -U 10";

				"${modifier}+Up" = "focus up";
				"${modifier}+w" = "focus up";
				"${modifier}+Down" = "focus down";
				"${modifier}+s" = "focus down";
				"${modifier}+Left" = "focus left";
				"${modifier}+a" = "focus left";
				"${modifier}+Right" = "focus right";
				"${modifier}+d" = "focus right";

				"${modifier}+Shift+Up" = "move up";
				"${modifier}+Shift+w" = "move up";
				"${modifier}+Shift+Down" = "move down";
				"${modifier}+Shift+s" = "move down";
				"${modifier}+Shift+Left" = "move left";
				"${modifier}+Shift+a" = "move left";
				"${modifier}+Shift+Right" = "move right";
				"${modifier}+Shift+d" = "move right";

				"${modifier}+Shift+1" = "move container to workspace number 1";
				"${modifier}+Shift+2" = "move container to workspace number 2";
				"${modifier}+Shift+3" = "move container to workspace number 3";
				"${modifier}+Shift+4" = "move container to workspace number 4";
				"${modifier}+Shift+5" = "move container to workspace number 5";
				"${modifier}+Shift+6" = "move container to workspace number 6";
				"${modifier}+Shift+7" = "move container to workspace number 7";
				"${modifier}+Shift+8" = "move container to workspace number 8";
				"${modifier}+Shift+9" = "move container to workspace number 9";
				"${modifier}+Shift+0" = "move container to workspace number 10";

				"${modifier}+e" = "layout tabbed";
				"${modifier}+Tab" = "layout toggle tabbed split";

				"${modifier}+q" = "kill";

				"${modifier}+1" = "workspace number 1";
				"${modifier}+2" = "workspace number 2";
				"${modifier}+3" = "workspace number 3";
				"${modifier}+4" = "workspace number 4";
				"${modifier}+5" = "workspace number 5";
				"${modifier}+6" = "workspace number 6";
				"${modifier}+7" = "workspace number 7";
				"${modifier}+8" = "workspace number 8";
				"${modifier}+9" = "workspace number 9";
				"${modifier}+0" = "workspace number 10";

				"${modifier}+Shift+r" = "reload";
				"${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
			};
		};
	};

  	# Let Home Manager install and manage itself.
  	programs.home-manager.enable = true;
}
