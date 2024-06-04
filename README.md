# fzf-win

## An awesome fzf wrapper for Windows

<p align="center">
  <a href="#about-">About</a> &nbsp;&bull;&nbsp;
  <a href="#installation-">Installation</a> &nbsp;&bull;&nbsp;
  <a href="#usage-">Usage</a> &nbsp;&bull;&nbsp;
  <a href="#configuration-">Configuration</a> &nbsp;&bull;&nbsp;
  <a href="#contributing-">Contributing</a>
</p>

<br>

## About 📖

`fzf-win` is a friendly and powerful wrapper `fzf` on Windows.
It offers an easy way to search and open files, directories, and even search file content from any shell.
Designed with simplicity and efficiency in mind, `fzf-win` transforms the way you navigate files on Windows.

What sets `fzf-win` apart is its easily customizable commands for actions you perform often. It comes pre-configured with commands to open Visual Studio Code, Vim, Windows File Explorer, and more, saving you time and keystrokes. 

So why wait? Start exploring `fzf-win` today and discover a better way to navigate your files! 🚀


## Installation 📥

Getting started with `fzf-win` is easy! You can either download the latest installer from our [releases page](https://github.com/joacortez/fzf-win/releases) or directly from this [link](https://github.com/joacortez/fzf-win/releases/download/v1.0.0/fzf-win_v1.0.0_x86_Windows.msi) 📦.

For the DIY enthusiasts out there, you can also clone the repo and use `build.bat` to build the installer yourself. No compilation is needed, just add the `src` directory to your path and you're good to go! 🛠️

### Prerequisites 📋

To ensure a smooth experience with `fzf-win`, make sure you have the following tools installed:

- [fzf](https://github.com/junegunn/fzf) (tested with version 0.52.1) 📂
- [RigGrep](https://github.com/BurntSushi/ripgrep) (tested with version 13.0.0 (rev af6b6c543b)) 🔍
- [bat](https://github.com/sharkdp/bat) (tested with version 0.24.0) 🦇
- [Git](https://git-scm.com/) (tested with version 2.43.0.windows.2) 🌐

You can easily check if these tools are installed by running the following commands in your terminal:

```sh
ff --health
```

While older versions of these tools may work, they are not officially supported. If you encounter any issues or want to request support for a specific version, don't hesitate to open an [issue](https://github.com/joacortez/fzf-win/issues). We're here to help! :raised_hands:

## Usage 🚀

Welcome to `fzf-win` 🎉, your new best friend for navigating files on Windows! Here's how you can get started:

fzf-win can be called using three commands depending on what you want to search for:
- `ff` to Find Files/bn
- `fd` to Find Directories
- `fl` to Find Lines in files.

All of these commands have the same syntax:
```sh
ff|fd|fl [OPTIONS] [ARGUMENTS]
```
Here are all the available options and arguments for each command (I'm going to use `ff` as an example, but you can replace it with `fd` or `fl`):

- **Running a command** 🏃‍♂️: To run a command, simply type `ff <command>`. Replace `<command>` with the command you want to run. If no command is specified it will run the default command which is `echo` but can be customized (see Configuration)

- **Listing all available commands** 📜: To see a list of all available commands, type `ff -l` or `ff --list`. This will show you all the commands you can run.

- **Getting help** 🆘: If you're ever feeling lost, just type `ff -h` or `ff --help` to get a helpful list of commands and options. We're here to help you!
You can also get help for a specific command by typing `ff <command> -h` or `ff <command> --help`.


- **Executing a one-time command** ⏱️: Want to run a command just once? No problem! Use `ff -c ARG1 ARG2` to execute a one-time command. Replace `ARG1` and `ARG2` with your arguments.

- **Listing all commands** 📝: To see all the commands you have configured, use `ff -l` or `ff --list`. It's like your personal command directory!

- **Adding a new command** ➕: To add a new command to the config file, use `ff -a NAME ARG1 ARG2`. Replace `NAME` with the name of your command, and `ARG1` and `ARG2` with your arguments.

    - You can also edit the config file of the command you want to update. The config file is located at `%INSTALL_DIR%\utils\<command>.cfg` or run `ff --add --help` to get more info and the complete path.

- **Checking your environment** 🌍: To check if all the dependencies are accessible from the current environment, use `fzf-win --health`. It's like a health checkup for your project!
- **Combining fzf-win with Other CLI Utilities** 🤝: By default, if no command is specified, `fzf-win` returns the path to the selected file. This makes it easy to pipe (`|`) the output to other commands. For example, `ff | clip` will copy the content of the selected file to your clipboard. It's like teamwork for your commands!

If you have any questions, please visit the the [repo](https://github.com/joacortez/fzf-win). And if you encounter any bugs, don't hesitate to report them at the [issues](https://github.com/joacortez/fzf-win/issues). Happy coding! 🚀

## Configuration ⚙️

`fzf-win` is highly customizable, allowing you to tailor your commands to suit your needs.
Here's how you get started:

### Commands 📜

You can add, edit, or remove commands from the config file located at `%INSTALL_DIR%\utils\<command>.cfg` or run `ff -a -h` to get the full path. 

To quickly add commands to the config file, use the `ff -a` command. For example:

```sh
ff -a qvim vim -q
```

This will add a new command to the config file that you can later call using `ff qvim`, which would result in `vim <selected-file> -q`.

> :exclamation: **Note**: The command name must be unique. If you try to add a command with the same name as an existing command, the newer one will always win. You can list all currently configured commands using `ff --list`.

For more complex commands or to delete or edit existing ones, you can do it directly in the configuration files. Each "mode" has its own config file.
For this example we'll use `ff`. For other modes change `ff` for the desired one.

Go to `%INSTALL_DIR%\utils\ff.cfg` or run `ff --add --help` to get the full path.

The configuration files are simple text files that contain the following fields:
```cfg
<command_name>=<command_prefix>,<command_suffix>
```

The command is later put together as `<command_prefix> <selected_file> <command_suffix>`.
You always need a command name and a command prefix, but the command suffix is optional.


Here's an example of a configuration file for the `ff` command:

```cfg
cd=cd /D,
vim=vim,+"cd %:p:h"
code=code,
explorer=explorer,
=echo,
```

In this example there are several named commands (cd, vim, code, ...) and one "default" command (empty name).
The default command is the one that will be executed if no command is specified when running `ff`.

### Path to dependencies 🗂️

If don't want to add the needed dependencies to the PATH or are having issues with them, you can specify the path to the installation directory for each dependency. 
Run `ff --health` to check if the dependencies are accessible and check the config file is to update it if needed.
In fzf-win.cfg update the following part with your paths

```cfg
; Paths to dependencies. Change if you do not want to use the default path
dependency_mapping[fzf],fzf
dependency_mapping[bat],bat
dependency_mapping[rg],rg
dependency_mapping[git],git
```

### Other Options

In the fzf-win.cfg file, there are a lot of compatibility options. Feel free to play around.
You can find this file at INSTALLDIR/utils/fzf-win.cfg.
If you're unsure where your INSTALLDIR is, you can use ff --add --help to find it.

Happy configuring! 🚀


## Contributing 🤝

We welcome contributions to `fzf-win` and are grateful for any support! Here's how you can contribute:

1. **Create an Issue**: If you've found a bug, want to request a feature, or have a question about the code, please create an issue! This helps us keep track of what we need to work on. Be sure to check first if the issue already exists to avoid duplicates.

2. **Submit a Pull Request**: If you've fixed a bug or implemented a new feature, we'd love to see it! Please create a pull request (PR) with your changes. Be sure to reference the issue number in your PR.

3. **Follow Conventional Commits**: To keep our commit history readable, we follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. Please format your commit messages accordingly.

4. **Keep a Clean Commit History**: Try to make sure each commit is a minimal, self-contained change. Avoid including unrelated changes in the same commit.

Remember, contributions aren't just about code! We appreciate help with documentation, design, testing, and more. Thank you for considering contributing to `fzf-win`! 🚀
