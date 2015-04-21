# OS X setup #

Tools to automate configuring OS X, synchronising operating system and application settings and data between multiple installations. Generally, the problem being solving is synchronising some of the contents of the Library folder, not user files can be placed anywhere and easily synchronising using Dropbox or iCloud Drive.

These tools are sync system agnostic, and should work with Dropbox, Omni Presence, or any other similar system.

## Status ##

The tools and documentation are very rough. While I do use them, there is a lot of overseeing and manual intervention.

## How it works ##

1. Prepare the data to be synchronised. This is currently a manual and tedious process.
2. Place this data in a folder that is synchronised by another system.
3. Run the tools to update the local data from the synchronised data. I do this manually, but it could be scheduled to run periodically.

Two techniques are currently implemented: symbolic links and writing specific user defaults.

## Notes ##

Replacing `~/Library/Fonts` with a symbolic link does not work. OS X does not find the linked files. I currently keep a Fonts folder in Dropbox and manually synchronise this with `~/Library/Fonts`.

## Licence ##

MIT license — see License.txt
