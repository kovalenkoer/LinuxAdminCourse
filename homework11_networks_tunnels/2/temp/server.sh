#!/usr/bin/env bash

setenforce 0

#Installing packets

yum install -y epel-release
yum install -y openvpn easy-rsa

#Creating CA and server keys

cd /usr/share/easy-rsa/3
echo "yes" | /usr/share/easy-rsa/3/easyrsa init-pki
echo "openvpnserver" | /usr/share/easy-rsa/3/easyrsa build-ca nopass
echo "openvpnserver" | /usr/share/easy-rsa/3/easyrsa gen-req server nopass
echo "yes" | /usr/share/easy-rsa/3/easyrsa sign-req server server
/usr/share/easy-rsa/3/easyrsa gen-dh
/usr/sbin/openvpn --genkey --secret ta.key

cp -ar /usr/share/easy-rsa/3/pki/ca.crt /etc/openvpn
cp -ar /usr/share/easy-rsa/3/pki/private/ca.key /etc/openvpn
cp -ar /usr/share/easy-rsa/3/pki/issued/server.crt /etc/openvpn
cp -ar /usr/share/easy-rsa/3/pki/private/server.key /etc/openvpn
cp -ar /usr/share/easy-rsa/3/pki/dh.pem /etc/openvpn
cp -ar /usr/share/easy-rsa/3/ta.key /etc/openvpn

#Generating client certificates

echo "client" | /usr/share/easy-rsa/3/easyrsa gen-req client nopass
echo "yes" | /usr/share/easy-rsa/3/easyrsa sign-req client client
cp -ar /usr/share/easy-rsa/3/pki/issued/client.crt /srv
cp -ar /usr/share/easy-rsa/3/pki/private/client.key /srv

#Setup server config

cp -ar /srv/server.conf /etc/openvpn
mkdir /etc/openvpn/ccd && mkdir /var/log/openvpn
#echo "iroute 192.168.2.0 255.255.255.0" > /etc/openvpn/ccd/client


#Service start
sleep 10
systemctl start openvpn@server
systemctl enable openvpn@server

#Check status

ss -ua | grep openvpn
systemctl status openvpn@server
ip a

