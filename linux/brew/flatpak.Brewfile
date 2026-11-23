# GUI applications. Flathub by default; the two self-published apps come
# from the FlatPark remote (dl.flatpark.org). The `remote:` + `url:` form is
# Homebrew's Tier-3 "named shared remote": brew bundle adds the remote when
# missing (bluefin already ships it via remotes.d/flatpark.flatpakrepo;
# dakota does not). The url points at the .flatpakrepo file so the GPG key
# is imported — a bare repo URL would get --no-gpg-verify. Both app ids
# verified against the FlatPark repo summary, 2026-11.
flatpak "be.alexandervanhee.gradia"
flatpak "com.belmoussaoui.Decoder"
flatpak "com.belmoussaoui.Obfuscate"
# No extension-management app ships with dakota: the standalone GNOME
# Extensions app was retired upstream (only gnome-extensions CLI remains in
# gnome-shell; GNOME Settings gained an Extensions panel). ExtensionManager
# adds EGO browsing/install on top.
flatpak "com.mattjakeman.ExtensionManager"
flatpak "com.brave.Browser"
flatpak "com.discordapp.Discord"
flatpak "com.github.huluti.Curtail"
flatpak "com.github.tchx84.Flatseal"
flatpak "com.protonvpn.www"
flatpak "com.spotify.Client"
flatpak "com.usebottles.bottles"
flatpak "de.haeckerfelix.Fragments"
flatpak "fr.handbrake.ghb"
flatpak "io.beekeeperstudio.Studio"
flatpak "io.github.flattool.Warehouse"
flatpak "io.github.getnf.embellish"
flatpak "io.github.nozwock.Packet"
flatpak "io.github.nroduit.Weasis"
# Solaar: configures Logitech Unifying/bolt receivers, keyboards and mice.
# Flatpak-only on Linux; it needs the host udev rules from `just solaar-udev`
# (Dakota ships none) and its shell-side companion
# (solaar-extension@sidevesh, see linux/gnome/recipes/extensions.just).
flatpak "io.github.pwr_solaar.solaar"
flatpak "io.github.tobagin.karere"
flatpak "io.github.tunix.valhalla", remote: "flatpark", url: "https://dl.flatpark.org/flatpark.flatpakrepo"
flatpak "com.nousresearch.hermes-light", remote: "flatpark", url: "https://dl.flatpark.org/flatpark.flatpakrepo"
flatpak "io.github.vikdevelop.SaveDesktop"
flatpak "io.gitlab.liferooter.TextPieces"
flatpak "it.mijorus.gearlever"
flatpak "md.obsidian.Obsidian"
flatpak "org.gimp.GIMP"
flatpak "org.gnome.Snapshot"
flatpak "org.gnome.SoundRecorder"
flatpak "org.gnome.design.Lorem"
flatpak "org.gnome.gitlab.YaLTeR.VideoTrimmer"
flatpak "org.gnome.seahorse.Application"
flatpak "org.libreoffice.LibreOffice"
flatpak "org.telegram.desktop"
flatpak "us.zoom.Zoom"
