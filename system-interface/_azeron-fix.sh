#!/bin/sh
# --- Azeron Cyborg II controller freeze fix ---
#
# Issue:
#   In Xbox360 mode, Azeron’s analog stick + keyboard mapping buttons freeze
#   the device whenever the analog stick is moved, until un+replugged.
#
# Root cause:
#   Both `usbhid` and `xpad` try to claim interfaces for "one" Azeron device. If HID grabs them first (default linux behaviour for the Azeron),
#   keymaps “work” briefly but stick input bricks the device.
#
# Fix approach:
#   - Trigger on *usb_interface* udev events (this event is automatically signalled by the kernel, when our Azeron device has fully generated its (shiity) config files, so we can safely rebind those config files in our script below, without worrying about half-generated files (rebinding null fields too early).
#   - But only act if ALL interfaces (1.0–1.4) for the Azeron are present.
#   - Then: unbind all from usbhid, rebind them to xpad.
#
# Why this works:
#   By waiting until enumeration has created *all* the child interfaces,
#   we ensure we’re not racing against the kernel. This avoids needing `sleep` hacks. Event driven.

LOGFILE="/tmp/azeron.log"
echo "[fix-azeron] triggered at $(date)" >> "$LOGFILE"

# Expected interfaces for Azeron Cyborg II on port 1-10
BASEDEV="1-10"
EXPECTED_IFACES="0 1 2 3 4"

# Check that all expected interface paths exist
all_present=true
for idx in $EXPECTED_IFACES; do
  if [ ! -e "/sys/bus/usb/devices/${BASEDEV}:1.$idx" ]; then
    all_present=false
  fi
done

if [ "$all_present" != true ]; then
  echo "[fix-azeron] Not all interfaces ready yet, exiting" >> "$LOGFILE"
  exit 0
fi

# If we get here, all interfaces are present -> proceed
echo "[fix-azeron] All interfaces detected, applying fix" >> "$LOGFILE"

# Ensure xpad driver is loaded
modprobe xpad 2>>"$LOGFILE"

# Register the unchanging Azeron Cyborg II specific vendorId/productId for xpad to recognize
echo "16d0 12f7" > /sys/bus/usb/drivers/xpad/new_id 2>>"$LOGFILE"

# Unbind from usbhid, rebind to xpad (these aren't the exact fields required but it works empirically)
for idx in $EXPECTED_IFACES; do
  iface="${BASEDEV}:1.$idx"
  echo "[fix-azeron] Handling $iface" >> "$LOGFILE"
  echo "$BASEDEV:1.$idx" > /sys/bus/usb/drivers/usbhid/unbind 2>>"$LOGFILE"
  echo "$BASEDEV:1.$idx" > /sys/bus/usb/drivers/xpad/bind 2>>"$LOGFILE"
done

echo "[fix-azeron] done" >> "$LOGFILE"