from fabric.api import run, env, shell_env
from fabric.operations import get, settings, put, sudo, local #*

import cuisine

# system dependencies
# aptitude  install build-essential
# aptitude  install python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev

# if cryptography module raise exception during setup:
# aptitude install python-pyparsing python-appdirs
# pip install appdirs --upgrade
# pip install pyparsing --upgrade
# pip uninstall cryptography
# pip install cryptography
# pip install fabric cuisine --upgrade

#il server A e il client B.
#Se voglio collegarmi senza password da B ad A faccio su B:
#ssh-keygen -t dsa
#ssh-copy-id -i ~/.ssh/id_dsa.pub AHOSTNAME
# EVITA RSA!

# Fabric normally aborts the execution if it can't reach one of the hosts.
env.skip_bad_hosts=True

# connection timeout
# env.timeout=2

# We can set Fabric to only give a warning instead of aborting when something fails.
env.warn_only=True

def shutdown():
    with shell_env(PASW='pwdsudo'):
        run( 'echo $PASW | sudo -S init 0' )

def host_type():
    with settings(warn_only=True):
        run('uname -a')
    
def diskspace():
    run('df -ah')

def hello(name="world"):
   """
       call: fab hello:name=Jeff
   """
   print("Hello %s!" % name)

def get_backups(rpath="/var/backups/", lpath='~'):
   """
       call: fab get_backups:rpath="/var/backups/"
   """
   get(rpath, lpath)

def run_command(os_command):
   run(os_command)

def put_file(lpath,rpath):
   put(lpath,rpath)

def replace_web_profiles(home_path):
   run('rm -R %s/.mozilla' % home_path)
   run('rm -R %s/.config/chromium' % home_path)
   run('mkdir %s/tmp_cla45; cd %s/tmp_cla45' % (home_path, home_path))
   run('tar xzvf %s/cla_user_web_profile*tar.gz -C %s/tmp_cla45/;' % (home_path, home_path))
   run('mv %s/tmp_cla45/.mozilla %s/; mv %s/tmp_cla45/chromium %s/.config/' % (home_path, home_path, home_path, home_path))
   run('rm -R %s/tmp_cla45/' % home_path)

def kill_webpage():
   words = ['chromium-browser', 'firefox']
   for i in words:
       run("ps ax | grep %s | awk -F' ' {'print $1'} | xargs echo | xargs kill -TERM" % i)

def open_webpage(webpage_url):
    with shell_env(DISPLAY=':0'):
        #run('nohup firefox "%s" &' % webpage_url, pty=False)
        run('nohup chromium-browser "%s" &' % webpage_url, pty=False)

def ensure_packages():
    packages = ['xdotool', 'firefox', 'chromium-browser', 'x11vnc']
    for i in packages:
        cuisine.package_ensure(i)

def wake_screen():
    with shell_env(DISPLAY=':0'):
        run('xdotool key k')

def wol_setup():
    sudo("echo enabled > /sys/bus/pci/devices/0000\:00\:$(lspci -tv | grep Ethernet | awk -F'-' {'print $2'})/power/wakeup")


def wol():
    macs = ['00:23:54:b6:2f:a1',
            '00:23:54:b6:36:06',
            '00:23:54:b6:31:11',
            '00:23:54:b6:34:d8',
            '00:23:54:b6:35:7b',
            '00:23:54:b6:31:a8',
            '00:23:54:b6:33:b0',
            '00:23:54:b6:2f:60',
            '00:23:54:b6:2c:e4',
            '00:23:54:b6:34:92',
            '00:23:54:b6:2f:8e',
            '00:23:54:b6:2e:ce',
            '00:23:54:b6:2b:13',
            '00:23:54:b6:2f:ac',
            '00:23:54:b6:34:63',
            '00:23:54:b6:33:38',
            '00:23:54:b6:36:56',
            '00:23:54:b6:36:96',
            '00:23:54:b6:36:12',
            '00:23:54:b6:2f:4c',
            '00:23:54:b6:35:8c',
            '00:23:54:b6:2e:f2',
            '00:23:54:b6:2f:3e',
            '00:23:54:b6:2f:4e',
            '00:23:54:b6:2e:f4',
            '00:22:43:5e:d0:f1',
            '00:23:54:b6:36:25',
            '00:23:54:b6:35:7f',
            '00:23:54:b6:2a:24',
            '00:0a:e6:19:22:03',
            '00:24:81:9d:ce:6e',
            'd4:3d:7e:07:35:b2',
            'd4:3d:7e:07:34:41']
    
    for i in macs:
        local('wakeonlan %s' % i)

def run_vnc():
    with shell_env(DISPLAY=':0'):
        run('nohup x11vnc -shared -forever -timeout 45 -tightfilexfer -nopw -bg', pty=False)
