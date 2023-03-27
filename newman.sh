#!/bin/bash

for file in collections/*.yaml; do
    IFS=''
    buf=''
    while read line; do
        SCRIPT_GROUP=$(echo "$line"|sed -r -e '/(.*)\{\{\s*\$File\:([^|]+)\s*\|\s*indent\s*([0-9]+)\s*\}\}(.*)/!d;s//\1;\2;\3;\4/')
        PRELINE=$(echo $SCRIPT_GROUP|cut -d ";" -f 1)
        SCRIPT_PATH=$(echo $SCRIPT_GROUP|cut -d ";" -f 2)
        INDENT=$(echo $SCRIPT_GROUP|cut -d ";" -f 3)
        SURLINE=$(echo $SCRIPT_GROUP|cut -d ";" -f 4)
        if [[ -z $SCRIPT_PATH ]]; then
            buf="${buf}${line}\n"
        else
            SCRIPT_PATH=$(echo $SCRIPT_PATH | xargs)
            buf="${buf}${PRELINE}\n"
            while read line2; do
                buf2=''
                for (( i=0; i<$INDENT; ++i))
                do
                    buf2="${buf2} "
                done
                buf2="${buf2}${line2}"
                buf="${buf}${buf2}\n"
            done < <(grep "" $SCRIPT_PATH)
            buf="${buf}${SURLINE}\n"
        fi
    done < <(grep "" $file)
    echo '----'
    echo -e $buf
    echo -e $buf |yq -ojson
    newman run /dev/stdin < <(echo -e $buf | yq -ojson eval)
done
