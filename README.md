# Analysis-matlab

## Resources layout and Windows junction

This repo uses a Windows junction so the UI can reference shared assets under a stable path while the files physically live in the library submodule.

- Stable path (junction in this repo):
  - `+UserInterface/Resources`
- Junction target (real files):
  - `external/library-matlab/src/+UserInterface/Resources`

A junction is a Windows/NTFS filesystem feature (not Git). Reading or writing under `+UserInterface/Resources` actually accesses the target directory above. Writing there will modify the library submodule and can make it appear "dirty" in Git if the change isn’t committed in the submodule repo.

### Policy: local-first, shared-second
To avoid dirtying the library with Analysis-only files, store Analysis-specific assets here and make code search this folder first:

1) `+UserInterface/+StabilityControl/Resources` (Analysis-only assets)
2) `+UserInterface/Resources` (junction into shared library resources)
3) `external/library-matlab/src/+SimViewer/Resources` (additional shared icons)
4) `external/library-matlab/src/@Application/private` (legacy fallback)

The splash image resolver in `+Utilities/SplashScreen.m` implements this search order (local-first, then shared).

You can inspect the junction with PowerShell:

```
Get-Item "+UserInterface/Resources" | Format-List FullName, LinkType, LinkTarget
```

Expected: `LinkType: Junction` and a `LinkTarget` pointing to `external/library-matlab/src/+UserInterface/Resources`.

---

## Licensing for development (SimMacLib dev whitelist)

- This repo depends on the shared library submodule at `external/library-matlab` (tag v0.1.7 or later).
- The library’s `SimMacLib` supports a developer whitelist for local/offline use:
  - If no entitlement token is provided, `SimMacLib` will allow `login()` to succeed when the current machine’s MAC address matches one of the entries in `DevMacWhitelist` (defined in `external/library-matlab/src/@SimMacLib/SimMacLib.m`).
  - This avoids Java dependencies and is intended for developer machines only.

### How to add another developer machine

1) Get the MAC on the target machine (Windows PowerShell):
   - `getmac`
   - Use the “Physical Address” in hyphen form, e.g. `AA-BB-CC-11-22-33`.
2) Edit the library file and append the MAC to `DevMacWhitelist`:
   - `external/library-matlab/src/@SimMacLib/SimMacLib.m`
3) Tag the library and bump this repo’s submodule:
   - In the library repo: create a new tag (e.g., `v0.1.8`) and push.
   - In this repo: `git submodule update --remote external/library-matlab`, commit the pointer, and push.

## Production licensing (tokens)

- For production or CI, provide an entitlement token instead of relying on the dev whitelist:
  - Set environment: `SIMMACLIB_LICENSE_TOKEN="<token>"`
  - Optional: `SIMMACLIB_LICENSE_URL` if using a remote entitlement service; `SIMMACLIB_ENTITLEMENT_ID` if required by the service.
  - When a token is present, the dev whitelist is bypassed and the configured token flow is used.
