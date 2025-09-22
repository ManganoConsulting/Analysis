# Analysis-matlab

Licensing for development (SimMacLib dev whitelist)

- This repo depends on the shared library submodule at `external/library-matlab` (tag v0.1.7 or later).
- The library’s `SimMacLib` supports a developer whitelist for local/offline use:
  - If no entitlement token is provided, `SimMacLib` will allow `login()` to succeed when the current machine’s MAC address matches one of the entries in `DevMacWhitelist` (defined in `external/library-matlab/src/@SimMacLib/SimMacLib.m`).
  - This avoids Java dependencies and is intended for developer machines only.

How to add another developer machine

1) Get the MAC on the target machine (Windows PowerShell):
   - `getmac`
   - Use the “Physical Address” in hyphen form, e.g. `AA-BB-CC-11-22-33`.
2) Edit the library file and append the MAC to `DevMacWhitelist`:
   - `external/library-matlab/src/@SimMacLib/SimMacLib.m`
3) Tag the library and bump this repo’s submodule:
   - In the library repo: create a new tag (e.g., `v0.1.8`) and push.
   - In this repo: `git submodule update --remote external/library-matlab`, commit the pointer, and push.

Production licensing (tokens)

- For production or CI, provide an entitlement token instead of relying on the dev whitelist:
  - Set environment: `SIMMACLIB_LICENSE_TOKEN="<token>"`
  - Optional: `SIMMACLIB_LICENSE_URL` if using a remote entitlement service; `SIMMACLIB_ENTITLEMENT_ID` if required by the service.
  - When a token is present, the dev whitelist is bypassed and the configured token flow is used.
