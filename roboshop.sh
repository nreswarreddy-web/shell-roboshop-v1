#!/bin/bash

        ami_id="ami-0055977a6e828a4f4"
		instance-type="t3.micro"
		domin-name="daw92ss.store"
		hosted_zone_id="Z04926153FHNHA0C48N6P"

        for instance in $@
        do

          echo " creating the instance :"$instance""

        done

        