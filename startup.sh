#!/bin/bash

set -x

IP=$(ip route show |grep -o src.* |cut -f2 -d" ")
# kubernetes sets routes differently -- so we will discover our IP differently
if [[ ${IP} == "" ]]; then
  IP=$(hostname -i)
fi

zone=$(TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document \
| jq -r '.availabilityZone' | grep -o .$)

case "${zone}" in
    a)
      color=Crimson
      ;;
    b)
      color=CornflowerBlue
      ;;
    c)
      color=LightGreen
      ;;
    *)
      zone=unknown
      color=Yellow
      ;;
esac

export CODE_HASH="$(cat code_hash.txt)"
export IP
export AZ="pod ${IP} in AZ-${zone}"

# exec container command
exec node server.js
