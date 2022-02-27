#!/bin/bash
su vagrant -c "pat updateforms"
systemctl restart pat@vagrant
systemctl status pat@vagrant
