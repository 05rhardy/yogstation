
/var/list/pretty_filter_items = list()

// Append pretty filter items from file to a list
/proc/setup_pretty_filter(var/path = "config/pretty_filter.txt")
	var/list/filter_lines = file2list(path)

	for(var/line in filter_lines)
		if(!add_pretty_filter_line(line))
			continue

// Add a filter pair
/proc/add_pretty_filter_line(var/line)
	if(!length(line))
		return 0

	if(findtextEx(line,"#",1,2))
		return 0

	//Split the line at every "="
	var/list/parts = text2list(line, "=")
	if(!parts.len)
		return 0

	//pattern is before the first "="
	var/pattern = parts[1]
	if(!pattern)
		return 0

	//replacement follows the first "="
	var/replacement = ""
	if(parts.len >= 2)
		replacement = parts[2]

	if(!replacement)
		return 0

	pretty_filter_items.Add(line)
	return 1

// List all filters that have been loaded
/client/proc/list_pretty_filters()
	set category = "Admin"
	set name = "Pretty Filters - List"

	usr << "<font size='3'><b>Pretty filters list</b></font>"
	for(var/line in pretty_filter_items)
		var/list/parts = text2list(line, "=")
		var/pattern = parts[1]
		var/replacement = parts[2]

		usr << "&nbsp;&nbsp;&nbsp;<font color='#994400'><b>[pattern]</b></font> -> <font color='#004499'><b>[replacement]</b></font>"
	usr << "<font size='3'><b>End of list</b></font>"

// Enter a piece of text and have it tested against the filter list
/client/proc/test_pretty_filters(msg as text)
	set category = "Admin"
	set name = "Pretty Filters - Test"

	usr << "\"[msg]\" becomes: \"[pretty_filter(msg)]\"."

// Enter a piece of text and have it tested against the filter list
/client/proc/add_pretty_filter(line as text)
	set category = "Admin"
	set name = "Pretty Filters - Add Pattern"

	if(add_pretty_filter_line(line))
		usr << "\"[line]\" was added for this round - It has not been added to the permanent file."
	else
		usr << "\"[line]\" was not added."

//Filter out and replace unwanted words, prettify sentences
/proc/pretty_filter(var/text)
	for(var/line in pretty_filter_items)
		var/list/parts = text2list(line, "=")
		var/pattern = parts[1]
		var/replacement = parts[2]

		var/regex/R = new("/[pattern]/[replacement]/i")
		var/newtxt = R.Replace(text)
		while(newtxt)
			text = newtxt
			newtxt = R.ReplaceNext(text)

	return text