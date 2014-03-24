#!/bin/bash

# Based on the solarized theme.
 
case "$1" in 
	"solarized-ish-dark")
		PALETTE="#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3"
		BG_COLOR="#00002B2B3636"
		FG_COLOR="#65657B7B8383"
		;;
	"solarized-ish-light")
		PALETTE="#EEEEE8E8D5D5:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#070736364242:#FDFDF6F6E3E3:#CBCB4B4B1616:#9393A1A1A1A1:#838394949696:#65657B7B8383:#6C6C7171C4C4:#58586E6E7575:#00002B2B3636"
		BG_COLOR="#FDFDF6F6E3E3"
		FG_COLOR="#535364646666"
		;;
	*)
	echo "Unknown theme."
	exit
	;;
esac

theme=/apps/gnome-terminal/profiles/Default

gconftool-2 --set "$theme/use_theme_background" --type bool false
gconftool-2 --set "$theme/use_theme_colors" --type bool false
gconftool-2 --set "$theme/palette" --type string "$PALETTE"
gconftool-2 --set "$theme/background_color" --type string "$BG_COLOR"
gconftool-2 --set "$theme/foreground_color" --type string "$FG_COLOR"

