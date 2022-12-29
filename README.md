# bee helper

ruby script to download today's spelling bee hints file, check against a 
local list of words already found, and output customized hints list

## setup

```sh
git clone https://github.com/escowles/bee_helper.git
cd bee_helper
bundle install
echo "PATH=$PATH:$PWD/bin" >> ~/.bash_profile
```

## usage

copy your current set of words to the clipboard, then:

```sh
bee_helper
```
