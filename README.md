<p align="center">
  <img src="./assets/hadoopkrbtransparent.png" height="250">
</p>

# Hadoop Cluster + Kerberos Authentication Server

End-2-End SSL encrypted Hadoop Cluster with KRB5 + OpenLDAP backend, featuring a NGINX Docker powered web server

**⚠️⚠️ *These scripts assume that you are running on 🐧 Ubuntu/Debian !* ⚠️⚠️**

**Table of Contents**

- [Hadoop Cluster + Kerberos Authentication Server](#hadoop-cluster---kerberos-authentication-server)
- [Features](#features)
- [Preparation](#preparation)
- [Installation](#installation)
- [How it works & User Guide](#how-it-works---user-guide)
    + [Communications](#communications)
    + [Hadoop](#hadoop)
    + [Kerberos & OpenLDAP](#kerberos---openldap)
    + [NGINX and Authentik](#nginx-and-authentik)

# Features
- Distributed minimal 3-node Hadoop Cluster configuration
- UNIX user mapping to hadoop services
- Kerberos 5 with OpenLDAP backend
- NGINX based web server featuring fail2ban and certbot with Authentik for Kerberos SPNEGO authentication

# Preparation
Please make sure you have set up OpenSSH on all your machines for key-based and GSSAPI authentification and you have generated SSH keys for all your machines

You are expected to create your ~/.ssh/config appropriately and listed the correct public keys to each machine's respective authorized_keys file

# Installation
Simply clone this repository in all the machines you intend to setup :
```bash
git clone https://github.com/haytamxp/kerberos_hadook.git
```
> **RECOMMENDED TO VERIFY THE CONFIGURATIONS BEFORE RUNNING THE MAIN SCRIPT**

Once you are satisfied with the configurations and made your changes, simply run main.sh with root privileges

```bash
sudo ./main.sh
```
and select which part of the cluster software would you want to install and dedicate on this machine.

After installation please finish configuration of your NGINX subfolders/subdomains and link Authentik with Kerberos as shown in Authentik Docs

# How it works & User Guide

This script sets up a 5 node system that features :
- 1 Dedicated Namenode
- 2 Dedicated Datanodes
- 1 Kerberos 5 server with OpenLDAP backend
- 1 Web accessible NGINX webserver with Authentik for web-based management and SPNEGO authentification, Authentik can also be used to handle internal Kerberos authentication mechanisms normally handled by OpenSSH + KDC GSSAPI based authentification

### Communications

these services communicate with each other via NGINX TCP streams on the subdomains, NGINX itself reaches these services via Key based SSH TCP port forwarding tunnels running on Docker

For the specific configuration that these scripts was made for, many of these servers are on different networks, necessitating SSH (or OpenVPN/WireGuard split tunnels if the LAN firewall allows it) for access.

Configuration would be significantly simpler if all the machines reside on the same local network.

Whenever a client, be it a person or a UNIX process, attempts to access a Kerberised service.
it must first get a valid ticket granting ticket via the command :
```bash
kinit -kt <keytab file location> <user>/<hostname>@COMPANY.REALM
```
you will know you have the TGT via the command
```bash
klist
```

Of course, this requires that you have krb5-client installed and configured to point to the KDC server

after that you can either ssh directly to the kerberized service or via a SPNEGO-enabled web browser, either open a TCP forwarding port directly to the service's exposed WebUI port bound to the remote's localhost or if NGINX and Authentik are setup, simply go to https://service.domain.url, which should redirect you to pre-configured Authentik, which will handle authentication and forwarding of your Kerberos ticket to the service.

### Hadoop

Due to limited hardware resources on the tested machines, each node in the hadoop cluster has only HDFS and YARN enabled, each service is bound to a unique UNIX user, with specific permissions.
| UNIX user  | Purpose  |
| :------------ | :------------ |
|  hadoopadmin |  Admin user that has full access to the hadoop local install and is what the user SSH into |
|  hdfs |  handles HDFS related processes |
|  yarn |  handles YARN related processes |
|  hive |   handles Hive related processes, is part of HDFS |
|  mapred |   handles MapReduce and JobHistory related processes |
|  HTTP |   handles HTTPFS related processes, is part of HDFS |

All of these UNIX users do not have sudo or docker permissions, nor can they access home folders outside of their owner:group.

`hadoopadmin` can only use sudo to switch to the other hadoop UNIX users to run commands as them, all the hadoop UNIX users are part of the `hadoopadmin` group, so in case of permission issues, one must just change group permissions.

To start the Hadoop cluster,  login to the **Namenode** as `hadoopadmin` and run this command :
```bash
hdp start
```
To start the Hadoop cluster,  on the same **Namenode** as `hadoopadmin` and run this command :
```bash
hdp stop
```

hadoopadmin starts/stops the hadoop services by sshing to the nodes, and then starting the daemon's as their respective UNIX users via the command `sudo -u <user> <command>`

> This does means that one must have ~/.ssh/config on every machine in the cluster with aliases pointing to the nodes, including localhost,  logging in as user `hadoopadmin` and their respective authentification method, do note the alias must match what's been set in etc/hadoop/workers file

### Kerberos & OpenLDAP

Hadoop Inter-Process Communication are authenticated via Kerberos, so the `hdp`  program takes care of getting fresh TGT for each user/hostname@COMPANY.REALM

Kerberos stores it's principals in an OpenLDAP backend database running on the same machine, and one can easily manage it via the OpenLDAP CLI or any of the LDAP management GUIs that support OpenLDAP, the Alpine SSH docker image on the webserver should make it easy to connect any OpenLDAP GUI app to the OpenLDAP backend by simply specifying `<hostname/ip>:<port>` and adding the port forwarding rule to `<docker-compose-location>/ssh/entrypoint-krb.sh`.
In case the GUI is running outside Docker, one must bind the access port to localhost by editing the `docker-compose.yml` file containing the configuration of the ssh tunnel pointing to LDAP server, default is `krb-tunnel`.

### NGINX and Authentik

The webserver runs a Docker image of Linuxserver's SWAG (Secure Web Application Gateway); this NGINX webserver makes it easy to manage services via it's built-in proxy configs and integrated certbot for SSL encryption (using LetsEncrypt or ZeroSSL) and fail2ban services.

and Authentik, an Identity Provider that can (and while outside the scope of these scripts, it is in the tested implementation), configured to connect to Kerberos as a federated login source provider with sync and SPNEGO support.

Authenthik offers a very clean WebUI for managing users, proxy providers (We setup SWAG as a forward auth proxy provider, and Hadoop as an associated application, both associated to the default embedded Auth Outpost), etc...

> Please do note that this Hadoop is configured with the same certificate as the one used in NGINX, **you are expected to replace it with your own to avoid issues by converting your NGINX provided CA certificate to JKS/JCEKS, or making a self-signed certificate using OpenSSL, for the former you will need your root CA certificate and the private keys used for signing it**
