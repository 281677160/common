#!/bin/bash

sed -i '/coremark/d' /etc/rc.local
sed -i '/mediaurlbase/d' /etc/rc.local
rm -rf /etc/FinishIng.sh

exit 0
