# MSR Recovery Slice v31b — Bazaar and Back Return Path

This slice patches `zone/aa.cpp` without relying on the older comment marker that failed in v31.

## Fixes

- Treats `aaOrigin = 1000` as the rank id used by the recovered DB.
- Also allows `aa_ability.id = 331` for Origin.
- Outside Bazaar:
  - Saves Return-Zone / Return-X / Return-Y / Return-Z / Return-H / Return-Instance.
  - Sends the player to one of the two known Bazaar landing spots:
    - `-151.44, 168.93, -16.25`
    - `-151.47, -177.88, -16.25`
- Inside Bazaar:
  - Reads Return-* buckets.
  - Sends the player back to the saved origin location.

## Apply

```bash
cd /opt/msr/repo/msr
tar -xzf /opt/msr/incoming/MSR_recovery_slice_v31b_bazaar_back_return.tar.gz -C /tmp
bash /tmp/msr_recovery_slice_v31b_bazaar_back_return/apply_recovery_slice_v31b_bazaar_back_return.sh /opt/msr/repo/msr
python3 /tmp/msr_recovery_slice_v31b_bazaar_back_return/verify_recovery_slice_v31b_bazaar_back_return.py /opt/msr/repo/msr
```

## Build/deploy

```bash
cd /opt/msr/repo/msr
cmake --build build/linux-release --target zone -j"$(nproc)"

pkill -f 'eqlaunch' || true
pkill -f '/zone' || true
sleep 2

cp /opt/msr/repo/msr/build/linux-release/bin/zone /opt/msr/server/bin/zone.new
chmod +x /opt/msr/server/bin/zone.new
mv -f /opt/msr/server/bin/zone.new /opt/msr/server/bin/zone
```

Restart world/zones from `/opt/msr/server`.

## Commit

```bash
git commit -m "Zone: Restore Bazaar-and-Back return path"
```
