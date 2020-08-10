# mira-ta/git-dock

## How to use

**Note!** docker-compose.yml may not be supported yet due to interactive key manipulating (adding/removing from authorized keys file).

First, pull the docker image or build it manually using this repository and commands below:

```sh
# to pull docker image (not yet published)
docker pull mira-ta/git-dock

# or download git repository
git clone https://github.com/mira-ta/git-dock && \
    docker build --tag git-dock:latest git-dock/
```

After that you can run your docker container:

```sh
HOST_MACHINE_PORT=8022
HOST_MACHINE_VOLUME=/var/repositories

# create volume directory and then
# map repository to `git` user
# inside the container.
mkdir --parents "${HOST_MACHINE_VOLUME}" && \
    chown --recursive 1000:1000 "${HOST_MACHINE_VOLUME}"

docker run --interactive --tty --publish ${HOST_MACHINE_PORT}:22 \
    --volume "${HOST_MACHINE_VOLUME}"/:/home/git/.git-repositories/:rw \
    --name my_precious_git_repository_server \
    git-dock:latest
```

Then you will prompt to either run server or not.

```
Welcome to configure script!
Type `keys` to see little help about keys manipulating.
Type `run` (not recommended) to exec server.
Type `exit` or tap Ctrl+D to exit configure script.
> 
```

Type `keys add` to add your key:

```
Welcome to configure script!
Type `keys` to see little help about keys manipulating.
Type `run` (not recommended) to exec server.
Type `exit` or tap Ctrl+D to exit configure script.
> keys add
Please, enter the public key (in one line): 
```

Then procede putting your public key in standard input:

```
Welcome to configure script!
Type `keys` to see little help about keys manipulating.
Type `run` (not recommended) to exec server.
Type `exit` or tap Ctrl+D to exit configure script.
> keys add
Please, enter the public key (in one line): my-precious-format Some_Really_Cool_Public_Key_Everyone_Is_Envy_About stuff_here_goes_wherever_cuz_it_is_a_comment
```

After that confirm your key:

```
Welcome to configure script!
Type `keys` to see little help about keys manipulating.
Type `run` (not recommended) to exec server.
Type `exit` or tap Ctrl+D to exit configure script.
> keys add
Please, enter the public key (in one line): my-precious-format Some_Really_Cool_Public_Key_Everyone_Is_Envy_About stuff_here_goes_wherever_cuz_it_is_a_comment
Are you sure? (y/N): y
Key has been added to `/home/git/.ssh/authorized_keys`.
> 
```

Continuing from this step you can either run server manually (but you *won't be able to stop process using Ctrl+C* or other binding since your standard input will be attached to running sshd instance):
```sh
Welcome to configure script!
Type `keys` to see little help about keys manipulating.
Type `run` (not recommended) to exec server.
Type `exit` or tap Ctrl+D to exit configure script.
> keys add
Please, enter the public key (in one line): my-precious-format Some_Really_Cool_Public_Key_Everyone_Is_Envy_About stuff_here_goes_wherever_cuz_it_is_a_comment
Are you sure? (y/N): y
Key has been added to `/home/git/.ssh/authorized_keys`.
> run
Executing sshd server (not recommended if you are in `attached` mode,
a.k.a --interactive --tty flags are provided to docker run).
```

Or exit typing `exit`/Ctrl+D and restart the container in detached mod:

```sh
docker start my_precious_git_repository_server
```

## Updating keys

If you want to update your keys, remove the `.git-repositories/.interactive-disabled` file which will make script be executed in interactive mode rather than running sshd as soon as it starts, and add key using guide above.

```sh
HOST_MACHINE_VOLUME=/var/repositories

# delete that file on host (!) machine and restart container
rm -f "${HOST_MACHINE_VOLUME}"/.interactive-disabled
```

## Contributing

Feel free to contribute and report bugs.

