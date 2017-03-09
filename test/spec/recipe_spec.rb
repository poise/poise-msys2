#
# Copyright 2015-2017, Noah Kantrowitz
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

require 'spec_helper'

describe 'poise-msys2::default' do
  recipe { include_recipe 'poise-msys2' }
  around do |ex|
    old = ENV['SYSTEMDRIVE']
    ENV['SYSTEMDRIVE'] = 'C:'
    begin
      ex.run
    ensure
      if old.nil?
        ENV.delete('SYSTEMDRIVE')
      else
        ENV['SYSTEMDRIVE'] = old
      end
    end
  end

  context 'with defaults' do
    it { is_expected.to install_poise_msys2('C:\\msys2').with(full_installer_url: 'https://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20161025.tar.xz') }
  end # /context with defaults

  context 'with attributes' do
    before do
      override_attributes['poise-msys2'] = {}
      override_attributes['poise-msys2']['root'] = 'Z:\\msys'
      override_attributes['poise-msys2']['install_url'] = 'https://mymirror/msys2-base-%{arch}-%{version}.tar.xz'
      override_attributes['poise-msys2']['install_version'] = 'today'
    end

    it { is_expected.to install_poise_msys2('Z:\\msys').with(full_installer_url: 'https://mymirror/msys2-base-x86_64-today.tar.xz') }
  end # /context with attributes
end
