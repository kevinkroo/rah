#
# https://roostify.atlassian.net/wiki/spaces/TU/pages/65833843/Heroku
#
# Roostify Auto Heroku (rah)
#  usage: rah <client> <prod|stage>
#
# todo:
#  - strict sanity checking at start of script
#    - test heroku, fork plugin
#  - careful evaluation of exit codes 
#  - construct cname, assign to ${cname}
#  - order isn't contigent for all steps, consider doing 
#    some tasks outside of this automation:
#    - fastly config
#    - create account / create global admins


# Test rooaws functions properly
# rooaws
# if [[ $? != 0 ]]; then 
# exit $?; 
# fi

# test thor 
# test heroku / heroku fork
# test aws cli 
# test ruby 

#
# create s3 buckets - this could be done directly with aws cli. Doing so would eliminate
#  the dependency of 'rooaws.' Bear in mind bucket policies are needed (cli/s3-policies)
#
# rooaws roostify/prod
# Verify rooaws environment is correct
# 
# aws_s3_bucket = roostify-${client}
# heroku_app_name = roostify-${client}
#
# thor s3:create roostify-${client} -e
# thor pipeline:create_app roostify-${client} -e	
#
# thor s3:create roostify-${aws_s3_bucket} -e
# thor pipeline:create_app roostify-${heroku_app_name} -e	

# https://dev.to/rpalo/smooth-ruby-one-liners-154

hex_string = $(ruby -rsecurerandom -e 'print SecureRandom::hex(32)')


# heroku config:set --help

# conditional test argv for prod|stage for ${heroku_environment}

heroku config:set 
 # this is also the cname - be consistent
 APP_DOMAIN=roostify-${client}.herokuapp.com 
 APP_RELEASE_STAGE=${client}-roostify-core-${heroku_environment}
 S3_BUCKET=roostify-${client}
 CURRENT_ENCRYPTION_KEY=${hex_string>
 PREVIOUS_ENCRYPTION_KEY=${hex_string>

# run migrations - test exit codes from each 

heroku run rake db:schema:load -a roostify-${client}
heroku run rake db:migrate:status -a roostify-${client}
heroku run rake db:migrate -a roostify-${client}
heroku restart -a roostify-${client}

# adjust dynos - conditional test for prod|stage

heroku ps:scale web=1:performance-m -a roostify-${client}
heroku ps:scale worker=1:standard-2x -a roostify-${client}

# heroku ps:scale web=1:standard-2x -a roostify-${client}
# heroku ps:scale worker=1:standard-1x -a roostify-${client}

#
# create account - unsure if this could be done as a ruby one-liner or if irb would help
#
# heroku run rails console -a roostify-<client>
#
# a = Account.create!(name: '<name>', internal_name: '<name>', enable_yodlee: true, enable_timeline: true, cname: '<cname>')
# a.token
#
# create global admins 
#
# thor pipeline:create_roostify_users --include roostify-<client> --account_token <token> -e

#
# add domain
# 
# heroku domains:add ${cname} -a roostify-${client}

#
# schedule database backups
#
# heroku pg:backups schedule DATABASE_URL --at '00:00 America/Los_Angeles' -a roostify-${client}


