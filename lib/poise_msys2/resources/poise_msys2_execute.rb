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

require 'chef/provider/execute'
require 'chef/resource/execute'
require 'poise'

require 'poise_msys2/shell_out_mixin'


module PoiseMsys2
  module Resources
    # (see PoiseMsys2Execute::Resource)
    # @since 1.0.0
    module PoiseMsys2Execute
      # A `poise_msys2_execute` resource to run Python scripts and commands.
      #
      # @provides poise_msys2_execute
      # @action run
      # @example
      #   poise_msys2_execute 'make' do
      #     user 'myuser'
      #     cwd '/c/myapp'
      #   end
      class Resource < Chef::Resource::Execute
        include Poise(parent: :poise_msys2)
        provides(:poise_msys2_execute)
        actions(:run)

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

      # The default provider for `poise_msys2_execute`.
      #
      # @see Resource
      # @provides poise_msys2_execute
      class Provider < Chef::Provider::Execute
        include ::PoiseMsys2::ShellOutMixin
        provides(:poise_msys2_execute)

        private

        # Hack the base provider to re-route through MSYS2.
        #
        # @api private
        def shell_out!(*args)
          # I don't actually use shell_out! in my definitions so this won't
          # cause a recursive loop.
          msys_shell_out!(*args)
        end
      end

    end
  end
end
