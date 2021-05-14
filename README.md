# POSIX Compliant Youtube-dl And Ffmpeg Automator

POSIX compliant script for downloading content to a specified directory 
using `youtube-dl` and then converting using `ffmpeg`.

To change the default options to suit your needs see 'Basic Configuration' 
in `dl.sh`. 

## Usage

```
Usage: dl.sh [-e|--extension FILE_EXTENSION] [-s|--skip-ffmpeg]
[--youtube-dl YOUTUBE-DL_OPTION...] [--ffmpeg FFMPEG_OPTION...] [-h|--help] [-v|--version]
```

Everything read after `--youtube-dl` or `--ffmpeg` is considered an option for the corresponding program. 
`youtube-dl` option interpretation comes to an end once `--ffmpeg` is met or vice versa. 
`--extension FILE_EXTENSION`, `--skip-ffmpeg`, `--version` and `--help` should all precede 
`--youtube-dl` or `--ffmpeg` in order for them to be interpreted as options passed to `dl.sh`.

For instance, in the example below, the options `-f bestaudio -u $USER -p $PASSWD` are interpreted by `youtube-dl` and,
and `-vol 256 -i` is interpreted by `ffmpeg`, not `dl.sh`.
```
dl.sh --youtube-dl -f bestaudio -u $USER -p $PASSWD --ffmpeg -vol 256 -i
```

`-i` flag for `ffmpeg` should come last since dl.sh calls ffmpeg as such:
```
eval "ffmpeg ""$ffmpeg_opt"" \"$file\" \"$new_file\""
```
where `"$ffmpeg_opt"` is all the options passed to ffmpeg, `"$file"` is the input file and `"$new_file"` is the output file.

`--extension FILE_EXTENSION` determines the file extension that the content will be converted into.
`--skip-ffmpeg` allows for `dl.sh` to skip `ffmpeg` conversion.

## Configuration

By default `dl.sh` sets `~/.dl.conf` as its configuration file. Here's what the contents of `~/.dl.conf` should look like:
```
"$HOME/$OUT_DIR"
https://www.example.com/1
https://www.example.com/2
https://www.example.com/3
https://www.example.com/4
```
where the first line is interpreted as the directory to which the content will be downloaded to. `eval` is used for interpretation thus
please use quotes whenever possible. Rest of the lines should all be valid URLs to downloadable content. If the directory in the configuration
file doesn't exist, it will be created.	`"$HOME"`, `~`, `'My Home 123'` are all valid directory names. (Don't forget to use quotes!)

## LICENSE

`dl.sh` is free/libre software. This program is released under the 
GPLv3 license, which you can find in the file [LICENSE.txt](LICENCE.txt).
