eval "$(pyenv init -)"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

pv() {
    local python_version=$1
    local env_name=$2
    local requirements_file="$3"

    cout "Creating virtual environment '$env_name' with python version '$python_version'"
    pyenv virtualenv $python_version $env_name
    pyenv local $env_name

    if [ "$requirements_file" != "" ]; then
        cout "Installing requirements"
        pip install -r $requirements_file
    fi
}