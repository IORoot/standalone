#!/bin/bash


# Deine all spinnaker icons / colours
function stylesheet()
{
    TEXT_WHITE_FFF='\e[38;2;255;255;255m'
    TEXT_STONE_500='\e[38;2;120;113;108m'
    TEXT_STONE_600='\e[38;2;87;83;78m'
    TEXT_ORANGE_500='\e[38;2;249;115;22m'
    TEXT_YELLOW_500='\e[38;2;234;179;8m'
    TEXT_GRAY_200='\e[38;2;229;231;235m'
    TEXT_GRAY_400='\e[38;2;156;163;175m'
    TEXT_GRAY_500='\e[38;2;107;114;128m'
    TEXT_GRAY_600='\e[38;2;75;85;99m'
    TEXT_GRAY_700='\e[38;2;55;65;81m'
    TEXT_VIOLET_500='\e[38;2;139;92;246m'
    TEXT_RED_500='\e[38;2;239;68;68m'
    TEXT_GREEN_500='\e[38;2;34;197;94m'
    TEXT_EMERALD_500='\e[38;2;16;185;129m'
    TEXT_TEAL_500='\e[38;2;20;184;166m'
    TEXT_SKY_500='\e[38;2;14;165;233m'
    TEXT_AMBER_500='\e[38;2;245;158;11m'
    RESET_TEXT='\e[39m'
}

usage()
{
    if [ "$#" -lt 1 ]; then

        cat <<EOF

    🪢 Standalone

        Search through file and replace any 'source' commands with the actual content of the source file.

        Usage:

        standalone --input source_file --output target_file

EOF

        exit 1
    fi
}

# ╭──────────────────────────────────────────────────────────╮
# │         Take the arguments from the command line         │
# ╰──────────────────────────────────────────────────────────╯
function arguments()
{
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
    case $1 in

    
        -i|--input)
            INPUT="$2"
            shift
            shift
            ;;


        -o|--output)
            OUTPUT="$2"
            shift
            shift
            ;;


        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;


        *)
            POSITIONAL_ARGS+=("$1") # save positional arg back onto variable
            shift                   # remove argument and shift past it.
            ;;
    esac
    done
    
}



function main()
{

    # Check for all necessary flags
    if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
        usage
        exit 1
    fi

    # Check output is not the same as input, otherwise input will be wiped away.
    if [ "$INPUT" == "$OUTPUT" ]; then
        printf "<input> and <output> are the same, aborting.\n"
        exit 1
    fi

    # Remove any existing target file to overwrite it.
    if [[ -f "$OUTPUT" ]]; then
        printf "${TEXT_AMBER_500}Target File already exists, deleting.${RESET_TEXT} \n"
        rm $OUTPUT
    fi
    

    printf "Processing: ${TEXT_AMBER_500}%s${RESET_TEXT} ➡️  ${TEXT_TEAL_500}%s${RESET_TEXT}\n" "$INPUT" "$OUTPUT"

    # Start reading the source INPUT file
    # Use '-r' to ignore newlines and backslashes
    while IFS= read -r line; do
        
        # IF the line matches 
        # whitespace followed by 'source' or '.' command
        # catch the filename after too.
        if [[ $line =~ ^[[:space:]]*(source|\.)[[:space:]]+([^[:space:]]+) ]]; then

            printf "🔎 Found matching source line. %s \n" "$line" 

            # Get the contents of the file
            FILENAME="${BASH_REMATCH[2]}"

            # Check source file exists
            if [[ ! -f "$FILENAME" ]]; then
                printf "${TEXT_RED_500}File does not exist: $FILENAME ${RESET_TEXT} \n"
                exit 1
            fi

            # Get contents of file
            FILE_CONTENTS=$(<"$FILENAME")

            # Remove the first line if it matches a shell line
            if [[ $FILE_CONTENTS =~ ^#!/bin/(ba)?sh.*$'\n' ]]; then
                FILE_CONTENTS=${FILE_CONTENTS#*$'\n'}
            fi

            # Echo the file contents to the screen.
            printf "${TEXT_GREEN_500}%s${RESET_TEXT}\n" "$FILE_CONTENTS"

            # Comment out the source line
            COMMENTED_LINE="# $line"
            printf '%s\n' "$COMMENTED_LINE" >> $OUTPUT 

            # echo everything else to file
            printf '%s\n' "$FILE_CONTENTS" >> $OUTPUT

        # echo everything else in INPUT file
        else
            printf "${TEXT_STONE_600}%s${RESET_TEXT}\n" "$line"
            printf '%s\n' "$line" >> $OUTPUT
        fi

    done < "$INPUT"


    # Retrieve source file permissions and apply to target file
    SOURCE_PERMISSIONS=$(stat -f %A "$INPUT")
    chmod "$SOURCE_PERMISSIONS" "$OUTPUT"
}


stylesheet
usage "$@"
arguments "$@"
main "$@"
