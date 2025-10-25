OBS assets directory

- Manual for now: place all images, videos, audio, and other media you reference in OBS scenes in this folder (or subfolders).
- In OBS, reference files via paths under ~/.config/obs-studio/assets/ so scenes stay portable across machines.
- OBS does not copy external files into its config. If you reference files outside this folder, those paths may break on other systems.
- Later we can add an automation step to import external assets and rewrite scene paths; for now this is a manual step.
