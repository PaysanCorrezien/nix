#FIX: this doesnt work require error ?
{ lib, pkgs, config, ... }:
# CREDIT: https://gitee.com/DreamMaoMao/searchjump.yazi/blob/main/init.lua
let
  mkYaziPlugin = name: text: {
    "${name}" = toString (pkgs.writeTextDir "${name}.yazi/init.lua" text) + "/${name}.yazi";
  };
  plugins_init_lua = ''
      -- stylua: ignore
    local CH_TABLE={[ ]}

    local KEYS_LABLE = {
    	"j", "f", "d", "k", "l", "h", "g", "a", "s", "o", "i", "e", "u", "n", "c", "m", "r","p", "b", "t", "w", "v", "x", "y", "q", "z",
    	"I", "J","L","H", "A", "B", "Y", "D", "E", "F", "G",  "Q","R", "T", 
    	"U", "V", "W", "X", "Z", "C","K",  "M", "N", "O", "P","S", 
    }

    local INPUT_KEY = {
    	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O","P", "Q", "R", "S", "T","U", "V", "W", "X", "Y","Z",

    	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
    	"o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2"
    	, "3", "4", "5", "6", "7", "8", "9", "-", "_", ".", "<Esc>","<Space>","<Enter>","<Backspace>"
    }

    local INPUT_CANDS = {
    	{ on = "A" }, { on = "B" }, { on = "C" }, { on = "D" }, { on = "E" },
    	{ on = "F" }, { on = "G" }, { on = "H" }, { on = "I" }, { on = "J" },
    	{ on = "K" }, { on = "L" }, { on = "M" }, { on = "N" }, { on = "O" },
    	{ on = "P" }, { on = "Q" }, { on = "R" }, { on = "S" }, { on = "T" },
    	{ on = "U" }, { on = "V" }, { on = "W" }, { on = "X" }, { on = "Y" },
    	{ on = "Z" },

    	{ on = "a" }, { on = "b" }, { on = "c" }, { on = "d" }, { on = "e" },
    	{ on = "f" }, { on = "g" }, { on = "h" }, { on = "i" }, { on = "j" },
    	{ on = "k" }, { on = "l" }, { on = "m" }, { on = "n" }, { on = "o" },
    	{ on = "p" }, { on = "q" }, { on = "r" }, { on = "s" }, { on = "t" },
    	{ on = "u" }, { on = "v" }, { on = "w" }, { on = "x" }, { on = "y" },
    	{ on = "z" }, { on = "0" }, { on = "1" }, { on = "2" }, { on = "3" },
    	{ on = "4" }, { on = "5" }, { on = "6" }, { on = "7" }, { on = "8" },
    	{ on = "9" }, { on = "-" }, { on = "_" }, { on = "." }, { on = "<Esc>" },
    	{ on = "<Space>" }, { on = "<Enter>" }, { on = "<Backspace>" }
    }


    local function get_match_position(name, find_str)
    	if find_str == "" or find_str == nil then
    		return nil, nil
    	end

    	local startPos, endPos = {}, {}
    	local startp, endp
    	local convert_name = ""
    	local convert_find_str = ""
    	name = string.lower(name)

    	-- change chiese char to en char with "##" as marker
    	for ch in string.gmatch(name, "[%z\1-\127\194-\244][\128-\191]*") do
    		if ch:byte() > 127 and CH_TABLE[ch] then
    			convert_name = convert_name .. string.upper(CH_TABLE[ch]) .. "##"
    		else
    			convert_name = convert_name .. ch
    		end
    	end	

    	-- record all match start position and end position
    	-- startPos[index],endPos[index],sanme index corresponde a search result

    	-- find match en str
    	endp = 0
    	while true do
    		startp, endp = string.find(convert_name, find_str, endp + 1)
    		if not startp then
    			break
    		end
    		table.insert(startPos, startp)
    		table.insert(endPos, endp)
    	end

    	-- find match chinese str
    	for ch in string.gmatch(find_str, ".") do
    		convert_find_str = convert_find_str .. string.upper(ch) .. "##"
    	end	

    	endp = 0
    	startp = 0
    	local zh_insert_index = 0
    	while true do
    		startp, endp = string.find(convert_name,convert_find_str, endp + 1)
    		if not startp then
    			break
    		end
    		
    		for pindex, pos in ipairs(startPos) do
    			if pos > startp then
    				zh_insert_index = pindex
    				break
    			end
    		end

    		if zh_insert_index == 0 then
    			table.insert(startPos,startp)
    			table.insert(endPos,endp)
    		else
    			table.insert(startPos,zh_insert_index,startp)
    			table.insert(endPos,zh_insert_index,endp)
    		end

    	end		

    	if #startPos > 0 then
    		return startPos, endPos,convert_name
    	else
    		return nil, nil,nil
    	end
    end

    local get_first_match_lable = ya.sync(function(state)
    	if state.match == nil then
    		return nil
    	end

    	for url, _ in pairs(state.match) do
    		return #state.match[url].key > 0 and state.match[url].key[1] or nil
    	end	
    	
    	return nil
    end)

    -- apply search result to show
    local set_match_lable = ya.sync(function(state, url, name, file)
    	local span = {}
    	local key = {}
    	local i = 1
    	if state.match[url].key and #state.match[url].key > 0 then
    		key = state.match[url].key
    	end

    	local startPos = state.match[url].startPos
    	local endPos = state.match[url].endPos

    	if file:is_hovered() then
    		span[#span+1] = ui.Span(name:sub(1, startPos[1] - 1))
    	else
    		span[#span+1] =  ui.Span(name:sub(1, startPos[1] - 1)):fg(state.opt_unmatch_fg)
    	end

    	local match_str_fg
    	local match_str_bg
    	local first_match_lable = get_first_match_lable()

    	while i <= #startPos do
    		match_str_fg = key[i] == first_match_lable and state.opt_first_match_str_fg or state.opt_match_str_fg
    		match_str_bg = key[i] == first_match_lable and state.opt_first_match_str_bg or state.opt_match_str_bg

    		span[#span+1] = ui.Span(name:sub(startPos[i], endPos[i])):fg(match_str_fg):bg(match_str_bg)
    		if i <= #key then
    			span[#span+1] = ui.Span(key[i]):fg(state.opt_lable_fg):bg(state.opt_lable_bg)
    		end
    		if i + 1 <= #startPos then
    			if file:is_hovered() then
    				span[#span+1] =  ui.Span(name:sub(endPos[i] + 1, startPos[i + 1] - 1))
    			else
    				span[#span+1] = ui.Span(name:sub(endPos[i] + 1, startPos[i + 1] - 1)):fg(state.opt_unmatch_fg)
    			end
    		end
    		i = i + 1
    	end

    	if file:is_hovered() then
    		span[#span+1] = ui.Span(name:sub(endPos[i - 1] + 1, #name))
    	else
    		span[#span+1] = ui.Span(name:sub(endPos[i - 1] + 1, #name)):fg(state.opt_unmatch_fg)
    	end
    	return ui.Line(span)
    end)

    -- update the match data after input a str
    local update_match_table = ya.sync(function(state, pane, folder, convert_pattern)
    	if not folder then
    		return
    	end

    	local i

    	for i, file in ipairs(folder.window) do
    		local name = file.name:gsub("\r", "?", 1)
    		local url = tostring(file.url)
    		local next_char = ""
    		local startPos, endPos, convert_name = get_match_position(name, convert_pattern)
    		if startPos then
    			-- record match file data
    			state.match[url] = {
    				key = {},
    				startPos = startPos,
    				endPos = endPos,
    				isdir = file.cha.is_dir,
    				pane = pane,
    				cursorPos = i,
    			}
    			i = 1
    			while i <= #startPos do -- the next char of match string can't be used as lable for supporing further search
    				next_char = string.lower(convert_name:sub(endPos[i] + 1, endPos[i] + 1))
    				state.next_char[next_char] = ""
    				i = i + 1
    			end
    		end
    	end
    end)

    local record_match_file = ya.sync(function(state, patterns,re_match)
    	local exist_match = false

    	if state.match == nil then
    		state.match = {}
    	end

    	if state.next_char == nil then
    		state.next_char = {}
    	end

    	local covert_parttern

    	for _, pattern in ipairs(patterns) do
    		covert_parttern = ""
    		-- change chiese char to en char with "##" as marker
    		for ch in string.gmatch(pattern, "[%z\1-\127\194-\244][\128-\191]*") do
    			if ch:byte() > 127 and CH_TABLE[ch] then
    				covert_parttern = covert_parttern .. string.upper(CH_TABLE[ch]) .. "##"
    			elseif ch == "." and not re_match then
    				covert_parttern = covert_parttern .. "[.]"
    			else
    				covert_parttern = covert_parttern .. string.lower(ch)
    			end
    		end	

    		-- record match file from current window
    		update_match_table("current",cx.active.current, covert_parttern)

    		if not state.opt_only_current then
    			-- record match file from parent window
    			update_match_table("parent", cx.active.parent, covert_parttern)
    			-- record match file from preview window
    			update_match_table("preview", cx.active.preview.folder, covert_parttern)
    		end
    	end	

    	-- get valid key list (KEYS_LABLE but exclude state.next_char table)
    	local valid_lable = {}
    	for _, value in ipairs(KEYS_LABLE) do

    		if not state.opt_enable_capital_lable and string.byte(value) > 64 and string.byte(value) < 91 then
    			goto nextlable
    		end  

    		if state.next_char[string.lower(value)] == nil then
    			table.insert(valid_lable, value)
    		end

    		::nextlable::
    	end

    	-- assign valid key to each match file
    	local i = 1
    	local j
    	for url, _ in pairs(state.match) do
    		exist_match = true
    		j = 1
    		while j <= #state.match[url].startPos do -- some file may match multi position
    			table.insert(state.match[url].key, valid_lable[i])
    			i = i + 1
    			j = j + 1
    		end
    	end

    	-- flush page
    	if cx.active.preview.folder then
    		ya.manager_emit("peek", { force = true })
    	end

    	ya.render()

    	return exist_match
    end)

    local switch_entity_hightlights = ya.sync(function(st,fn)
    	local inc_backup = Entity._inc
    	Entity._inc = st.highlights_id - 1
    	local id = Entity:children_add(fn, 4000)
    	Entity._inc =  inc_backup
    	return id
    end)

    local toggle_ui = ya.sync(function(st)
    	if st.status_sj_id or st.entity_sj_highlights_id then
    		Status:children_remove(st.status_sj_id)
    		Entity:children_remove(st.entity_sj_highlights_id)
    		st.status_sj_id = nil
    		st.entity_sj_highlights_id = nil
    		if cx.active.preview.folder then
    			ya.manager_emit("peek", { force = true })
    		end
    		switch_entity_hightlights(st.highlights_function)
    		ya.render()
    		return
    	end

    	for _, value in ipairs(Entity._children) do
    		if value["order"] == 4000 then
    			st.highlights_function = value[1]
    			st.highlights_id = value["id"]
    			break
    		end
    	end
    	Entity:children_remove(st.highlights_id)

    	local function entity_highlights(self)
    		local file = self._file
    		local span = {}
    		local name = file.name:gsub("\r", "?", 1)

    		local url = tostring(file.url)

    		if st.match and st.match[url] then
    			span = set_match_lable(url, name, file)
    		elseif file:is_hovered() then
    			span = ui.Span(name)
    		else
    			span = ui.Span(name):fg(st.opt_unmatch_fg)
    		end

    		return span
    	end

    	st.entity_sj_highlights_id = switch_entity_hightlights(entity_highlights)

    	local function status_sj(self)
    		local style = self:style()
    		local match_pattern = (st.match_pattern and st.opt_show_search_in_statusbar) and ":" .. st.match_pattern or ""
    		return ui.Line {
    			ui.Span(THEME.status.separator_open):fg(style.bg),
    			ui.Span("[SJ]" .. match_pattern .. " "):style(style),
    		}
    	end
    	st.status_sj_id = Status:children_add(status_sj,1001,Status.LEFT)


    	if cx.active.preview.folder then
    		ya.manager_emit("peek", { force = true })
    	end

    	ya.render()
    end)

    local check_key_is_lable = ya.sync(function(state,final_input_str) 
    	if state.backouting then
    		state.backouting = false
    		return nil
    	end

    	if not state.match then
    		return nil
    	end

    	for url, _ in pairs(state.match) do
    		for _, value in ipairs(state.match[url].key) do
    			if value == final_input_str then
    				return url
    			end
    		end
    	end

    	return nil
    end)

    local set_target_str = ya.sync(function(state, patterns, final_input_str,re_match)

    	local url = check_key_is_lable(final_input_str)
    	if url then -- if the last str match is a lable key, not a searchchar,toggle jump action
    		if not state.args_autocd and  state.match[url].pane == "current" then-- if target file in current pane, use `arrow` instead of`reveal` tosupport select mode
    			local folder = cx.active.current
    			ya.manager_emit("arrow",{ state.match[url].cursorPos - folder.cursor - 1 + folder.offset})
    		elseif state.args_autocd and state.match[url].isdir then
    			ya.manager_emit("cd",{ url })
    		else
    			ya.manager_emit("reveal",{ url })
    		end
    		return true
    	end

    	-- clears the previously calculated data when input change
    	state.match = nil
    	state.next_char = nil

    	-- calculate match data
    	local exist_match = record_match_file(patterns,re_match)

    	-- apply match data to render
    	ya.render()
    	if not exist_match and (re_match == true or patterns[1] ~= "" ) and state.opt_auto_exit_when_unmatch then
    		return true
    	else
    		return false
    	end	
    end)

    local clear_state_str = ya.sync(function(state)
    	state.match = nil
    	state.next_char = nil
    	state.backouting = nil
    	state.match_pattern = nil
    	ya.render()
    end)

    local set_opts_default = ya.sync(function(state)
    	if (state.opt_unmatch_fg == nil) then
    		state.opt_unmatch_fg = "#b2a496"
    	end
    	if (state.opt_match_str_fg == nil) then
    		state.opt_match_str_fg = "#000000"
    	end
    	if (state.opt_match_str_bg == nil) then
    		state.opt_match_str_bg = "#73AC3A"
    	end
    	if (state.opt_first_match_str_fg == nil) then
    		state.opt_first_match_str_fg = "#000000"
    	end
    	if (state.opt_first_match_str_bg == nil) then
    		state.opt_first_match_str_bg = "#73AC3A"
    	end
    	if (state.opt_lable_fg == nil) then
    		state.opt_lable_fg = "#EADFC8"
    	end
    	if (state.opt_lable_bg == nil) then
    		state.opt_lable_bg = "#BA603D"
    	end
    	if (state.opt_only_current == nil) then
    		state.opt_only_current = false
    	end
    	if (state.opt_search_patterns == nil) then
    		state.opt_search_patterns = {}
    	end
    	if (state.opt_show_search_in_statusbar == nil) then
    		state.opt_show_search_in_statusbar = false
    	end
    	if (state.opt_auto_exit_when_unmatch == nil) then
    		state.opt_auto_exit_when_unmatch = true
    	end	
    	if (state.opt_enable_capital_lable == nil) then
    		state.opt_enable_capital_lable = false
    	end	
    	return state.opt_search_patterns
    end)

    local backout_last_input = ya.sync(function(state,input_str)
    	local final_input_str = input_str:sub(-2,-2)
    	input_str = input_str:sub(1,-2)

    	state.backouting = true
    	state.match_pattern = input_str
    	ya.render()
    	return input_str, final_input_str
    end)

    local flush_input_key_in_statusbar = ya.sync(function(state,input_str,re_match)
    	if re_match then
    		state.match_pattern = "[~]"
    	else
    		state.match_pattern = input_str
    	end
    	ya.render()
    end)

    local set_args_default = ya.sync(function(state,args)

    	if (args[1] ~= nil and args[1] == "autocd") then
    		state.args_autocd = true
    	else
    		state.args_autocd = false
    	end
    end)

    return {
    	setup = function(state, opts)
    		-- Save the user configuration to the plugin's state
    		if (opts ~= nil and opts.unmatch_fg ~= nil) then
    			state.opt_unmatch_fg = opts.unmatch_fg
    		end
    		if (opts ~= nil and opts.match_str_fg ~= nil) then
    			state.opt_match_str_fg = opts.match_str_fg
    		end
    		if (opts ~= nil and opts.match_str_bg ~= nil) then
    			state.opt_match_str_bg = opts.match_str_bg
    		end
    		if (opts ~= nil and opts.first_match_str_fg ~= nil) then
    			state.opt_first_match_str_fg = opts.first_match_str_fg
    		end
    		if (opts ~= nil and opts.first_match_str_bg ~= nil) then
    			state.opt_first_match_str_bg = opts.first_match_str_bg
    		end
    		if (opts ~= nil and opts.lable_fg ~= nil) then
    			state.opt_lable_fg = opts.lable_fg
    		end
    		if (opts ~= nil and opts.lable_bg ~= nil) then
    			state.opt_lable_bg = opts.lable_bg
    		end

    		if (opts ~= nil and opts.only_current ~= nil) then
    			state.opt_only_current = opts.only_current
    		end
    		if (opts ~= nil and opts.search_patterns ~= nil) then
    			state.opt_search_patterns = opts.search_patterns
    		end
    		if (opts ~= nil and opts.show_search_in_statusbar ~= nil) then
    			state.opt_show_search_in_statusbar = opts.show_search_in_statusbar
    		end
    		if (opts ~= nil and opts.auto_exit_when_unmatch ~= nil) then
    			state.opt_auto_exit_when_unmatch = opts.auto_exit_when_unmatch
    		end
    		if (opts ~= nil and opts.enable_capital_lable ~= nil) then
    			state.opt_enable_capital_lable = opts.enable_capital_lable
    		end
    	end,

    	entry = function(_, args)

    		local opt_search_patterns = set_opts_default()
    		set_args_default(args)

    		toggle_ui()

    		local input_str = ""
    		local patterns = {}
    		local final_input_str = ""
    		local re_match = false
    		while true do
    			local cand = ya.which { cands = INPUT_CANDS, silent = true }
    			if cand == nil then
    				goto continue
    			end

    			if INPUT_KEY[cand] == "<Esc>" then
    				break
    			end

    			if INPUT_KEY[cand] == "<Enter>" then
    				final_input_str = get_first_match_lable()
    				patterns = ""
    			elseif INPUT_KEY[cand] == "<Space>" then
    				final_input_str = ""
    				input_str = ""
    				patterns = opt_search_patterns
    				re_match = true
    			elseif INPUT_KEY[cand] == "<Backspace>" then
    				input_str,final_input_str = backout_last_input(input_str)
    				patterns = {input_str}
    				re_match = false
    			else
    				final_input_str = INPUT_KEY[cand]
    				input_str = input_str .. string.lower(INPUT_KEY[cand])
    				patterns = {input_str}
    				re_match = false
    			end

    			flush_input_key_in_statusbar(input_str,re_match)

    			local want_exit = set_target_str(patterns,final_input_str,re_match)
    			if want_exit then
    				break
    			end
    			::continue::
    		end

    		clear_state_str()
    		toggle_ui()
    	end
    }
  '';
in
lib.mkMerge [
  {
    programs.yazi = {
      plugins = mkYaziPlugin "search-jump" plugins_init_lua;

      initLua = ''
        require("searchjump"):setup {
        	unmatch_fg = "#b2a496",
            match_str_fg = "#000000",
            match_str_bg = "#73AC3A",
            first_match_str_fg = "#000000",
            first_match_str_bg = "#73AC3A",
            lable_fg = "#EADFC8",
            lable_bg = "#BA603D",
            only_current = false, -- only search the current window
            show_search_in_statusbar = false,
            auto_exit_when_unmatch = true,
            enable_capital_lable = false,
            search_patterns = {"%.e%d+","s%d+e%d+"}  -- demo:{"%.e%d+","s%d+e%d+"}
        }
      '';

      keymap.manager.prepend_keymap = [
        {
          on = "i";
          run = "plugin searchjump --args='autocd'";
          desc = "searchjump mode(auto cd select folder)";
        }
      ];
    };
  }

]
