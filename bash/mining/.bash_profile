if [[ "$SSH_CONNECTION" != "" && "$MY_SSH_CONNECTION" != "yes" ]]; then
    while true; do
        echo -n "Do you want to attach your tmux mining dashboard? [y/n]"
        read yn
        case $yn in
            [Yy]* ) MY_SSH_CONNECTION="yes" tmux attach; break;;
            [Nn]* ) break;;
            * ) echo "Please answer y/n";;
        esac
    done
fi

