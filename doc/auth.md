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

## OpenLdap

```bash
docker run -it -d  --name openldap --net=host \
        -e LDAP_TLS=false \
        -e LDAP_ADMIN_PASSWORD=admin \
        osixia/openldap:1.2.2
```