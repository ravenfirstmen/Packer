#!/bin/bash

qemu-img create -b focal-server-cloudimg-amd64.img -f qcow2 -F qcow2 focal-server-cloudimg-amd64-20G.img 20G
chown libvirt-qemu:kvm focal-server-cloudimg-amd64-20G.img
