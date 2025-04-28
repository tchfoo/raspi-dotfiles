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
          <script src="https://cdn.jsdelivr.net/gh/ymstnt/uni-week-counter@latest/script.js"></script>
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
                        <p id="week-number">N/A</p>
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
                  type = "custom-api";
                  title = "Miniflux";
                  url = "https://miniflux.ymstnt.com/v1/categories/1/entries?limit=10&order=published_at&direction=desc&status=unread";
                  headers = {
                    X-Auth-Token = {
                      _secret = config.age.secrets.glance-miniflux-token.path;
                    };
                    Accept = "application/json";
                  };
                  template = ''
                    <ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
                    {{ range .JSON.Array "entries" }}
                      <li>
                          <div class="flex gap-10 row-reverse-on-mobile thumbnail-parent">
                              <div class="grow min-width-0">
                                  <a href="https://miniflux.ymstnt.com/unread/category/1/entry/{{ .String "id" }}" class="size-title-dynamic color-primary-if-not-visited" target="_blank" rel="noreferrer">{{ .String "title" }}</a>
                                  <ul class="list-horizontal-text flex-nowrap text-compact">
                                      <li class="shrink-0">{{ .String "feed.title" }}</li>
                                      <li class="shrink-0">{{ .String "published_at" }}</li>
                                      <li class="min-width-0"><a class="visited-indicator text-truncate block" href="{{ .String "url" | safeURL }}" target="_blank" rel="noreferrer" title="Link">Link</a></li>
                                  </ul>
                              </div>
                          </div>
                      </li>
                    {{ end }}
                    </ul>
                  '';
                }
                {
                  type = "videos";
                  channels = [
                    "UCXuqSBlHAE6Xw-yeJA0Tunw" # Linus Tech Tips
                    "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                    "UCsBjURrPoezykLs9EqgamOA" # Fireship
                    "UCBJycsmduvYEL83R_U4JriQ" # Marques Brownlee
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
                }
                {
                  type = "releases";
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
                  symbol-link-template = "https://www.tradingview.com/symbols/{SYMBOL}/news";
                  markets = [
                    {
                      symbol = "EUR-HUF";
                      name = "EUR";
                    }
                    {
                      symbol = "USD-HUF";
                      name = "USD";
                    }
                    {
                      symbol = "GBP-HUF";
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
