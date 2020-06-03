#!/bin/bash
API_KEY="4c524f5ca0672f435b3420d9a3a8eab6"
API_HOST="http://api.musixmatch.com/ws/1.1/"

while getopts "ha:t:" option; do
    case "$option" in
        h)
            echo "Usage: $(basename $0) -a artist -t title"
            printf "Arguments:\n\t-h\tDisplay help\n\t-a\tArtist name\n\t-t\tSong title\n"
            exit
            ;;
        a)
            artist=$OPTARG
            ;;
        t)
            title=$OPTARG
            ;;
    esac
done

if [ -z "$artist" ] || [ -z "$title" ]; then
    echo Invalid parameters
    echo "Usage: $(basename $0) -a artist -t title"
    printf "Arguments:\n\t-h\tDisplay help\n\t-a\tAdd artist name\n\t-t\tAdd song title\n"
else
    track=$(curl -s "${API_HOST}track.search?q_artist=${artist}&q_track=${title}&f_has_lyrics=1&page=1&page_size=1&s_track_rating=desc&apikey=$API_KEY")
    validTitle=$(echo "$track" |  sed -n 's|.*"track_name":"\([^"]*\)".*|\1|p')
    validArtist=$(echo "$track" | sed -n 's|.*"artist_name":"\([^"]*\)".*|\1|p')
    track_id=$(echo "$track" | sed -n 's|.*"track_id":\([^"]*\),.*|\1|p')
    lyrics=$(curl -s "${API_HOST}track.lyrics.get?track_id=$track_id&apikey=$API_KEY" | sed -n 's|.*"lyrics_body":"\([^"]*\)".*|\1|p')

    if [ -z "$lyrics" ]; then
        echo Can\'t find the lyrics :\(
    else
        echo --------------------------
        printf "$validArtist - $validTitle\n"
        echo --------------------------
        printf "$lyrics \n"
    fi
fi

