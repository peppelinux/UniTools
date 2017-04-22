import os

DOMAIN_NAME     = 'test.unical.it'
IDPS_HOSTNAMES  = ['idp.test.unical.it',]
SPS_HOSTNAMES   = ['sp.'+DOMAIN_NAME]

# this should be overloaded by:  readlink -f /usr/bin/java | sed "s:bin/java::"
JAVA_HOME         = '/usr/lib/jvm/java-7-openjdk-amd64/jre'
TOMCAT_INST_PATH  = '/etc/tomcat7'
TOMCAT_JAR_PATH   = '/usr/share/tomcat7/lib'
TOMCAT_ADMIN_PW   = 'password'
TOMCAT_MANAGER_PW = 'password'
JSTL_DL_URL       = 'https://repo1.maven.org/maven2/jstl/jstl/1.2/jstl-1.2.jar'

LDAP_PW           = 'password'

IDP_DL_URL        = 'https://shibboleth.net/downloads/identity-provider/3.3.1/shibboleth-identity-provider-3.3.1.tar.gz'
IDP_INSTALL_PATH  = '/opt/shibboleth-idp' 
IDP_PW            = 'password'

IDPDP_USER = 'shibboleth'
IDPDP_PASW = 'password'

MYSQL_USER = 'shibboleth'
MYSQL_PW   = 'password'

BASE_DIR     = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_DIR = BASE_DIR+'/templates'
