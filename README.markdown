####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with swap_file](#setup)
    * [What swap_file affects](#what-swap_file-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with swap_file](#beginning-with-swap_file)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Manage swap files for your Linux environments.

##Setup

###What swap_file affects

* A list of files, packages, services, or operations that the module will alter, impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

###Beginning with swap_file

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps for upgrading, you may wish to include an additional section here: Upgrading (For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

##Usage

By default, it will create a swap file under `/mnt/swap.1` with the default size taken from the `$::memorysizeinbytes` fact divided by 1000000.

```puppet
include swap
```

For a custom setup, you can do something like this:

```puppet
swap {
  swapfile => '/swapfile/swap1',
  swapfilesize => '1000000'
}
```

To remove a prexisting swap, you can use ensure absent:

```puppet
swap {
  ensure   => 'absent'
  swapfile => '/swapfile/swap1',
}
```

##Limitations

Primary support is for Debian and RedHat, but should work on all Linux flavours.

##Development

Follow the CONTRIBUTING guidelines! :)
