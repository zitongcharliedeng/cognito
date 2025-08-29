# u17553z-OS
Owning multiple linux daily drivers, I need to achieve workflow parity to get closer to my ideal LifeOS which automates everything for me and tells me what to do to GTD and health-maxx. NixOS, being declarative, sounds like the perfect option. But I have no experience in it, so this repo will contain the history of me slowly crafting my dream OS! Will also document my current understanding of the Nix manager and flakes or whatever.

# Development timeline (in-order)
- [ ] Start off not with NixOS, but something purely in the terminal dotfiles or whatever (_i think this is called the nix Home Manager_). ie. get something working on my current Arch System that would also work on my Ubuntu laptop.
- [ ] Scrap all other distros and go with the full NixOS if i.e. gaming compatibility in Steam is fine; otherwise I can stick with stable distros which fix compatibilities like that for me, a layer above my main terminal-desktop-env.
- [ ] Rice the shit.

# Principles for my OS
https://www.youtube.com/watch?v=9OMDnZWXjn4&pp=0gcJCf8Ao7VqN5tD
https://youtu.be/YHm7e3f87iY
- Linux distro agnostic, terminal-desktop-environment.
- **No memorization needed**, fuzzy-finding and icon/ hints/ LLM / good intuitive UX, like a well made game. Should be more intuitive than Windows for boomers, or me if I had amnesia and needed to remember who I was - me as a shell of a man should still be able to use my LifeOS, and maybe through spaced-repetition healing and automation, I would pseudo-comeback from the dead and regenerate myself from my digital systems.  _Maybe the minimal requirement is that the user understands English._
- Minimialist.
- Open-source stuff.
- Automated widgets e.g. RemNote / SuperMemo/ TickTick data all combined into a central, always visible "desktop background" terminal, with a GUI (in the terminal), like the maccel terminal.
- Modules of my OS reflect how my own human brain abstracts concepts e.g. Basal Ganglia -> Calendar and TickTick integrations, Hippocampus -> RemNote spaced repetition queues, Neocortex -> Long-term NAS storages.
  - As a result, maybe my home screen can be a graphical diagram of a brain, and I click on whatever section of the digital brain I want to access to get there.
- Network based bi-linking - imitate the brain and read more about interesting concepts like supermemo.guru
  
# Installation guide for a TDE ontop of the current, non-NixOS distro

**Step 1:** Install the Nix Package Manager

First, you need to install Nix on your current Linux distribution. This is a one-line command that sets up the Nix package manager alongside your existing system. This is what allows you to use Nix to manage user-level packages.
`sh <(curl -L https://nixos.org/nix/install) --daemon`

**Step 2:** Go to (ie., ~/nix-config) where `flake.nix` and home.nix is, and apply the configuration using a terminal in that directory and running the command `home-manager switch --flake`. Home-manager is defined inline from our config smartly by the command without needing its own initial install.
