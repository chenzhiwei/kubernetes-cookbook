# Kubernetes cookbook

This is an under development cookbook, will complete it as soon as the Chef for RHEL 7.x release.

## Intro

You should at least give your Etcd IP address, Kubernetes master IP address, minions IP address list and the interface where the IP is located on.

The default Kubernetes service address is `10.254.0.0/16`.

Suppose your minion list is `['192.168.122.21', '192.168.122.22', '192.168.122.23']`, the Docker bridge(`kbr0`) will be `172.17.INDEX.1`(INDEX is the minion node index in the list).

## Recipes

* kubernetes::go  Install golang package.
* kubernetes::etcd  Install and config etcd.
* kubernetes::master  Install and configure Kubernetes Master node.
* kubernetes::docker  Install and configure docker on Minion node.
* kubernetes::openvswitch  Install and configure openvswitch on Minion nodes.
* kubernetes::minion  Install and configure Kubernetes Minion nodes.

## Libraries

* network  Get the IPv4 address of the given interface. 
