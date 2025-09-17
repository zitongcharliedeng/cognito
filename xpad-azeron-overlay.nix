self: super:

{
  linuxPackages = super.linuxPackages.extend (lpSelf: lpSuper: {
    xpad = lpSuper.xpad.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ./_azeron-fix-for-xpad.patch ];
    });
  });
}
