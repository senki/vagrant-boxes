<a name="1.4.1"></a>
# [1.4.1](https://github.com/senki/vagrant-boxes/compare/v1.4.0...v) (2017-03-23)


### Features

* remove 'mysqlbackuphandler.sh', no more feasible ([75564fb](https://github.com/senki/vagrant-boxes/commit/75564fb))
* Remove 'vagrant-vbguest' dependency ([79630f8](https://github.com/senki/vagrant-boxes/commit/79630f8))
* Replace official Ubntu bux with boxcutter variant ([8380565](https://github.com/senki/vagrant-boxes/commit/8380565))
* Add vagrant user, insert Vagrant insecure certificate ([e69d24c](https://github.com/senki/vagrant-boxes/commit/e69d24c))
* Reconsider VBoxGuestAdditions updates ([487aab4](https://github.com/senki/vagrant-boxes/commit/487aab4))
* Remove Ubuntu Precise support. No longer feasible ([27b6408](https://github.com/senki/vagrant-boxes/commit/27b6408))
* Test the newly created boxes ([6ed62a9](https://github.com/senki/vagrant-boxes/commit/6ed62a9))


### Bug Fixes

* Missing update check file ([ce7c0de](https://github.com/senki/vagrant-boxes/commit/ce7c0de))


### Code Refactoring

* Linfo is now from git repo ([ec7e337](https://github.com/senki/vagrant-boxes/commit/ec7e337))
* Added back linfo config file ([35e580b](https://github.com/senki/vagrant-boxes/commit/35e580b))
* Merge from [jrgp/linfo](https://github.com/jrgp/linfo) [1498290](https://github.com/jrgp/linfo/commit/1498290) to 'vagrant/test/linfo' ([5c48f12](https://github.com/senki/vagrant-boxes/commit/5c48f12))
* Delete linfo files ([0a4cbe7](https://github.com/senki/vagrant-boxes/commit/0a4cbe7))


<a name="1.3.1"></a>
# [1.3.1](https://github.com/senki/vagrant-boxes/releases/tag/v1.3.1) (2016-11-15)


### Features

* **build:** Replace custom script with vagrant-vbguest plugin ([89b7ba7](https://github.com/senki/vagrant-boxes/commit/89b7ba7))
* **build:** Introduce logtail script; fewer keystroke needed ([9c5c970](https://github.com/senki/vagrant-boxes/commit/9c5c970))



<a name="1.3.0"></a>
# [1.3.0](https://github.com/senki/vagrant-boxes/releases/tag/v1.3.0) (2016-11-02)


### Bug Fixes

* Add serial port just for sure ([24ac3aa](https://github.com/senki/vagrant-boxes/commit/24ac3aa))


### Code Refactoring

* **build:** VirtualBox Addition install moved out from standard process ([dafec5b](https://github.com/senki/vagrant-boxes/commit/dafec5b))
* **build:** Helper script change ([6c05998](https://github.com/senki/vagrant-boxes/commit/6c05998))


### Features

* **test:** Add new benchmark script ([c174c44](https://github.com/senki/vagrant-boxes/commit/c174c44))
* New Ubuntu box: Xeanial ([bd8beec](https://github.com/senki/vagrant-boxes/commit/bd8beec))
* Update doc style ([970b98a](https://github.com/senki/vagrant-boxes/commit/970b98a))


### BREAKING CHANGES

* build: Helper script location, name and behaviour changed
* build: VirtualBox Addition script location, name and behaviour changed
