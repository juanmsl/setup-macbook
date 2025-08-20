# Setup your Macbook

1. Download this repository as .zip
2. Uncompress the zip file
3. Execute script `update.sh`
4. Done!

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/juanmsl/setup-macbook/refs/heads/master/update.sh)"
```


> More interesting things [Here](https://www.swyx.io/new-mac-setup/)

---

### Important commands to update

#### Encrypt file
```bash
openssl bf -a -salt -in file -out file.encrypt
```

#### Decrypt file
```bash
openssl bf -d -a -in file.encrypt -out file
```

#### Create ssh key
```bash
ssh-keygen -t rsa -b 4096 -C name -f $HOME/.ssh/id_rsa_name -N ""
```
