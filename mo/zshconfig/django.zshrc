runserver() {
    local host="$1"

    if [ "$host" = "" ]; then
        host="0.0.0.0:8080"
    fi

    python mo_services/manage.py runserver $host --settings=mo_services.settings.development
}

makemigrations() {
    local selected_app=$1

    if [ "$selected_app" != "" ]; then
        cout "Creating migrations for app '$selected_app'"
    else
        cout "Creating migrations"
    fi

    python mo_services/manage.py makemigrations $selected_app --settings=mo_services.settings.development
}

django_cmd() {
    python mo_services/manage.py $@ --settings=mo_services.settings.development
}

alias migrate="python mo_services/manage.py migrate --settings=mo_services.settings.development"