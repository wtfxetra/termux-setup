#!/data/data/com.termux/files/usr/bin/bash
# Variables
XXDIR="$HOME/termux-setup"
XPKGS=("nano" "curl" "git" "wget" "openssh")
XSHELL="fish"
QUIET="> /dev/null 2>&1"

# Functions

xslsp() {
    sleep 1
}

xquiet() {
    eval "$@ $QUIET"
}

update_packages() {
    echo "Updating Packages . . . . . ."
    xquiet "yes | pkg update"
    xquiet "yes | pkg upgrade"
}

remove_motd() {
    echo "Removing Motd . . . . . ."
    mv $PREFIX/etc/motd $PREFIX/etc/motd.bak
    mv $PREFIX/etc/motd.sh $PREFIX/etc/motd.sh.bak
    mv $PREFIX/etc/motd-playstore $PREFIX/etc/motd-playstore.bak
}
install_packages() {
    echo "Installing Necessary Packages  . . . . . ."
    xquiet "pkg install $XPKGS -y"
    xquiet "pkg install $XSHELL -y"
}

change_shell() {
    echo "Changing Default Shell to $XSHELL"
    xquiet "chsh -s $XSHELL"
}

make_dirs() {
    echo "Creating Directories . . . . . ."
    mkdir -p $HOME/{Downloads,Video,.backup,.config}
}

copy_config() {
    echo "Copying Configs . . . . . ."
    cp -r "$XXDIR/HOME/." "$HOME/"
}

gh-ssh-setup() {
    local email=""
    local key_path="$HOME/.ssh/id_ed25519"
    
    # Ask for email
    echo "Ssh Keygen . . . . . ."
    echo "Enter your GitHub email address:"
    read -r email
    
    # Validate email
    if [ -z "$email" ]; then
        echo "Error: Email cannot be empty!"
        return 1
    fi
    
    # Create .ssh directory if it doesn't exist
    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        echo "Created .ssh directory"
    fi
    
    # Check if key already exists
    if [ -f "$key_path" ]; then
        echo "SSH key already exists at: $key_path"
        read -p "Do you want to overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            return 1
        fi
        rm -f "$key_path" "$key_path.pub"
        echo "Removed existing key"
    fi
    
    # Generate ed25519 key
    echo "Generating ed25519 SSH key for: $email"
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""
    
    # Start SSH agent and add key
    echo "Starting SSH agent..."
    eval $(ssh-agent) > /dev/null
    ssh-add "$key_path"
    
    # Display public key
    echo ""
    echo "=== Copy the public key below and add it to GitHub ==="
    echo ""
    cat "$key_path.pub"
    echo ""
    echo "=== Public key displayed above ==="
    echo ""
    echo "Go to: GitHub Settings -> SSH and GPG keys -> New SSH key"
    echo ""
}

#
setup_main() {
    update_packages
    xslsp
    remove_motd
    xslsp
    install_packages
    xslsp
    change_shell
    xslsp
    make_dirs
    xslsp
    git clone https://github.com/wtfxetra/termux-setup ~/termux-setup
    copy_config
    xslsp
    #gh-ssh-setup
    
    
}

#

setup_main
