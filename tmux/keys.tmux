# Remap window/pane creation to open on current path
unbind c
unbind '"'
unbind %
bind-key c new-window -c '#{pane_current_path}'
bind-key '"' split-window -v -c '#{pane_current_path}'
bind-key % split-window -h -c '#{pane_current_path}'
