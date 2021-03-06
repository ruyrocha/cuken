#
# Author:: Hedgehog (<hedgehogshiatus@gmail.com>)
# Copyright:: Copyright (c) 2011 Hedgehog.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
Then /^these remote Cookbooks exist:$/ do |table|
  check_remote_cookbook_table_presence(table)
end

Then /^these remote Cookbooks do not exist:$/ do |table|
  check_remote_cookbook_table_presence(table, false)
end

Given /^the remote Cookbook repository "([^"]*)"$/ do |ckbk_repo|
  in_dir do
    repo = Dir.exist?(ckbk_repo) ? Pathname(ckbk_repo).expand_path.realdirpath : ckbk_repo
    chef.remote_cookbook_repo = repo
  end
end

Given /^the remote Cookbooks URI "([^"]*)"$/ do |ckbk_uri|
  in_dir do
    repo = Dir.exist?(ckbk_uri) ? Pathname(ckbk_uri).expand_path.realdirpath : ckbk_uri
    chef.cookbooks_uri = repo
  end
end
