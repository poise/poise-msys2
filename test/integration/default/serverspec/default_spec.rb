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

Kernel.send(:define_method, :warn) {|*args| nil }
require 'serverspec'
set :backend, :cmd
set :os, :family => 'windows'

describe file('/python_test.txt') do
  its(:content) { is_expected.to eq "Hello world\n" }
end

describe file('/python_test2.txt') do
  its(:content) { is_expected.to eq "Hello world two\n" }
end
