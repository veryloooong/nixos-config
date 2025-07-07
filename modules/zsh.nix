{ lib, ...}:

{
  programs.zsh = {
    enable = true;

    # emacs style keymapping
    defaultKeymap = "emacs";

    # main plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    # aliases
    shellAliases = {
      ls = "eza";
      system-update = "sudo nixos-rebuild switch";
      cat = "bat";
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
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../shell/omp.toml));
  };
}
