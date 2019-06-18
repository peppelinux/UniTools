## Useful GIT commands


#### Basics
````
git clone https://github.com/peppelinux/SQL4students.git

# add file and modify whatever you want
# then add all the newly created files and apply all changements
git add -A
git commit -a -m "Sintetic description about what you've done"

# then upload your code in remote repository
git push 
````

#### Amend a commit
It could be helpfull understand how to undo a wrong commit

````
git commit -a --amend
# then change message or exit from console editor (CTRL+X if you're using nano or :wq if vim)
git push -f
````

#### Update local repository
It happens that the master/parent repository goes ahead from your forked repository.
You should merge all the newly changed things into your repository and then sync your local folder

````
# sync remote merged repository with your local folder
git pull
````

#### force a pull
This is usefull if you have to force a pull even if you have some uncommitted or a different committed situation
````
git fetch --all
git reset --hard origin/master
````
#### remove/undo the last commit or file changes
````
git reset --hard HEAD^^
git pull
````

#### destroy commit history
This is usefull if you want to rebase your commit timeline
````
git checkout --orphan latest_branch
git add -A
git commit -am "rebase"
git branch -D master
git branch -m master
git push -f origin master
````

#### rebase
````
git log
git rebase -i  cd18ce4a1c4a464382a7e16f4c0d138e6ac17db8
# pick in the high lines, squash of fixup in the lower with an editor like nano/vi or whatever

git status

# fix some definitions
git rebase --edit-todo

# c'mon
git commit --amend

git push

# put squash or fixup inot desidered lines
# git checkout master
# git push

# if something goes wrong and you want to reset all
rm -fr .git/rebase-merge
````

#### change repository origin
This is usefull if you want to change your remote repository from one to another
````
export GITREPO_URL="put here the repository address"

git remote rm origin
git remote add origin $GITREPO_URL
git config master.remote origin
git config master.merge refs/heads/master
git push --set-upstream origin master
````

#### create a branch, pushing it, destroy locally and remotely
````
# do uncommited changments, then move them to a separate branch called dev
git checkout -b dev
# push changes into remote branch
git push origin dev
# returns to master
git checkout master

# destroy local branch
git branch -d dev

# destroy remote branch
git push origin --delete dev
````

#### store credentials
It happens to write too much your login/password for a push.
This could help us to write some less digits... sometimes!
````
# for two hours
git config --global credential.helper 'cache --timeout 7200'
````

#### Adding ssh key
````
ssh-keygen -t rsa

# copy this to atlassian/github pub ssh keys
cat ~/.ssh/id_rsa.pub

# propagate key
ssh -T git@bitbucket.org

# clone using ssh clone url
git clone git@bitbucket.org:teamname/reponame.git
````

## pull a fork into a separate branch and then merge it
````
git checkout -b italia-master master
git pull https://github.com/italia/spid-testenv2.git master

git checkout master
git merge --no-ff italia-master
git push origin master
````
