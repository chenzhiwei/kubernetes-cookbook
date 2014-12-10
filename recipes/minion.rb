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
include_recipe 'kubernetes::network'
include_recipe 'kubernetes::docker'

pkg_url = node['kube']['package']
pkg_name = ::File.basename(pkg_url)
download_dir = '/root'

# download kubernetes package
remote_file "#{download_dir}/#{pkg_name}" do
  source pkg_url
end

# extract kubernetes package
execute "extract package #{pkg_name}" do
  cwd download_dir
  command "tar xf #{pkg_name} && tar xf kubernetes/server/kubernetes-server-linux-amd64.tar.gz"
end

# copy kubernetes bin to /usr/bin dir
execute 'copy kubernetes to /usr/bin dir' do
  cwd download_dir
  command '/bin/cp -rf kubernetes/server/bin/kube* /usr/bin/'
end

# create kube user
user 'create kube user' do
  username 'kube'
  comment 'kubernetes user'
  home '/var/lib/kubelet'
  shell '/usr/sbin/nologin'
  supports manage_home: true
end

# create /etc/kubernetes directory
directory '/etc/kubernetes' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

# generate etcd servers string
etcd_servers = []
node['etcd']['host'].each do |host|
  etcd_servers << "http://#{host}:4001"
end
node.set['etcd']['servers'] = etcd_servers.join(',')

# generate kubernetes config file
%w(config kubelet proxy).each do |file|
  template "/etc/kubernetes/#{file}" do
    cookbook 'kubernetes'
    source "#{file}.erb"
    owner 'root'
    group 'root'
    mode 00644
    action :create
  end
end

# generate systemd file
%w(kubelet.service kube-proxy.service).each do |service|
  cookbook_file "/usr/lib/systemd/system/#{service}" do
    source service
    mode 00644
    action :create
  end
end

# define kubernetes master services
%w(kubelet kube-proxy).each do |service|
  service service do
    action [:enable, :restart]
  end
end
