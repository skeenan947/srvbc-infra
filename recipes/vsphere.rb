#
# Cookbook Name:: srvbc-infra
# Recipe:: vsphere 
#
# Copyright (c) 2015 Shaun Keenan, All Rights Reserved.
require 'chef/provisioning/docker_driver'

node['provisioning']['hosts'].each do |nodetype,h|
  machine_image nodetype do
    role 'base'
    role nodetype
    machine_options :docker_options => {
      :base_image => {
        :name => 'ubuntu',
        :repository => 'ubuntu',
        :tag => '14.04'
      }
    }
  end
  
  1.upto(h['count']) do |num|
    machine "#{nodetype}-#{num}" do
      from_image nodetype
      machine_options :docker_options => {
        :command => '/usr/sbin/sshd -p 8022 -D',
        :ports => 8022
      }
    end
  end
end