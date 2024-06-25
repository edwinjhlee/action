# shellcheck shell=bash

set +o errexit

# Section: init
___X_CMD_GHACTION_X=${___X_CMD_GHACTION_X:-index.html}  # x0, x1, x2

___x_cmd_ghaction_init_x_cmd(){
    # x log :init "x-cmd/dev"
    echo "-------------------------------HOME[$HOME]" >&2
    ___X_CMD_ROOT_CODE=;
    eval "$(curl "https://raw.githubusercontent.com/x-cmd/get/main/$___X_CMD_GHACTION_X")" || true
    # eval "$(curl https://raw.githubusercontent.com/x-bash/get/main/index.html 2>/dev/null)" 2>/dev/null || true
    # eval "$(curl https://get.x-cmd.com 2>/dev/null)" 2>/dev/null || true
}

___x_cmd_ghaction_init_git_clone_current(){
    if [ -n "$ws_owner_repo" ] && [ -n "$ws_repo_ref" ]; then
        local repo="${ws_owner_repo#*/}"
        local url
        if [ -n "$github_token" ]; then
            local owner="${ws_owner_repo%/*}"
            url="https://${owner}:${github_token}@github.com/${ws_owner_repo}.git"
        else
            url="https://github.com/${ws_owner_repo}.git"
        fi

        x log :init "git: cloning [ref=$ws_repo_ref] from [url=$url]"
        git clone --branch "$ws_repo_ref" "$url" && {
            x log :init "git: Creating [link=$(pwd)/ws] to [target=$(pwd)/$repo]"
            ln -s "$(pwd)/$repo" "$(pwd)/ws"
        }
    fi
}

___x_cmd_ghaction_init_git(){
    if [ -n "$git_user" ]; then
        x log :init "git: config user.name"
        git config --global user.name "$git_user"
    fi

    if [ -n "$git_email" ]; then
        x log :init "git: config user.email"
        git config --global user.email "$git_email"
    fi

    ___x_cmd_ghaction_init_git_clone_current
}

___x_cmd_ghaction_init_docker(){
    if [ -n "$docker_username" ] && [ -n "$docker_password" ]; then
        x log :init "docker: login [username=$docker_username]"
        docker login -u "$docker_username" -p "$docker_password"
    fi

    if [ -n "$docker_buildx_init" ]; then
        x log :init "docker: buildx init"
        docker buildx create --use
    fi
}

___x_cmd_ghaction_init_ssh_key(){
    # x log :init "ssh: loding ssh-agent and create ~/.ssh and add known_hosts"
    printf "%s\n" "ssh: loding ssh-agent and create ~/.ssh and add known_hosts"

    eval "$(ssh-agent)"
    mkdir -p ~/.ssh

    curl -s https://raw.githubusercontent.com/x-cmd/knownhost/main/dist/all.txt >> ~/.ssh/known_hosts

    [ -z "$ssh_key" ] && return

    printf "%s\n" "$ssh_key" >> ~/.ssh/id_rsa
    chmod 600 ~/.ssh/known_hosts ~/.ssh/id_rsa
    ssh-add ~/.ssh/id_rsa
} 

___x_cmd_ghaction_init()(
    set -o errexit

    ___x_cmd_ghaction_init_ssh_key

    ___x_cmd_ghaction_init_x_cmd
    ___x_cmd_ghaction_init_docker
    ___x_cmd_ghaction_init_git
)
# EndSection

___x_cmd_ghaction_run(){
    set +o errexit;
    # ___X_CMD_VERSION=latest
    # ___X_CMD_ROOT_V_VERSION="${___X_CMD_ROOT:-"$HOME/.x-cmd.root"}/v/${___X_CMD_VERSION}"
    # . "${___X_CMD_ROOT_V_VERSION}/X"

    ___X_CMD_ROOT="$HOME/.x-cmd.root"
    . "${___X_CMD_ROOT}/X"

    # set +o pipefail;
    cd ws
    if [ -n "$___X_CMD_GHACTION_PREHOOK" ]; then
        x log :X "Running PREHOOK."
        eval "$___X_CMD_GHACTION_PREHOOK"
    fi

    if [ -f "$___X_CMD_GHACTION_SCRIPT" ]; then
        x log :X "Running file: $___X_CMD_GHACTION_SCRIPT"
        source "$___X_CMD_GHACTION_SCRIPT"
    fi

    if [ -n "$___X_CMD_GHACTION_CODE" ]; then
        x log :X "Running code."
        eval "$___X_CMD_GHACTION_CODE"
    fi

    if [ -n "$___X_CMD_GHACTION_POSTHOOK" ]; then
        x log :X "Running POSTHOOK."
        eval "$___X_CMD_GHACTION_POSTHOOK"
    fi
}

if [ "$#" -gt 0 ]; then
    case "$1" in
        run)        shift; ___x_cmd_ghaction_run "$@" ;;
        init)       shift; ___x_cmd_ghaction_init "$@" ;;
    esac
fi

