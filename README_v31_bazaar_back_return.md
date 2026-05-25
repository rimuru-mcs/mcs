# MSR Recovery Slice v31 — Bazaar and Back Return + Two Landing Spots

This slice patches `zone/aa.cpp` so the recovered **Bazaar and Back** / **Origin** AA:

- triggers on the recovered schema correctly (`aaOrigin` rank id 1000 and Origin ability id 331),
- sends players to one of two Bazaar landing spots instead of `0,0,0`,
- returns players to their saved origin when the AA is used again from Bazaar.

## Landing spots

Captured from the recovered/live behavior:

- Landing A: `-151.44, 168.93, -16.25`
- Landing B: `-151.47, -177.88, -16.25`

The Tearel reference point `-540.67, 211.58, 2.75` is not used as an AA landing in this slice.

## Apply

```bash
cd /opt/msr/repo/msr

tar -xzf /path/to/MSR_recovery_slice_v31_bazaar_back_return.tar.gz -C /tmp

bash /tmp/msr_recovery_slice_v31_bazaar_back_return/apply_recovery_slice_v31_bazaar_back_return.sh /opt/msr/repo/msr

python3 /tmp/msr_recovery_slice_v31_bazaar_back_return/verify_recovery_slice_v31_bazaar_back_return.py /opt/msr/repo/msr
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

Restart zones from `/opt/msr/server`.

## Test

1. Log in outside Bazaar.
2. Use Bazaar and Back.
3. Confirm the character lands at one of the two `/loc` points.
4. Use Bazaar and Back again from Bazaar.
5. Confirm the character returns to the saved source location.

## Suggested commit

```bash
git commit -m "Zone: Restore Bazaar-and-Back return path"
```
