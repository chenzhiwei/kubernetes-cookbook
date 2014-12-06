name              'kubernetes'
maintainer        'Chen Zhiwei'
maintainer_email  'zhiweik@gmail.com'
license           'Apache 2.0'
description       'Configures and installs Kubernetes'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '0.1.0'

%w(redhat centos).each do |os|
  supports os
end
