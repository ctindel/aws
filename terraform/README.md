Terraform
=========

Terraform is a tool for building, changing, and versioning infrastructure
safely and efficiently.

Requirements
------------

You'll need the following software installed on your machine in order to
utilize the our Terraform setup:

* [aws-cli][]
* [Terraform][] >= v0.7.11

[aws-cli]: https://github.com/aws/aws-cli#installation
[Terraform]: https://www.terraform.io/intro/getting-started/install.html

Overview
--------

Here's an overview of our file structure...

    terraform/
    ├── modules/
    │   └── aws/
    │       └── network/
    │           ├── bastion/
    │           ├── nat/
    │           ├── private_subnet/
    │           ├── public_subnet/
    │           └── vpc/
    ├── providers/
    │   └── aws/
    │       ├── bootkeys/
    │       │   └── bootkey-20161115.id_rsa.pub
    │       ├── env/
    │       │   ├── _base_config_/
    │       │   ├── infra/
    │       │   └── infra-staging/
    │       └── global/
    │           └── main.tf
    ├── .gitignore
    └── README.md

### Modules

[Modules][] can be thought of as functions that define generic resource
building blocks for our infrastructure. They're just self-contained groups of
Terraform configurations. Each module should have three separate files:

    <module-name>/
    ├── variables.tf
    ├── main.tf
    └── output.tf

[Modules]: https://www.terraform.io/docs/modules/

A variable is a required argument, all of the resources themselves are defined
within main, and an output is a return value. Output values can be referenced
by other modules to gather information they might need like the VPC ID, etc.
Modules can be nested, but in general, it's easier to grok by keeping a flat
namespace.

### Providers

A [provider][] in Terraform parlance is the internal adapter code for
understanding API interactions with an upstream service and exposing actual
resources. Since we're defining AWS resources, best practices would have us
store our configuration files under the file hierarchy of `providers/aws/*`.

[provider]: https://www.terraform.io/docs/providers/

We also want to support multiple environments. That means we can have our usual
infrastructure team "infra" VPC, but also an "infra-stage" staging VPC to test
Terraform changes. In the future, we could also support dedicated VPCs and
infrastructure management for other projects or other Elastic teams by defining
additional environments.

> _IMPORTANT: Environments are a completely separate concept from the actual
> AWS account that we're connected to._

Within each environment directory, we define the combination of modules and
actual variable values and that make up our desired infrastructure. Every
environment will have some shared fundamental setup configuration for things
like the VPC and network-related resources. To reduce duplication, the those
common configuration files are just symlinks to a shared `env/_base_config_/`
directory. The differences between the environments come from their
`terraform.tfvars` variable definitions and any additional `*.tf` files.

The `global/` directory is meant to be where we define resources that are
universal across environments. Things like IAM users/policies, CloudTrail
configurations, etc.

Usage
-----

Once you have the required software installed, you'll need to:

1. configure your AWS credentials profile to match our existing account
2. change into the desired Terraform environment directory
3. run the `init.sh` script to sync your local state with our shared S3 bucket
   and set up the environment for your session
4. run your desired `terraform` commands

### 1. Set up AWS Profiles

These profiles should be defined in your `~/.aws/credentials` file.

```ini
[sa-demo]
aws_access_key_id = <your-key-id-here>
aws_secret_access_key = <your-secret-key-here>
```

If your shell startup scripts export `$AWS_` variables into your environment,
you should make sure that you've exported the values that match the AWS account
profile you're targetting with Terraform.

### 2. Change into an Environment Directory

All `terraform` commands should be run from within an environment directory,
like `providers/aws/env/infra/`. Terraform will pick up any `*.tf`
configuration files within that directory when running commands.

### 3. Run the Initialization Script

Terraform relies on a lot of state data to determine if resources need to be
created/updated/destroyed/etc. Normally, the state data will be written to
a local file, but we have to share that state data via some mechanism so
Terraform can be used by multiple team members.

We're using the [S3 backend][] for syncing remote state data automatically. To
configure your session to point to the correct S3 bucket (based on your AWS
profile and current Terraform environment), you need to run the initialization
script:

    $ ./init.sh
    [...]

[S3 backend]: https://www.terraform.io/docs/state/remote/s3.html

The script will prompt you for any required information, it will configure your
session, and then it will grab all of the required modules to store in the
local `.terraform/modules` cache. Once it completes, all state data will by
automatically synced with the S3 bucket as necessary.

> _The `init.sh` script should be run every time you change AWS profiles, or
> make code changes to any Terraform modules._

No locking of the shared state takes place, so we do have to coordinate with
each other if multiple team members are making infrastructure-related changes
at the same time.

### 4. Run `terraform` Commands

Now you're ready to actually use Terraform. In general, you should generate an
execution plan before actually applying it:

    $ terraform plan

See `terraform help` and the [upstream documentation][] for more details.

[upstream documentation]: https://www.terraform.io/docs/

Tips
----

* Do **not** use resource description fields as comments about those resources.
  If you change a resource description, Terraform will try to destroy and
  recreate the resource, as updating descriptions is not supported by AWS. Just
  use tagging, or comments in your code.
