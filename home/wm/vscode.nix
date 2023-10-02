{ config, pkgs, ... }:

{
    programs.vscode = {
		enable = true;
		enableUpdateCheck = false;
		mutableExtensionsDir = false;
		extensions = with pkgs.vscode-extensions; [
			jnoortheen.nix-ide
			rust-lang.rust-analyzer
			streetsidesoftware.code-spell-checker
			arrterian.nix-env-selector
			mads-hartmann.bash-ide-vscode
			foxundermoon.shell-format
		];
		userSettings = {
			"workbench.colorTheme" = "Visual Studio Dark";
			"window.zoomLevel" = 2;
			"editor.tabSize" = 4;
			"editor.indentSize" = "tabSize";
			"editor.minimap.enabled" = false;
			"[nix]"."editor.tabSize" = 4;
			"nixEnvSelector.nixFile" = "\${workspaceRoot}/shell.nix";
		};
	};

}