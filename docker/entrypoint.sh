#!/bin/sh
set -e

# sh 启动时会把 PWD 重置为当前目录，覆盖掉通过 PWD 传入的密码；
# 从本进程初始环境里取回原值
MIMOTION_PWD="$(tr '\0' '\n' < /proc/$$/environ | sed -n 's/^PWD=//p')"
export MIMOTION_PWD

# 带参数时直接执行，例如手动跑一次：/app/mimotion
if [ "$#" -gt 0 ]; then
  if [ -n "$MIMOTION_PWD" ]; then
    export PWD="$MIMOTION_PWD"
  fi
  exec "$@"
fi

JOB=/app/mimotion
if [ -n "$MIMOTION_PWD" ]; then
  # supercronic 用 sh -c 执行任务，同样会重置 PWD，这里在命令前恢复
  JOB="PWD=\"\$MIMOTION_PWD\" $JOB"
fi
echo "$CRON $JOB" > /tmp/crontab
echo "定时任务: $(cat /tmp/crontab) (TZ=$TZ)"
exec supercronic -passthrough-logs /tmp/crontab
