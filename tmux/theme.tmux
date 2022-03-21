# THEME
set -g status-bg black
set -g status-fg white
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green](#S) #(whoami)@#H#[default]'
set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg) #[default]#[fg=blue]%H:%M #[default]'
setw -g pane-border-style fg=white,bg=black
setw -g pane-active-border-style fg=green,bg=black

# Include setting titles
set-option -g set-titles on
set-option -g set-titles-string '[#S@#H] #W'
