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

      eval "$(fnm env --use-on-cd --shell zsh)"

      eval "$(devenv hook zsh)"

      # Claude Code: API key decrypted by sops-nix at boot
      if [ -f ~/.config/claude-code/api-key ]; then
        export ANTHROPIC_AUTH_TOKEN="$(cat ~/.config/claude-code/api-key)"
        export DEEPSEEK_API_KEY="$(cat ~/.config/claude-code/api-key)"
      fi

      # Z.ai (GLM models): sops-nix template, only set when non-empty
      if [ -s ~/.config/claude-code/zai-api-key ]; then
        export ZAI_API_KEY="$(cat ~/.config/claude-code/zai-api-key)"
      fi

      # GitHub token for the skills hub / gh (5,000 req/hr instead of 60)
      if [ -s ~/.config/claude-code/github-token ]; then
        export GITHUB_TOKEN="$(cat ~/.config/claude-code/github-token)"
        export GH_TOKEN="$GITHUB_TOKEN"
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
