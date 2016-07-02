replicated
------

Installs [replicated](http://www.replicated.com/)

Requirements
======

This role requires Ansible 1.7 or higher.

Dependencies
======

This role assumes you have already installed

- gpg
- Docker

and that the Linux kernel supports AUFS.

Example Playbook
========

Install replicated
```
- hosts: all
  sudo: true

  roles:
    - {role: replicated}
```

License
====

[MIT](LICENSE)

Author Information
=========

Patrick Humpal
