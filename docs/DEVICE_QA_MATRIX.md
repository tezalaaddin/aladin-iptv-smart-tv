# Device QA matrix

Run the automated unit/widget suite first, then execute `scripts/tv_remote_soak_test.ps1`
on each physical television profile.

| Profile | Resolution | RAM | Required checks |
|---|---:|---:|---|
| Low-end TV box | 1280x720 | 1 GB | 30 min D-pad soak, live zapping, HW decoder |
| Standard TV | 1920x1080 | 2 GB | 60 min live/VOD, subtitles, audio tracks |
| High-end TV | 3840x2160 | 4 GB+ | 4K ABR, frame-rate matching, 90 min soak |
| Phone portrait | 1080x2400 | 4 GB+ | portrait player, touch controls, RTL |
| Phone landscape | 2400x1080 | 4 GB+ | compact navigation, rotation resume |

Release gate: no focus trap, no clipped localized labels, no FATAL/ANR, no
unbounded memory growth, and playback must resume after a network interruption.
