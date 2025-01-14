# To run:
# rm ~/.local/bin/awless && sudo gem uninstall mdl && sudo dnf -y remove fastfetch  && vhs demo.tape -o /tmp/demo2.gif && vhs publish /tmp/demo2.gif

Output demo.gif

Require echo

Set Shell "zsh"
Set FontSize 12
Set Width 1000
Set Height 700

Type ": This is Pacrat!"
Enter
Sleep 500ms

Type "bat demo.ini"
Sleep 2
Enter
Sleep 5

Type ": A few things are already installed at this point."
Enter
Sleep 2
Enter

Type "PACRAT_NONINTERACTIVE=1 PACRAT_NESTFILE=demo.ini ./pacrat"
# Type "PACRAT_NESTFILE=demo.ini ./pacrat"
Enter
Sleep 32s

Type "fastfetch"
Enter

Sleep 3s
