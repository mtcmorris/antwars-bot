#!/usr/bin/env sh
./playgame.py -So --player_seed 42 --end_wait=0.25 --verbose --log_dir game_logs --log_input --turns 1000 --map_file maps/example/tutorial1.map "$@" "ruby ruby_starter_package/bin/bot" "python sample_bots/python/LeftyBot.py" | java -jar visualizer.jar

echo "\n\n**** Check out game_logs for input your bot was given/replays"

echo "Bot log:"
cat 'ruby_starter_package/log.txt'
