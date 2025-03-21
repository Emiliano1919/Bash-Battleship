#!/bin/bash
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
Press any key to start...
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
        if (NR == 18) {
        print red $0 reset;
        next;
    }
    else {
        print $0;
    }
}'
read
# Clear the terminal screen
clear

declare -a player1Board
declare -a player2Board
numbers=(1 2 3 4 5 6 7 8 9 10)
letters=(a b c d e f g h i j)
possibleDirections=(H V)
declare -i playerTurn
playerTurn=1
initializeBoard(){
    for ((y=0; y<10; y++)); do
        for ((x=0; x<10; x++)); do
            player1Board[(y*10)+x]="~";
        done
    done
}
printBoard(){
    clear
    printf "Player %u Board \n \n" "$1"
    printf "     "
    for ((x=0; x<10; x++)); do
        printf "%c |  " "${numbers[$x]}"
    done
    printf "\n"
    printf "  " 
    for ((x=0; x<51; x++)); do
        printf "_" 
    done
    printf "\n"
    for ((y=0; y<10; y++)); do
        printf "%c |  " "${letters[$y]}"
        for ((x=0; x<10; x++)); do
            printf "%c |  " "${player1Board[$((y * 10 + x))]}"
        done
        printf "\n"
    done
    printf "  " 
    for ((x=0; x<51; x++)); do
        printf "-" 
    done
}
exists_in_list() {
    local value="$1"
    local list=("${@:2}")
    for element in "${list[@]}"; do
        if [ "$element" = "$value" ]; then
            return 0
        fi
    done
    return 1
}

actuallyPlaceShip(){
    local shipType=$1
    local shipLength=$2
    local col=$3
    local row=$4
    local direction=$5
    if [ "$direction" = "H" ]; then
        for ((i=0; i<shipLength; i++)); do
            player1Board[(row*10)+col+i]="$shipType";
        done
    fi

    if [ "$direction" = "V" ]; then
        for ((i=0; i<shipLength; i++)); do
            player1Board[((row+i)*10)+col]="$shipType";
        done
    fi
}

placeShip(){
    local shipType=$1
    local shipLength=$2
    local doneWithPlacement=0

    while (( doneWithPlacement != 1 )); do
        echo "Place your $shipType of length $shipLength"
        read -p "Enter the starting column (i.e., a): " column
        read -p "Enter the starting row (i.e., 2): " row
        read -p "Enter the direction (H for horizontal, V for vertical): " direction

        row=$((row-1)) #the board starts at 0 but we show it to the user as 1
        col=$(( $(printf "%d" "'$column") - 97 ))  # Convert alphabetical column to 0-9 format
        

        if ! (exists_in_list "$column" "${letters[@]}"); then
            printf "This is not a valid column"
            continue
        fi
        if ! (exists_in_list "$row" "${numbers[@]}"); then
            printf "This is not a valid row"
            continue
        fi
        if ! (exists_in_list "$direction" "${possibleDirections[@]}"); then
            printf "This is not a valid direction"
            continue
        fi

        # Check for valid placement based on direction
        validPlacement=true
        if [ "$direction" = "H" ]; then
            # Out of bounds check
            if (( col + shipLength - 1 >= 10 )); then
                validPlacement=false
                printf "Ship cannot be placed horizontally, it extends beyond the board\n"
            else
                # Check if any of the spaces are already occupied
                for ((i=0; i<shipLength; i++)); do
                    if (( player1Board[(row*10)+(col+i)] != "~" )); then
                        validPlacement=false
                        printf "This position is already occupied\n"
                        break
                    fi
                done
            fi
        elif [ "$direction" = "V" ]; then
            # Out of bounds check
            if (( row + shipLength - 1 >= 10 )); then
                validPlacement=false
                printf "Ship cannot be placed vertically, it extends beyond the board\n"
            else
                # Check if any of the spaces are already occupied
                for ((i=0; i<shipLength; i++)); do
                    if (( player1Board[((row+i)*10)+col] != "~" )); then
                        validPlacement=false
                        printf "This position is already occupied\n"
                        break
                    fi
                done
            fi
        fi

        if [ "$validPlacement" = true ]; then
            actuallyPlaceShip "$shipType" "$shipLength" "$col" "$row" "$direction"
            doneWithPlacement=1 
        fi
    done
}
initializeBoard
printBoard $playerTurn
actuallyPlaceShip "*" 4 1 1 "H"
printBoard $playerTurn


exists_in_list "a" "${letters[@]}"