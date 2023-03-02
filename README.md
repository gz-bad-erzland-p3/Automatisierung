# Automatisierung
Die automatisierte Aufsetzung und Aktualisierung des Webservers erfolgt mittels Vagrant und Ansible.

Die VM wird durch Vagrant über den Provider "VMWare Workstation" erstellt.
```
c:\vagrant\lnx-docker>vagrant up --no-provision
```

Über den Controle Node wird die VM automatisch Konfiguriert.
```
[admin@lnx-ansible-ctl vagrant/lnx-docker]$ ansible-playbook --vault-password-file=/home/admin/.vault_pass playbooks/site.yml
``` 
