# djaypro2itunes

Copy BPMs stored in Algoriddim **[djay Pro 2](https://www.algoriddim.com/djay-mac)** for Mac to iTunes meta tags.

- Version: 0.1.0 / 18 November 2018
- Author: Norbert Schirmer
- Email: [purebounce@email.de](mailto:purebounce@email.de)

With this script you can copy BPMs from Algoriddim djay pro 2 to iTunes. BPM will be copied to `BPM` tag. This is based on [djay2itunes](https://github.com/ofstudio/djay2itunes.js), now working for djay pro 2, and only for djay pro 2.

Having the accurate BPM information in iTunes can also be handy for using djay pro on other devices, as unfortunately  djay pro does not synchronise the BPM information between different devices. The BPM information in iTunes seems to be used by djay pro as a hint when analysing the tracks. So once you have set the correct BPM on one device, and synced the BPM via the iTunes tags, it is very likely that djay pro on an other device will come up with the same BPM after analysis.

## Compatibility

Tested on:

 - djay pro 2.0.10
 - iTunes 12.9.0.164
 - macOS 10.14.1

**Use at your own risk!** It's recommended to backup iTunes library first.

## Usage

1. Analyse tracks using Algoriddim djay pro 2
2. Close djay application
3. Open iTunes and select necessary tracks
4. Run `djaypro2itunes.app` (or open djaypro2itunes.js in Script Editor and run)   
**Note:**  app is not signed. Open  `djaypro2itunes.app` by "right-click" -> Open to avoid security warnings.
6. Choose overwrite existing tags or not
7. djaypro2itunes will first load the complete djay pro metadata files and then perform the updates in itunes

## Limitations

Tracks in the djay metadata are identified by artist, songname and duration (not case sensitive). So finding the corresponding tracks in iTunes is limited to this information.

## Version history

* _2018-11-18_ / **v0.1.0**
    - Based on [djay2itunes](https://github.com/ofstudio/djay2itunes.js)
    - Works for djay pro 2 on macOS. And only djay pro 2
    - Only updates BPM


## License

MIT
