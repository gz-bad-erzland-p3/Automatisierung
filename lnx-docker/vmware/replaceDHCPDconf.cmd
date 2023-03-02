@ECHO OFF

SET DHCPD_FILENAME=vmnetdhcp.conf
SET DHCPD_PATH=%ALLUSERSPROFILE%\VMware

xcopy "%~dp0%DHCPD_FILENAME%" "%DHCPD_PATH%\%DHCPD_FILENAME%" /Y

%Public%\Desktop\SystemDienste\restartVMdhcp.lnk
