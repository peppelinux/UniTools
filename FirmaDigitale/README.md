# Appunti
Il file p7m è un file di firma digitale nel formato CAdES (CMS Advanced Electronic Signatures) che è un’estensione del Cryptographic Message Syntax (CMS) che è basato a sua volta su PKCS#7. Il file p7m non è altro che un contenitore che incapsula sia il documento originale (non criptato) che la firma digitale personale e quella della catena della CA che ha rilasciato il certificato. Andando per ordine nel file p7m troviamo:
- nei primi byte  l’header PKCS#7
- poi viene il nostro documento originale (non criptato)
- quindi l’hash di firma (che valida per legge il contenuto)
- il certificato digitale personale di chi ha firmato
- ed infine il certificato della CA

# Tipi di firme
- PAdES (PDF Advanced Electronic Signatures)  è una firma che può essere apposta solo su file  PDF: l’apposizione di una firma PAdES lascia immutata l’estensione del documento, che continuerà a chiamarsi “nomefile.pdf”. As defined in the upcoming PDF 2.0 specification: The PDF signatures using the Subfilter value ETSI.CAdES.detached are referred to as PAdES signatures and they follow one of two CMS profiles created to be compatible with the corresponding CAdES profiles defined in ETSI EN 319 122 (ISO 32000-2 FDIS section 12.8.3.4 - CAdES signatures as used in PDF).

- CAdES (CMS Advanced Electronic Signatures) è una firma digitale che può essere apposta su qualsiasi tipo di file. Tale modalità di firma genera una “busta crittografica” contenente il documento informatico originale e si caratterizza per il suffisso P7M che si aggiunge all’estensione del file (es. citazione.pdf.p7m). In altri termini, nella firma CAdES il documento oggetto di firma digitale viene incapsulato in un contenitore informatico “chiuso” con una firma digitale, che ne garantisce quindi l’autenticità e l’integrità (oltre che il “non ripudio”);

- Xades, si possono firmare solo file xml;

NB: DER is binary format, its structure is called ASN.1. PEM format is Base64 encoded DER.


# Collegamenti e risorse esterne
- https://github.com/mozilla-releng/signtool
- https://github.com/wbond/asn1crypto
- https://msdn.microsoft.com/en-us/library/8s9b9yaz(VS.80).aspx
- http://penguindreams.org/blog/signature-verification-between-java-and-python/
- https://gist.github.com/ezimuel/3cb601853db6ebc4ee49
- https://stackoverflow.com/questions/10782826/digital-signature-for-a-file-using-openssl
- https://www.zimuel.it/blog/sign-and-verify-a-file-using-openssl
- http://qistoph.blogspot.it/2012/01/manual-verify-pkcs7-signed-data-with.html

java
- http://wiki.cacert.org/PdfSigning
- https://github.com/kwart/jsignpdf (http://jsignpdf.sourceforge.net/)
- http://j4sign.sourceforge.net/
- https://www.linuxtrent.it/documentazione/pillole-e-annotazioni-tecniche/pillola-31-firmare-digitalmente-un-documento-pdf-trami
- https://github.com/open-eid/SiVa
- https://github.com/damianofalcioni/Websocket-Smart-Card-Signer

js
- https://github.com/web-eid/web-eid.js
- http://kjur.github.io/jsrsasign/

normativa
- http://www.agid.gov.it/agenda-digitale/infrastrutture-architetture/il-regolamento-ue-ndeg-9102014-eidas

Playing pdfs
- https://williamjturkel.net/2013/08/24/working-with-pdfs-using-command-line-tools-in-linux/

# Qualche appunto

Per Cades può andare bene
````
# estrazione
perl -ne 's/^.*%PDF/%PDF/; print if /%PDF/../%%EOF/' documento.pdf.p7m >documento.pdf

# verifica della firma senza estrazione del file
openssl smime -verify -noverify -in documento.pdf.p7m -inform DER -out documento.pdf

# Per estrarre il certificato digitale personale di chi ha firmato basta usare openssl con il comando
openssl pkcs7 -inform DER -in documento.pdf.p7m -print_certs -out cert.pem

````

Binwalk, ti dice sempre la verità
````
#https://github.com/ReFirmLabs/binwalk/wiki/Usage
binwalk -B filename
````

Controllare presenza token hardware di firma digitale
````
apt install opensc
pkcs15-tool -c
````


