#########################################################################################
# 
# This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.
# 
# Copyright (C) 2022 GuglioIsStupid
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#########################################################################################

all: win32 win64 macos nx release

lovefile:
	rm -rf build/lovefile
	mkdir -p build/lovefile

	cd love; zip -r -9 ../build/lovefile/Rit.love .

win32: lovefile
	rm -rf build/win32
	mkdir -p build/win32

	cp -r build/lovefile/Rit.love build/win32/game.love
	cp -r resources/win32/* build/win32
	cp -r resources/win32/discord-rpc.dll build/win32

win64: lovefile
	rm -rf build/win64
	mkdir -p build/win64

	cp -r build/lovefile/Rit.love build/win64/game.love
	cp -r resources/win64/* build/win64
	cp -r resources/win64/discord-rpc.dll build/win64

macos: lovefile
	rm -rf build/macos
	mkdir -p build/macos/Rit.app 

	cp -r resources/macos/love.app/. build/macos/Rit.app
	cp -r build/lovefile/Rit.love build/macos/Rit.app/Contents/Resources/game.love

nx: lovefile
	rm -rf build/nx
	mkdir -p build/nx

	nacptool --create "Rit" "GuglioIsStupid" "0.0.3-beta" build/nx/Rit.nacp

	mkdir -p build/nx/romfs
	cp -r build/lovefile/Rit.love build/nx/romfs/game.love

	elf2nro resources/nx/love.elf build/nx/Rit.nro --icon=resources/nx/icon.jpg --nacp=build/nx/Rit.nacp

	rm -r build/nx/romfs
	rm build/nx/Rit.nacp 

release:
	# zip all build/* folders and put to build/release
	
	cd build; zip -r -9 win32.zip win32
	cd build; zip -r -9 win64.zip win64
	cd build; zip -r -9 macos.zip macos
	cd build; zip -r -9 nx.zip nx

clean:
	rm -r build