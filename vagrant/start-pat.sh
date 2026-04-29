#!/bin/bash
su vagrant -c "pat templates update"
systemctl restart pat@vagrant
systemctl status pat@vagrant
