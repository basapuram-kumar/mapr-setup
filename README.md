# This a collection of Ansible scripts

Please follow below steps to install cluster from scratch
#pwd
/etc/ansible

 Step 1:
 Change all hosts on required role wise in "host_templates/hosts_cluster " file.
 
 Step 2: 
 Provide all cluster ip's and hostsname's at "roles/etc-hosts-copy/templates/etc-hosts" file: 
 for example:
 10.0.20.4	ip-10-0-20-4.us-west-1.compute.internal
 
Command to execute:
[root@ip-10-0-20-4 ansible]# ansible-playbook -i host_templates/hosts_cluster nsc-install.yml 
