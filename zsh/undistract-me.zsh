# commands to ignore
cmdignore=(htop tmux top vim)

# end and compare timer, notify-send if needed
function notifyosd-precmd() {
	retval=$?
    if [[ ${cmdignore[(r)$cmd_basename]} == $cmd_basename ]]; then
        return
    else
        if [ ! -z "$cmd" ]; then
            cmd_end=`date +%s`
            ((cmd_time=$cmd_end - $cmd_start))
        fi
        if [ $retval -gt 0 ]; then
            cmdstat="failed"
        else
            cmdstat="success"
        fi
        if [ ! -z "$cmd" -a $cmd_time -gt 10 ]; then
            if [ ! -z $SSH_TTY ] ; then
                twmnc -i $cmdstat -t "$cmd_basename on `hostname`" -c "\"$cmd\" took $cmd_time seconds"
            else

                twmnc -i $cmdstat -t "$cmd_basename" -c "\"$cmd\" ${cmd_time}s"
            fi
        fi
        unset cmd
    fi
}

# make sure this plays nicely with any existing precmd
precmd_functions+=( notifyosd-precmd )

# get command name and start the timer
function notifyosd-preexec() {
    cmd=$1
    cmd_basename=${${cmd:s/sudo //}[(ws: :)1]} 
    cmd_start=`date +%s`
}

# make sure this plays nicely with any existing preexec
preexec_functions+=( notifyosd-preexec )
