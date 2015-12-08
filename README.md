## vagrant-boilerplate


## Install

**Please never clone this package, unless you are willing to developing it!**  

This repository intended to use as a `git remote`. Before set this, you need to configure your git globally. This is needed, otherwise your essential files overwritten whit this package.

### Prepare

#### Configure merge driver

Set `merge` to always use your files:   
```sh
$ git config --global merge.ours.name "Keep ours merge"
$ git config --global merge.ours.driver true
```

This repository contains a `.gitattributes` file for work with `merge.ours` git config. 

For further documentation for this, see: http://stackoverflow.com/a/930495

#### Initialize your project

Make sure your `README.md` file are in your repository:  
```sh
$ cd /path/to/your/project/
$ touch README.md
$ git init
$ git add --all
$ git commit -m 'initial commit'
```

### Include vagrant-boilerplate

Set this repository as git remote & pull files:  
```sh
$ git remote add -t master -m master --no-tags vagrant-boilerplate https://senki@bitbucket.org/senki/vagrant-boilerplate.git
$ git fetch vagrant-boilerplate
$ git pull vagrant-boilerplate master
```

### Post install

After pull from remote, you need to edit the `Vagrantfile`, file.  

## Creator

**Csaba Maulis**

- <http://twitter.com/_senki>
- <http://bitbucket.com/senki>

## Copyright and license

Code and documentation copyright 2014 Csaba Maulis. Released under [the MIT license](LICENSE).
