# Author: Andrey Listopadov
# Module for opening a list of recent files open
# https://github.com/andreyorst/fzf.kak

hook global ModuleLoaded fzf %{
    map global fzf -docstring "open recent file list" 'r' '<esc>: require-module fzf-recent; fzf-recent<ret>'
}

provide-module fzf-recent %§

define-command -hidden fzf-recent %{ evaluate-commands %sh{
    reverse() {
        perl -e 'print reverse <>' "$@"
    }
    recents=""
    file="$HOME/.cache/kak-mru"

    for line in `reverse $file`; do
        [ -z "$line" ] && continue
        recents="$line
$recents"
        shift
    done
    
    message="Set recent to edit in current client.
<ret>: switch to selected recent.
${kak_opt_fzf_window_map:-ctrl-w}: open recent file list in new window"
    [ -n "${kak_client_env_TMUX:-}" ] && tmux_keybindings="
${kak_opt_fzf_horizontal_map:-ctrl-s}: open recent file list in horizontal split
${kak_opt_fzf_vertical_map:-ctrl-v}: open recent file list in vertical split"
    printf "%s\n" "info -title 'fzf recent' '$message$tmux_keybindings'"
    [ -n "${kak_client_env_TMUX:-}" ] && additional_flags="--expect ${kak_opt_fzf_vertical_map:-ctrl-v} --expect ${kak_opt_fzf_horizontal_map:-ctrl-s}"

    printf "%s\n" "fzf -kak-cmd %{edit -existing} -items-cmd %{printf \"%s\n\" \"$recents\"} -fzf-args %{--expect ${kak_opt_fzf_window_map:-ctrl-w} $additional_flags}"
}}

§
