#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Author:: Hedgehog (<hedgehogshiatus@gmail.com>)
# Portions Copyright:: Copyright (c) 2008, 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
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

Given /^the remote cookbook repository "([^"]*)"$/ do |ckbk_repo|
  in_current_dir do
    chef.remote_cookbook_repo = Pathname(ckbk_repo).expand_path.realdirpath
  end
end

Given /^the local cookbook repository "([^"]*)"$/ do |ckbk_repo|
  in_current_dir do
    chef.local_cookbook_repo = Pathname(ckbk_repo).expand_path.realdirpath
  end
end

Then /^the local cookbook repository exists$/ do
  chef.local_cookbook_repo.exist?.should be_true
  #TODO: check_file_presence([file], true), etc.
end

Given /^a cookbook path "([^"]*)"$/ do |path|
  in_current_dir do
    chef.cookbook_paths << Pathname(path).expand_path.realdirpath
  end
end

Then /^the local cookbook "([^"]*)" exists$/ do |ckbk|
  chef.cookbook_paths.each do |pn|
    curr_ckbk = pn.basename.to_s
    curr_ckbk.should == ckbk if curr_ckbk == ckbk
  end
  #TODO: check_file_presence([file], true), etc.
end

Given /^I clone the remote cookbook repository branch "([^"]*)" to "([^"]*)"$/ do |brnch, ckbk_path|
  chef.local_cookbook_repo = chef_clone_repo(ckbk_path, true, chef.remote_cookbook_repo, brnch)
end

When /^I successfully generate all cookbook metadata$/ do
  chef.cookbook_paths.each{|pn| run_knife_command("cookbook metadata #{pn.basename}")}
end

When /^I successfully generate cookbook "([^"]*)" metadata$/ do |ckbk|
  chef.cookbook_paths.each do |pn|
    curr_ckbk = pn.basename.to_s
    if curr_ckbk == ckbk
      run_knife_command("cookbook metadata #{curr_ckbk}")
    end
  end
end