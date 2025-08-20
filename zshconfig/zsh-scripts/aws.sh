# AWS ASSUME ROLE CREDENTIALS

AWS_USERNAME=""
AWS_ROOT_ACCOUNT_NAME=""
AWS_IAM_ROLE=""

credentials() {
    local CREDENTIALS_ACCOUNT_ID="$1"
    local CREDENTIALS_ROLE_NAME="$2"
    local CREDENTIALS_PROFILE="$3"

    aws sts assume-role --role-arn "arn:aws:iam::"$CREDENTIALS_ACCOUNT_ID":role/$CREDENTIALS_ROLE_NAME" --role-session-name $AWS_USERNAME --profile $CREDENTIALS_PROFILE --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text | awk '{print "export AWS_ACCESS_KEY_ID=\""$1"\";\nexport AWS_SECRET_ACCESS_KEY=\""$2"\";\nexport AWS_SECURITY_TOKEN=\""$3"\";"}'
}

credentials_aws_account() {
    credentials $1 $AWS_IAM_ROLE $AWS_ROOT_ACCOUNT_NAME
}

# AWS DOCKER

docker_login() {
    local pass=$(aws ecr get-login-password --region us-east-1 --profile $1)
    local command="docker login -u AWS -p \"$pass\" https://$2.dkr.ecr.us-east-1.amazonaws.com"
    eval $command
}

# AWS S3

delete_bucket() {
    aws s3 rb s3://$1 --force --profile $2
}

delete_buckets() {
    local profile="$1"
    declare -a buckets=($@)

    for bucket in "${buckets[@]}"
    do
        ask "[$bucket]"
        if [ "${answer}" = "yes" ]; then
            delete_bucket "$bucket" "$profile" | grep '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
        fi

        echo ""
    done
}

# AWS AZURE LOGIN

alias azure-login="aws-azure-login --profile $AWS_ROOT_ACCOUNT_NAME"
