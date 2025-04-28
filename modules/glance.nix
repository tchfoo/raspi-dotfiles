{
  config,
  ...
}:

{
  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 11146;
      };
      document = {
        head = ''
          <script src="https://cdn.statically.io/gh/ymstnt/uni-week-counter/main/script.js"></script>
        '';
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                  first-day-of-week = "monday";
                }
                {
                  type = "html";
                  source = ''
                    <div class="widget">
                      <div class="widget-header">
                        <h2 class="uppercase">Current week</h2>
                      </div>
                      <div class="widget-content">
                        <p id="week-number" class="color-highlight" onclick="checkDateBefore()" onload="checkDateBefore()">Click me!</p>
                        <img src="" onerror="checkDateBefore()" />
                      </div>
                    </div>
                  '';
                }
                {
                  type = "twitch-channels";
                  channels = [
                    "alexovics"
                    "cosmoyaha"
                    "jollywangcore"
                    "lukacs00"
                    "minecraft"
                    "xisumavoid"
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  bangs = [
                    {
                      title = "nixpkgs";
                      shortcut = "!nixpkgs";
                      url = "https://search.nixos.org/packages?query={QUERY}";
                    }
                    {
                      title = "NixOS Options";
                      shortcut = "!nixopt";
                      url = "https://search.nixos.org/options?query={QUERY}";
                    }
                    {
                      title = "Google";
                      shortcut = "!g";
                      url = "https://google.com/q={QUERY}";
                    }
                    {
                      title = "GitHub Repositories";
                      shortcut = "!ghr";
                      url = "https://github.com/search?q={QUERY}&type=repositories";
                    }
                    {
                      title = "GitHub Code Search";
                      shortcut = "!ghc";
                      url = "https://github.com/search?&q={QUERY}&type=code";
                    }
                    {
                      title = "GitHub Users";
                      shortcut = "!ghu";
                      url = "https://github.com/search?&q={QUERY}&type=users";
                    }
                    {
                      title = "GitHub Issues";
                      shortcut = "!ghi";
                      url = "https://github.com/search?&q={QUERY}&type=issues";
                    }
                    {
                      title = "GitHub Commit Search";
                      shortcut = "!ghcom";
                      url = "https://github.com/search?&q={QUERY}&type=commits";
                    }
                    {
                      title = "GitHub Packages";
                      shortcut = "!ghpkg";
                      url = "https://github.com/search?&q={QUERY}&type=registrypackages";
                    }
                    {
                      title = "GitHub Pull Requests";
                      shortcut = "!ghpr";
                      url = "https://github.com/search?&q={QUERY}&type=pullrequests";
                    }
                    {
                      title = "GitHub Discussions";
                      shortcut = "!ghd";
                      url = "https://github.com/search?&q={QUERY}&type=discussions";
                    }
                  ];
                }
                {
                  type = "split-column";
                  widgets = [
                    {
                      type = "bookmarks";
                      groups = [
                        {
                          title = "Tchfoo & co.";
                          links = [
                            {
                              title = "gepDrive";
                              url = "https://gd.tchfoo.com";
                            }
                            {
                              title = "ymstnt";
                              url = "https://ymstnt.com";
                            }
                            {
                              title = "Tchfoo Services Status";
                              url = "https://status.tchfoo.com";
                            }
                          ];
                        }
                        {
                          title = "University";
                          color = "146 63 51";
                          links = [
                            {
                              title = "Neptun";
                              url = "https://neptun.uni-obuda.hu/ujhallgato";
                            }
                            {
                              title = "Moodle";
                              url = "https://main.elearning.uni-obuda.hu/";
                            }
                            {
                              title = "K-MOOC";
                              url = "https://www.kmooc.uni-obuda.hu/";
                            }
                            {
                              title = "OPEN e-learning";
                              url = "https://open.elearning.uni-obuda.hu/";
                            }
                            {
                              title = "ÓE Website";
                              url = "https://uni-obuda.hu/";
                            }
                            {
                              title = "Tanév rendje";
                              url = "https://uni-obuda.hu/tanev-rendje/";
                            }
                            {
                              title = "NIKHÖK";
                              url = "https://nikhok.hu";
                            }
                          ];
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = {
                    _secret = config.age.secrets.glance-weather-location.path;
                  };
                  units = "metric";
                  hour-format = "24h";
                  hide-location = true;
                }
                {
                  type = "releases";
                  cache = "12h";
                  show-source-icon = true;
                  token = {
                    _secret = config.age.secrets.glance-gh-token.path;
                  };
                  repositories = [
                    "glanceapp/glance"
                    "pocket-id/pocket-id"
                    "go-vikunja/vikunja"
                    "miniflux/v2"
                    "helix-editor/helix"
                    "superseriousbusiness/gotosocial"
                    "bewcloud/bewcloud"
                    "privacyguides/privacyguides.org"
                  ];
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "EURHUF=X";
                      name = "EUR";
                    }
                    {
                      symbol = "HUF=X";
                      name = "USD";
                    }
                    {
                      symbol = "GBPHUF=X";
                      name = "GBP";
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts."glance.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.glance.settings.server.host}:${toString config.services.glance.settings.server.port}";
        recommendedProxySettings = true;
      };
    };
  };
}
