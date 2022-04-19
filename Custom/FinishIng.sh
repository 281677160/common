#!/bin/bash

if [[ -f '/etc/webweb.sh' ]]; then
  source /etc/webweb.sh
  reboot -f
fi
if [[ -f '/mnt/network' ]]; then
  cp -Rf /mnt/network /etc/config/network
  uci commit luci
fi
sed -i '/coremark/d' /etc/rc.local
sed -i '/mediaurlbase/d' /etc/rc.local
rm -rf /etc/FinishIng.sh

exit 0
