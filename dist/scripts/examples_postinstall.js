#!/usr/bin/env node
/*
 * Using libraries within examples and linking them within packages.json like:
 * "react-native-library-name": "file:../"
 * will cause problems with the metro bundler if the example will run via
 * `react-native run-[ios|android]`. This will result in an error as the metro
 * bundler will find multiple versions for the same module while resolving it.
 * The reason for that is that if the library is installed it also copies in the
 * example folder itself as well as the node_modules folder of the library
 * although their are defined in .npmignore and should be ignored in theory.
 *
 * This postinstall script removes the node_modules folder as well as all
 * entries from the libraries .npmignore file within the examples node_modules
 * folder after the library was installed. This should resolve the metro
 * bundler issue mentioned above.
 *
 * It is expected this scripts lives in the libraries root folder within a
 * scripts folder. As first parameter the relative path to the libraries
 * folder within the example's node_modules folder may be provided.
 * This script will determine the path from this project's package.json file
 * if no such relative path is provided.
 * An example's package.json entry could look like:
 * "postinstall": "node ../scripts/examples_postinstall.js node_modules/react-native-library-name/"
 */
'use strict';
var fs = require('fs');
var path = require('path');
/// Delete all files and directories for the given path
var removeFileDirectoryRecursively = function (fileDirPath) {
    // Remove file
    if (!fs.lstatSync(fileDirPath).isDirectory()) {
        fs.unlinkSync(fileDirPath);
        return;
    }
    // Go down the directory an remove each file / directory recursively
    fs.readdirSync(fileDirPath).forEach(function (entry) {
        var entryPath = path.join(fileDirPath, entry);
        removeFileDirectoryRecursively(entryPath);
    });
    fs.rmdirSync(fileDirPath);
};
/// Remove example/node_modules/react-native-library-name/node_modules directory
var removeLibraryNodeModulesPath = function (libraryNodeModulesPath) {
    var nodeModulesPath = path.resolve(libraryNodeModulesPath, 'node_modules');
    if (!fs.existsSync(nodeModulesPath)) {
        console.log("No node_modules path found at ".concat(nodeModulesPath, ". Skipping delete."));
        return;
    }
    console.log("Deleting: ".concat(nodeModulesPath));
    try {
        removeFileDirectoryRecursively(nodeModulesPath);
        console.log("Successfully deleted: ".concat(nodeModulesPath));
    }
    catch (err) {
        console.log("Error deleting ".concat(nodeModulesPath, ": ").concat(err.message));
    }
};
/// Remove all entries from the .npmignore within  example/node_modules/react-native-library-name/
var removeLibraryNpmIgnorePaths = function (npmIgnorePath, libraryNodeModulesPath) {
    if (!fs.existsSync(npmIgnorePath)) {
        console.log("No .npmignore path found at ".concat(npmIgnorePath, ". Skipping deleting content."));
        return;
    }
    fs.readFileSync(npmIgnorePath, 'utf8').split(/\r?\n/).forEach(function (entry) {
        if (entry.length === 0) {
            return;
        }
        var npmIgnoreLibraryNodeModulesEntryPath = path.resolve(libraryNodeModulesPath, entry);
        if (!fs.existsSync(npmIgnoreLibraryNodeModulesEntryPath)) {
            return;
        }
        console.log("Deleting: ".concat(npmIgnoreLibraryNodeModulesEntryPath));
        try {
            removeFileDirectoryRecursively(npmIgnoreLibraryNodeModulesEntryPath);
            console.log("Successfully deleted: ".concat(npmIgnoreLibraryNodeModulesEntryPath));
        }
        catch (err) {
            console.log("Error deleting ".concat(npmIgnoreLibraryNodeModulesEntryPath, ": ").concat(err.message));
        }
    });
};
// Main start sweeping process
(function () {
    // Read out dir of example project
    var exampleDir = process.cwd();
    console.log("Starting postinstall cleanup for ".concat(exampleDir));
    // Resolve the React Native library's path within the example's node_modules directory
    var libraryNodeModulesPath = process.argv.length > 2
        ? path.resolve(exampleDir, process.argv[2])
        : path.resolve(exampleDir, 'node_modules', require('../package.json').name);
    console.log("Removing unwanted artifacts for ".concat(libraryNodeModulesPath));
    removeLibraryNodeModulesPath(libraryNodeModulesPath);
    var npmIgnorePath = path.resolve(__dirname, '../.npmignore');
    removeLibraryNpmIgnorePaths(npmIgnorePath, libraryNodeModulesPath);
})();
