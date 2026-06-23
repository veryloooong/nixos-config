{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # emacs binding
    defaultKeymap = "emacs";

    # main plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    # aliases
    shellAliases = {
      ls = "eza";
      cat = "bat";
      open = "xdg-open";
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
    ];

    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      eval "$(nodenv init - zsh)"

      # Claude Code: API key decrypted by sops-nix at boot
      if [ -f ~/.config/claude-code/api-key ]; then
        export ANTHROPIC_AUTH_TOKEN="$(cat ~/.config/claude-code/api-key)"
      fi
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
