# ssm

Helpers for seeding AWS SSM Parameter Store secrets out-of-band and guarding a
deploy against unset placeholders, per
[RFC #356.1](https://lickdteam.atlassian.net/wiki/spaces/ET/pages/4605706241).

Parameters follow the convention `/ecs/<env>/<service>/<KEY>`. Missing keys are
seeded with a recognisable sentinel (`PENDING`) so they exist without holding a
real value; a guard then fails CI if any referenced key still holds that sentinel.

* [setup](#setup)
  * [install](#install)
  * [environment](#environment)
  * [service override](#service-override)
  * [key-name list](#key-name-list)
  * [placeholder override](#placeholder-override)
* [commands](#commands)
  * [ssm_put](#ssm_put)
  * [ssm_sync](#ssm_sync)
  * [ssm_guard](#ssm_guard)

## setup

### install

Opt into these helpers by adding `ssm` to your project's `MAKE_FILES` (see the
[README](../README.md#includes)), so `ssm.mk` is downloaded alongside the rest:

```makefile
init: MAKE_FILES = common ssm
```

### environment

Every target needs an environment. The `_%` variants take it from the target
stem, so `ssm_sync_production` targets the `production` environment. For a base
target, pass `SSM_ENV` instead:

```shell
SSM_ENV=production make ssm_sync
```

### service override

The service segment of the path defaults to the repo name (the git remote
basename, or the working-directory name if there is no remote). Override it if
your parameters live under a different service:

```makefile
SSM_SERVICE = api-backend
```

You can also override the whole prefix if your convention differs:

```makefile
SSM_PATH_PREFIX = /ecs/$(SSM_ENV)/api-backend
```

### key-name list

`ssm_sync` and `ssm_guard` read a committed list of key names, one per line
(blank lines and `#` comments are ignored). It defaults to `ssm.keys` in the
project root:

```makefile
SSM_KEYS_FILE = $(PWD)/ssm.keys
```

```text
# ssm.keys
DATABASE_URL
STRIPE_SECRET_KEY
MAIL_PASSWORD
```

### placeholder override

The sentinel written for a freshly-seeded key defaults to `PENDING`:

```makefile
SSM_PLACEHOLDER = PENDING
```

## commands

### ssm_put

Create or update a single named `SecureString` parameter for an environment.

```shell
KEY='DATABASE_URL' VALUE='postgres://...' make ssm_put_production
KEY='DATABASE_URL' VALUE='postgres://...' SSM_ENV=production make ssm_put
```

### ssm_sync

Reconcile the committed key-name list against SSM: create a placeholder
`SecureString` for any missing key, and leave existing values untouched (it
never overwrites a real value).

```shell
make ssm_sync_production
SSM_ENV=production make ssm_sync
```

### ssm_guard

Fail when any referenced key is missing or still holds the placeholder sentinel,
so a placeholder cannot reach a deployed task. Safe to run in CI before a deploy;
it never prints parameter values.

```shell
make ssm_guard_production
SSM_ENV=production make ssm_guard
```
