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

describe PoiseMsys2::Resources::PoiseMsys2 do
  step_into(:poise_msys2)

  describe '#full_install_url' do
    context 'with a version' do
      recipe do
        poise_msys2 'C:\\msys2' do
          install_url 'https://mymirror/msys2-base-%{arch}-%{version}.tar.xz'
          install_version 'today'
        end
      end

      it { is_expected.to install_poise_msys2('C:\\msys2').with(full_installer_url: 'https://mymirror/msys2-base-x86_64-today.tar.xz') }
    end # /context with a version

    context 'without a version' do
      recipe do
        poise_msys2 'C:\\msys2' do
          install_url 'https://mymirror/msys2.tar.xz'
        end
      end

      it { is_expected.to install_poise_msys2('C:\\msys2').with(full_installer_url: 'https://mymirror/msys2.tar.xz') }
    end # /context without a version
  end # /describe #full_install_url

  describe 'action :install' do
    before do
      allow(File).to receive(:exist?).and_call_original
    end

    recipe do
      poise_msys2 'C:\\msys2' do
        install_url 'https://mymirror/msys2.tar.xz'
      end
    end

    context 'with no existing install' do
      before do
        allow(File).to receive(:exist?).with('C:\\msys2').and_return(false)
      end

      it { is_expected.to unpack_poise_archive('https://mymirror/msys2.tar.xz').with(destination: 'C:\\msys2') }
    end # /context with no existing install

    context 'with an existing install' do
      before do
        allow(File).to receive(:exist?).with('C:\\msys2').and_return(true)
      end

      it { is_expected.to_not unpack_poise_archive('https://mymirror/msys2.tar.xz') }
    end # /context with an existing install
  end # /describe action :install

  describe 'action :upgrade' do
    recipe do
      poise_msys2 'C:\\msys2' do
        action :upgrade
        install_url 'https://mymirror/msys2.tar.xz'
      end
    end

    it do
      # This is a silly test, but coverage++.
      expect_any_instance_of(described_class::Provider).to receive(:msys_shell_out!).with('exit')
      expect_any_instance_of(described_class::Provider).to receive(:msys_shell_out!).with(%w{pacman --sync --refresh --noconfirm})
      expect_any_instance_of(described_class::Provider).to receive(:msys_shell_out!).with(%w{pacman --sync --sysupgrade --sysupgrade --noconfirm})
      run_chef
    end
  end # /describe action :upgrade

  describe 'action :uninstall' do
    recipe do
      poise_msys2 'C:\\msys2' do
        action :uninstall
        install_url 'https://mymirror/msys2.tar.xz'
      end
    end

    it { is_expected.to delete_directory('C:\\msys2').with(recursive: true) }
  end # /describe action :uninstall
end
