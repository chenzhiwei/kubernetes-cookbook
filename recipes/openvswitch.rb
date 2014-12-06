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

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Kubernetes
end

ip_address = address_for(node['kube']['interface'])

package node['kube']['openvswitch']['package'] do
  action :upgrade
end

# create ovs bridge obr0
execute 'ovs-vsctl br-exists obr0 || ovs-vsctl add-br obr0'

# create ovs gre tunnel
node['kube']['kubelet']['machines'].each_index do |i|
  port = "gre#{i}"
  remote_ip = node['kube']['kubelet']['machines'][i]
  next if remote_ip == ip_address
  execute "ovs-vsctl port-to-br #{port} || ovs-vsctl add-port obr0 #{port} -- set Interface #{port} type=gre options:remote_ip=#{remote_ip}"
end

# create kuber bridge
execute 'brctl addbr kbr0 || :'

# make obr0 a port of kbr0
execute 'brctl addif kbr0 obr0 || :'

# persistent kbr0
index = 0
node['kube']['kubelet']['machines'].each_index do |i|
  remote_ip = node['kube']['kubelet']['machines'][i]
  if remote_ip == ip_address
    index = i
    break
  end
end
kbr_ip = "172.17.#{index}.0"
template '/etc/sysconfig/network-scripts/ifcfg-kbr0' do
  cookbook 'kubernetes'
  source 'ifcfg-kbr0.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    ip: kbr_ip
  )
end

# make kbr0 active
execute 'ifup kbr0'

# create router file for kbr0
content = ''
node['kube']['kubelet']['machines'].each_index do |i|
  remote_ip = node['kube']['kubelet']['machines'][i]
  next if remote_ip == ip_address
  content << "172.17.#{i}.0/24 via #{remote_ip}\n"
end
file "/etc/sysconfig/network-scripts/route-#{node['kube']['interface']}" do
  owner 'root'
  group 'root'
  mode 00644
  content content
end

# make the routes active
execute "ifup #{node['kube']['interface']}"
