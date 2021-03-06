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

poise_msys2_package 'python2'

poise_msys2_execute 'python test' do
  command ['python2', '-c', <<-EOH.strip]
open('/c/python_test.txt', 'w').write('Hello world\\n')
EOH
end

poise_msys2_execute 'python test 2' do
  command %q{python2 -c "open('/c/python_test2.txt', 'w').write('Hello world two\\n')"}
end
