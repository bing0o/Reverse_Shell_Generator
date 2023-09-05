# script to autocomplete arguments' values for payload script 
# works only with zsh, to use:
# 1) must have payload script in your path as `payload` like: cp payload.sh /usr/local/bin/payload 
# 2) source _payload in your ~/.zshrc, like: echo 'source /path/to/_payload' >> ~/.zshrc 
# to check if it works type:`payload -t <TAB>`, you should have 4 suggestions types of the payload.

function _payload()
{
  case $3 in
    -t||--type)
        COMPREPLY+=("python")
        COMPREPLY+=("netcat")
        COMPREPLY+=("bash")
        COMPREPLY+=("php")
        ;;
    -i||--ip)
        COMPREPLY+=(
                "$(ifconfig | grep 'inet ' | awk '{print $2}')"
                "$(curl ipinfo.io/ip 2>/dev/null)"
        )
        ;;
    -e||--encode)
        COMPREPLY+=(
                "base64"
                "url"
        )
        ;;
   -I||--interface)
        COMPREPLY+=("$(ifconfig | grep 'flags' | awk '{print $1}' | tr -d :)")
        ;;
  esac
}

complete -F _payload payload
