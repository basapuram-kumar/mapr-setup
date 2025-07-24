# Ansible scripts for MapR Cluster setup

Please follow below steps to install cluster from scratch

 Supported OS details
 ---------------------
 CentOS-7
 
 Tested MapR Versions
 --------------------
 MapR - v6.1.1
 MapR - MEP-6.3.6

Steps
-----
 Step 1:
 Make sure to have Passwordless login to all the cluster hosts.


 Step 2:
 Change all hosts on required role wise in "host_templates/hosts_cluster " file.

 
 Step 3: 
 Provide all cluster ip's and hostsname's at "roles/etc-hosts-copy/templates/etc-hosts" file: 

 for example:

10.100.7.63 mapr611-test.acceldata.ce


 Step4:
Provide the acceesible repository details at "./group_vars/all" file.

Ex: 
Accessible repo url, authentication details(user-name & Password) for repo.

And

Provide the Disk details at "./group_vars/all" file  

  ``` disks: /dev/vdb ```

And,

  If needed to change the security from default maprsasl to kerberos, modify at "./group_vars/all" file  

  ``` security_all: kerberos ```

 Step5: 
The default confiuguration will be used to setup maprsasl security.

Command to execute:
-------------------
 ansible-playbook -i host_templates/hosts_cluster nsc-install.yml 
