#!/bin/bash

export Convert_path="$HOME_PATH/build/common/Convert"
cp -Rf ${Convert_path}/99-default-settings $HOME_PATH/package/emortal/default-settings/files/99-default-settings
cp -Rf ${Convert_path}/SourceCode $HOME_PATH/feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
cp -Rf ${Convert_path}/SourceCode $HOME_PATH/package/emortal/autocore/files/arm/rpcd_10_system.js > /dev/null 2>&1
cp -Rf ${Convert_path}/SourceCode $HOME_PATH/package/emortal/autocore/files/x86/rpcd_10_system.js > /dev/null 2>&1
chmod 664 $HOME_PATH/feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
chmod 664 $HOME_PATH/package/emortal/autocore/files/arm/rpcd_10_system.js > /dev/null 2>&1
chmod 664 $HOME_PATH/package/emortal/autocore/files/x86/rpcd_10_system.js > /dev/null 2>&1
exit 0
