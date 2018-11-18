/**
 * djaypro2itunes.js
 *
 * @overview Get BPMs from Algoriddim djay Pro 2 to iTunes
 * @see {@link https://github.com/purebounce/djaypro2itunes}
 * @author Norbert Schirmer <purebounce@email.de>
 * @version: 0.1.0
 * 16 November 2018
 * Based on {@link https://github.com/ofstudio/djay2itunes.js} 
 */
/**
 * @external Application
 */
/**
 * @external Track
 */
/**
 * @external PropertyListFile
 */
/**
 * @external Progress
 */
function run() {

    /**
     * Application Settings
     *
     * @typedef {Object}
     * @property {Array} djayVersions - array of names, database paths and priorities to use
     * @property {Object} djay - actual djay version from djayVersions, see `checkDjayInstalled`
     * @property {Boolean} replaceExisting - Replace existing iTunes tags or not
     */
    var settings = {
        djayVersions: [
            {
                name: 'djay Pro 2',
                priority: 0, // Newer version - higher priority
                path: '~/Library/Group Containers/VJXTL73S8G.com.algoriddim.userdata/Library/Application Support/Algoriddim/Metadata'
            }
        ],
        djay: undefined,
        replaceExisting: undefined,
    };


    /**
     * Find djay version installed by database paths
     *
     * @param {Array} djayVersions - Array of djayVersions {@see settings}
     * @returns {boolean} - False if no djay database found
     * @returns {Object} - Found djay object with highest priority (lower number)
     */
    var checkDjayInstalled = function (djayVersions) {
        var result = false,
            system = new Application('System Events');
        for (var i = 0; i < djayVersions.length; i++) {
            // If path exists
            if (system.folders.byName(djayVersions[i].path).exists()) {
                // and with higher priority
                if (result === false || djayVersions[i].priority < result.priority) {
                    result = djayVersions[i];
                }
            }
        }
        return result;
    };

    /**
     * Quit application if running
     *
     * @param {String} appName - Name of application to quit
     * @param {boolean} ask - Confirm quit or not
     * @returns {boolean} - Result
     */
    var quitIfRunning = function (appName, ask) {
        var quitConfirm = false,
            system = new Application('System Events'),
            quitResult, djay;
		console.log('Looking for ' + appName);
        if (system.processes.name().indexOf(appName) > 0) {
            if (ask) {
                djay = new Application(appName);
                djay.includeStandardAdditions = true;
                quitConfirm = djay.displayDialog(
                    'We must quit ' + appName + ' before we continue',
                    {
                        buttons: ['Cancel', ('Quit ' + appName)],
                        defaultButton: ('Quit ' + appName)
                    }
                ).buttonReturned == ('Quit ' + appName);
            } else {
                quitConfirm = true;
            }
            if (quitConfirm) {
                try {
                    quitResult = djay.quit();
                }
                catch (e) {
                    return false;
                }
                return quitResult;
            } else {
                // User canceled
                return false;
            }
        }
        // Application is not running
        return true;
    };

    /**
     * UI: Ask to replace existing iTunes tags or not
     *
     * @param {Application} app
     * @returns {boolean}
     */
    var askReplaceExisting = function (app) {
        return (app.displayDialog(
            'Replace existing iTunes data?',
            {
                buttons: ['No', 'Yes'],
                defaultButton: 'Yes'
            }
        ).buttonReturned === 'Yes');
    };

    /**
     * Retrieve BPM from djay database for track in iTunes
     *
     * @param {Track} track
     * @param {Dictionary} songDB
     * @returns {Integer} - bpm if track was found in database, undefined otherwise
     */

    var getBPM = function (track, songDB) {
	     /**
         * Djay identifies the songs in the database by 'slugs': artist, songname, duration.
		 * Please note that the djay database for these slugs is not case sensitive. 
		 * In case of duplicates in your itunes library, there will only be one entry in the database.
         * We index our internal database by:
         * `artist    songname   duration`
         * separated by tabs (\t)
         *
         * Because djay determines duration of the track slightly different than iTunes
         * and sometimes track duration in iTunes and in djay differs in 1 second up or down
         * we must search in 2 different slugs with ±1 second duration
         *
         * @param {Track} track
         * @returns {Array} - Returns an array of possible slugs
         */
		var trackSlugs = function(track) {
			var ArtistAndName = track.artist() + '\t' + track.name();
			var duration = track.duration();
			return[
				ArtistAndName + '\t' + Math.floor(duration),
				ArtistAndName + '\t' + Math.ceil(duration)
			];
		}
		var getValue = function (key, songDB) {
			var value;
			try {
				value = songDB[key];
			} catch (e) {
				value = undefined
			}
			return value	
		}
		var slugs = trackSlugs(track);
		var isNumber = function (value, i, a) {
                return typeof value === 'number'
        };
		var bpm = [
            getValue(slugs[0], songDB),
            getValue(slugs[1], songDB)
        ].find(isNumber);
		if (bpm == undefined) {
			console.log('Warning: could not retrieve bpm for: "' + slugs[0] + '"  as well as "' + slugs[1] + '"');
		} 
		return bpm
	}
	


    /**
     * Replace BPM tag in iTunes
     *
     * @param {Track} track
     * @param {Number} bpm
     * @param {Boolean} overwrite
     * @returns {Boolean} - true if replaced, false if no
     */
    var replaceBPM = function (track, bpm, overwrite) {
        if (bpm > 0) {
            if (track.bpm() === 0 || (overwrite && track.bpm != bpm)) {
                track.bpm = bpm;
				console.log('Setting BPM of "' + track.artist() + ': ' + track.name() + '" to ' + bpm);
                return true;
            }
        }
        return false;
    };




    /**
     * Main application
     *
	 * 1. Check for djay installed
	 * 2. Quit djay if running (this ensures that metadata is written to files
	 * 3. Check if any tracks are selected in iTunes
	 * 4. Ask for overwrite existing iTunes tags
     * 5. Read djay Pro 2 database into memory (may take some time)
     * 6. Iterate selected tracks in itunes
     * 7. Say "Done!"
     */

    var app = Application.currentApplication();
    app.includeStandardAdditions = true;
    app.activate();
	
	
	// Check for djay installed
    settings.djay = checkDjayInstalled(settings.djayVersions);
    if (!settings.djay) {
        app.displayAlert('No djay database found! Please check djay installed.');
        return false;
    }

    if (!quitIfRunning(settings.djay.name, true)) {
        app.displayAlert('Please quit djay first and try again!');
        return false;
    }
	

    var itunes = new Application('iTunes'),
        selection = itunes.selection();

    itunes.includeStandardAdditions = true;

    if (!selection.length > 0) {
        // If no tracks selected
        itunes.activate();
		console.log('There are no tracks selected in iTunes. Nothing to be done.');
        itunes.displayAlert('djaypro2itunes: Please select a few tracks in iTunes and try again!');
        return false;
    }
    settings.replaceExisting = askReplaceExisting(app);

	var system = new Application('System Events');
	var metadata = system.aliases.byName(settings.djay.path);
	var items = metadata.diskItems;
	var songDB = {};
	var folder, files;

	
	Progress.totalUnitCount = items.length;
    Progress.description = 'Loading djay song metadata folders';

	console.log('Loading djay song metadata');
	for (var i = 0; i < items.length; i++) {
		folder = items[i];
		console.log('loading folder ' + i + ' of ' + items.length);
		if (folder.class() == "folder") {
			files = folder.diskItems;
			for (var j = 0; j < files.length; j++) {
				try {
					var plist = system.propertyListFiles.byName(files[j].path());
					var pitems = plist.propertyListItems;
					var info = pitems.byName('info').value();
					var key = info['Artist'] + '\t' + info['Name'] + '\t' + info['Duration'];
					var bpm = Math.round(pitems.byName('beatGridInfo').value()['bpm']);
					if (!(key in songDB)) {//As djay Pro 2 identifies metadata with the same key (not case sensitive) there will only be one entry per key 
						songDB[key] = bpm;
					} else {
						console.log('Warning: entry for key: "' + key + '" already exists');
					}	
				}
				catch(err) {
					console.log('ERROR: ' + err.message);
				}	
			}
	    }
		Progress.completedUnitCount += 1;	
	}
	console.log('Database loaded, number of entries: ' + Object.keys(songDB).length);

		

    Progress.totalUnitCount = selection.length;
    Progress.description = 'Processing tracks';
    replacedCounter = 0;
	unresolvedCounter = 0;

    // Iterate selection
    for (var i = 0; i < selection.length; i++) {

        if (selection[i].class() === 'fileTrack') {
			bpm = getBPM(selection[i], songDB);
			if (bpm == undefined) {
				unresolvedCounter++
			}
			replacedFlag = replaceBPM(selection[i], bpm, settings.replaceExisting)
			replacedCounter += (replacedFlag ? 1 : 0);
            Progress.completedUnitCount = i + 1;
        }
    }

    itunes.activate();
	var message = 'Updated ' + replacedCounter + ' of ' + selection.length + ' selected tracks.' + 
		((unresolvedCounter != 0) ? ' Could not find ' + unresolvedCounter + ' tracks in djay database.' : '');
	console.log(message);
    app.displayNotification(
        message,
        {
            withTitle: 'djaypro2itunes',
            subtitle: 'Done!'
        }
    );
    return true;
}
