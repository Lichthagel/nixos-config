{
  pkgs,
  selfPkgs,
  unstablePkgs,
  ...
}: {
  home.packages = with pkgs; [
    # sans & mono
    unstablePkgs.geist-font

    # sans
    (google-fonts.override {
      fonts = [
        "Josefin Sans"
        "M PLUS 1"
        "M PLUS 1 Code"
        "M PLUS 2"
        "Nunito"
        "Outfit"
        "Plus Jakarta Sans"
        "Rubik"
        "Sen"
        "Sora"
      ];
    })
    selfPkgs.afacad
    selfPkgs.gabarito
    ibm-plex
    inter
    jost
    lexend
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    open-sans
    overpass

    # mono
    (unstablePkgs.nerdfonts.override {
      fonts = [
        "CascadiaCode"
        "FantasqueSansMono"
        "FiraCode"
        "GeistMono"
        "Iosevka"
        "JetBrainsMono"
        "MartianMono"
        "Monaspace"
        "NerdFontsSymbolsOnly"
        "SourceCodePro"
        "VictorMono"
      ];
    })
    cascadia-code
    fantasque-sans-mono
    fira-code
    iosevka-bin
    jetbrains-mono
    unstablePkgs.kode-mono
    selfPkgs.kode-mono-nerdfont
    selfPkgs.lilex
    martian-mono
    monaspace
    selfPkgs.monolisa
    selfPkgs.monolisa-custom
    selfPkgs.monolisa-nerdfont
    selfPkgs.monolisa-custom-nerdfont
    recursive
    selfPkgs.recursive-nerdfont
    source-code-pro
    victor-mono
  ];

  fonts.fontconfig.enable = true;
}
