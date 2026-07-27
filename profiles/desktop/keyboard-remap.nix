{ ... }: {
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "katakanahiragana";
          };
          control = {
            capslock = "capslock";
          };
        };
      };
    };
  };
}
