# Installation

1. Clone

        $ git clone git@github.com:mheffner/awsam.git $DIR/awsam

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

# Use

## Add an account

If the environment already contains AWS variables, these will be
presented as defaults.

    $ aem add
    Creating a new AWS account...
    Short name: staging
    Description: Staging account
    Access key [12346]: 123
    Secret key [secret123456]: 455
    Cert key file [/path/to/key_cert.pem]: cert.pem
    Private key file [/path/to/private_key.pem]: key.pem

## Select the active account

This will update the current environment with the appropriate AWS
environment variables.

    $ aem use staging

## List accounts

The active account will be marked with an arrow.

    $ aem list
    
    AWS Accounts:
    
       prod [Librato Production] [1 keys]
    => staging [Staging account]
       dev [Librato Development] [1 keys]

## Import a key pair

Add a key to the default account, or the specified account. Defaults
chosen from current environment if set.

    $ aem key add
    Importing a key pair to account staging [Staging account]
    
    Key pair name [my-keypair]: new-keypair
    Key pair file [/path/to/my-keypair.pem]: keypair.pem

## `assh` utility: SSH by instance ID

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

## Remove an account

You can remove an account as long as it is not the active one.

    $ aem remove staging

# Long-term Goals

aem utility:

 * list accounts by name
 * choose account by name (sets environ)
 * list shows active account
 * support default account
 * accounts as yaml config files

assh utility:

 * ssh's to an instance name
 * ssh to a tag name (multiple?)
 * caches instance id => hostname for fast lookup
 * determines correct key to add
 * determines user?


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

