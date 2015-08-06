#
# Cookbook Name:: srvbc-infra
# Recipe:: vsphere 
#
# Copyright (c) 2015 Shaun Keenan, All Rights Reserved.
require 'chef/provisioning/vsphere_driver'

chef_gem 'chef-provisioning-vsphere' do
  action :install
  compile_time true
end

p = node['provisioning']
creds = data_bag_item('provisioning_creds','vsphere')

with_vsphere_driver host: p['vsphere_host'],
  insecure: true,
  user:     creds['vsphere_user'],
  password: creds['vsphere_pass']


with_machine_options :bootstrap_options => {
  use_linked_clone: false,
  network_name: [p['network']],
  datacenter: p['datacenter_name'],
  template_name: p['template'],
  :ssh => {
    :paranoid => false,
  }
}


node['provisioning']['hosts'].each do |nodetype,h|
  1.upto(h['count']) do |num|
    machine "#{nodetype}-#{num}" do
      num_cpus: h['num_cpus'],
      memory_mb: h['memory_mb'],
      template_name: p['templates'][h['template']]['name']
      ssh => {
        :user => p['templates'][h['template']]['ssh_user']
      }
      role 'base',
      role nodetype
    end
  end
end