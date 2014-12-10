# Kubernetes cookbook

Kubernetes cookbook that let you easy to deploy Kubernetes environment on RHEL/CentOS 7.x.

## Intro

You should at least give below information:

* Etcd server address list

The Etcd server and Kubernetes master can be located on same node, a list usually only contains one ip address which is the Kubernetes master's ip address.

* Kubernetes master ip address

The Kubernetes master ip address, a string.

* Kubernetes minion ip address list and the interface where the IP is located on

The ip address list and interface(eth0, eth1...).

## Quick start

Suppose your Kubernetes nodes are(You should make the nodes' hostname resolvable):

| **Role**    | **Hostname**  | Interface | IP Address     |
|:------------|:--------------|:----------|:---------------|
| Kube Master | kuber-master  | eth0      | 192.168.122.10 |
| Kube Minion | kuber-minion1 | eth0      | 192.168.122.11 |
| Kube Minion | kuber-minion2 | eth0      | 192.168.122.12 |
| Kube Minion | kuber-minion3 | eth0      | 192.168.122.13 |

Checkout code:

```
# git clone https://github.com/chenzhiwei/kubernetes-cookbook kubernetes
# vim kubernetes/environments/kubernetes.json
```

The sample `environments/kubernetes.json` file content:

```
{
  "name": "kubernetes",
  "override_attributes": {
    "kube": {
      "api": {
        "host": "192.168.122.10"
      },
      "kubelet": {
        "machines": ["192.168.122.11", "192.168.122.12", "192.168.122.13"]
      },
      "interface": "eth0"
    },
    "etcd": {
      "host": ["192.168.122.10"]
    }
  }
}
```

Upload the Kubernetes role/environment/cookbook to Chef server:

```
# knife role from file roles/*.json
# knife environment from file environments/kubernetes.json
# knife cookbook upload kubernetes
```

Start boostraping your nodes:

```
# knife bootstrap 192.168.122.10 -E kubernetes -r 'role[kubernetes-etcd],role[kubernetes-master]'
# knife bootstrap 192.168.122.11 -E kubernetes -r 'role[kubernetes-minion]'
# knife bootstrap 192.168.122.12 -E kubernetes -r 'role[kubernetes-minion]'
# knife bootstrap 192.168.122.13 -E kubernetes -r 'role[kubernetes-minion]'
```

Login Kubernetes master:

```
# kubecfg list minions
```

## Roles

* kubernetes-etcd  Install and configure etcd server.
* kubernetes-master Install and configure Kubernetes master node.
* kubernetes-minion Install and configure Kubernetes minion nodes.

## Recipes

* kubernetes::go  Install golang package.
* kubernetes::etcd  Install and config etcd.
* kubernetes::master  Install and configure Kubernetes Master.
* kubernetes::docker  Install and configure docker on Minion.
* kubernetes::minion  Install and configure Kubernetes Minion.
* kubernetes::network  Configure Kubernetes Minions network through openvswitch.
* kubernetes::firewall  Disable Firewall.

## Libraries

* network  Get the IPv4 address of the given interface. 

## License

This cookbook is distributed under the terms of the Apache License, Version 2.0. The full terms and conditions of this license are detailed in the LICENSE file.
