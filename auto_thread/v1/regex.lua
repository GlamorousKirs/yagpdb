{{/* Variables */}}
{{ $CHANNEL_ANNOUNCEMENT := 1316486246167609385 }}
{{ $AUTO_ARCHIVE_DURATION := 4320 }}
{{/* 
	$AUTO_ARCHIVE_DURATION valid values:
	60 = 1 hour
	1440 = 24 hours
	4320 = 3 days
	10080 = 1 week
*/}}

{{/*
	AUTO THREAD V1
	By @glamorouskirs
	Github: https://github.com/GlamorousKirs/yagpdb

	Trigger type: Regex
	Trigger: \A
*/}}

{{ $date := currentTime.Format "01/02/06" }}

{{ if eq .Channel.ID $CHANNEL_ANNOUNCEMENT }}
	{{ $thread := createThread nil $.Message.ID (print "Announcement " $date) false $AUTO_ARCHIVE_DURATION false }}
{{ end }}
