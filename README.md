# POSIX Compliant Youtube-dl And Ffmpeg Automator

POSIX compliant script for downloading content to a specified directory 
using `youtube-dl` and then converting using `ffmpeg`.

To change the dafault options to suit your needs see 'Basic Configuration' 
in `dl.sh`.

## Usage

```
Usage: dl.sh [-e|--extension FILE_EXTENSION] [-s|--skip-ffmpeg] [--youtube-dl YOUTUBE-DL_OPTION...] [--ffmpeg FFMPEG_OPTION...] 
[-h|--help] [-v|--version]
```

Everything read after `--youtube-dl` or `--ffmpeg` is considered an option for the corresponding program. 
Stop `youtube-dl` option interpretation comes to an end once the `--ffmpeg` is met or vice versa. 
`--extension FILE_EXTENSION`, `--skip-ffmpeg`, `--version` and `--help` should all precede 
`--youtube-dl` or `--ffmpeg` in order for them to be interpreted as options passed to `dl.sh`.

For instance, in the example below, the options `-f bestaudio -u $USER -p $PASSWD` are interpreted by `youtube-dl` and,
and `-vol 256 -i` is interpreted by `ffmpeg`, not `dl.sh`.
```
dl.sh --youtube-dl -f bestaudio -u $USER -p $PASSWD --ffmpeg -vol 256 -i
```

`-i` flag for `ffmpeg` should come last since dl.sh calls ffmpeg as such:
```
eval ffmpeg "$ffmpeg_opt" \"$file\" \"$new_file\"
```
where `"$ffmpeg_opt"` is all the options passed to ffmpeg, `"$file"` is the input file and `"$new_file"` is the output file.

## LICENSE

`dl.sh` is free/libre software. This program is released under the 
GPLv3 license, which you can find in the file [LICENSE.txt](LICENCE.txt).
