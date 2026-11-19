# The patches of GE's tree that this package applies to Wine, in GE's order: its script
# patches/protonprep-valve-staging.sh written out, because that script cannot run here (it needs the
# wine-staging submodule and a git checkout). package.nix runs this with apply_ge applying each patch;
# tests/ge-sequence runs it with apply_ge naming each patch and holds the names against what GE's own
# script would apply. Expects $ge (GE's patches folder) and the function apply_ge.
apply_ge_dir() { for p in $(ls "$1"/*.patch | sort); do apply_ge "$p"; done; }
sni="$ge/wine-hotfixes/em-fixups/0001-winewayland-add-SNI-tray-icons-and-native-context-me.patch"
apply_ge_dir "$ge/wine-hotfixes/wine-wayland"
apply_ge "$sni"
apply_ge_dir "$ge/wine-hotfixes/wineland-child-rendering"
for p in $(ls "$ge"/wine-hotfixes/em-fixups/*.patch | sort); do [ "$p" = "$sni" ] || apply_ge "$p"; done
for d in winedevice-Default_Drivers ntdll-Hide_Wine_Exports kernel32-Debugger ntdll-ext4-case-folder \
         winex11-Window_Style winex11-ime-check-thread-data winex11-Fixed-scancodes comctl32_animate_avi \
         d3drm-starwars windowscodecs-TIFF_Support mmsystem.dll16-MIDIHDR_Refcount; do
  apply_ge_dir "$ge/wine-hotfixes/wine-staging/$d"
done
for f in assettocorsa-hud pso2_hack vgsoh silence-starcitizen-unsupported-os eac_60101_timeout \
         layered-overlay-wine layered-overlay-direct-present \
         0001-win32u-Avoid-zero-WM_ACTIVATEAPP-lparam-on-first-for \
         black-desert-keep-fullscreen-on-focus-loss maplestory-kernelbase-charprev-null \
         maplestory-spi-stickykeys-filterkeys ai-limit-dx12-compute-shader-fallback \
         max-payne-cpu-detection return-to-krondor-text-bitmap-readback nascar25-protector \
         ace-driverentry-kernel-return-address ace-ntoskrnl-mmcopymemory-stub \
         ace-ntoskrnl-service-key-name ace-ntoskrnl-keep-mdl-section-views-mapped \
         ace-ntoskrnl-psgetcontextthread-thunk ace-lsass-samss-service-stub \
         ace-wineboot-start-samss-service; do
  apply_ge "$ge/game-patches/$f.patch"
done
apply_ge_dir "$ge/wine-hotfixes/qcap-dshow-fixes"
apply_ge_pending() { for f in "$@"; do apply_ge "$ge/wine-hotfixes/pending/$f.patch"; done; }
apply_ge_pending urlmon-pump-thread-user-messages-during-synchronous-bind wineboot-create-sqm-machine-id \
         crypt32-pfx-record-machine-keyset-in-prov-info crypt32-pfx-use-the-container-key-spec \
         crypt32-reject-ncrypt-only-private-keys crypt32-wc3-modern-chain-engine-config \
         crypt32-wc3-trace-chain-engine-config crypt32-wc3-check-exclusive-flags-size \
         crypt32-wc3-accept-legacy-chain-engine-config crypt32-wc3-preserve-exclusive-root-and-test-layouts
apply_ge "$ge/wine-hotfixes/mta-certificate/0001-crypt32-support-sha256-certificate-properties.patch"
apply_ge_pending d2d1-register-tint-effect d2d1-render-bitmap-sprites-tint-and-layers \
         d2d1-isolate-target-clip-stacks \
         version-GetFileVersionInfoByHandle-stub ws2_32-validate-connect-address \
         kernel32-refresh-power-status-asynchronously secur32-fallback-without-no-shuffle-extensions \
         secur32-schannel-fix-incomplete-message-missing-size \
         wined3d-preserve-runtime-opengl-gpu-description winex11-use-x11-drawables-for-steam-opengl-overlay \
         winex11-keep-forza-background-windows-unmapped-on-wlroots \
         winex11-handle-unsupported-minimization-on-satellite winex11-bound-pointer-grab-wait \
         server-clip-off-desktop-minimized-window-paint win32u-share-selected-cursors-across-processes \
         win32u-limit-extra-swapchain-image-to-doom win32u-use-three-image-present-modes-for-hades-wayland \
         win32u-use-three-image-present-modes-for-path-of-exile ntdll-retry-native-view-allocation-with-effective-range \
         ntdll-reserve-top-down-space-for-large-address-aware-wow64 ntdll-keep-nvidia-dlss-address-range-free \
         ntdll-remove-redundant-packed-split-lock \
         ntdll-block-apcs-until-process-exit-state-is-set \
         server-dont-touch-freed-handle-table-in-close-handle \
         ntdll-prefer-native-version-resource-heuristics ntdll-keep-builtin-amd-ags-ahead-of-version-heuristic \
         ole32-clipboard-stale-handle-1-tests ole32-clipboard-stale-handle-2-fix unity_crash_hotfix
apply_ge_dir "$ge/wine-hotfixes/llvm-libc"
apply_ge_pending registry_RRF_RT_REG_SZ-RRF_RT_REG_EXPAND_SZ NCryptDecrypt_implementation \
         0009-HACK-kernel32-Spoof-GetProcAddress-of-KiUserApcDispa icuuc-icuin-forwarder-dlls \
         0001-server-Dynamically-relocate-.exes-by-default-too 0002-ntdll-allow-disabling-executable-ASLR
for f in winealsa-override-channel-count 0001-fshack-Implement-AMD-FSR-upscaler-for-fullscreen-hac \
         0001-win32u-Implement-NtGdiDdDDIQueryAdapterInfo-cases 83-nv_low_latency_wine \
         build_failure_prevention-add-nls 0001-win32u-add-env-switch-to-disable-wm-decorations \
         wine_host_block_envvar 0001-HACK-kernelbase-allow-overriding-dlls-for-DLSS-XeSS- \
         0002-HACK-ntdll-add-optiscaler-inection-hack 0003-HACK-ntdll-redirect-streamline-dlls-for-upgrade \
         0001-ntdll-Read-QueryPerformanceCounter-from-the-TSC-in-us \
         0002-ntdll-Only-read-the-kernel-clocksource-for-QPC-at-start-up \
         0001-ntdll-Implement-IOCTL_SERIAL_GET_DTRRTS-for-serial-dev; do
  apply_ge "$ge/proton/$f.patch"
done
apply_ge_dir "$ge/ge-video-rework"
apply_ge_dir "$ge/proton-ds5-haptic"
apply_ge_pending winebus-switch-pro-xinput-identity winebus-diablo-iv-dualsense-edge-identity \
         ntdll-srwlock-skip-needless-shared-release-wake \
         ntdll-heap-reuse-free-blocks-of-partially-used-lfh-groups \
         ntdll-take-in-flight-alert-when-wait-on-address-times-out \
         ntdll-tests-wait-on-address-wake-racing-timeout ntdll-run-purple-agent-in-new-wow64-mode \
         cmd-make-choice-timeout-work-on-console-input \
         win32u-release-images-presented-to-hidden-windows win32u-report-b8g8r8a8-unorm-surface-format-first \
         win32u-prefer-native-hdr-colorspace-for-host-layers winewayland-fix-win-data-locking-in-ime-text-input \
         winewayland-avoid-user-lock-under-win-data-in-client-surface-callbacks \
         winewayland-advertise-openvr-openxr-device-extensions winewayland-animate-animated-cursors \
         rtworkq-dont-hold-queues-section-during-system-queue-shutdown dsound-keep-hq-resampler-for-any-buffer-count \
         win32u-defer-nvidia-wayland-host-instance-destroy \
         server-keep-owned-ntsync-mutex-until-owner-releases-or-dies \
         server-keep-in-process-mutex-closed-while-in-use kernel32-tests-abandon-mutex-acquired-after-close
apply_ge_dir "$ge/wine-hotfixes/bluetooth-le"
apply_ge_pending ntdll-free-teb-and-stacks-of-killed-threads kernel32-tests-killed-thread-stack-freed \
         ntdll-dont-keep-reply-pipe-open-during-thread-init
