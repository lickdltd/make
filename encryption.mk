# encryption

ENC_VERSION ?= latest
ENC_DIRECTORY_DECRYPTED ?= $(PWD)/decrypted
ENC_DIRECTORY_ENCRYPTED ?= $(PWD)/encrypted

ifndef AWS_REGION
$(error AWS_REGION is not defined)
endif

ENC_DOCKER_CMD = docker run --rm \
	-e AWS_REGION=$(AWS_REGION) \
	-v ~/.aws:/root/.aws:ro \
	-v $(ENC_DIRECTORY_DECRYPTED):/tmp/decrypted \
	-v $(ENC_DIRECTORY_ENCRYPTED):/tmp/encrypted \
	ghcr.io/lickdltd/kms:$(ENC_VERSION)

ENC_ENCRYPT_CMD = $(ENC_DOCKER_CMD) encrypt --key $(ENC_KMS_KEY) --input-dir /tmp/decrypted --output-dir /tmp/encrypted
enc_encrypt:
	$(ENC_ENCRYPT_CMD)
enc_encrypt_%:
	$(ENC_ENCRYPT_CMD)

ENC_DECRYPT_CMD = $(ENC_DOCKER_CMD) decrypt --key $(ENC_KMS_KEY) --input-dir /tmp/encrypted --output-dir /tmp/decrypted
enc_decrypt:
	$(ENC_DECRYPT_CMD)
enc_decrypt_%:
	$(ENC_DECRYPT_CMD)
