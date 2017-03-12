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

require 'spec_helper'

describe PoiseMsys2::Resources::PoiseMsys2Package do
  step_into(:poise_msys2_package)
  def fixture_file(path)
    IO.read(File.expand_path("../../fixtures/#{path}", __FILE__))
  end
  let(:root) { 'C:\\msys2' }
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("#{root}/etc/pacman.conf").and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("#{root}/etc/pacman.conf").and_return(fixture_file('pacman.conf'))
  end

  context 'with a parent' do
    recipe do
      poise_msys2 'C:\\msys2'
      poise_msys2_package 'nano'
    end

    it do
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman -Qi nano', timeout: 900).and_return(double(stdout: '', exitstatus: 1))
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman', '-Sl', timeout: 900).and_return(double(stdout: fixture_file('list'), exitstatus: 0))
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman --sync --noconfirm --noprogressbar nano', timeout: 900).and_return(double(error!: nil))
      run_chef
    end
  end # /context with a parent

  context 'without a parent' do
    recipe do
      poise_msys2_package 'nano'
    end

    it do
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman -Qi nano', timeout: 900).and_return(double(stdout: '', exitstatus: 1))
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman', '-Sl', timeout: 900).and_return(double(stdout: fixture_file('list'), exitstatus: 0))
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman --sync --noconfirm --noprogressbar nano', timeout: 900).and_return(double(error!: nil))
      run_chef
      is_expected.to install_poise_msys2('C:\\msys2')
    end
  end # /context without a parent

  context 'with a root' do
    let(:root) { 'C:\\othermsys' }
    recipe do
      poise_msys2_package 'nano' do
        root 'C:\\othermsys'
      end
    end

    it do
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman -Qi nano', timeout: 900).and_return(double(stdout: '', exitstatus: 1))
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman', '-Sl', timeout: 900).and_return(double(stdout: fixture_file('list'), exitstatus: 0))
      expect_any_instance_of(described_class::Provider).to receive(:shell_out).with('pacman --sync --noconfirm --noprogressbar nano', timeout: 900).and_return(double(error!: nil))
      run_chef
      is_expected.to_not install_poise_msys2('C:\\msys2')
    end
  end # /context with a root
end
