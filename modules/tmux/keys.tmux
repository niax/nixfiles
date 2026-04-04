# Remap window/pane creation to open on current path
unbind c
unbind '"'
unbind %
bind-key C-a last-window
bind-key a send-prefix
bind-key c new-window -c '#{pane_current_path}'
bind-key '"' split-window -v -c '#{pane_current_path}'
bind-key % split-window -h -c '#{pane_current_path}'

# save scrollback to file
bind-key P command-prompt -p 'save history to filename:' -I '~/tmux.history' 'capture-pane -S - ; save-buffer %1 ; delete-buffer'
