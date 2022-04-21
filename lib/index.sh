# shellcheck shell=bash

set +o errexit

init_x_cmd(){
    eval "$(curl https://get.x-cmd.com/dev 2>/dev/null)" 2>/dev/null || true
}

init_git(){
    [ -n "$git_user" ] && git config --global user.name "$git_user"
    [ -n "$git_email" ] && git config --global user.email "$git_email"
    if [ -n "$git_ssh_url" ] && [ -n "$git_ref" ]; then
        git clone --branch "$git_ref" "$git_ssh_url"
        git_ssh_url="${git_ssh_url##*/}"
        cd "${git_ssh_url%.git}"
    fi
    true
}

init_docker(){
    if [ -n "$docker_username" ] && [ -n "$docker_password" ]; then
        docker login -u "$docker_username" -p "$docker_password"
    fi

    if [ -n "$docker_buildx_init" ]; then
        docker buildx create --use
    fi
    true
}

init_ssh_key(){
    eval "$(ssh-agent)"
    mkdir -p ~/.ssh

    [ -z "$ssh_key" ] && return

    printf "%s\n" "
github.com,52.74.223.119 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
gitee.com,180.97.125.228 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMuEoYdx6to5oxR60IWj8uoe1aI0X1fKOHWOtLqTg1tsLT1iFwXV5JmFjU46EzeMBV/6EmI1uaRI6HiEPtPtJHE=
" >> ~/.ssh/known_hosts

    echo "$ssh_key" >> ~/.ssh/id_rsa
    chmod 600 ~/.ssh/known_hosts ~/.ssh/id_rsa
    ssh-add ~/.ssh/id_rsa 
} 2>/dev/null 1>&2

init_main(){
    ___X_CMD_IN_CHINA_NET=
    init_x_cmd
    init_docker
    init_ssh_key
    init_git
    true
}

run_script_before(){
    set +o errexit; . $HOME/.x-cmd/.boot/boot
}

run_shellcode_before(){
    set +o errexit; . $HOME/.x-cmd/.boot/boot; ___X_CMD_INSIDE_GITHUB_ACTION=___shellcode___
}

[ "$#" -gt 0 ] && "$@"

