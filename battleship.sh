#/!/bin/bash
tput clear;
# Get terminal size
height=$(tput lines);
width=$(tput cols);
# Calculate the center coordinates
centre_y=$(( (height / 2) - 10));
centre_x=$(( (width / 2) - 32 ));
IFS= read -r -d '' WELCOME<<-"EOF"
    █████████████████████████████████████████████████████████
    █▄─▄─▀██▀▄─██─▄─▄─█─▄─▄─█▄─▄███▄─▄▄─█─▄▄▄▄█─█─█▄─▄█▄─▄▄─█
    ██─▄─▀██─▀─████─█████─████─██▀██─▄█▀█▄▄▄▄─█─▄─██─███─▄▄▄█
    ▀▄▄▄▄▀▀▄▄▀▄▄▀▀▄▄▄▀▀▀▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▄▀▄▀▄▄▄▀▄▄▄▀▀▀

                           |`-:_
  ,----....____            |    `+.
 (             ````----....|___   |
  \     _                      ````----....____
   \    _)                                     ```---.._
    \                                                   \
  )`.\  )`.   )`.   )`.   )`.   )`.   )`.   )`.   )`.   )`.   )hh
-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `

------------------------------------------------------------------
This ASCII pic can be found at
https://asciiart.website/index.php?art=transportation/nautical
EOF
echo "$WELCOME" | while IFS= read -r line; do
    tput cup "$centre_y" "$centre_x"
    #Set cursor to the middle (relative to the tree) of the screen
    echo "$line"
    ((centre_y++))  #You need to increment the row position if not you will just overwrite
done  |  awk -v brown="$(tput setaf 52)"\
     -v green="$(tput setaf 34)"\
     -v reset="$(tput sgr0)"\
     -v yellow="$(tput setaf 214)"\
     -v yellower="$(tput setaf 220)"\
     -v white="$(tput setaf 15)"\
     -v red="$(tput setaf 1)"\
     -v reder="$(tput setaf 160)"\
     -v blue="$(tput setaf 27)"\
     -v gold="$(tput setaf 208)"\
     -v blink="$(tput blink)"\
     -v bold="$(tput bold)" '
{
    if (NR >= 1 && NR <= 4) {
        print yellow $0 reset;
        next;
    } 
    if (NR >= 12 && NR <= 13) {
        gsub(/\)/, blink white ")" reset, $0);
        gsub(/\./, blink blue "." reset, $0);
        gsub(/\_/, blue "\_" reset, $0);
        gsub(/\-/, blue "\-" reset, $0);
        gsub(/\`/, blue "`" reset, $0);
        print
        next;
    }
    else {
        print $0;
    }
}'
