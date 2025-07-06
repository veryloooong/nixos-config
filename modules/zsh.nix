{ lib, ...}:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.oh-my-posh = {
    enable = true;
    #enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../shell/omp.toml));
  };
}
