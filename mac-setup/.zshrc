# ============================================================
# Save this file as: ~/.zshrc
# (i.e. /Users/YOUR_USERNAME/.zshrc)
#
# To install:
# cp .zshrc ~/.zshrc
# source ~/.zshrc
# ============================================================

# Tell ls to be colourful
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
# Tell grep to highlight matches
alias grep='grep --color=auto'

# GIT
alias ga='git add'
alias gaa='git add .'
alias gaaa='git add --all'
alias aa='git add . && git commit --amend'
alias gp='git pull'
alias gs='git status'

# KUBERNETES
export KUBE_EDITOR='nano'
alias k='kubectl'
alias kctx="kubectx"
alias kns="kubens"
alias ktx='kubectl config get-contexts'
alias ktxu='kubectl config use-context'
alias ktxqa='kubectl config use-context qa-eu-west'
alias ktxprod='kubectl config use-context production-eu-west'
alias ktxprodus='kubectl config use-context prod-us-east'
alias ktxdev='kubectl config use-context dev-eu-west'
alias kl='kubectl logs'
alias kd='kubectl describe'
alias awsl="aws sso login --profile"
alias pods="kubectl get pods"
alias deps="kubectl get deployment"
alias jobs="kubectl get job"
alias cms="kubectl get cm"

# DOCKER
alias tf="terraform"
alias dc="docker compose"
alias dcu="docker compose up"
alias dcd="docker compose down"

# Tools
alias ls="eza --icons"
alias ll="eza -la --icons"
alias cat="batcat"
#alias ll="ls -la"

# JAVA VERSION SWITCHER (macOS)
function j8()  { export JAVA_HOME=$(/usr/libexec/java_home -v 1.8); java -version; }
function j11() { export JAVA_HOME=$(/usr/libexec/java_home -v 11);  java -version; }
function j17() { export JAVA_HOME=$(/usr/libexec/java_home -v 17);  java -version; }
function j21() { export JAVA_HOME=$(/usr/libexec/java_home -v 21);  java -version; }

# VERSIONS SUMMARY
alias versions='sdk current java; java -version; docker -v; helm version; gradle -v; mvn -v; kubectl version --client; snowsql -v;'

# HOMEBREW (macOS package manager)
alias bs="brew search"
alias bi="brew install"

# CUSTOM
alias sdkhow="echo $'sdk current java\nsdk current maven\nsdk current gradle\nsdk use java <version>\nsdk list java'"
alias ktxhow="echo $'kubectl config get-contexts\nkubectl config use-context <context-name>'"

# Git branch in prompt
function parse_git_branch() {
  local ref
  ref=$(git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p')

  local char_count
  char_count=$(command echo "$ref" | wc -c)

  # Truncate long branch names to 22 chars + ellipsis
  if [[ ${char_count} -gt 25 ]]; then
    ref=$(command echo ${ref} | cut -c 1-22)
    ref="${ref}..."
  fi

  echo -e '\U2387' $ref
}

# Kubernetes context in prompt
parse_kube_context() {
  local ctx
  ctx=$(kubectl config current-context 2>/dev/null)
  [[ -n "$ctx" ]] && echo "(k8s:$ctx)"
}

# Colors for prompt
COLOR_DEF=$'%f'
COLOR_USR=$'%F{243}'
COLOR_DIR=$'%F{197}'
COLOR_GIT=$'%F{208}'   # orange
COLOR_K8S=$'%F{39}'    # blue

# Assemble the prompt
setopt PROMPT_SUBST
export PROMPT='${COLOR_DIR}%3d ${COLOR_GIT}$(parse_git_branch)${COLOR_K8S} $(parse_kube_context)${COLOR_DEF} $ '

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# PYENV
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
