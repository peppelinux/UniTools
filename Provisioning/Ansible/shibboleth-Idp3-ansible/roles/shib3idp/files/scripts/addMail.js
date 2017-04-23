
importPackage(Packages.org.slf4j);
  
logger = LoggerFactory.getLogger("net.shibboleth.idp.attribute");
addM.addValue("foo@bar.com");
addM.addValue("bar@bar.bar");
 
logger.info("Values of scriptTest were: {} ", addM.getValues());

