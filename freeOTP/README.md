Install deps, plug phone and dump backup 
```
apt install adb maven qrencode
adb backup -f ./freeotp.ab -noapk org.fedorahosted.freeotp
git clone https://github.com/nelenkov/android-backup-extractor.git
cd android-backup-extractor
mvn clean package
cd ..
java -jar android-backup-extractor/target/abe.jar unpack freeotp.ab tokens
````

print out values
````
import base64
import json
import html
import re
import os


with open('tokens') as a:
    b = a.read()
    
    start, end = b.index('<map>'), b.index('</map>')
    for i in b[start:end].splitlines()[1:]:
        res = re.findall(r'(:?<.*>)(.*)(:?<.*>)', i)
        if res and len(res[0]) > 1:
            s = html.unescape(res[0][1])
            data = json.loads(s)
            if isinstance(data, dict):
                for k,v in list(data.items()):
                    if k == 'secret':
                        val = bytes((x + 256) & 255 for x in v)
                        code = base64.b32encode(val).decode()
                        data['secret_decoded'] = code
                    if not data.get('issuerInt'):
                        data['issuerInt'] = data['issuerExt']

                # otpauth://totp/ACME%20Co:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30
                _url = "otpauth://totp/{issuerInt}:{label}?secret={secret_decoded}&issuer={issuerInt}&algorithm={algo}&digits={digits}&period={period}".format(**data)
                print(f"{k}: {v}")
                print(_url)
                os.system(f'qrencode -o "token.png" "{_url}"')
                os.system("display token.png")
                    
                print()
````

We'll get something like this

````
algo: SHA1
counter: 0
digits: 6
issuerExt: Slack
issuerInt: Slack
label: giuseppe@that.mail
period: 30
secret: THATSECRET
type: TOTP
````

and also it will display a QRcode image to easily import the OTP in your mobile phone.
