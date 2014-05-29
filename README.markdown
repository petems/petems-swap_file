####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with swap_file](#setup)
    * [What swap_file affects](#what-swap_file-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Manage [swap files](http://en.wikipedia.org/wiki/Paging) for your Linux environments. This is based on the gist by @Yggdrasil, with a few changes and added specs.

##Setup

###What swap_file affects

* Swapfiles on the system
* Any mounts of swapfiles

##Usage

The simplest use of the module is this:

```puppet
include swap
```

By default, the module it will create a swap file under `/mnt/swap.1` with the default size taken from the `$::memorysizeinbytes` fact divided by 1000000.

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
