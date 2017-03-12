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

describe PoiseMsys2::ShellOutMixin do
  around do |ex|
    old_user = ENV['USER']
    old_pathext = ENV['PATHEXT']
    begin
      ENV['USER'] = 'poise'
      ENV['PATHEXT'] = ".com;.exe;.bat"
      ex.run
    ensure
      ENV['USER'] = old_user
      ENV['PATHEXT'] = old_pathext
    end
  end
  before do
    allow(File).to receive(:executable?).and_call_original
    allow(File).to receive(:executable?).with(/^C:\\root(.*)$/) {|path| File.exist?(File.expand_path("../fixtures/shell_out_root/#{path[8..-1]}", __FILE__)) }
    stub_const('File::PATH_SEPARATOR', ';')
  end

  def expect_shell_out(*args)
    expect_any_instance_of(provider(:poise_test)).to receive(:poise_shell_out).with(*args)
    run_chef
  end

  describe '#msys_shell_out' do
    resource(:poise_test) do
      include Poise
      attribute(:command)
      attribute(:path)
    end
    provider(:poise_test) do
      include described_class

      def action_run
        msys_shell_out(*new_resource.command)
      end
    end

    context 'with a string command' do
      recipe do
        poise_test 'test' do
          command ['echo hello world']
          path 'C:\\root'
        end
      end
      it do
        expect_shell_out(['C:\\root\\usr\\bin\\bash.exe', '-l', '-c', 'echo hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise'})
      end
    end # /context with a string command

    context 'with an array command' do
      recipe do
        poise_test 'test' do
          command [['echo', 'hello world']]
          path 'C:\\root'
        end
      end
      it do
        expect_shell_out(['C:\\root\\usr\\bin\\echo.exe', 'hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise'})
      end
    end # /context with an array command

    context 'with an unknown array command' do
      recipe do
        poise_test 'test' do
          command [['foobar', 'hello world']]
          path 'C:\\root'
        end
      end
      it do
        expect_shell_out(['foobar', 'hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise'})
      end
    end # /context with an unknown array command

    context 'with an array command and a custom $PATH' do
      recipe do
        poise_test 'test' do
          command [['echo', 'hello world'], {environment: {'PATH' => 'C:\\root\\bin'}}]
          path 'C:\\root'
        end
      end
      it do
        expect_shell_out(['C:\\root\\bin\\echo.bat', 'hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise', 'PATH' => 'C:\\root\\bin'})
      end
    end # /context with an array command and a custom $PATH

    context 'with an array command and an absolute command' do
      recipe do
        poise_test 'test' do
          command [['C:\\root\\other\\echo.exe', 'hello world']]
          path 'C:\\root'
        end
      end
      it do
        expect_shell_out(['C:\\root\\other\\echo.exe', 'hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise'})
      end
    end # /context with an array command and an absolute command

    context 'with a parent resource' do
      resource(:poise_test) do
        include Poise(:poise_msys2)
        attribute(:command)
      end
      provider(:poise_test) do
        include described_class

        def action_run
          msys_shell_out(*new_resource.command)
        end
      end
      recipe do
        poise_msys2 'C:\\root'
        poise_test 'test' do
          command ['echo hello world']
        end
      end
      it do
        expect_shell_out(['C:\\root\\usr\\bin\\bash.exe', '-l', '-c', 'echo hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise'})
      end
    end # /context with a parent resource

    context 'with a root property' do
      resource(:poise_test) do
        include Poise
        attribute(:command)
        attribute(:root)
      end
      provider(:poise_test) do
        include described_class

        def action_run
          msys_shell_out(*new_resource.command)
        end
      end
      recipe do
        poise_test 'test' do
          command ['echo hello world']
          root 'C:\\root'
        end
      end
      it do
        expect_shell_out(['C:\\root\\usr\\bin\\bash.exe', '-l', '-c', 'echo hello world'], cwd: 'C:\\root', environment: {'MSYSTEM' => 'MSYS', 'MSYS2_PATH_TYPE' => 'minimal', 'CHERE_INVOKING' => '1', 'HOME' => '/home/poise'})
      end
    end # /context with a root property
  end # /describe #msys_shell_out

  describe 'msys_shell_out!' do
    resource(:poise_test)
    provider(:poise_test) do
      include described_class

      def action_run
        msys_shell_out!('echo hello world')
      end
    end
    recipe do
      poise_test 'test'
    end
    it do
      cmd = double()
      expect(cmd).to receive(:error!)
      expect_any_instance_of(provider(:poise_test)).to receive(:msys_shell_out).with('echo hello world').and_return(cmd)
      run_chef
    end
  end # /describe msys_shell_out!
end
