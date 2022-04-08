# Session

## Token

A token contains the following elements : 
 - userId
 - the expiration date
 - signature
 
Token validity period can be change in tercen config file.

```yaml
tercen.token.validity: '15' #15 days
```
The token signature is generate using a secret key.

The secret key can be change in tercen config file.
```yaml
tercen.secret: "3ab70b11-d7bd-4097-958f-01b7ac4e955f"
```

# SAML

To use SAML authentication the following properties need to be configured in tercen config file.

## Azure AD

```yaml
tercen.auth.method: 'saml'
tercen.saml.request.issuer: https://my.tercen.com/_service/sso/auth/saml
tercen.saml.idp.issuer: https://sts.windows.net/5b5c94c6-14cf-42da-85bc-4e08722b253b/
tercen.saml.audience: https://my.tercen.com/_service/sso/auth/saml
tercen.saml.binding.url: https://login.microsoftonline.com/5b5c94c6-14cf-42da-85bc-4e08722b253b/saml2
tercen.saml.certificate.file: /etc/tercen/saml/cert.pem
```
## Keycloak


```shell
mkdir /home/alex/dev/keycloak/data
# running keycloak in port 5480
docker run -d --name keycloak -p 5480:8080 \
      -e KEYCLOAK_USER=admin \
      -e KEYCLOAK_PASSWORD=admin \
      -v /home/alex/dev/keycloak/data:/opt/jboss/keycloak/standalone/data/ \
      quay.io/keycloak/keycloak:16.1.1
```

Tercen config 

```yaml
tercen.auth.method: 'saml'
tercen.saml.request.issuer: http://tercen01:5400/_service/sso/auth/saml
tercen.saml.audience: http://tercen01:5400/_service/sso/auth/saml
tercen.saml.idp.issuer: http://127.0.0.1:5480/auth/realms/master/protocol/saml
tercen.saml.binding.url: http://127.0.0.1:5480/auth/realms/master/protocol/saml
tercen.saml.certificate.file: /home/alex/.config/tercen/cert.pem
```

Keycloak setting
```text
- Name ID Format : is set to email.
- Client Signature Required : is off
```

## PEM certificate
Here is an example of PEM certificate :

```text
-----BEGIN CERTIFICATE-----
MIIC8DCCAdigAwIBAgIQGKJCRqQqqYhF69tbYp0/NDANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQD
EylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMjAyMjMwOTIx
MzdaFw0yNTAyMjMwOTIxMzdaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQg
U1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxnS2mMMQ+LNs
j0apk9t0aMwmgbdVQHWvR4pgyhG3ztvK+lodjg0DZpzX7pwOv8ahJ7syz54lGQccf4MjMbuJut4+
vLk7KGeJOP/vGlBy+E9kFRXxxzvXbnkR64c4z7QKZXjXRLfSq58pJd/MYrhX7jGRyVo8u1QFspiu
Mbo4KooKIJ3wrIxkDXF2r39xufaKOjB3q8SKoOAWA1Yb3r2q4SxqGed8JlzF3RnijQFPa8YgU53X
AHEWG1gMYWiwID3YauKCVl9go9zMMj8fsnMEz6UIwaLZ3wUODFyRmwEkRvk1Qi/MhPqryqO5UMsO
bH9d2LpzwjPvH82Txo7xrvc1SQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBlQotwm8WY+2GYGhE1
12qC5yV80IHk/QB5aJM6o1UWBTddf0On/TneEVUfoNXAl+MiFH5CRN3X+noRRuQ7LGHXa6xkhSnY
3Rj4KuENHQPerCCMND9tSdSpJVHSN/AvTD3p6zhvl942O9Pvd3BRlL6ID7tYZdf3gmSfcTfhwsDv
eaoCql0ZfhGh2Y5xD80rzHb6mpjMp7weJfEJ4w2QcO1iKn7hP6hn7UrU97/+BiUfneh3E8s2T5wV
3oXC3zC8t5y7NeKhRRUBMDBko9PI6e51/oBJKKyqtSfYDZpiASur53e5bCsV4sbsaIEX/jm8OAbR
Si4fVLNr4sYh107TfGFC
-----END CERTIFICATE-----
```



# ldap

To use ldap for authentication set the following in ./config/tercen.config.yaml file.

```yaml
tercen.user.service: 'ldap'
tercen.user.service.ldap.host: '127.0.0.1'
tercen.user.service.ldap.port: '389'
# TLS
# tercen.user.service.ldap.protocol: 'ssl'
# tercen.user.service.ldap.port: '636'

tercen.user.service.ldap.admin.dn: cn=admin,dc=example,dc=org
tercen.user.service.ldap.admin.password: admin
tercen.user.service.ldap.base.search: dc=example,dc=org
tercen.user.service.ldap.search.attribute: uid
# tercen.user.service.ldap.method: compare
tercen.user.service.ldap.method: bind
```
## Authentication directly to the LDAP server ("bind" authentication).

When a new session is created, the following is executed
- using ldap admin account, search for an object where uid=username
- if not found an invalid credential error is generated
- if found, use the object DN and password to perform a [bind](https://ldap.com/the-ldap-bind-operation/)
- if the [bind](https://ldap.com/the-ldap-bind-operation/) operation succeed a Token is generated,
 and a session is created based on that token.
  
## Password comparison

When a new session is created, the following is executed
- using ldap admin account, search for an object where uid=username
- if not found an invalid credential error is generated
- if found, compare stored password (SSHA) with given password
- if passwords match a Token is generated, and a session is created based on that token.

## TLS

For now self signed certificate is accepted.

## Using OpenLdap

Start openldap container and populate it with adam user.

```bash
docker run -it -d  --name openldap \
        -e LDAP_TLS=false \
        -e LDAP_ADMIN_PASSWORD=admin \
        -p 3890:389 \
        osixia/openldap:1.2.2

# add user
# user : adam
# pwd: adam
docker cp doc/adam_ldap_user.ldif openldap:/adam_ldap_user.ldif
docker exec -it openldap ldapadd -x -w admin -D "cn=admin,dc=example,dc=org" -f /adam_ldap_user.ldif
```

Set the following config and restart tercen.

Tercen config

```shell
tercen.user.service: 'ldap'
tercen.user.service.ldap.host: '172.17.0.1'
tercen.user.service.ldap.protocol: ''
tercen.user.service.ldap.port: '3890'
tercen.user.service.ldap.admin.dn: cn=admin,dc=example,dc=org
tercen.user.service.ldap.admin.password: admin
tercen.user.service.ldap.base.search: dc=example,dc=org
tercen.user.service.ldap.search.attribute: uid
tercen.user.service.ldap.method: bind
```

Clean up

```shell
docker rm -f openldap
```