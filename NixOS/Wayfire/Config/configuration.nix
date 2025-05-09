{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix    # Importa as configurações de hardware geradas automaticamente
  ];
 
  boot.loader.systemd-boot.enable = true;                # Habilita o carregador de sistema systemd-boot
  boot.loader.efi.canTouchEfiVariables = true;           # Permite ao NixOS escrever variáveis EFI

  nixpkgs.config.allowUnfree = true;                     # Permite pacotes com licenças não-livres

  networking.hostName = "wayfire-nixos";                 # Define o nome de host da máquina
  time.timeZone = "America/Sao_Paulo";                   # Define o fuso horário do sistema
  i18n.defaultLocale = "en_US.UTF-8";                    # Define o locale padrão do sistema
  console.keyMap = "us";                                 # Define o layout de teclado do console

  networking.networkmanager.enable = true;               # Habilita o NetworkManager para gerenciar conexão de rede

  users.users.akyil = {                                  # Configuração do usuário 'akyil'
    isNormalUser = true;                                 # Usuário não-root
    description = "Usuário Akyil";                       # Descrição do usuário
    extraGroups = [ "wheel" "video" "audio" "input" "libvirtd" ];  # Grupos adicionais
    shell = pkgs.fish;                                   # Define o shell padrão como Fish
  };

  # [...]

  nixpkgs.overlays = [
    (import /home/akyil/nixos/config/overlays/pywm-wayland-scanner.nix)  # Caminho para o seu overlay
  ];

  programs.nix-ld.enable = true; # ativa o compat de binários externos

  programs.fish.enable = true;                           # Habilita o Fish como shell interativo

  programs.xwayland.enable = true;                       # Habilita o XWayland para compatibilidade X11

  hardware.pulseaudio.enable = false;                    # Desabilita PulseAudio
  services.pipewire = {                                  # Configura e habilita o PipeWire
    enable = true;
    alsa.enable = true;                                  # Suporte ALSA
    alsa.support32Bit = true;                            # Suporte a bins de 32 bits
    pulse.enable = true;                                 # Habilita compatibilidade PulseAudio
    jack.enable = true;                                  # Habilita compatibilidade JACK
  };

  xdg.portal = {                                         # Configura portais XDG para sandboxing
    enable = true;
    config.common.default = "*";                         # Permite todos por padrão
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation.libvirtd.enable = true;                 # Habilita o serviço libvirtd para VMs

  systemd.services."start-libvirt-default-network" = {   # Serviço systemd para iniciar a rede "default" do libvirt no boot
    description = "Start default libvirt network on boot"; 

    after = [ "libvirtd.service" ];                      # Só inicia depois que o serviço libvirtd estiver rodando
    
    wantedBy = [ "multi-user.target" ];                  # Garante que rode no boot
    
    serviceConfig = {
      Type = "oneshot";                                  # Executa uma vez e termina
      ExecStart = "/run/current-system/sw/bin/virsh net-start default"; # Comando para iniciar a rede
      RemainAfterExit = true;                            # Marca como "ativo" mesmo após terminar
    };
  };

  # services.spice-vdagentd.enable = true;               # Habilita o agente SPICE para VMs

  networking.firewall.allowedTCPPorts = [ 6969 ];        # Abre porta TCP 6969 no firewall
  # Se UDP for necessário, descomente a linha abaixo
  # networking.firewall.allowedUDPPorts = [ 6969 ];      # Abre porta UDP 6969

  environment.systemPackages = with pkgs; [              # Pacotes instalados globalmente
    blender-hip         # Programa de modelagem 3D especializado
    reaper              # DAW para edição de áudio
    unityhub            # Hub do Unity Engine
    android-studio      # IDE Android
    virt-manager        # GUI para gerenciamento de VMs
    gnome-boxes
    lunarvim            # Editor de texto (configurado como IDE)
    firefox-esr

    wayfire             # Compositor Wayland (Wayfire)
    xwayland            # Compatibilidade X11 no Wayland
    wlsunset            # Ajuste de temperatura de cor no Wayland
    grim                # tira foto
    slurp
    ffmpeg
    swww
    wf-recorder
    alacritty

    libsForQt5.dolphin  # Dolphin file manager (Qt5)
    libsForQt5.ark      # Ark para compressão/extração (Qt5)
    unzip               # Descompactador de ZIP
    unrar               # Descompactador de RAR

    steam               # Plataforma de jogos Steam
    lutris              # Gerenciador de jogos
    prismlauncher       # Launcher para jogos Prismatik
    jdk21               # Java Development Kit 21
    git

    pulseaudio          # Cliente PulseAudio (requerido por alguns apps)
    playerctl           # Controle de player via CLI

    libsForQt5.konsole  # Terminal Konsole (Qt5)
    fish                # Fish shell
    fastfetch           # Ferramenta de info de sistema

    noto-fonts-cjk-sans # Fontes Noto CJK sans

   # mesa                             # Drivers Mesa padrão (Open Source)
   # libva                            # Aceleração de vídeo VAAPI
   # libvdpau                         # Suporte VDPAU (NVIDIA legacy, mas útil também com AMD via vaapiVdpau)
   # vaapiVdpau                       # Ponte VAAPI ↔ VDPAU
   # vulkan-loader                    # Biblioteca principal Vulkan
   # vulkan-validation-layers         # Camadas de validação Vulkan (debug de jogos)
 
    libsForQt5.qt5ct                  # tema
    libsForQt5.breeze-icons 
    
   # xdg-desktop-portal-gtk           # Portal GTK
   # xdg-desktop-portal-wlr           # Portal WLR para Wayland 

    cmake              # necessário para alguns builds que dependem dele
    pkg-config         # para resolver dependências nativas
    libdrm             # biblioteca de gerenciamento de recursos gráficos
    wayland            # já que você está no Wayfire
    meson              # sistema de build usado por wlroots
    ninja              # backend do meson
    wlroots
    wayland-scanner
    protontricks
    icu # <- substitui libicu
    glibc
    zlib    # comum para descompressão
    icu73
    whitesur-icon-theme
    liberation_ttf
    nwg-look
    wine
    wineWowPackages.stable
    winetricks
    file
    dotnetCorePackages.sdk_8_0_3xx
    wayfirePlugins.focus-request
    wtype
    wayfirePlugins.wcm
];

  hardware.graphics = {              # Configurações de GPU
    enable = true;                   # Habilita drivers gráficos
    enable32Bit = true;   
    };

  fonts = {                          # Configuração de fontes e fontconfig
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;                 # Habilita fontconfig
      antialias = true;              # Habilitação de antialias
      hinting.enable = true;         # Habilita hinting
      subpixel.rgba = "rgb";         # Subpixel rendering RGB
    };
  };

  programs.java = {                  # Configuração do Java
    enable = true;
    package = pkgs.jdk21;            # Define pacote JDK21
  };

  environment.sessionVariables = {   # Variáveis de ambiente para sessões
    QT_QPA_PLATFORM = "wayland";     # Define plataforma Qt para Wayland
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "Fusion";    # Força estilo Fusion no Qt
    GTK_THEME = "Adwaita:dark";      # Tema GTK Adwaita escuro
  };

  system.stateVersion = "23.11";     # Versão do estado do sistema para atualizações
}

