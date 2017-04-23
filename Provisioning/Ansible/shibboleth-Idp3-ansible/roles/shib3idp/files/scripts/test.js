importPackage(Packages.org.slf4j);
logger = LoggerFactory.getLogger("net.shibboleth.idp.attribute");

//        Java8
//        logger = Java.type("org.slf4j.LoggerFactory").getLogger("net.shibboleth.idp.attribute.resolver.scriptDiTest")

// logger = LoggerFactory.getLogger("scriptTesting");
// scriptTest = new BasicAttribute("scriptTest");

scriptTest.getValues().add("################################## Valori a disposizione dell'IdP ##################################");

logger.info( scriptTest.getValues());

notavailmsg="N/A: maybe not referenced as dependency in resolver:AttributeDefinition of THIS script";
try { logger.info("distinguishedName: " + distinguishedName.getValues()); } catch(err) { logger.info("distinguishedName: "+notavailmsg); }
try { logger.info("uid: " + uid.getValues()); } catch(err) { logger.info("uid: "+notavailmsg); }
try { logger.info("sn: " + sn.getValues()); } catch(err) { logger.info("sn: "+notavailmsg); }
try { logger.info("givenName: " + givenName.getValues()); } catch(err) { logger.info("givenName: "+notavailmsg); }
try { logger.info("mail: " + mail.getValues()); } catch(err) { logger.info("mail: "+notavailmsg); }
try { logger.info("commonName: " + commonName.getValues()); } catch(err) { logger.info("commonName: "+notavailmsg); }
try { logger.info("surname: " + surname.getValues()); } catch(err) { logger.info("surname: "+notavailmsg); }
try { logger.info("givenName: " + givenName.getValues()); } catch(err) { logger.info("givenName: "+notavailmsg); }
try { logger.info("accountName: " + accountName.getValues()); } catch(err) { logger.info("accountName: "+notavailmsg); }
try { logger.info("eduPersonPrincipalName: " + eduPersonPrincipalName.getValues()); } catch(err) { logger.info("eduPersonPrincipalName: "+notavailmsg); }
try { logger.info("epeList: " + epeList.getValues()); } catch(err) { logger.info("epeList: "+notavailmsg); }
try { logger.info("eduPersonEntitlement: " + eduPersonEntitlement.getValues()); } catch(err) { logger.info("eduPersonEntitlement: "+notavailmsg); }
try { logger.info("affiliationID: " + affiliationID.getValues()); } catch(err) { logger.info("affiliationID: "+notavailmsg); }
try { logger.info("eduPersonAffiliation: " + eduPersonAffiliation.getValues()); } catch(err) { logger.info("eduPersonAffiliation: "+notavailmsg); }
try { logger.info("eduPersonScopedAffiliation: " + eduPersonScopedAffiliation.getValues()); } catch(err) { logger.info("eduPersonScopedAffiliation: "+notavailmsg); }
try { logger.info("displayName: " + displayName.getValues()); } catch(err) { logger.info("displayName: NOT "+notavailmsg); }
try { logger.info("Group: " + Group.getValues()); } catch(err) { Group.info("Group: "+notavailmsg); }
try { logger.info("mappedGroup: " + mappedGroup.getValues()); } catch(err) { logger.info("mappedGroup: "+notavailmsg); }
try { logger.info("adGroup: " + adGroup.getValues()); } catch(err) { logger.info("adGroup: "+notavailmsg); }
try { logger.info("eduPersonTargetedID: " + eduPersonTargetedID.getValues()); } catch(err) { logger.info("eduPersonTargetedID: "+notavailmsg); }
try { logger.info("transientId: " + transientId.getValues()); } catch(err) { logger.info("transientId: NOT "+notavailmsg); }
try { logger.info("schacHomeOrganization: " + schacHomeOrganization.getValues()); } catch(err) { logger.info("schacHomeOrganization: "+notavailmsg); }
try { logger.info("schacHomeOrganizationType: " + schacHomeOrganizationType.getValues()); } catch(err) { logger.info("schacHomeOrganizationType: "+notavailmsg); }
try { logger.info("ITCF: " + ITCF.getValues()); } catch(err) { logger.info("ITCF: "+notavailmsg); }
try { logger.info("preferredLanguage: " + preferredLanguage.getValues()); } catch(err) { logger.info("preferredLanguage: "+notavailmsg); }
try {
    for ( i = 0;  i < memberOf.getValues().size(); i++ ){
	 logger.info("MemberOf: " + memberOf.getValues().get(i));  
    }
} catch(err) { logger.info("memberOf: "+notavailmsg); }

