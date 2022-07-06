Please create an SSL Certiifcate for the installation with an appropriate DNS name
You will need it in two formats 

1. For the Nginx Ingress inbound SSL (.crt + .pem)
2. For the Signing of JWT Tokens in TenatService (.pfx + password)

If the password is differnet from that configured in the YAML file please change it.

place the following files in this directory named as follows:

<installationName>.crt
<installationName>.key

<installationName>.pfx


OpenSSL Commands:

From PFX

Get the .key

    openssl pkcs12 -in [installationName.pfx] -nocerts -out [installationName-encrypted.key]

extract private key data

    openssl rsa -in [installationName-encrypted.key] -out [keyfilename-decrypted.key]

Get the .crt 

    openssl pkcs12 -in [installationName.pfx] -clcerts -nokeys -out [installationName.crt]

From 

    openssl pkcs12 -export -out installationName.pfx -inkey installationName.key -in installationName.crt

Viw pfx details

    openssl pkcs12 -info -in certificate.pfx -nodes