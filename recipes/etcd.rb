# encoding: UTF-8
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

include_recipe 'kubernetes::firewall'
include_recipe 'kubernetes::go'

pkg_url = node['etcd']['package']
pkg_name = ::File.basename(pkg_url)
name = ::File.basename(pkg_name, '.tar.gz')
download_dir = '/root'

# download etcd package
remote_file "#{download_dir}/#{pkg_name}" do
  source pkg_url
end

# extract etcd package
execute "extract package #{pkg_name}" do
  cwd download_dir
  command "tar xf #{pkg_name}"
end

# copy etcd bin to /usr/bin dir
execute 'copy etcd to /usr/bin dir' do
  cwd download_dir
  command "/bin/cp -rf #{name}/etcd* /usr/bin/"
end

# create etcd user
user 'create etcd user' do
  username 'etcd'
  comment 'etcd user'
  home '/var/lib/etcd'
  shell '/usr/sbin/nologin'
end

# create /var/lib/etcd directory
directory '/var/lib/etcd' do
  owner 'etcd'
  group 'etcd'
  mode 00755
  action :create
end

# create /etc/etcd directory
directory '/etc/etcd' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

# generate etcd.conf file
template '/etc/etcd/etcd.conf' do
  cookbook 'kubernetes'
  source 'etcd.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  action :create
end

# generate systemd file
cookbook_file '/usr/lib/systemd/system/etcd.service' do
  source 'etcd.service'
  mode 00644
  action :create
end

# define etcd service
service 'etcd' do
  action [:enable, :restart]
end
