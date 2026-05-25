# MSR Recovery Slice v30 — Bazaar-and-Back Origin AA Recovery

## Purpose

This slice restores the intended Bazaar access path after the guild tribute crash was isolated.

The recovered server uses the stock Origin AA as the player-facing **Bazaar and Back** button:

- `aa_ability.id = 331`
- `aa_ability.name = Origin`
- `aa_ability.first_rank_id = 1000`
- `aa_ranks.id = 1000`
- `aa_ranks.spell = 5824`
- source constant: `aaOrigin = 1000`

The existing custom code compared `ability->id == aaOrigin`, which compares `331 == 1000` and therefore does not fire for the real Origin ability. This slice changes the check to also accept `rank->id == aaOrigin`.

It also removes the temporary AA table send guard added during crash isolation, because GDB proved the fatal world-entry crash was in `Client::SendGuildTributes()`, not AA table sending.

## Files changed

- `zone/aa.cpp`

## Files included

- `apply_recovery_slice_v30_bazaar_origin_aa.sh`
- `verify_recovery_slice_v30_bazaar_origin_aa.py`

## Apply

```bash
cd /opt/msr/repo/msr

tar -xzf /path/to/MSR_recovery_slice_v30_bazaar_origin_aa.tar.gz -C /tmp

bash /tmp/msr_recovery_slice_v30_bazaar_origin_aa/apply_recovery_slice_v30_bazaar_origin_aa.sh /opt/msr/repo/msr

python3 /tmp/msr_recovery_slice_v30_bazaar_origin_aa/verify_recovery_slice_v30_bazaar_origin_aa.py /opt/msr/repo/msr
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

## Do not revert

Keep the guild tribute send guard active for now. That guard is what allowed world entry after GDB found the `Client::SendGuildTributes()` buffer overflow on `"Aura of Preservation"`.

## Test

1. Log in.
2. Confirm the AA window/button is visible again.
3. Use Origin / Bazaar and Back outside Bazaar.
4. Confirm it sends the player to Bazaar.
5. Use it again or test the return-path logic if available.
6. Confirm world entry still survives.
