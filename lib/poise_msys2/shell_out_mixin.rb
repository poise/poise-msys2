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

require 'shellwords'


module PoiseMsys2
  # Mixin for providers to run commands in the MSYS2 environment.
  #
  # @since 1.0.0
  module ShellOutMixin
    def msys_shell_out(*cmd, cwd: nil, environment: {}, **options)
      # Work out the root folder.
      root = if new_resource.respond_to?(:parent)
        new_resource.parent.path
      else
        new_resource.path
      end
      # Some environment variables needed for MSYS2.
      environment['MSYSTEM'] = 'MSYS'
      environment['MSYS2_PATH_TYPE'] = 'minimal'
      environment['CHERE_INVOKING'] = '1'
      environment['HOME'] ||= "/home/#{ENV['USER']}"
      # Default working directory for safety.
      cwd ||= root
      # We need to get a single string to pass to bash.
      cmd.flatten!
      cmd = if cmd.length == 1
        cmd.first
      else
       Shellwords.join(cmd)
      end
      # Run the command via bash (for now).
      poise_shell_out(["#{root}/usr/bin/bash.exe", '-l', '-c', cmd], cwd: cwd, environment: environment, **options)
    end

    def msys_shell_out!(*args)
      msys_shell_out(*args).tap(&:error!)
    end

  end
end
