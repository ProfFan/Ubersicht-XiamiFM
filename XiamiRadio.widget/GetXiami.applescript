on encode(value)
	set type to class of value
	if type = integer or type = boolean then
		return value as text
	else if type = text then
		return encodeString(value)
	else if type = list then
		return encodeList(value)
	else if type = script then
		return value's toJson()
	else
		error "Unknown type " & type
	end if
end encode


on encodeList(value_list)
	set out_list to {}
	repeat with value in value_list
		copy encode(value) to end of out_list
	end repeat
	return "[" & join(out_list, ", ") & "]"
end encodeList


on encodeString(value)
	set rv to ""
	repeat with ch in value
		if id of ch = 34 then
			set quoted_ch to "\\\""
		else if id of ch = 92 then
			set quoted_ch to "\\\\"
		else if id of ch ≥ 32 and id of ch < 127 then
			set quoted_ch to ch
		else
			set quoted_ch to "\\u" & hex4(id of ch)
		end if
		set rv to rv & quoted_ch
	end repeat
	return "\"" & rv & "\""
end encodeString


on join(value_list, delimiter)
	set original_delimiter to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set rv to value_list as text
	set AppleScript's text item delimiters to original_delimiter
	return rv
end join


on hex4(n)
	set digit_list to "0123456789abcdef"
	set rv to ""
	repeat until length of rv = 4
		set digit to (n mod 16)
		set n to (n - digit) / 16 as integer
		set rv to (character (1 + digit) of digit_list) & rv
	end repeat
	return rv
end hex4


on createDictWith(item_pairs)
	set item_list to {}
	
	script Dict
		on setkv(key, value)
			copy {key, value} to end of item_list
		end setkv
		
		on toJson()
			set item_strings to {}
			repeat with kv in item_list
				set key_str to encodeString(item 1 of kv)
				set value_str to encode(item 2 of kv)
				copy key_str & ": " & value_str to end of item_strings
			end repeat
			return "{" & join(item_strings, ", ") & "}"
		end toJson
	end script
	
	repeat with pair in item_pairs
		Dict's setkv(item 1 of pair, item 2 of pair)
	end repeat
	
	return Dict
end createDictWith


on createDict()
	return createDictWith({})
end createDict

set the_title to ""
tell application "Google Chrome Canary"
	
	set window_list to every window # get the windows
	repeat with the_window in window_list # for every window
		set tab_list to every tab in the_window # get the tabs
		repeat with the_tab in tab_list # for every tab
			set the_url to the URL of the_tab
			if the_url contains "xiami.com/radio/play" then
				set the_title to the title of the_tab # grab the title
				set the_title to ((characters 1 thru -11 of the_title) as string) # concatenate then all
				tell the_tab
					set the_artist to execute javascript "document.querySelector(\".artist_info strong\").textContent"
					set the_data to execute javascript "document.head.attributes.getNamedItem('data-nowplaying').value"
				end tell
			end if
		end repeat
	end repeat
	
end tell

if the_title is not "" and the_artist is not "" then
	encode(createDictWith({{"title", the_title as string}, {"artist", the_artist as string}, {"data", the_data as string}}))
else
	encode(createDictWith({{"title", ""}, {"artist", ""}, {"data", ""}}))
end if
