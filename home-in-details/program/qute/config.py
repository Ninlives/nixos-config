from qutebrowser.api import cmdutils, message

config.load_autoconfig(True)

acl_proxy    = 'socks://@address@:@aclPort@'
global_proxy = 'socks://@address@:@localPort@'

c.content.javascript.can_access_clipboard = True;
c.content.proxy     = acl_proxy
c.scrolling.smooth  = True
c.auto_save.session = True

config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('<Ctrl-p>', 'spawn --userscript qute-keepass -p ~/.config/nixpkgs/security/data/Password.kdbx', mode='insert')

@cmdutils.register()
def toggle_proxy():
    if c.content.proxy == global_proxy:
        c.content.proxy = acl_proxy
        message.info(f"Switch proxy to {acl_proxy}")
    elif c.content.proxy == acl_proxy:
        c.content.proxy = 'none'
        message.info(f"Switch proxy to none")
    else:
        c.content.proxy = global_proxy
        message.info(f"Switch proxy to {global_proxy}")
