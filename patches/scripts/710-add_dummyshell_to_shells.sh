[ "$FREETZ_PATCH_CUSTOM_TOOLS_DUMMYSHELL_LOGIN_SHELL" == "y" ] || return 0
echo1 "adding dummyshell to the list of login shells"
grep -q "^/usr/bin/dummyshell$" "${FILESYSTEM_MOD_DIR}/etc/shells" >/dev/null 2>&1 || ( echo "/usr/bin/dummyshell" >> "${FILESYSTEM_MOD_DIR}/etc/shells" )
