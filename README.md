## Rails project to kickstart development

Comes with:

 * Rails 3
 * jQuery
 * Haml
 * inherited_resources
 * exception_notifier
 * Rspec, Factory Girl, Steak and Spork

## How to hit the ground running

<pre>
# define a rails application name and a folder name where you want to 
# checkout your project
RAILS_NAME=ProjectOne
FS_NAME=projectone

# checkout project zero into a new folder
git clone git@github.com:panter/project_zero.git $FS_NAME

# remove git history
rm -rf $FS_NAME/.git

# setup rvm
echo "rvm ruby-1.8.7@$FS_NAME" > $FS_NAME/.rvmrc
cd $FS_NAME

# run some search replace on project name
perl -p -i -e "s/FutureKids/$RAILS_NAME/" config/*
perl -p -i -e "s/FutureKids/$RAILS_NAME/" config/initializers/*
perl -p -i -e "s/FutureKids/$RAILS_NAME/" config/environments/*
perl -p -i -e "s/FutureKids/$RAILS_NAME/" *
perl -p -i -e "s/FutureKids/$RAILS_NAME/" spec/*
perl -p -i -e "s/FutureKids/$RAILS_NAME/" app/views/layouts/*
perl -p -i -e "s/project_zero/$FS_NAME/" config/initializers/*


# push the project into a new location
git init
git add .
git commit -am"adapted from https://github.com/panter/project_zero"
git remote add origin gitosis@git.yourdomain.com:$FS_NAME.git
git push origin master:refs/heads/master
</pre>


## See the branches

There are branches of this project with other configurations.

