#!/bin/bash
cp -Rf 99-default-settings package/emortal/default-settings/files/99-default-settings
cp -Rf SourceCode feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
cp -Rf SourceCode package/emortal/autocore/files/arm/rpcd_10_system.js
cp -Rf SourceCode package/emortal/autocore/files/x86/rpcd_10_system.js
chmod 664 feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
chmod 664 package/emortal/autocore/files/arm/rpcd_10_system.js
chmod 664 package/emortal/autocore/files/x86/rpcd_10_system.js
rm -rf {99-default-settings,SourceCode,Convert.sh,1806-default-settings}
exit 0
