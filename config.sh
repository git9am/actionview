#!/bin/sh

echo "configure starting..."

chmod -R 777 storage
chmod -R 777 bootstrap/cache

#replace eloquent model
export eloquentuserfile=vendor/cartalyst/sentinel/src/Users/EloquentUser.php
export eloquentuserinterfacefile=vendor/cartalyst/sentinel/src/Users/UserInterface.php

find vendor/cartalyst/sentinel/src -type f -print0 | xargs -0 \
  sed -i 's/Illuminate\\Database\\Eloquent\\Model/Jenssegers\\Mongodb\\Eloquent\\Model/g'

#mongodb object ids are read in as strings
sed -i 's/getUserId(): int/getUserId(): string/g' $eloquentuserfile
sed -i 's/getUserId(): int/getUserId(): string/g' $eloquentuserinterfacefile

#initialize activition's completed
export activationrepofile=vendor/cartalyst/sentinel/src/Activations/IlluminateActivationRepository.php
if [ `grep -c '$activation->completed = false;' $activationrepofile` -eq 0 ]; then
  sed -i '/$activation->user_id = $user->getUserId();/a\        $activation->completed = false;' $activationrepofile
fi

#add avatar field to fillable
if [ `grep -c "'avatar'," $eloquentuserfile` -eq 0 ]; then
  sed -i "/fillable/a\        'avatar'," $eloquentuserfile
fi
#add invalid_flag field to fillable
if [ `grep -c "'invalid_flag'," $eloquentuserfile` -eq 0 ]; then
  sed -i "/fillable/a\        'invalid_flag'," $eloquentuserfile
fi
#add ldap_dn field to fillable
if [ `grep -c "'ldap_dn'," $eloquentuserfile` -eq 0 ]; then
  sed -i "/fillable/a\        'ldap_dn'," $eloquentuserfile
fi
#add directory field to fillable
if [ `grep -c "'directory'," $eloquentuserfile` -eq 0 ]; then
  sed -i "/fillable/a\        'directory'," $eloquentuserfile
fi
#add provider field to fillable
if [ `grep -c "'sync_flag'," $eloquentuserfile` -eq 0 ]; then
  sed -i "/fillable/a\        'sync_flag'," $eloquentuserfile
fi

echo "configure complete."
