# shellcheck shell=bash

set +o errexit

# Section: init
___x_cmd_ghaction_init_x_cmd(){
    # x log :init "x-cmd/dev"
    # TODO: wait edit can remove https://gitee.com/x-cmd/x-cmd/blob/main/X#L1
    ___X_CMD_VERSION=latest
    ___X_CMD_PATH_VERSION="${___X_CMD_ROOT:-"$HOME/.x-cmd.root"}/v/${___X_CMD_VERSION}"

    eval "$(curl https://raw.githubusercontent.com/x-bash/get/main/index.html 2>/dev/null)" 2>/dev/null || true
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
    x log :init "ssh: loding ssh-agent and create ~/.ssh and add known_hosts"

    eval "$(ssh-agent)"
    mkdir -p ~/.ssh

    printf "%s\n" "
github.com,52.74.223.119 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
gitee.com,180.97.125.228 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMuEoYdx6to5oxR60IWj8uoe1aI0X1fKOHWOtLqTg1tsLT1iFwXV5JmFjU46EzeMBV/6EmI1uaRI6HiEPtPtJHE=
" >> ~/.ssh/known_hosts

    [ -z "$ssh_key" ] && return

    printf "%s\n" "$ssh_key" >> ~/.ssh/id_rsa
    chmod 600 ~/.ssh/known_hosts ~/.ssh/id_rsa
    ssh-add ~/.ssh/id_rsa
} 2>/dev/null 1>&2

___x_cmd_ghaction_init()(
    set -o errexit

    ___x_cmd_ghaction_init_x_cmd
    ___x_cmd_ghaction_init_docker
    ___x_cmd_ghaction_init_ssh_key
    ___x_cmd_ghaction_init_git
)
# EndSection

___x_cmd_ghaction_run(){
    set +o errexit;
    ___X_CMD_VERSION=latest
    ___X_CMD_PATH_VERSION="${___X_CMD_ROOT:-"$HOME/.x-cmd.root"}/v/${___X_CMD_VERSION}"
    . "${___X_CMD_PATH_VERSION}/X"
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

