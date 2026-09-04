jar cvfm MyApp.jar MANIFEST.MF -C bin/ .
systemctl status getty@tty5
● getty@tty5.service - Getty on tty5
     Loaded: loaded (/usr/lib/systemd/system/getty@.service; disabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/getty@tty5.service.d
             └─joe_auto_login.conf
 ...
