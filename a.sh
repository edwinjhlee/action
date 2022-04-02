# shellcheck shell=sh

eval "$(curl https://get.x-cmd.com/dev)"

x vault prepare "devteam/*"

x git init ssh-key "$(x vault get devteam/ssh-key)"
x gh token "$(x vault get devteam/github-token)"

x qywx bot token "$QYWX_TOKEN"

(
    cd "$repo" || {
        x qywx bot msg "Building failure."
        exit 1
    }
    : do something
    git commit -m "ready"
    git push
) && \
(
    x ws build || exit 1
    x gh release create something
    x gh release upload xxxx
    x gh release msg "This is ready"
) && {
    x qywx bot msg "Builing success"
}

