function getDateString(timeinclude = false){
	local timeTable = {}
	LocalTime(timeTable)
	if(!timeinclude){
		return timeTable.day.tostring() + "-" + timeTable.month.tostring() + "-" + timeTable.year.tostring()
	} else {
		return timeTable.day.tostring() + "-" + timeTable.month.tostring() + "-" + timeTable.year.tostring() + " [" + timeTable.hour.tostring() + ":" + timeTable.minute.tostring() + "]"
	}
}
