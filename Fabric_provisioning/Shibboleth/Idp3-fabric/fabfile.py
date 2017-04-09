from fabric.api import hosts,run,execute,shell_env,roles,warn_only
from fabric.operations import get, settings, put, sudo, local
from fabric.contrib.files import sed, exists
from fabric.state import env
import cuisine

from jinja2 import Template, Environment, FileSystemLoader
from StringIO import StringIO
import sys
import datetime

from config import *

# template engine
_j2_env    = Environment(loader=FileSystemLoader(TEMPLATE_DIR),
                            trim_blocks=True)

# roles
env.roledefs['shibboleth-idp'] = IDPS_HOSTNAMES
env.roledefs['shibboleth-sp']  = SPS_HOSTNAMES
env.roledefs['all']            = IDPS_HOSTNAMES + SPS_HOSTNAMES

def _run_safe_commands(commands):
    for command in commands:
        #~ print('run: %s' % command)
        r = run(command)
        if r.failed:
            raise Exception('%s execution failed' % command)


def _safe_put(localfile, remotefile):
    """
        do backup before overwrite
        _suffix is the value that will be appended to the file
    """
    _suffix = '.%s.bak' % datetime.datetime.now().strftime('%Y-%m-%d_%H%M')
    if exists(remotefile):
        run('mv %s %s' % (remotefile, remotefile+_suffix))
    #~ print('put %s. Backup: %s' % (remotefile, remotefile+_suffix))
    put(localfile, remotefile)

def _download_file(furl, fpath):
    if not exists(fpath):
        print('Downloading %s' % furl)
        r = run('wget %s -P %s' % (furl, fpath))
        if r.failed:
            raise Exception('Download error')

def _install_packages(packages):
    """
        packages = ['nginx', 'mysql-server', ...]
    """
    for package in packages:
        cuisine.package_ensure(package) 

@roles('all')
def install_requirements():
    pass
    
@roles('shibboleth-idp')
def setup_idp():
    _install_packages([    
                'html2text',
                'emacs24-nox',
                'vim',
                'ntp',
                'apache2',
                'openjdk-7-jdk',
                #~ 'libjstl1.1-java',
                #~ 'tomcat7',
                #~ 'libmysql-java',
                'libapache2-mod-shib2',
                'libapache2-mod-php5',
                'slapd',
                ])

@roles('shibboleth-idp')
def install_tomcat7_idp():
    """
      Do not use this if you have an already running instance of tomcat
    """
    print(sys._getframe().f_code.co_name)
    _install_packages([
                    'tomcat7', 
                    'libmysql-java', 
                    'libjstl1.1-java'
                    ])
    
    # RENDER AND PUT idp.xml template into Catalina
    idpxml =  _j2_env.get_template('tomcat7/idp.xml').render(
                                            idp_path = IDP_INSTALL_PATH,
                                            )
    _safe_put(    
        StringIO(idpxml), 
        TOMCAT_INST_PATH+'/Catalina/localhost/idp.xml'
        )
    
    _safe_put(    
        TEMPLATE_DIR+'/tomcat7/server.xml', 
        TOMCAT_INST_PATH+'/server.xml'
        )
    
    _safe_put(    
        TEMPLATE_DIR+'/tomcat7/tomcat7', 
        '/etc/default/tomcat7'
        )
    
    # installs addictional JARS
    _download_file( JSTL_DL_URL, TOMCAT_JAR_PATH,  )
    
    commands = [
    #~ 'systemctl tomcat7 enable',
    'update-rc.d tomcat7 enable',
    'service tomcat7 restart'
    ]
    
    _run_safe_commands(commands)
    with settings(warn_only=True): 
        run('ln -sf /usr/share/java/mysql.jar /usr/share/tomcat7/lib/mysql.jar')
    
@roles('shibboleth-idp')
def install_shibboleth_idp():
    commands = [
    'chown -R tomcat7 {0}/conf/ {0}/logs/ {0}/metadata/ {0}/credentials/'.format(
            IDP_INSTALL_PATH),
            ]
    
@roles('shibboleth-idp')
def configure_idp():
    # http://docs.fabfile.org/en/1.13/api/contrib/files.html
    # fabric.contrib.files.upload_template
    # fabric sed

    
    _ldap_properties_file = _idp_path + '/conf/ldap.properties'
    print('modify %s' % _ldap_properties_file)
    sed(_ldap_properties_file, 
        '#idp.authn.LDAP.authenticator\t*\s*= bindSearchAuthenticator', 
        'idp.authn.LDAP.authenticator = bindSearchAuthenticator')
    
    
    
    
@roles('shibboleth-idp')
def install_mysql():
    run('apt-get install mysql-server', with_sudo=True)
 
def deploy():
    execute(install_apache)
    execute(install_mysql)
