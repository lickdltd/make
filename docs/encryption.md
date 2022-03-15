# encryption

* [setup](#setup)
  * [key](#key)
  * [directory definitions](#directory-definitions)
* [commands](#commands)
  * [encrypt](#encrypt)
  * [decrypt](#decrypt)

## setup

### key

```makefile
enc_%: ENC_KMS_KEY = alias/your-kms-key-name
```

### directory-definitions

```makefile
enc_%: ENC_DIRECTORY_DECRYPTED = $(PWD)/path/to/decrypted
enc_%: ENC_DIRECTORY_ENCRYPTED = $(PWD)/path/to/encrypted

enc_%_prod: ENC_DIRECTORY_DECRYPTED = $(PWD)/path/to/decrypted/prod
enc_%_prod: ENC_DIRECTORY_ENCRYPTED = $(PWD)/path/to/encrypted/prod
```

## commands

### encrypt

```shell
make enc_encrypt
make enc_encrypt_prod
```

### decrypt

```shell
make enc_decrypt
make enc_decrypt_prod
```
