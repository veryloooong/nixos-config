{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # main plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    # aliases
    shellAliases = {
      ls = "eza";
      cat = "bat";
      system-update = "sudo nixos-rebuild switch";
      code = "code --ozone-platform-hint=auto --enable-wayland-ime";
    };

    # history
    history = {
      size = 5000;
      append = true;
      saveNoDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      ignoreAllDups = true;
    };

    # fzf-tab plugin
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.2.0";
          sha256 = "q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
        };
      }
      {
        name = "zsh-vi-mode";
	src = pkgs.fetchFromGitHub {
	  owner = "jeffreytse";
	  repo = "zsh-vi-mode";
	  rev = "v0.11.0";
	  sha256 = "xbchXJTFWeABTwq6h4KWLh+EvydDrDzcY9AQVK65RS8=";
	};
      }
    ];

    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (
      builtins.unsafeDiscardStringContext (builtins.readFile ../config/omp.toml)
    );
  };
}
