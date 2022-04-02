# shellcheck shell=sh

eval "$(curl https://get.x-cmd.com/dev)"

x git init ssh-key "$(x safe get devteam/ssh-key)"

[ -z "$GITHUB_TOKEN" ] || GITHUB_TOKEN="$(x safe get devteam/qywx-token)"
x gh token "$GITHUB_TOKEN"

[ -z "$QYWX_TOKEN" ] || QYWX_TOKEN="$(x safe get devteam/qywx-token)"
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
    x gh release create --title something --msg "This is ready"
    x gh release upload xxxx
) && {
    x qywx bot msg "Builing success"
}

