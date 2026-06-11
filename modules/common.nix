{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
    borgbackup
    borgmatic
    cloud-utils # growpart
    dig
    fastfetch
    ffmpeg
    file
    git
    git-crypt
    git-lfs
    glances
    iftop
    iotop
    jq
    ncdu
    nmap
    rclone
    silver-searcher
    tcpdump
    tmux
    vim
    wget
  ];

  # Shell aliases
  environment.shellAliases = {
    # Git
    undocommit = "git reset --soft HEAD~1";
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "cd.." = "cd ..";
    cls = "clear";
    q = "exit";
    # Utilities
    rpwd = "openssl rand -base64 48";
    ta = "tmux attach || tmux";
    # SSH
    sshk = "ssh-keygen -f ~/.ssh/known_hosts -R";
  };

  # Bash shell functions and init
  programs.bash = {
    interactiveShellInit = ''
      # Git functions
      pp() { git pull --rebase && git push; }
      addiff() { git add . && git diff --staged; }
      gitdrop() { git stash && git stash drop; }

      # SSH functions
      sshi() { ssh -o StrictHostKeyChecking=no "$@"; }
      sudossh() { ssh -t "$1" sudo -i; }
      rreboot() { ssh -t "$1" 'sudo /sbin/reboot'; }

      # Navigation
      priv() { cd ~/priv/"$1"*; }
      p() { cd ~/priv/"$1"*; }

      # Kubernetes
      k8slist() { kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n "$1"; }
    '';
  };

  # Git system-wide config
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      alias = {
        l = "log --pretty=oneline -n 20 --graph --abbrev-commit";
        s = "status -s";
        showlog = "log -p --";
      };
    };
  };

  # Tmux config
  programs.tmux = {
    enable = true;
    historyLimit = 30000;
    extraConfig = ''
      # Solarized dark theme
      set-option -g status-style fg=yellow,bg=black
      set-window-option -g window-status-style fg=brightblue,bg=default,dim
      set-window-option -g window-status-current-style fg=brightred,bg=default,bright
      set-option -g pane-border-style fg=white
      set-option -g pane-active-border-style fg=white
      set-option -g message-style fg=brightred,bg=black
      set-option -g display-panes-active-colour blue
      set-option -g display-panes-colour brightred
      set-window-option -g clock-mode-colour green
      set-window-option -g window-status-bell-style fg=black,bg=red
    '';
  };

  # Vim as default editor with custom config
  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.vim-full.customize {
      vimrcConfig.customRC = ''
        set number
        syntax on
        set autoindent
        set cursorline
        set incsearch
        set hlsearch
        filetype indent on
        autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
      '';
    };
  };

  # Stop waiting for services to properly stop.
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "30s";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
