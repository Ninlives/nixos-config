function tp(){
    local f=$HOME/.cache/location
    if [[ ! -e $f || "$(cat $f)" == "Matrix" ]];then
        echo Follow the white rabbit
        sudo speech
        echo Zion > $f
    else
        echo Knock knock Neo
        sudo speechless
        echo Matrix > $f
    fi
}

function tps(){
    local f=$HOME/.cache/location
    if [[ ! -e $f ]];then
        echo Location: Matrix
    else
        echo Location: $(cat $f)
    fi
}

function vpns(){
    local f=$HOME/.cache/proxy
    if [[ ! -e $f ]];then
        echo Proxy: v2ray
    else
        echo Proxy: $(cat $f)
    fi
}

function vpnt(){
    local f=$HOME/.cache/proxy
    if [[ ! -e $f || "$(cat $f)" == "v2ray" ]];then
        systemctl stop v2ray.service
        systemctl start v2ray-ss.service
        echo shadowsocks > $f
    else
        systemctl stop v2ray-ss.service
        systemctl start v2ray.service
        echo v2ray > $f
    fi
}
