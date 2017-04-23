<?php
$header_attributes = array(
		"HTTP_EPPN"								=>array (REQUIRED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.6"),
		"HTTP_AFFILIATION"						=>array (REQUIRED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.9"),
		"HTTP_UNSCOPED_AFFILIATION"				=>array (REQUIRED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.1"),
		"HTTP_ENTITLEMENT"						=>array (REQUIRED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.7"),
		"HTTP_PERSISTENT_ID"					=>array (NONEED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.10"),
		"HTTP_PRIMARY_AFFILIATION"				=>array (NONEED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.5"),
		"HTTP_NICKNAME"							=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.2"),
		"HTTP_PRIMARY_ORGUNIT_DN"				=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.8"),
		"HTTP_ORGUNIT_DN"						=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.4"),
		"HTTP_ORG_DN"							=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.3"),
		"HTTP_CN"								=>array (OPTIONAL,"","urn:oid:2.5.4.3"),
		"HTTP_SN"								=>array (OPTIONAL,"","urn:oid:2.5.4.4"),
		"HTTP_GIVENNAME"						=>array (OPTIONAL,"","urn:oid:2.5.4.42"),
		"HTTP_MAIL"								=>array (OPTIONAL,"","urn:oid:0.9.2342.19200300.100.1.3"),
		"HTTP_UID"								=>array (OPTIONAL,"","urn:oid:0.9.2342.19200300.100.1.1"),
		"HTTP_TELEPHONENUMBER"					=>array (OPTIONAL,"","urn:oid:2.5.4.20"),
		"HTTP_TITLE"							=>array (OPTIONAL,"","urn:oid:2.5.4.12"),
		"HTTP_INITIALS"							=>array (OPTIONAL,"","urn:oid:2.5.4.43"),
		"HTTP_DESCRIPTION"						=>array (OPTIONAL,"","urn:oid:2.5.4.13"),
		"HTTP_CARLICENSE"						=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.1"),
		"HTTP_DEPARTMENTNUMBER"					=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.2"),
		"HTTP_DISPLAYNAME"						=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.241"),
		"HTTP_EMPLOYEENUMBER"					=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.3"),
		"HTTP_EMPLOYEETYPE"						=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.4"),
		"HTTP_PREFERREDLANGUAGE"				=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.39"),
		"HTTP_MANAGER"							=>array (OPTIONAL,"","urn:oid:0.9.2342.19200300.100.1.10"),
		"HTTP_SEEALSO"							=>array (OPTIONAL,"","urn:oid:2.5.4.34"),
		"HTTP_FACSIMILETELEPHONENUMBER"			=>array (OPTIONAL,"","urn:oid:2.5.4.23"),
		"HTTP_POSTALADDRESS"					=>array (OPTIONAL,"","urn:oid:2.5.4.16"),
		"HTTP_STREET"							=>array (OPTIONAL,"","urn:oid:2.5.4.9"),
		"HTTP_POSTOFFICEBOX"					=>array (REQUIRED,"","urn:oid:2.5.4.18"),
		"HTTP_POSTALCODE"						=>array (OPTIONAL,"","urn:oid:2.5.4.17"),
		"HTTP_ST"								=>array (OPTIONAL,"","urn:oid:2.5.4.8"),
		"HTTP_L"								=>array (OPTIONAL,"","urn:oid:2.5.4.7"),
		"HTTP_O"								=>array (OPTIONAL,"","urn:oid:2.5.4.10"),
		"HTTP_OU"								=>array (OPTIONAL,"","urn:oid:2.5.4.11"),
		"HTTP_BUSINESSCATEGORY"					=>array (OPTIONAL,"","urn:oid:2.5.4.15"),
		"HTTP_PHYSICALDELIVERYOFFICENAME"		=>array (OPTIONAL,"","urn:oid:2.5.4.19"),
		"HTTP_ROOMNUMBER"						=>array (OPTIONAL,"","urn:oid:0.9.2342.19200300.100.1.6"),
		"HTTP_SHIB_IDENTITY_PROVIDER"			=>array (OPTIONAL,"","Default attribute"),
		"HTTP_SHIB_AUTHENTICATION_METHOD"		=>array (OPTIONAL,"","Default attribute"),
		"HTTP_SHIB_AUTHENTICATION_INSTANT"		=>array (OPTIONAL,"","Default attribute"),
		"HTTP_SHIB_AUTHNCONTEXT_CLASS"			=>array (OPTIONAL,"","Default attribute"),

		);

$environment_attribute = array(
#Name of the environment variable	=>array (NONEED|OPTIONAL|REQUIRED, "value or regex", SAML attribute name),
		"codiceaccesso"						=>array (REQUIRED,"","ORGANIZZAZIONE_servizioX_codice"),
		"eppn"						=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.6"),
		"affiliation"				=>array (NONEED,"staff","urn:oid:1.3.6.1.4.1.5923.1.1.1.9"),
		"entitlement"				=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.7"),
		"displayName"				=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.241"),
		"cn"						=>array (OPTIONAL,"","urn:oid:2.5.4.3"),
		"sn"						=>array (OPTIONAL,"","urn:oid:2.5.4.4"),
		"givenName"					=>array (OPTIONAL,"","urn:oid:2.5.4.42"),
		"mail"						=>array (REQUIRED,"@{{ domain }}","urn:oid:0.9.2342.19200300.100.1.3"),
		"uid"						=>array (NONEED,"","urn:oid:0.9.2342.19200300.100.1.1"),
		"telephoneNumber"			=>array (NONEED,"","urn:oid:2.5.4.20"),
		"title"						=>array (NONEED,"","urn:oid:2.5.4.12"),
		"schacHomeOrganization"		=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.25178.1.2.9"),
		"schacHomeOrganizationType"	=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.25178.1.2.10"),
		"ActiveDir_group"			=>array (OPTIONAL,"","miaOrganizzazione:adGroup"),
		"Additional_mail"			=>array (OPTIONAL,"","miaOrganizzazione:adMail"),
/*		"persistent-id"				=>array (REQUIRED,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.10"),
		"initials"					=>array (REQUIRED,"test","urn:oid:2.5.4.43"),
		"description"				=>array (OPTIONAL,"","urn:oid:2.5.4.13"),
		"unscoped-affiliation"		=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.1"),
		"org-dn"					=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.3"),
		"carLicense"				=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.1"),
		"departmentNumber"			=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.2"),
		"primary-affiliation"		=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.5"),
		"nickname"					=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.2"),
		"primary-orgunit-dn"		=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.8"),
		"orgunit-dn"				=>array (OPTIONAL,"","urn:oid:1.3.6.1.4.1.5923.1.1.1.4"),
		"displayName"				=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.241"),
		"employeeNumber"			=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.3"),
		"employeeType"				=>array (OPTIONAL,"","urn:oid:2.16.840.1.113730.3.1.4"),
		"preferredLanguage"			=>array (OPTIONAL,"test","urn:oid:2.16.840.1.113730.3.1.39"),
		"manager"					=>array (OPTIONAL,"","urn:oid:0.9.2342.19200300.100.1.10"),
		"seeAlso"					=>array (OPTIONAL,"","urn:oid:2.5.4.34"),
		"facsimileTelephoneNumber"	=>array (OPTIONAL,"","urn:oid:2.5.4.23"),
		"postalAddress"				=>array (OPTIONAL,"","urn:oid:2.5.4.16"),
		"street"					=>array (OPTIONAL,"","urn:oid:2.5.4.9"),
		"postOfficeBox"				=>array (NONEED,"test","urn:oid:2.5.4.18"),
		"postalCode"				=>array (NONEED,"","urn:oid:2.5.4.17"),
		"st"						=>array (OPTIONAL,"","urn:oid:2.5.4.8"),
		"l"							=>array (NONEED,"","urn:oid:2.5.4.7"),
		"o"							=>array (NONEED,"","urn:oid:2.5.4.10"),
		"ou"						=>array (OPTIONAL,"","urn:oid:2.5.4.11"),
		"businessCategory"			=>array (OPTIONAL,"","urn:oid:2.5.4.15"),
		"physicalDeliveryOfficeName"=>array (OPTIONAL,"","urn:oid:2.5.4.19"),
		"roomNumber"				=>array (OPTIONAL,"","urn:oid:0.9.2342.19200300.100.1.6")
*/
		);

 
#check if Shib-Identity-Provider environment variable is set. 
# If true, we can assume environment variables are enabled.
$header_name = "Environment Variable"; 

  if (! empty($_SERVER['Shib-Identity-Provider'])){
	$attributeArray = $environment_attribute;
  } else {
	$attributeArray = $header_attributes;
	$header_name = "Header Name"; 
  }


  foreach ($attributeArray  as $attribute => $options) {
    
    switch($options[0]) {
      case NONEED:	$attributes_noneed[$attribute]=$options;
      			break;
      
      case OPTIONAL: 	$attributes_optional[$attribute]=$options;
      			break; 
      
      case REQUIRED:    $attributes_required[$attribute]=$options;
			break;
      			
    }
  }
    ksort($attributes_noneed , SORT_STRING | SORT_FLAG_CASE);    
    ksort($attributes_optional , SORT_STRING | SORT_FLAG_CASE);    
    ksort($attributes_required , SORT_STRING | SORT_FLAG_CASE);
?>
