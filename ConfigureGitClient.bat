
@rem TODO: fetch user name and email from logged in user attributes, but confirm them with the user running script
set USER_NAME="Ivan Boyko"
set USER_EMAIL="boiko.ivan@gmail.com"



git config --global pull.rebase=true
@rem if you commit changes to your local Git clone and in the meantime someone else commit and push their changes to remote, next time when you pull it will by default merge two streams (branches) or work. This creates unnecessary complexity – branches in the history + additional "merge" commit.
@rem If you use "rebase" option than "git pull" will fetch new commits from remote, and then rebase your new commits on top of them. In most cases it does it well, it the worst case scenario it will ask for help to merge if changes touch the same lines of files (but that would be asked in case of "merge" strategy too!). As a result – history is more linear and no additional meta commit for "merge"

git config --global core.autocrlf=true
@rem This makes sure Git convert line endings in text files in your local Git clone to CRLF, but will automatically convert them to LF as this is the internal Git format.
@rem This helps to show correct diff - showing only meaningful changes and not changes in line endings; and helps with some Windows tools that don’t understand LF endings

git config --global user.name %USER_NAME%
git config --global user.email %USER_EMAIL%
@rem These parameters will make up the Author of your commits (when you do "git commit")
@rem They will be displayed in code history in VSTS, so it’s pretty important to have them right
@rem Credentials used to push to VSTS remote - can be absolutely different! You can even push someone else’s commits, if you’ve got them somehow in your Git clone
@rem [note] Visual Studio seems to ask you for these when you first connect to remote Git and clone a repo


@rem To check your current config:
@rem git config --global -l
