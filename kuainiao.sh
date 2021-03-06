#!/bin/bash

base_dir=`dirname $0`
source "$base_dir/browser.sh"
data_dir="$base_dir/data"
[ ! -d "$data_dir" ] && mkdir -p "$data_dir"
mi="$data_dir/mi"
cookies="$data_dir/cookies"


# Mi Account
user="XXXXXXXXXXX"
passwd="XXXXXXXXXXX"


xunlei_mi_auth="https://open-api-auth.xunlei.com/platform?m=BindOauth"
mi_oauth=`get "$xunlei_mi_auth" | grep -Eo "http.+[0-9]"`
getFollowRedirect "$mi_oauth" > "$mi"
sid="sid=oauth2.0"
callback=`cat "$mi" | grep -Eo "callback:.+oauth2.0\"" | grep -Eo "http.+oauth2.0"`
qs=`cat "$mi" | grep -Eo "qs:.+\"" | grep -Eo "\".+\"" | sed 's/\"//g'`
_sign=`cat "$mi" | grep -Eo "\"_sign.+\"" | grep -Eo "\"[^_:].+\"" | sed 's/\"//g'`
qs=qs=`urlencode "$qs"`
_sign=_sign=`urlencode "$_sign"`
callback=callback=`urlencode "$callback"`


mi_auth="https://account.xiaomi.com/pass/serviceLoginAuth2"
user="user=$user"
hash="hash=`echo -n $passwd | md5sum | awk '{print $1}' | tr 'a-z' 'A-Z'`"
xunlei_auth=`post "$mi_auth" "$user&$hash&$sid&$callback&$qs&$_sign" | grep -Eo "http.+'" | sed "s/'//"`
saveCookies "$xunlei_auth" "$cookies"
sessionid=sessionid=`cat "$cookies" | grep -Eo "ws.+"`
userid=userid=`cat "$cookies" | grep userid | grep -Eo "[0-9]+" | tail -1`
user_type=user_type="1"
client_type=client_type="guanwang-huodongweb-1.0"
peerid=peerid="5c6b3947-b48c-43ea-b821-72fa73e3e186"


kuainiao_transfer="https://xlkn-ssl.xunlei.com/"
method="queryportal"
host=host="api.portal.swjsq.vip.xunlei.com"
port=port="81"
kuainiao_speeder=`get "$kuainiao_transfer$method?$host&$port&$user_type&$dial_account&$peerid&$sessionid&$userid&$client_type"`
host=host=`echo "$kuainiao_speeder" | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`
port=port=`echo "$kuainiao_speeder" | grep -Eo "[0-9]+" | tail -1`
dial_account=dial_account=`get "${kuainiao_transfer}bandwidth?$host&$port&$peerid&$sessionid&$userid&$client_type" | grep -Eo "\"dial_account.+[0-9]+\"" | grep -Eo "[0-9]+"`
action="upgrade"
[ "$1" = "0" ] && action="recover"
result=`get "$kuainiao_transfer$action?$host&$port&$user_type&$dial_account&$peerid&$sessionid&$userid&$client_type" | grep -Eo "bandwidth"`
if [ "$result" = "" ]; then
    method="keepalive"
    peerid=peerid=`get "$kuainiao_transfer$method?$host&$port&$user_type&$dial_account&$peerid&$sessionid&$userid&$client_type" | grep -Eo "[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}"`
    if [ "$peerid" != "peerid=" ]; then
        method="recover"
        result=`get "$kuainiao_transfer$method?$host&$port&$user_type&$dial_account&$peerid&$sessionid&$userid&$client_type" | grep -Eo "bandwidth"`
        [ "$action" = "upgrade" ] && peerid=peerid="5c6b3947-b48c-43ea-b821-72fa73e3e186" && result=`get "$kuainiao_transfer$action?$host&$port&$user_type&$dial_account&$peerid&$sessionid&$userid&$client_type" | grep -Eo "bandwidth"`
    fi
fi
[ "$result" != "" ] && echo "Action $action succeeded!" || echo "Action $action failed!"
