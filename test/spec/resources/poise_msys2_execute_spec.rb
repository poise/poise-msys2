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

describe PoiseMsys2::Resources::PoiseMsys2Execute do
  step_into(:poise_msys2_execute)

  context 'with a parent' do
    recipe do
      poise_msys2 'C:\\msys2'
      poise_msys2_execute 'echo hello world'
    end

    it do
      expect_any_instance_of(described_class::Provider).to receive(:msys_shell_out!).with('echo hello world', kind_of(Hash))
      run_chef
    end
  end # /context with a parent

  context 'without a parent' do
    recipe do
      poise_msys2_execute 'echo hello world'
    end

    it do
      expect_any_instance_of(described_class::Provider).to receive(:msys_shell_out!).with('echo hello world', kind_of(Hash))
      run_chef
      is_expected.to install_poise_msys2('C:\\msys2')
    end
  end # /context without a parent

  context 'with an array command' do
    recipe do
      poise_msys2 'C:\\msys2'
      poise_msys2_execute 'echo hello world' do
        command ['echo', 'hello world']
      end
    end

    it do
      expect_any_instance_of(described_class::Provider).to receive(:msys_shell_out!).with(['echo', 'hello world'], kind_of(Hash))
      run_chef
    end
  end # /context with an array command
end

