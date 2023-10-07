## Install
[Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Ubuntuならaptで入る

## Run
hostsを更新した後、playbookを指定して実行


```
ansible-playbook -i hosts <playbook> --ask-become-pass
```
