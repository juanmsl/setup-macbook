alias gch="git checkout"
alias gi="git init"
alias gs="git status"
alias ga="git add -A"
alias gc="git commit -m"
alias gca="git commit --amend --no-edit"
alias gac="ga && gc"
alias gaca="ga && gca"
alias push="git push origin"
alias pull="git pull origin"
alias gd="git diff"
alias gb="git branch"
alias gclean='git branch --no-color --merged | grep -vE "^([+*]|\s*(master|main|develop)\s*$)" | xargs git branch -d'

gbname() {
  # local ref=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  local ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

git_push() {
    local branch="$1"
    local target="$2"
    local message="$3"

    if [ "$target" = "" ]; then
        target="master"
    fi

    if [ "$message" = "" ]; then
        message="Creating branch ${branch}"
    fi

    cout "[1/4] Checkout to branch [$branch]:"
    gch -b $branch
    cout "[2/4] Adding changes"
    ga
    cout "[3/4] Commiting [$branch]"
    gc "$message"

    if [ "$target" = "." ]; then
        cout "[4/4] Pushing changes to branch [$branch]"
        push $branch
    else
        cout "[4/4] Pushing changes to branch [$branch], and creating merge to branch [$target]"
        push $branch -o merge_request.create -o merge_request.target=$target -o merge_request.remove_source_branch
    fi
    echo ""
}

gch_pull() {
    branch="$1"
    gch ${branch} && pull ${branch} && gclean
}

git_clean_clone() {
    local envFile="$1"

    if [ "$envFile" = "" ]; then
        envFile=".env"
    fi

    origin=$(git remote -v | grep -Eo "git@(.)*.git" | sort -u)
    name=$(echo "$origin" | grep -Eo "/(.)*.git" | sed 's/^.//' | sed 's/.git//g')
    vars=$(cat $envFile)

    cout "Repository (${name}) - ${origin}"

    directory=$(pwd)
    cd ..
    rm -rf $directory
    git clone ${origin}
    cd ${name}
    echo $vars > .env
}

alias git_update_no_commit="gaca && push $(gbname) --no-verify -f"

git_update_from() {
    branch="$1"
    pull ${branch} --rebase && push $(gbname) --no-verify -f
}
