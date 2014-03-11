AWSAM (Amazon Web Services Account Manager) allows you to easily manage multiple sets of AWS credentials. It has support for multiple accounts and multiple key-pairs per account.

Account switching auto-populates ENV vars used by AWS' command line tools and AWSAM additionally gives you intelligent wrappers for `ssh` and `scp` which can be used like:

    # ssh by AWS instance id
    $ assh ubuntu@i-123456

    # scp by instance id
    $ ascp local-file ubuntu@i-123456:remote-file

AWSAM supports both AWS' legacy [Java-based CLI tools](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html) and their newer [python-based CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).

# Installation

1. Clone (better if you use a ruby version manager) or gem install

        $ git clone https://github.com/mheffner/awsam.git $DIR/awsam
        # or
        $ gem install awsam

2. Setup PATH (for non gem installs)

        $ echo "export PATH=\$PATH:$DIR/awsam/bin" >> $HOME/.bashrc
        $ source $HOME/.bashrc

3. Install BASH rc file

        $ raem --init
        Initialized AWS Account Manager

        Add the following to your .bashrc:

          if [ -s $HOME/.awsam/bash.rc ]; then
              source $HOME/.awsam/bash.rc
          fi

## Updating

1. Update repo (fetch && merge) or `gem update awsam`

2. Run `raem --init`. Ignore instructions to setup .bashrc if
   you've already done so.

3. Close and reopen your shell or `source ~/.bashrc`.

# Use

## Add an account

If the environment already contains AWS variables, these will be
presented as defaults.

    $ aem add
    Creating a new AWS account...
    Short name: staging
    Description: Staging account
    AWS Region [us-east-1]: us-east-1
    Access key [12346]: 123
    Secret key [secret123456]: 455
    AWS ID: aws_account

Note: if your shell can't find the `aem` command it is most likely because you haven't successfully sourced `.awsam/bash.rc` in the install steps.

## Select the active account

This will update the current environment with the appropriate AWS
environment variables.

    $ aem use staging

When selecting an account you can mark it as the default account with
the `--default` option:

    $ aem use --default staging

## List accounts

The active account will be marked with an arrow. The default, if set,
will be marked with an asterisk.

    $ aem list

    AWS Accounts:

       prod [Librato Production] [1 key: my-prod-key]
    => staging [Staging account]
      *dev [Librato Development] [1 key: devel-key]


## Import a key pair

Add a key to the default account, or the specified account. Defaults
chosen from current environment if set.

    $ aem key add my-key-name /path/to/my-keypair.pem
    Imported key pair my-key-name for account staging [Staging account]

## Select a key

This will select an SSH keypair to use from your current account and
set the environment variables `AMAZON_SSH_KEY_NAME` and
`AMAZON_SSH_KEY_FILE` appropriately. It will also highlight the key in
the list output with the '>' character.

    $ aem key use my-key-name

    $ aem list

    AWS Accounts:

       staging [Staging account]
    => dev [Librato Development] [1 key: >my-key-name]

You can also define a default key for each account that will
automatically be selected when the account is chosen. Just use the
`--default` option when selecting a key to set a default key. Picking
a default will place an asterisk next to the key name in the `aem
list` output.

    $ aem key use --default my-key-name

## assh utility: SSH by instance ID

Instance IDs will be looked up using the current account details. If
the instance's keypair name exists, that keyfile will be used as the
identity file to ssh.

Usage:

    $ assh [user@]<instance-id>

Example:

    $ assh ubuntu@i-123456
    warning: peer certificate won't be verified in this SSL session
    Loging in as ubuntu to ec2-1.2.3.4.compute-1.amazonaws.com

    ...

    ubuntu@host:~$

## ascp utility: SCP by instance ID

Instance IDs will be looked up using the current account details. If
the instance's keypair name exists, that keyfile will be used as the
identity file to scp.

Usage:

    $ ascp [user@]<instance ID>:remote-file local-file
    $ ascp local-file [user@]<instance ID>:remote-file

## Remove a key

You can remove ah SSH key from an account (defaults to the current
account).

    $ aem key remove --acct prod my-prod-key

## Remove an account

You can remove an account as long as it is not the active one.

    $ aem remove staging

# Environment variables

*AWS Account Manager* sets a variety of environment variables when
selecting accounts and SSH keypairs. Some of these environment
variables match the ones used by the Amazon EC2 CLI tools and some our
unique to AWSAM. It is often convenient to use these environment
variables in DevOPs scripts in place of hard-coded values -- allowing
your scripts to be seamlessly used for staging and production
environments simply by switching the active account with `aem`.

The environment variables set when selecting an account are:

* `AMAZON_ACCESS_KEY_ID` and `AWS_ACCESS_KEY_ID` and `AWS_ACCESS_KEY` - API access key

* `AMAZON_SECRET_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` and `AWS_SECRET_KEY` - Secret API access key

* `AMAZON_AWS_ID` - The integer ID of this AWS account

When selecting an SSH key, the following environment variables are
set:

* `AMAZON_SSH_KEY_NAME` - Name of the keypair.
* `AMAZON_SSH_KEY_FILE` - Full path to the public key PEM file

# TODO List

assh utility:

 * ssh to a tag name (multiple?)
 * caches instance id => hostname for fast lookup
 * determines user?
 * supports complete SSH CLI options
 * inline commands, eg: `ssh user@instance sudo tail /var/log/messages`

## Contributing to awsam

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Mike Heffner. See LICENSE.txt for
further details.

