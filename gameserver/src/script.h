// Copyright 2023 The Forgotten Server Authors and Alejandro Mujica for many specific source code changes, All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#pragma once

#include "luascript.h"
#include "enums.h"

class Scripts
{
	public:
		Scripts();
		~Scripts();

		bool loadScripts(std::string folderName, bool isLib, bool reload);
		LuaScriptInterface& getScriptInterface() {
			return scriptInterface;
		}
	private:
		LuaScriptInterface scriptInterface;
};
