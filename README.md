# vagrant-terraform-enterprise

This is a basic Vagrant environment that installs Terraform Enterprise in PoC mode for qu

## Pre-requisites

* A Terraform Enterprise license file (renamed to `vagrant-terraform-enterprise.rli`)
* vagrant-hostsupdater


## Running

```
vagrant plugin install vagrant-hostsupdater
vagrant up
```

## 

* Vagrant IP Address: https://203.0.113.10
* Replicated Dashboard: https://tfe.example.com:8800/
* TFE Login: https://tfe.example.com