# @TODO: code from master via Igor; not yet armbian-next'fied! warning!!
compile_plymouth_theme_armbian() {

	local tmp_dir work_dir
	tmp_dir=$(mktemp -d)
	chmod 700 "${tmp_dir}"
	plymouth_theme_armbian_dir=armbian-plymouth-theme_${REVISION}_all
	display_alert "Building deb" "armbian-plymouth-theme" "info"

	mkdir -p "${tmp_dir}/${plymouth_theme_armbian_dir}"/{DEBIAN,usr/share/plymouth/themes/armbian}

	# set up control file
	cat <<- END > "${tmp_dir}/${plymouth_theme_armbian_dir}"/DEBIAN/control
		Package: armbian-plymouth-theme
		Version: $REVISION
		Architecture: all
		Maintainer: $MAINTAINER <$MAINTAINERMAIL>
		Depends: plymouth, plymouth-themes
		Section: universe/x11
		Priority: optional
		Description: boot animation, logger and I/O multiplexer - armbian theme
	END

	cp "${SRC}"/packages/plymouth-theme-armbian/debian/{postinst,prerm,postrm} \
		"${tmp_dir}/${plymouth_theme_armbian_dir}"/DEBIAN/
	chmod 755 "${tmp_dir}/${plymouth_theme_armbian_dir}"/DEBIAN/{postinst,prerm,postrm}

	# this requires `imagemagick`

	convert -resize 256x256 \
		"${SRC}"/packages/plymouth-theme-armbian/armbian-logo.png \
		"${tmp_dir}/${plymouth_theme_armbian_dir}"/usr/share/plymouth/themes/armbian/bgrt-fallback.png

	# convert -resize 52x52 \
	# 	"${SRC}"/packages/plymouth-theme-armbian/spinner.gif \
	# 	"${tmp_dir}/${plymouth_theme_armbian_dir}"/usr/share/plymouth/themes/armbian/animation-%04d.png

	convert -resize 52x52 \
		"${SRC}"/packages/plymouth-theme-armbian/spinner.gif \
		"${tmp_dir}/${plymouth_theme_armbian_dir}"/usr/share/plymouth/themes/armbian/throbber-%04d.png

	cp "${SRC}"/packages/plymouth-theme-armbian/watermark.png \
		"${tmp_dir}/${plymouth_theme_armbian_dir}"/usr/share/plymouth/themes/armbian/

	cp "${SRC}"/packages/plymouth-theme-armbian/{bullet,capslock,entry,keyboard,keymap-render,lock}.png \
		"${tmp_dir}/${plymouth_theme_armbian_dir}"/usr/share/plymouth/themes/armbian/

	cp "${SRC}"/packages/plymouth-theme-armbian/armbian.plymouth \
		"${tmp_dir}/${plymouth_theme_armbian_dir}"/usr/share/plymouth/themes/armbian/

	fakeroot dpkg-deb -b "-Z${DEB_COMPRESS}" "${tmp_dir}/${plymouth_theme_armbian_dir}" > /dev/null
	rsync --remove-source-files -rq "${tmp_dir}/${plymouth_theme_armbian_dir}.deb" "${DEB_STORAGE}/"
	rm -rf "${tmp_dir}"
}