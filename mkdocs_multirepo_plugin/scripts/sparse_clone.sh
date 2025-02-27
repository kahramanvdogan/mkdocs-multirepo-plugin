#!/bin/bash
set -f

url="$1"
name="$2"
branch=$3
shift 3
dirs=( "$@" )

protocol="$(echo "$url" | sed 's/:\/\/.*//')"
url_rest="$(echo "$url" | sed 's/.*:\/\///')"


if [[ $url_rest == *'azure.com'* && -n  "$AccessToken" ]]; then
    url_to_use="${protocol}://$AccessToken@$url_rest"
    git config http.extraheader "AUTHORIZATION: bearer $AccessToken"
elif [[ $url_rest == *'github.com'* && -n "$GithubAccessToken" ]]; then
    url_to_use="${protocol}://x-access-token:$GithubAccessToken@$url_rest"
elif [[ $url_rest == *'gitlab.com'* && -n  "$GitlabCIJobToken" ]]; then
    url_to_use="${protocol}://gitlab-ci-token:$GitlabCIJobToken@$url_rest"
else
  url_to_use="$url"
fi


git clone --branch "$branch" --depth 1 --filter=blob:none --sparse $url_to_use "$name" || exit 1
cd "$name"
git sparse-checkout set --no-cone ${dirs[*]}
rm -rf .git
