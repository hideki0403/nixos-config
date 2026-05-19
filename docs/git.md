# Setup git

```sh
git config --file ~/.gitconfig.local user.name "YOUR NAME"
git config --file ~/.gitconfig.local user.email "YOUR EMAIL"
```
```
[yukineko@vm:~]$ gh auth login
? Where do you use GitHub? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? No
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: ****-****
Press Enter to open https://github.com/login/device in your browser...
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Configured git protocol
open /home/yukineko/.config/gh/config.yml: read-only file system
```
