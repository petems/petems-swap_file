####Table of Contents

1. [Overview](#overview)
2. [Module Description ](#module-description)
3. [Setup](#setup)
    * [What swap_file affects](#what-swap_file-affects)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [Development](#development)

##Overview

Manage [swap files](http://en.wikipedia.org/wiki/Paging) for your Linux environments. This is based on the gist by @Yggdrasil, with a few changes and added specs.

##Setup

###What swap_file affects

* Creating files from the path given using `/bin/dd` by default or `/usr/bin/fallocate` optionally for performance reasons. <aside class="notice"> WARNING: the fallocate option is known not to work on XFS partitions. The exec that creates the file with fallocate will check and verify the swap file destination is not an XFS partition automatically. </aside>
* Swapfiles on the system
* Any mounts of swapfiles

##Usage

The simplest use of the module is this:

```puppet
swap_file::files { 'default':
  ensure   => present,
}
```

By default, the module it will:

* create a file using /bin/dd atr `/mnt/swap.1` with the default size taken from the `$::memorysizeinbytes`
* A `mount` for the swapfile created

For a custom setup, you can do something like this:

```puppet
swap_file::files { 'tmp file swap':
  ensure    => present,
  swapfile  => '/tmp/swapfile',
  add_mount => false,
}
```
To use fallocate for swap file creation instead of dd do this. <aside class="notice"> This will fail on XFS partitions. </aside>

```puppet
swap_file::files { 'tmp file swap':
  ensure    => present,
  swapfile  => '/tmp/swapfile',
  cmd       => 'fallocate',
}
```

To remove a prexisting swap, you can use ensure absent:

```puppet
swap_file::files { 'tmp file swap':
  ensure   => absent,
}
```

## Previous to 1.0.1 Release

Previously you would create swapfiles with the `swap_file` class:

```
class { 'swap_file':
   swapfile     => '/mount/swapfile',
   swapfilesize => '100 MB',
}
```

However, this had many problems, such as not being able to declare more than one swap_file because of duplicate class errors.

This is now removed from 2.x.x onwards.

##Limitations

Primary support is for Debian and RedHat, but should work on all Linux flavours.

Right now there is no BSD support, but I'm planning on adding it in the future

##Development

Follow the CONTRIBUTING guidelines! :)
