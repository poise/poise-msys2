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

require 'poise/utils/shell_out'


module PoiseMsys2
  # Mixin for providers to run commands in the MSYS2 environment.
  #
  # @since 1.0.0
  module ShellOutMixin
    include Poise::Utils::ShellOut

    # Folders within the MSYS2 root to use for executable lookups.
    MSYS2_PATH = %w{/usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin}

    def msys_shell_out(*cmd, cwd: nil, environment: {}, **options)
      # Work out the root folder.
      root = if new_resource.respond_to?(:root) && new_resource.root
        # For the backwards compat on poise_msys2_package.
        new_resource.root
      elsif new_resource.respond_to?(:parent)
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
      # Deal with whatever nesting and nulls we have.
      cmd.flatten!
      cmd.compact!
      real_cmd = if cmd.length == 1
        # Running in shell wrapper mode to mimic Ruby.
        ["#{root}/usr/bin/bash.exe", '-l', '-c', cmd.first]
      else
        # Try and do a path-ish lookup.
        [msys_which(cmd.first, root, path: environment['PATH']) || cmd.first] + cmd.drop(1)
      end
      # Run the command via bash (for now).
      poise_shell_out(real_cmd, cwd: cwd, environment: environment, **options)
    end

    def msys_shell_out!(*args)
      msys_shell_out(*args).tap(&:error!)
    end

    def msys_which(cmd, root, path: nil)
      # If it was already absolute, just return that.
      return cmd if cmd =~ /^(\/|([a-z]:)?\\)/i
      paths = if path
        path.split(File::PATH_SEPARATOR)
      else
        # Executable has a relative path, so we need to pretend to do a $PATH
        # lookup. This is hard because we can't see the MSYS $PATH so just
        # fake it and hope it is good enough.
        MSYS2_PATH.map {|path_suffix| ::File.join(root, path_suffix) }
      end
      # Always check without an extension first just in case.
      path_exts = [''] + (ENV['PATHEXT'] ? ENV['PATHEXT'].split(::File::PATH_SEPARATOR).map(&:strip) : [])
      # Based on Chef::Mixin::Which#which
      # Copyright 2010-2017, Chef Softare, Inc.
      paths.each do |candidate_path|
        path_exts.each do |candidate_ext|
          filename = ::File.join(candidate_path, cmd + candidate_ext)
          return filename.gsub(/\//, '\\') if ::File.executable?(filename)
        end
      end
      false
    end

  end
end
