mv /root/.oh-my-zsh /etc/oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/oh-my-zsh/themes/powerlevel10k 
rm /etc/zsh/zshrc
cp "$current_path/ohmyzsh-p10k/globalZshrc" /etc/zsh/zshrc
echo "source /etc/zsh/zshrc" | tee /etc/skel/.zshrc > /dev/null
for user in $(cut -f1 -d: /etc/passwd); do
    if [ -d /home/$user ]; then
        echo "source /etc/zsh/zshrc" |
        tee /home/$user/.zshrc > /dev/null
        chown $user:$user /home/$user/.zshrc
    fi
done

rm /root/.zshrc
cp "$current_path/ohmyzsh-p10k/rootZshrc" /root/.zshrc

rm /etc/.p10k.zsh
cp "$current_path/ohmyzsh-p10k/p10k" /etc/.p10k.zsh

for user in $(cut -f1 -d: /etc/passwd); do
    if [ -d /home/$user ]; then
        cat <<EOF | tee /home/$user/.zshrc > /dev/null
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi
source /etc/zsh/zshrc
[[ ! -f /etc/.p10k.zsh ]] || source /etc/.p10k.zsh
EOF
        chown $user:$user /home/$user/.zshrc
    fi
done
cat <<EOF | tee /etc/skel/.zshrc > /dev/null
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi
source /etc/zsh/zshrc
[[ ! -f /etc/.p10k.zsh ]] || source /etc/.p10k.zsh
EOF

rm /root/.zshrc
cp "$current_path/ohmyzsh-p10k/rootZshrc" /root/.zshrc
echo "Customization completed."