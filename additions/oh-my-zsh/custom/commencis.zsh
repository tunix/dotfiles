export COMMENCIS_HOME="$HOME/Cloud/Google/Documents/corporate/commencis"

if [[ -d $COMMENCIS_HOME ]]; then
    source $COMMENCIS_HOME/init.sh
fi

function is_proxy_on() {
    if [[ $COMMENCIS_PROXY_ACTIVATED == 1 ]]; then
        echo "yes"
    else
        echo "no"
    fi
}

function activate_proxy_for_npm() {
    node -v &> /dev/null

    if [[ $? == 0 ]]; then
        echo "Enabling proxy for npm..."
        npm config set proxy $http_proxy
        npm config set https-proxy $http_proxy
    fi
}

function deactivate_proxy_for_npm() {
    node -v &> /dev/null

    if [[ $? == 0 ]]; then
        echo "Disabling proxy for npm..."
        npm config delete proxy
        npm config delete https-proxy
    fi
}

function activate_proxy() {
    export all_proxy=$POZITRON_PROXY
    export http_proxy="http://$all_proxy"
    export https_proxy="http://$all_proxy"
    export ftp_proxy=$http_proxy
    export rsync_proxy=$http_proxy
    export no_proxy=$POZITRON_NO_PROXY_HOSTS

    # activating proxy for git
    git config --global http.proxy $http_proxy
    git config --global https.proxy $http_proxy

    # activating proxy for npm
    activate_proxy_for_npm

    COMMENCIS_PROXY_ACTIVATED=1
}

function deactivate_proxy() {
    unset all_proxy
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset rsync_proxy
    unset no_proxy

    # deactivating proxy for git
    git config --global --unset http.proxy
    git config --global --unset https.proxy

    # deactivating proxy for npm
    deactivate_proxy_for_npm

    COMMENCIS_PROXY_ACTIVATED=0
}
