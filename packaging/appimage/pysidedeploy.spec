[app]
title = NelvaMusic
project_dir = .
input_file = app/main.py
exec_directory = build_appimage/deploy
project_file =
icon = assets/icons/Nelva.png

[python]
packages = Nuitka==4.1.1
android_packages = buildozer==1.6.0,cython==0.29.33

[qt]
qml_files = app/ui/qml/ControlButton.qml,app/ui/qml/EqualizerPanel.qml,app/ui/qml/LibrarySongsView.qml,app/ui/qml/LibraryView.qml,app/ui/qml/Main.qml,app/ui/qml/MusicView.qml,app/ui/qml/NowPlayingView.qml,app/ui/qml/PlayerControls.qml,app/ui/qml/PlaylistCard.qml,app/ui/qml/PlaylistDetailView.qml,app/ui/qml/PlaylistsView.qml,app/ui/qml/SettingsSection.qml,app/ui/qml/SettingsView.qml,app/ui/qml/Sidebar.qml,app/ui/qml/SidebarButton.qml,app/ui/qml/TopBar.qml,app/ui/qml/TrackDelegate.qml,app/ui/qml/components/ActionButton.qml,app/ui/qml/components/AlbumArtStage.qml,app/ui/qml/components/PlaybackControls.qml,app/ui/qml/components/PlayerButton.qml,app/ui/qml/components/PlayingIndicator.qml,app/ui/qml/components/ProgressBar.qml,app/ui/qml/components/ProgressSection.qml,app/ui/qml/components/TrackHeader.qml,app/ui/qml/components/TrackInfo.qml,app/ui/qml/components/VolumeControl.qml,app/ui/qml/components/VolumeSlider.qml,app/ui/qml/components/WaveformProgress.qml,app/ui/qml/components/WindowResizeHandles.qml
excluded_qml_plugins = QtCharts,QtQuick3D,QtSensors,QtTest,QtWebEngine
modules = Core,DBus,Gui,Network,OpenGL,Qml,QmlMeta,QmlModels,QmlWorkerScript,Quick,QuickControls2,QuickTemplates2,Widgets
plugins = accessiblebridge,egldeviceintegrations,generic,iconengines,imageformats,networkaccess,networkinformation,platforminputcontexts,platforms,platformthemes,qmltooling,scenegraph,styles,tls,vectorimageformats,wayland-decoration-client,wayland-graphics-integration-client,wayland-shell-integration,xcbglintegrations

[android]
wheel_pyside =
wheel_shiboken =
plugins =

[ios]
wheel_pyside =
wheel_shiboken =
xcframework_path =
bundle_id =
team_id =
version = 1.0
deployment_target =
entitlements =
signing_style = Automatic
header_search_paths =

[nuitka]
macos.permissions =
mode = standalone
extra_args = --quiet --noinclude-qt-translations --include-data-dir=app/ui/qml=app/ui/qml --include-data-dir=assets=assets --include-data-dir=plugins=plugins --include-data-dir=app/i18n/translations=app/i18n/translations

[buildozer]
mode = debug
recipe_dir =
jars_dir =
ndk_path =
sdk_path =
local_libs =
arch =
