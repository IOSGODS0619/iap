
# ModMenuLoader (ready-to-upload)

This repo contains the source for a Theos tweak that creates a **floating animated neon skull**
mod menu with an ON/OFF toggle to `dlopen`/`dlclose` an included `iOSGodsiAPCracker.dylib`.

## What to do
1. Upload this folder to a **new GitHub repository** (public).
2. Push to `main`. GitHub Actions will run and attempt to build the tweak.
3. After success, download the `.deb` artifact from **Actions -> modmenu-deb**.

## Notes
- The included `Resources/iOSGodsiAPCracker.dylib` will be packaged manually in your tweak packaging step.
- If the build fails due to missing iOS SDK, you'll need to provide an SDK or use a prebuilt Theos action that includes it.
