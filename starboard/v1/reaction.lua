{{/* Variables */}}
{{$EMBED_COLOR := 0xFFFBB0}}                               
{{$EMBED_FOOTER_STAR_ICON := "https://media.tenor.com/vafOLwS0j0sAAAAi/star-yıldız.gif"}} 
{{$NOTIFY_AUTHOR_ENABLED := true}}                          
{{$REWARD_ROLE := 1316388547384840225}}                     
{{$REWARD_ROLE_ENABLED := true}}                            
{{$STARBOARD_CHANNEL := 1316157169221242971}}              
{{$STAR_EMOJI := "⭐"}}                                      
{{$STARRED_EMOJI := "💫"}}                                   
{{$STARRED_TEXT := "𝑆𝑇𝐴𝑅𝑅𝐸𝐷"}}                           
{{$STARS_TEXT := " 𝑆𝑎𝑟𝑠"}}                              
{{$THRESHOLD := 1}}                                          

{{/*
        STARBOARD V1
        By @glamorouskirs
        Github: https://github.com/GlamorousKirs/yagpdb

        Trigger type: Reaction (Added + Removed reactions)
*/}}

{{$embed := sdict
    "description" $.Message.Content
    "color" $EMBED_COLOR
    "author" (sdict "name" $.Message.Author.Globalname "icon_url" ($.Message.Author.AvatarURL "512"))
    "footer" (sdict "text" (print $THRESHOLD $STARS_TEXT) "icon_url" "https://media.tenor.com/vafOLwS0j0sAAAAi/star-yıldız.gif")
}}

{{if $.Message.Attachments}} {{$embed.Set "image" (sdict "url" (index $.Message.Attachments 0).URL)}} {{end}}

{{$hasStarReaction := false}}
{{$hasGlowingStar := false}}

{{range .Message.Reactions}}
    {{if eq .Emoji.APIName $STAR_EMOJI}} {{$hasStarReaction = ge .Count $THRESHOLD}} {{end}}
    {{if eq .Emoji.APIName $STARRED_EMOJI}} {{$hasGlowingStar = true}} {{end}}
{{end}}

{{/* Handle messages outside of the starboard channel */}}
{{if not (eq .Channel.ID $STARBOARD_CHANNEL)}}

	{{/* Ignores embeds, bots, and forward messages */}}
    {{if or $.Message.Embeds $.Message.MessageReference }} {{return}} {{end}}

    {{if $hasStarReaction}}
        {{if not $hasGlowingStar}}
            {{if $REWARD_ROLE_ENABLED}} {{giveRoleID $.Message.Author.ID $REWARD_ROLE}} {{end}}
            {{$msgID := sendMessageRetID $STARBOARD_CHANNEL (complexMessage "embed" (cembed $embed) "content" (printf "# %s\n-# on %s " $STARRED_TEXT $.Message.Link))}}
            {{addMessageReactions $STARBOARD_CHANNEL $msgID $STAR_EMOJI}}
            {{deleteAllMessageReactions nil $.Message.ID $STAR_EMOJI}}
            {{addReactions $STARRED_EMOJI}}

            {{if $NOTIFY_AUTHOR_ENABLED}}
                {{$starredLink := printf "https://discord.com/channels/%d/%d/%d" $.Guild.ID $STARBOARD_CHANNEL $msgID}}
                {{$gotStarredEmbed := sdict
                    "color" 0x2B2D31
                    "description" (printf "### %s\n-# on %s" $STARRED_TEXT $starredLink)
                    "footer" (sdict "text" $.Message.Author.Username "icon_url" ($.Message.Author.AvatarURL "512"))
                }}
                {{if $.Message.Content}} {{$gotStarredEmbed.Set "description" (printf "### %s\n-# on %s\n\n>>> %s" $STARRED_TEXT $starredLink $.Message.Content)}} {{end}}
                {{if $.Message.Attachments}} {{$gotStarredEmbed.Set "image" (sdict "url" (index $.Message.Attachments 0).URL)}} {{end}}
                {{$sent := sendMessageRetID nil (complexMessage "embed" $gotStarredEmbed "content" (printf "-# Content by %s" $.Message.Author.Mention))}}
            {{end}}
        {{else}}
            {{deleteMessageReaction nil $.Message.ID $.User.ID $STAR_EMOJI}}
        {{end}}
    {{else if eq .Reaction.Emoji.APIName $STAR_EMOJI}} 
        {{if $hasGlowingStar}} {{deleteMessageReaction nil $.Message.ID $.User.ID $STAR_EMOJI}} {{end}}
    {{else if eq .Reaction.Emoji.APIName $STARRED_EMOJI}} 
        {{deleteMessageReaction nil $.Message.ID $.User.ID $STARRED_EMOJI}}
    {{end}}
{{end}}

{{/* Handle messages inside the starboard channel */}}
{{if eq .Channel.ID $STARBOARD_CHANNEL}}
    {{range .Message.Reactions}}
        {{if eq .Emoji.APIName $STAR_EMOJI}}
            {{$currentCount := sub (add .Count $THRESHOLD) 1}}
            {{if lt $currentCount $THRESHOLD}} {{return}} {{end}}
            {{$existingMessage := getMessage $STARBOARD_CHANNEL $.Message.ID}}
            {{$existingEmbed := index $existingMessage.Embeds 0}}
            {{$updatedEmbed := cembed
                "description" $existingEmbed.Description
                "color" $existingEmbed.Color
                "author" $existingEmbed.Author
                "footer" (sdict "text" (printf "%d %s" $currentCount $STARS_TEXT) "icon_url" $EMBED_FOOTER_STAR_ICON)
                "image" $existingEmbed.Image
            }}
            {{editMessage nil $existingMessage.ID $updatedEmbed}}
        {{end}}
    {{end}}
{{end}}
