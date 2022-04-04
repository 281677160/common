#!/bin/bash

sed -i '/coremark/d' /etc/rc.local
sed -i '/mediaurlbase/d' /etc/rc.local
sed -i '/FinishIng.sh/d' /etc/rc.local
rm -rf /etc/FinishIng.sh
if [[ -f '/etc/webweb.sh' ]]; then
  source /etc/webweb.sh
  reboot -f
fi
exit 0
