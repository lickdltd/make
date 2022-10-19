# make

* [purpose](#purpose)
* [usage](#usage)
* [further reading](#further-reading)

## purpose

These files are created to replicate CI/CD commands defined in [github-actions](https://github.com/lickdltd/github-actions)
and are designed to be used purely for local development usage only.

## usage

### basic

> This example assumes that you have [wget](https://www.gnu.org/software/wget/) installed.

To use these files within your project, you can copy and paste the following code to the top of your project `Makefile`.  
Alternatively, you can write a custom adaptation to replicate the same functionality.

```makefile
init: MAKE_DIR = ./.make
init: MAKE_VERSION = v1
init: MAKE_FILES = common
init:
	@rm -rf $(MAKE_DIR)
	@mkdir -p $(MAKE_DIR)
	@for name in $(MAKE_FILES); do wget -qO $(MAKE_DIR)/$${name}.mk https://raw.githubusercontent.com/lickdltd/make/$(MAKE_VERSION)/$${name}.mk; done

-include ./.make/*.mk

# your project specific targets/rules go here
```

### target/rule

By putting the basic usage example above at the top of your `Makefile` you can then either run `make init` or `make`.  
The example uses `init` but can be whatever you'd prefer, for example `install` could be used instead.

### directory

In the basic usage above, the directory is defined as `./.make` but the important thing is that `MAKE_DIR` and `-include` match.  
It is also recommended ignoring the directory from your project by adding `.make` in the `.gitignore` file in the root of the project repo.

### version

These files are versioned and follow [semantic versioning](https://semver.org/) which is achieved with git tags, 
each patch version is locked and will never change while the minor and major tags will move based on the relevant patch version.  
It is recommended to lock your `MAKE_VERSION` to the current major version.

### includes

The above will include and download any files defined by `MAKE_FILES` which is a space delimited list.  
To include other files, it can be updated like so:

```makefile
init: MAKE_FILES = ansible common
```

## further reading

* [ansible](./docs/ansible.md)
* [aws](./docs/aws.md)
* [common](./docs/common.md)
* [docker](./docs/docker.md)
* [encryption](./docs/encryption.md)
* [lint](./docs/lint.md)
* [node](./docs/node.md)
* [php](./docs/php.md)
* [terraform](./docs/terraform.md)
