#!/opt/homebrew/bin/bash
tput clear;
# Get terminal size
height=$(tput lines);
width=$(tput cols);
# Calculate the center coordinates
centre_y=$(( (height / 2) - 10));
centre_x=$(( (width / 2) - 32 ));
welcome(){
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
}

declare -a player1Board
declare -a player2Board
declare -i player1Score
declare -i player2Score
declare -i playerTurn

playerTurn=1
numbers=(1 2 3 4 5 6 7 8 9 10)
letters=(A B C D E F G H I J)
fleetType=(C B c S D)
fleetName=(carrier battleship cruiser submarine destroyer)
fleetSize=(5 4 3 3 2)
possibleDirections=(H V)


initializeBoard(){
    local -n boardToInitialize=$1
    for ((y=0; y<10; y++)); do
        for ((x=0; x<10; x++)); do
            boardToInitialize[(y*10)+x]="~";
        done
    done
}
printBoard(){
    local -n boardToPrint=$1
    local playerNumber=$2
    local secretize="${3:-}" # Default to empty string if not provided
    clear
    printf "Player %u Board \n \n" "$playerNumber"
    printf "     "
    for ((x=0; x<10; x++)); do
        printf "%u |  " "${numbers[$x]}"
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
            if [ "$secretize" == "Y" ]; then
                if exists_in_list "${boardToPrint[$((y * 10 + x))]}" "${fleetType[@]}" ; then
                    printf "~ |  "
                else
                    printf "%c |  " "${boardToPrint[$((y * 10 + x))]}" # Show actual board value if no ship present
                fi
            else
                printf "%c |  " "${boardToPrint[$((y * 10 + x))]}" # Print normally if not secretize
            fi
        done
        printf "\n"
    done
    printf "  " 
    for ((x=0; x<51; x++)); do
        printf "-" 
    done
    printf "\n"
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
    local -n board=$6
    if [ "$direction" = "H" ]; then
        for ((i=0; i<shipLength; i++)); do
            board[(row*10)+col+i]="$shipType";
        done
    fi

    if [ "$direction" = "V" ]; then
        for ((i=0; i<shipLength; i++)); do
            board[((row+i)*10)+col]="$shipType";
        done
    fi
}
validateInput() {
    local row="$1"
    local column="$2"
    local direction="${3:-}"  # Default to empty string if not provided

    if ! (exists_in_list "$row" "${letters[@]}"); then
        printf "This is not a valid row \n"
        return 1
    fi
    
    if ! (exists_in_list "$column" "${numbers[@]}"); then
        printf "This is not a valid column \n"
        return 1
    fi
    
    # Only validate direction if it's provided
    if [[ -n "$direction" ]] && ! (exists_in_list "$direction" "${possibleDirections[@]}"); then
        printf "This is not a valid direction \n"
        return 1
    fi

    return 0
}

placeShip(){
    local shipType=$1
    local shipLength=$2
    local shipName=$3
    local -n currentBoard=$4
    local doneWithPlacement=0

    while (( doneWithPlacement != 1 )); do
        validPlacement=true
        echo "Place your $shipName of length $shipLength"
        read -p "Enter the starting row (A-J): " row
        read -p "Enter the starting column (1-10): " column
        read -p "Enter the direction (H for horizontal, V for vertical): " direction

        if ! validateInput "$row" "$column" "$direction"; then
            continue  # If validation fails, restart the loop
        fi

        row=$(( $(printf "%d" "'$row") - 65 ))  # Convert uppercase alphabetical row to 0-9 format
        column=$((column-1)) #the board starts at 0 but we show it to the user as 1

        # Check for valid placement based on direction
        if [ "$direction" = "H" ]; then
            # Out of bounds check
            if (( column + shipLength - 1 >= 10 )); then
                validPlacement=false
                printf "Ship cannot be placed horizontally, it extends beyond the board\n"
                continue
            else
                # Check if any of the spaces are already occupied
                for ((i=0; i<shipLength; i++)); do
                    if [[ ${currentBoard[(row*10)+(column+i)]} != "~" ]]; then
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
                continue
            else
                # Check if any of the spaces are already occupied
                for ((i=0; i<shipLength; i++)); do
                    if [[ ${currentBoard[((row+i)*10)+column]} != "~" ]]; then
                        validPlacement=false
                        printf "This position is already occupied\n"
                        break
                    fi
                done
            fi
        fi

        if [ "$validPlacement" = true ]; then
            actuallyPlaceShip "$shipType" "$shipLength" "$column" "$row" "$direction" currentBoard
            doneWithPlacement=1 
        fi
    done
}

