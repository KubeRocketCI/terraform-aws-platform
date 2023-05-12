## How to use pre-commit git hook.

### 1. Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.

##### MacOS

```bash
$ brew install pre-commit gawk terraform-docs tflint
```

##### Ubuntu 18.04

```bash
$ sudo apt update
$ sudo apt install -y gawk unzip software-properties-common
$ sudo add-apt-repository ppa:deadsnakes/ppa
$ sudo apt install -y python3.7 python3-pip
$ pip3 install pre-commit
$ curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar xzf terraform-docs.tgz && chmod +x terraform-docs && $ sudo mv terraform-docs /usr/bin/
$ curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
```

### 2. Install the git hook scripts
Run pre-commit install to set up the git hook scripts

```bash
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

### 3. Run

After pre-commit hook has been installed you can run it manually on all files in the repository

```bash
$ pre-commit run --all-files
Terraform fmt............................................................Passed
Terraform docs...........................................................Passed
Terraform validate.......................................................Passed
Terraform validate with tflint...........................................Failed
- hook id: terraform_tflint
- exit code: 3

1 issue(s) found:
...
```

or run just a specified hook to check yourself
```bash
$ pre-commit run -a terraform_tflint
Terraform validate with tflint...........................................Passed
```

The pre-commit hook will run automatically on each commit action in the current repo with hooks which are specified in the `.pre-commit-config.yaml` file.