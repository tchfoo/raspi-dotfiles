{
  config,
  ...
}:

{
  services.glance = {
    enable = true;
    openFirewall = true;
    environmentFile = config.age.secrets.glance.path;
    settings = {
      server = {
        port = 11146;
        proxied = true;
      };
      auth = {
        secret-key = "\${SECRET_KEY}";
        users = {
          ymstnt = {
            password = "\${USER_YMSTNT_PASSWORD}";
          };
        };
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
                  type = "group";
                  widgets = [
                    {
                      type = "calendar";
                      first-day-of-week = "monday";
                    }
                    {
                      type = "clock";
                      hour-format = "24h";
                      timezones = [
                        {
                          timezone = "Etc/UTC";
                          label = "UTC/GMT";
                        }
                        {
                          timezone = "EST5EDT";
                          label = "EST/EDT";
                        }
                        {
                          timezone = "GB";
                          label = "GMT/BST";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "html";
                  source = ''
                    <div class="widget">
                      <div class="widget-header">
                        <h2 class="uppercase">Current week (uni)</h2>
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
                  hide-header = true;
                  collapse-after = 3;
                  sort-by = "live";
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
                  hide-header = true;
                  new-tab = true;
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
                      title = "nixpkgs update tracker";
                      shortcut = "!nixu";
                      url = "https://nixpkgs-tracker.ocfox.me/?pr={QUERY}";
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
                  hide-header = true;
                  url = "https://miniflux.ymstnt.com/v1/entries?limit=10&order=published_at&direction=desc&status=unread";
                  headers = {
                    X-Auth-Token = "\${MINIFLUX_TOKEN}";
                    Accept = "application/json";
                  };
                  template = ''
                    <ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
                      {{ range .JSON.Array "entries" }}
                        <li>
                            <div class="flex gap-10 row-reverse-on-mobile thumbnail-parent">
                                <div class="grow min-width-0">
                                    <a href="https://miniflux.ymstnt.com/unread/entry/{{ .String "id" }}" class="size-title-dynamic color-primary-if-not-visited" target="_blank" rel="noreferrer">{{ .String "title" }}</a>
                                    <ul class="list-horizontal-text flex-nowrap text-compact">
                                        <li class="shrink-0">{{ .String "feed.title" }}</li>
                                        <li class="shrink-0" {{ .String "published_at" | parseTime "rfc3339" | toRelativeTime }}></li>
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
                  type = "split-column";
                  widgets = [
                    {
                      type = "bookmarks";
                      hide-header = true;
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
                    {
                      type = "monitor";
                      hide-header = true;
                      cache = "5m";
                      title = "Services";
                      sites = [
                        {
                          title = "gepDrive";
                          url = "https://gd.tchfoo.com";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "ymstnt.com";
                          url = "https://ymstnt.com";
                          icon = "https://raw.githubusercontent.com/ymstnt/website/refs/heads/main/static/android-chrome-512x512.png";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "Miniflux";
                          url = "#";
                          same-tab = true;
                          check-url = "https://miniflux.ymstnt.com";
                          icon = "di:miniflux";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "PocketID";
                          url = "#";
                          same-tab = true;
                          check-url = "https://auth.tchfoo.com";
                          icon = "di:pocket-id";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "Vikunja";
                          url = "https://tasks.tchfoo.com";
                          icon = "di:vikunja";
                          error-url = "https://status.tchfoo.com";
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
                  hide-header = true;
                  location = "\${WEATHER_LOCATION}";
                  units = "metric";
                  hour-format = "24h";
                  hide-location = true;
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "custom-api";
                      title = "Android";
                      title-url = "https://my.nextdns.io/\${NEXTDNS_ID_ANDROID}";
                      cache = "1h";
                      url = "https://api.nextdns.io/profiles/\${NEXTDNS_ID_ANDROID}/analytics/status?from=-1M";
                      headers = {
                        X-Api-Key = "\${NEXTDNS_API_KEY}";
                      };
                      template = ''
                        {{ if eq .Response.StatusCode 200 }}
                          <div style="display: flex; justify-content: space-between;">
                            {{ $total := 0.0 }}
                            {{ $blocked := 0.0 }}
                            {{ range .JSON.Array "data" }}
                              {{ $total = add $total (.Int "queries" | toFloat) }}
                              {{ if eq (.String "status") "blocked" }}
                                {{ $blocked = add $blocked (.Int "queries" | toFloat) }}
                              {{ end }}
                            {{ end }}
                            <div style="flex: 1; text-align: center;">
                              <p>Queries</p>
                              <p>{{ printf "%.0f" $total }}</p>
                            </div>
                            <div style="flex: 1; text-align: center; color: var(--color-negative);">
                              <p>Blocked</p>
                              <p>{{ printf "%.0f" $blocked }}</p>
                            </div>
                            <div style="flex: 1; text-align: center;">
                              <p>Block Rate</p>
                              {{ if gt $total 0.0 }}
                                <p>{{ div (mul $blocked 100) $total | printf "%.2f" }}%</p>
                              {{ else }}
                                <p>0.00%</p>
                              {{ end }}
                            </div>
                          </div>
                        {{ else }}
                          <div style="text-align: center; color: var(--color-negative);">
                            Error: {{ .Response.StatusCode }} - {{ .Response.Status }}
                          </div>
                        {{ end }}
                      '';
                    }
                    {
                      type = "custom-api";
                      title = "Windows";
                      title-url = "https://my.nextdns.io/\${NEXTDNS_ID_WINDOWS}";
                      cache = "1h";
                      url = "https://api.nextdns.io/profiles/\${NEXTDNS_ID_WINDOWS}/analytics/status?from=-1M";
                      headers = {
                        X-Api-Key = "\${NEXTDNS_API_KEY}";
                      };
                      template = ''
                        {{ if eq .Response.StatusCode 200 }}
                          <div style="display: flex; justify-content: space-between;">
                            {{ $total := 0.0 }}
                            {{ $blocked := 0.0 }}
                            {{ range .JSON.Array "data" }}
                              {{ $total = add $total (.Int "queries" | toFloat) }}
                              {{ if eq (.String "status") "blocked" }}
                                {{ $blocked = add $blocked (.Int "queries" | toFloat) }}
                              {{ end }}
                            {{ end }}
                            <div style="flex: 1; text-align: center;">
                              <p>Queries</p>
                              <p>{{ printf "%.0f" $total }}</p>
                            </div>
                            <div style="flex: 1; text-align: center; color: var(--color-negative);">
                              <p>Blocked</p>
                              <p>{{ printf "%.0f" $blocked }}</p>
                            </div>
                            <div style="flex: 1; text-align: center;">
                              <p>Block Rate</p>
                              {{ if gt $total 0.0 }}
                                <p>{{ div (mul $blocked 100) $total | printf "%.2f" }}%</p>
                              {{ else }}
                                <p>0.00%</p>
                              {{ end }}
                            </div>
                          </div>
                        {{ else }}
                          <div style="text-align: center; color: var(--color-negative);">
                            Error: {{ .Response.StatusCode }} - {{ .Response.Status }}
                          </div>
                        {{ end }}
                      '';
                    }
                    {
                      type = "custom-api";
                      title = "TV";
                      title-url = "https://my.nextdns.io/\${NEXTDNS_ID_TV}";
                      cache = "1h";
                      url = "https://api.nextdns.io/profiles/\${NEXTDNS_ID_TV}/analytics/status?from=-1M";
                      headers = {
                        X-Api-Key = "\${NEXTDNS_API_KEY}";
                      };
                      template = ''
                        {{ if eq .Response.StatusCode 200 }}
                          <div style="display: flex; justify-content: space-between;">
                            {{ $total := 0.0 }}
                            {{ $blocked := 0.0 }}
                            {{ range .JSON.Array "data" }}
                              {{ $total = add $total (.Int "queries" | toFloat) }}
                              {{ if eq (.String "status") "blocked" }}
                                {{ $blocked = add $blocked (.Int "queries" | toFloat) }}
                              {{ end }}
                            {{ end }}
                            <div style="flex: 1; text-align: center;">
                              <p>Queries</p>
                              <p>{{ printf "%.0f" $total }}</p>
                            </div>
                            <div style="flex: 1; text-align: center; color: var(--color-negative);">
                              <p>Blocked</p>
                              <p>{{ printf "%.0f" $blocked }}</p>
                            </div>
                            <div style="flex: 1; text-align: center;">
                              <p>Block Rate</p>
                              {{ if gt $total 0.0 }}
                                <p>{{ div (mul $blocked 100) $total | printf "%.2f" }}%</p>
                              {{ else }}
                                <p>0.00%</p>
                              {{ end }}
                            </div>
                          </div>
                        {{ else }}
                          <div style="text-align: center; color: var(--color-negative);">
                            Error: {{ .Response.StatusCode }} - {{ .Response.Status }}
                          </div>
                        {{ end }}
                      '';
                    }
                  ];
                }
                {
                  type = "releases";
                  hide-header = true;
                  cache = "12h";
                  show-source-icon = true;
                  collapse-after = 3;
                  token = "\${GH_TOKEN}";
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
                  hide-header = true;
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
        {
          name = "Repositories";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "split-column";
                  widgets = [
                    {
                      type = "repository";
                      hide-header = true;
                      repository = "tchfoo/raspi-dotfiles";
                      token = "\${GH_TOKEN}";
                      pull-requests-limit = -1;
                      issues-limit = -1;
                      commits-limit = 5;
                    }
                    {
                      type = "repository";
                      hide-header = true;
                      repository = "NixOS/nixpkgs";
                      token = "\${GH_TOKEN}";
                      pull-requests-limit = 5;
                      issues-limit = 5;
                      commits-limit = 5;
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
