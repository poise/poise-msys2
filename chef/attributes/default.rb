#
# Copyright 2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['poise-msys2']['root'] = "#{ENV['SYSTEMDRIVE'] || 'C:'}\\msys2"
default['poise-msys2']['install_url'] = 'https://downloads.sourceforge.net/project/msys2/Base/%{arch}/msys2-base-%{arch}-%{version}.tar.xz'
default['poise-msys2']['install_version'] = '20161025'
default['poise-msys2']['default_recipe'] = 'poise-msys2'