placeFleet(){
    local -n currentPlayerBoard=$1
    centre_y=$(( (height / 2) - 10));
    doneWithFleetPlacement=0
    IFS= read -r -d '' SELECTION<<-"EOF"
You must choose the position of the ships in your fleet
Ship Type   |   Ship Size   |   Symbol
------------|---------------|-----------
Carrier     |	5 cells     |   C
Battleship  |	4 cells     |   B
Cruiser     |	3 cells     |   c
Submarine   |	3 cells     |   S
Destroyer   |	2 cells     |   D
EOF
echo "$SELECTION" | while IFS= read -r line; do
    tput cup "$centre_y" "$centre_x"
    #Set cursor to the middle (relative to the tree) of the screen
    echo "$line"
    ((centre_y++))  #You need to increment the row position if not you will just overwrite
done
    while (( doneWithFleetPlacement != 1 )); do
        for ((t=0; t<5; t++)); do
            placeShip "${fleetType[$t]}" "${fleetSize[$t]}" "${fleetName[$t]}" currentPlayerBoard
            printBoard currentPlayerBoard  $playerTurn  # Show board after placing each ship
        done
        doneWithFleetPlacement=1
    done
}
actuallyAttack(){
    local col=$1
    local row=$2
    local -n boardToAttack=$3
    local -n playerAttackScore=$4
    if [[ ${boardToAttack[(row*10)+col]} = "~" ]]; then
        boardToAttack[(row*10)+col]="0";
        printf "Miss... \n"
    else
        boardToAttack[(row*10)+col]="X";
        ((playerAttackScore--))
        printf "Hit!!! \n"
    fi
}   

attack(){
    local -n playerToAttackBoard=$1
    local -n playerToAttackScore=$2
    doneWithAttack=0
    while (( doneWithAttack != 1 )); do
        echo "Place the coordinates of your attack:"
        read -p "Enter the starting row (A-J): " row
        read -p "Enter the starting column (1-10): " column

        if validateInput "$row" "$column"; then
            doneWithAttack=1
        else
            echo "Invalid input. Please enter a valid row (A-J) and column (1-10)."
        fi
    done
    row=$(( $(printf "%d" "'$row") - 65 ))  # Convert uppercase alphabetical row to 0-9 format
    column=$((column-1)) #the board starts at 0 but we show it to the user as 1

    if [[ ${playerToAttackBoard[(row*10)+column]} = "~" ]]; then
        playerToAttackBoard[(row*10)+column]="0";
        printf "Miss... \n"
    else
        playerToAttackBoard[(row*10)+column]="X";
        ((playerToAttackScore--))
        printf "Hit!!! \n"
    fi
}

placeShipsRandomly(){
    local -n currentBoard=$1
    for i in "${!fleetSize[@]}"; do
        placed=false
        while ! $placed; do
            direction=${possibleDirections[$((RANDOM % 2))]}
            row=$((RANDOM % 10))
            col=$((RANDOM % 10))

            # Check if the ship fits
            if [ "$direction" = "H" ] && (( col + fleetSize[$i] <= 10 )); then
                fit=true
                for ((j=0; j<fleetSize[$i]; j++)); do
                    if [[ ${currentBoard[(row*10)+(col+j)]} != "~" ]]; then
                        fit=false
                        break
                    fi
                done
                if $fit; then
                    actuallyPlaceShip "${fleetType[$i]}" "${fleetSize[$i]}" "$col" "$row" "$direction" currentBoard
                    placed=true
                fi
            elif [ "$direction" = "V" ] && (( row + fleetSize[$i] <= 10 )); then
                fit=true
                for ((j=0; j<fleetSize[$i]; j++)); do
                    if [[ ${currentBoard[((row+j)*10)+col]} != "~" ]]; then
                        fit=false
                        break
                    fi
                done
                if $fit; then
                    actuallyPlaceShip "${fleetType[$i]}" "${fleetSize[$i]}" "$col" "$row" "$direction" currentBoard
                    placed=true
                fi
            fi
        done
    done
}

gameLoop(){
    player1Score=17
    player2Score=17
    initializeBoard player1Board
    initializeBoard player2Board
    printBoard player1Board 1
    placeFleet player1Board
    placeShipsRandomly player2Board
    while ((player1Score!=0 || player2Score!=0)); do
        if (( playerTurn == 1 )); then
            printBoard player2Board 2 "Y"
            attack player2Board player2Score
            ((playerTurn++))
            printf "Player 2 Score is: %u " "$player2Score"
            read
        elif (( playerTurn == 2 )); then
            rowRANDOM=$((RANDOM % 10))
            colRANDOM=$((RANDOM % 10))
            #printBoard player1Board 1 "Y"
            actuallyAttack colRANDOM rowRANDOM player1Board player1Score
            ((playerTurn--))
            printBoard player1Board 1
            printf "Player 1 Score is: %u " "$player1Score"
            read
        fi
    done
    if (( player1Score == 0 )); then
        printf "The fleet of Player 1 has been destroyed \n
                Player 2 wins"
    elif (( player2Score == 0 )); then
        printf "The fleet of Player 2 has been destroyed \n
                Player 1 wins"
    fi
}
welcome
gameLoop



