# Poise-Msys2 Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-msys2.svg)](https://travis-ci.org/poise/poise-msys2)
[![Gem Version](https://img.shields.io/gem/v/poise-msys2.svg)](https://rubygems.org/gems/poise-msys2)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-msys2.svg)](https://supermarket.chef.io/cookbooks/poise-msys2)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-msys2.svg)](https://codecov.io/github/poise/poise-msys2)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-msys2.svg)](https://gemnasium.com/poise/poise-msys2)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to manage [MSYS2](http://www.msys2.org/).

## Quick Start

To install an MSYS2 package:

```ruby
poise_msys2_package 'mutt'
```

## Recipes

* `poise-msys2::default` – Install core MSYS2 system.

## Attributes

* `node['poise-msys2']['default_recipe']` – Recipe used by some resources to
  install MSYS2 if not already available. *(default: poise-msys2::default)*
* `node['poise-msys2']['install_url']` – URL template to download the MSYS2
  installer archive. Must point at the tar.xz archive, not the executable
  installer. *(default: https://downloads.sourceforge.net/project/msys2/Base/%{arch}/msys2-base-%{arch}-%{version}.tar.xz)*
* `node['poise-msys2']['install_version']` – Version of the MSYS2 installer to
  use. *(default: 20161025)*
* `node['poise-msys2']['root']` – Root folder for the MSYS2 installation.
  *(default: $SYSTEMDRIVE\msys2)*

## Resources

### `poise_msys2`

The `poise_msys2` resource installs MSYS2. This is normally handled via the
`poise-msys2::default` recipe but a customized recipe can be used instead.

```ruby
poise_msys2 'C:/msys' do
  install_url 'https://mymirror.local/msys2-base-x86_64-20161025.tar.xz'
end
```

#### Actions

* `:install` – Install MSYS2. *(default)*
* `:upgrade` – Upgrade all MSYS2 system packages.
* `:uninstall` – Remove MSYS2.

#### Properties

* `path` – Root folder for the MSYS2 installation. *(name attribute)*
* `install_url` – RL template to download the MSYS2 installer archive. Must
  point at the tar.xz archive, not the executable installer. *(required)*
* `install_version` – Version of the MSYS2 installer to use. *(default: '')*

### `poise_msys2_execute`

The `poise_msys2_execute` resource is like the core `execute` resource but runs
the command in the MSYS2 environment.

```ruby
poise_msys2_execute 'make' do
  cwd '/c/myapp'
end
```

#### Actions

* `:run` – Run the command. *(default)*

#### Properties

The `poise_msys2_execute` resource supports all the same properties as the
core `execute` resource, which can be found in the
[Chef documentation](https://docs.chef.io/resource_execute.html#attributes).

### `poise_msys2_package`

The `poise_msys2_package` resource manages packages in the MSYS2 environment
using the included `pacman` package manager system.

```ruby
poise_msys2_package 'nano' do
  action :upgrade
end
```

#### Actions

* `:install` – Install the package. *(default)*
* `:upgrade` – Upgrade the package.
* `:remove` – Uninstall the package.

#### Properties

The `poise_msys2_package` resource supports all the same properties as the
core `package` resource, which can be found in the
[Chef documentation](https://docs.chef.io/resource_package.html#attributes).

## Upgrading From `mingw`

Upgrading from the [`mingw` cookbook](https://github.com/chef-cookbooks/mingw)
is relatively straightforward. Replace all usage of `msys2_package` resources
with `poise_msys2_package`.

## Sponsors

Development sponsored by [SAP](https://cloudplatform.sap.com/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2015-2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
