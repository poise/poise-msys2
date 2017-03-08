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

require 'chef/resource'
require 'chef/provider'
require 'poise'

require 'poise_msys2/shell_out_mixin'


module PoiseMsys2
  module Resources
    # (see PoiseMsys2::Resource)
    # @since 1.0.0
    module PoiseMsys2
      # A `poise_msys2` resource to install MSYS2.
      #
      # @provides poise_msys2
      # @action install
      # @action upgrade
      # @action uninstall
      # @example
      #   poise_msys2 'C:/msys2'
      class Resource < Chef::Resource
        include Poise(container: true)
        provides(:poise_msys2)
        actions(:install, :upgrade, :uninstall)

        # @!attribute path
        #   Root folder for the MSYS2 installation.
        #   @return [String]
        attribute(:path, kind_of: String, name_attribute: true)

        # @!attribute install_url
        #   URL template to download the MSYS2 installer archive. Must point at
        #   the tar.xz archive, not the executable installer.
        #   @return [String]
        attribute(:install_url, kind_of: String, required: true)

        # @!attribute install_version
        #   Version of the MSYS2 installer to use.
        #   @return [String]
        attribute(:install_version, kind_of: String, default: '')

        # Helper method to interpolate the version in the URL.
        #
        # @return [String]
        def full_installer_url
          install_url % {
            version: install_version,
            arch: node['kernel']['machine'],
          }
        end
      end

      # Provider for `poise_msys2`.
      #
      # @see Resource
      # @provides poise_msys2
      class Provider < Chef::Provider
        include Poise
        include ::PoiseMsys2::ShellOutMixin
        provides(:poise_msys2)

        # `install` action for `poise_msys2`. Ensure MSYS2 is installed and ready.
        #
        # @return [void]
        def action_install
          notifying_block do
            install_archive
          end
          # The first time bash is run it sets up a bunch of user files and
          # support configs. Force this run before we do anything important.
          msys_shell_out!('exit') unless Chef::Config[:why_run]
        end

        # `upgrade` action for `poise_msys2`. Upgrades all system packages.
        #
        # @return [void]
        def action_upgrade
          converge_by 'Upgrading MSYS2 packages' do
            # Grab the latest definitions. Should this always run from action_install?
            msys_shell_out!(%w{pacman --sync --refresh --noconfirm})
            # Pass --sysupgrade twice to allow downgrades.
            msys_shell_out!(%w{pacman --sync --sysupgrade --sysupgrade --noconfirm})
          end
        end

        # `uninstall` action for `poise_msys2`. Ensure MSYS2 is removed.
        #
        # @return [void]
        def action_uninstall
          notifying_block do
            delete_root_directory
            # TODO anything else?
          end
        end

        private

        # Download and unpack the base system.
        #
        # @api private
        # @return [void]
        def install_archive
          poise_archive new_resource.full_installer_url do
            destination new_resource.path
            # Don't even bother redownloading after the initial unpack, we'll
            # handle updates in-place.
            not_if { ::File.exist?(new_resource.path) }
            # Run a system upgrade when we do the initial install.
            notifies :upgrade, new_resource, :immediately
          end
        end

        # Remove MSYS2's install root.
        #
        # @api private
        # @return [void]
        def delete_root_directory
          directory new_resource.path do
            action :delete
            recursive true
          end
        end
      end

    end
  end
end
