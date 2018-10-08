
## ENV ##

timestamp="$(date +%s)"
log="main.${timestamp}.log"

## MAIN ##

echo "Log: ${log}"
echo
set -x

BASE_IMAGE="dellelce/py-base" \
TARGET_IMAGE="dellelce/airflow-base" \
PREFIX="/app/airflow" \
./main.sh > ${log} &

## EOF ##
