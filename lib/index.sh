
set +o errexit

init_x_cmd(){
    eval "$(curl https://get.x-cmd.com/dev 2>/dev/null)" 2>/dev/null || true
}

init_git(){
    [ -n "$git_user" ] && git config --global user.name "$git_user"
    [ -n "$git_email" ] && git config --global user.email "$git_email"
    [ -n "$git_ssh_url" ] && [ -n "$git_ref" ] && git clone --branch "$git_ref" "$git_ssh_url"
    true
}

init_docker(){
    if [ -n "$docker_username" ] && [ -n "$docker_password" ]; then
        docker login -u "$docker_username" -p "$docker_password"
    fi

    if [ -n "$docker_buildx" ]; then
        docker buildx create --use
    fi
    true
}

init_ssh_key(){
    [ -z "$ssh_key" ] && return
    echo "github.com,52.74.223.119 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=" >> ~/.ssh/known_hosts
    echo "gitee.com,180.97.125.228 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMuEoYdx6to5oxR60IWj8uoe1aI0X1fKOHWOtLqTg1tsLT1iFwXV5JmFjU46EzeMBV/6EmI1uaRI6HiEPtPtJHE=" >> ~/.ssh/known_hosts
    echo "$ssh_key" >> ~/.ssh/id_rsa
    chmod 600 ~/.ssh/known_hosts ~/.ssh/id_rsa
    ssh-add ~/.ssh/id_rsa
}

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

