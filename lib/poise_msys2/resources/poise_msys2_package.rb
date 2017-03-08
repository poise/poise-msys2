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

require 'chef/resource/pacman_package'
require 'chef/provider/package/pacman'
require 'poise'

require 'poise_msys2/shell_out_mixin'


module PoiseMsys2
  module Resources
    # (see PoiseMsys2Package::Resource)
    # @since 1.0.0
    module PoiseMsys2Package
      # A `poise_msys2_package` resource to install packages using the pacman
      # client in MSYS2
      #
      # @provides poise_msys2_package
      # @action install
      # @action upgrade
      # @action remove
      # @example
      #   poise_msys2_package 'git'
      class Resource < Chef::Resource::PacmanPackage
        include Poise(parent: :poise_msys2)
        provides(:poise_msys2_package)
        actions(:install, :upgrade, :remove)

        # @!attribute root
        #   Backwards compat with the msys2_package resource from the mingw cookbook.
        #   @return [String, nil, false]
        attribute(:root, kind_of: [String, NilClass, FalseClass], default: nil)

        # Hook to force the msys2 install via recipe if needed.
        def after_created
          begin
            parent
          rescue Poise::Error
            # Use the default recipe to give us a parent the next time we ask.
            run_context.include_recipe(node['poise-msys2']['default_recipe'])
          end
          super
        end
      end

      # Provider for `poise_msys2_package`.
      #
      # @see Resource
      # @provides poise_msys2_package
      class Provider < Chef::Provider::Package::Pacman
        include Poise
        include ::PoiseMsys2::ShellOutMixin
        provides(:poise_msys2_package)

        private

        # Copied from Chef itself because there is no good way to change the
        # config file path to make it find the MSYS2 pacman config file.
        # Copyright 2010, Jan Zimmek
        #
        # @api private
        # @return [string]
        def candidate_version
          return @candidate_version if @candidate_version

          repos = %w{extra core community}

          # CHANGES ARE HERE. THE CONFIG FILE PATH.
          if ::File.exist?("#{new_resource.parent.path}/etc/pacman.conf")
            pacman = ::File.read("#{new_resource.parent.path}/etc/pacman.conf")
            repos = pacman.scan(/\[(.+)\]/).flatten
          end
          # /CHANGES

          package_repos = repos.map { |r| Regexp.escape(r) }.join("|")

          status = shell_out("pacman", "-Sl", timeout: new_resource.timeout)
          status.stdout.each_line do |line|
            case line
            when /^(#{package_repos}) #{Regexp.escape(new_resource.package_name)} (.+)$/
              # $2 contains a string like "4.4.0-1" or "3.10-4 [installed]"
              # simply split by space and use first token
              @candidate_version = $2.split(" ").first
            end
          end

          unless status.exitstatus == 0 || status.exitstatus == 1
            raise Chef::Exceptions::Package, "pacman failed - #{status.inspect}!"
          end

          unless @candidate_version
            raise Chef::Exceptions::Package, "pacman does not have a version of package #{new_resource.package_name}"
          end

          @candidate_version
        end

        # Trick all shell_out related things in the base class in to using
        # my msys_shell_out instead.
        #
        # @api private
        def shell_out(*args)
          if @shell_out_hack_inner
            # This is the real call.
            super
          else
            # This ia call we want to intercept and send to MSYS2.
            begin
              @shell_out_hack_inner = true
              msys_shell_out(*args)
            ensure
              @shell_out_hack_inner = false
            end
          end
        end

      end

    end
  end
end
